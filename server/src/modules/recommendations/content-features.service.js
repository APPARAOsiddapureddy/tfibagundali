const db = require('../../config/db');
const { computeFreshness } = require('./scoring/freshness');
const { computeTrust } = require('./scoring/trust');
const { computeEngagement } = require('./scoring/engagement');

async function syncUpdateFeatures(updateId) {
  const { rows } = await db.query(
    `SELECT u.* FROM tfi_updates u WHERE u.id = $1`,
    [updateId]
  );
  if (!rows[0]) return;
  const u = rows[0];
  const heroIds = u.hero_id ? [u.hero_id] : [];
  const movieIds = u.movie_id ? [u.movie_id] : [];
  const freshness = computeFreshness(u);
  const trust = computeTrust(u);
  const engagement = computeEngagement(u);
  const actions = [];
  if (['trailer', 'teaser'].includes(u.category)) actions.push('watch_trailer');
  if (u.movie_id) actions.push('follow_movie', 'set_alert');

  await db.query(
    `INSERT INTO content_features (
      content_type, content_id, category, trust_status, hero_ids, movie_ids,
      published_at, event_datetime, expires_at, engagement_score, trust_score,
      freshness_score, editorial_score, priority, is_pinned, action_types, updated_at
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,NOW())
    ON CONFLICT (content_type, content_id) DO UPDATE SET
      category = EXCLUDED.category,
      trust_status = EXCLUDED.trust_status,
      hero_ids = EXCLUDED.hero_ids,
      movie_ids = EXCLUDED.movie_ids,
      published_at = EXCLUDED.published_at,
      event_datetime = EXCLUDED.event_datetime,
      expires_at = EXCLUDED.expires_at,
      engagement_score = EXCLUDED.engagement_score,
      trust_score = EXCLUDED.trust_score,
      freshness_score = EXCLUDED.freshness_score,
      editorial_score = EXCLUDED.editorial_score,
      priority = EXCLUDED.priority,
      is_pinned = EXCLUDED.is_pinned,
      action_types = EXCLUDED.action_types,
      updated_at = NOW()`,
    [
      'update', u.id, u.category, u.trust_status, heroIds, movieIds,
      u.published_at, u.event_datetime, u.expires_at, engagement, trust, freshness,
      Number(u.editorial_score) || 0, u.priority, u.is_pinned, actions,
    ]
  );
}

async function syncAllContentFeatures() {
  const { rows: updates } = await db.query('SELECT id FROM tfi_updates WHERE is_active = TRUE');
  for (const u of updates) await syncUpdateFeatures(u.id);

  const { rows: polls } = await db.query('SELECT id FROM polls WHERE is_active = TRUE');
  for (const p of polls) {
    await db.query(
      `INSERT INTO content_features (content_type, content_id, category, trust_status, published_at, updated_at)
       SELECT 'poll', id, category, 'verified', created_at, NOW() FROM polls WHERE id = $1
       ON CONFLICT (content_type, content_id) DO UPDATE SET updated_at = NOW()`,
      [p.id]
    );
  }
  return { synced_updates: updates.length, synced_polls: polls.length };
}

module.exports = { syncUpdateFeatures, syncAllContentFeatures };
