const db = require('../../config/db');
const { loadUserContext } = require('./user-context');
const { NOTIFICATION_WEIGHTS, TRUST_SCORES } = require('./constants');
const { computePersonalAffinity } = require('./scoring/personal-affinity');

async function scoreNotificationCandidate(item, ctx) {
  const personal = computePersonalAffinity(item, ctx);
  const trust = TRUST_SCORES[item.trust_status] ?? 0.35;
  let urgency = 0.3;
  if (item.event_datetime) {
    const hours = (new Date(item.event_datetime) - Date.now()) / 3600000;
    if (hours >= 0 && hours <= 1) urgency = 1.0;
    else if (hours <= 24) urgency = 0.8;
    else if (hours <= 72) urgency = 0.5;
  }
  if (item.reminder_type) urgency = 1.0;

  const openness = Number(ctx?.interestProfile?.notification_sensitivity) || 0.5;
  const w = NOTIFICATION_WEIGHTS;
  return personal * w.personal + urgency * w.urgency + trust * w.trust + openness * w.openness;
}

async function shouldSuppress(userId, item, ctx) {
  const prefs = ctx?.notificationPreferences || {};
  if (prefs[item.category] === false) return true;
  if ((item.trust_status || '') === 'buzz' && !prefs.allow_buzz) return true;

  const { rows: recent } = await db.query(
    `SELECT COUNT(*)::int as c FROM notification_log
     WHERE user_id = $1 AND category = $2 AND sent_at > NOW() - INTERVAL '24 hours'`,
    [userId, item.category || 'general']
  );
  if (recent[0]?.c >= 3) return true;

  const { rows: ignored } = await db.query(
    `SELECT COUNT(*)::int as c FROM notification_log
     WHERE user_id = $1 AND dismissed = TRUE AND category = $2
     AND sent_at > NOW() - INTERVAL '7 days'`,
    [userId, item.category || 'general']
  );
  if (ignored[0]?.c >= 3) return true;

  if (item.content_id && ctx?.viewCounts?.[`update:${item.content_id}`]) return true;

  return false;
}

async function getNotificationTargets(userId, { limit = 10 } = {}) {
  const ctx = await loadUserContext(userId);
  if (!ctx) return { targets: [] };

  const { rows: updates } = await db.query(
    `SELECT id, title, category, trust_status, hero_id, movie_id, event_datetime, published_at, is_breaking
     FROM tfi_updates WHERE is_active = TRUE
     AND published_at > NOW() - INTERVAL '48 hours'
     AND trust_status IN ('official', 'verified', 'media_report')
     ORDER BY is_breaking DESC, published_at DESC LIMIT 30`
  );

  const { rows: reminders } = await db.query(
    `SELECT id, title, reminder_type, related_id, remind_at FROM reminders
     WHERE user_id = $1 AND remind_at BETWEEN NOW() AND NOW() + INTERVAL '2 hours'`,
    [userId]
  );

  const candidates = [
    ...reminders.map((r) => ({
      content_type: 'reminder',
      content_id: r.id,
      title: r.title,
      category: r.reminder_type,
      reminder_type: r.reminder_type,
      event_datetime: r.remind_at,
      trust_status: 'official',
      copy: r.title,
    })),
    ...updates.map((u) => ({
      content_type: 'update',
      content_id: u.id,
      title: u.title,
      category: u.category,
      hero_id: u.hero_id,
      movie_id: u.movie_id,
      trust_status: u.trust_status,
      event_datetime: u.event_datetime,
      published_at: u.published_at,
      copy: buildCopy(u),
    })),
  ];

  const targets = [];
  for (const c of candidates) {
    if (await shouldSuppress(userId, c, ctx)) continue;
    const score = await scoreNotificationCandidate(c, ctx);
    if (score < 0.45) continue;
    targets.push({ ...c, score, copy: c.copy || c.title });
    if (targets.length >= limit) break;
  }

  targets.sort((a, b) => b.score - a.score);
  return { targets, meta: { algorithm: 'notification_v1' } };
}

function buildCopy(update) {
  if (update.is_breaking) return `Breaking: ${update.title}`;
  if (update.category === 'trailer') return `New trailer update 🔥`;
  if (update.category === 'release') return `Release update: ${update.title}`;
  return update.title;
}

async function logNotificationSent(userId, target) {
  await db.query(
    `INSERT INTO notification_log (user_id, content_type, content_id, category, title, score)
     VALUES ($1,$2,$3,$4,$5,$6)`,
    [userId, target.content_type, target.content_id, target.category, target.copy, target.score]
  );
}

module.exports = { getNotificationTargets, logNotificationSent };
