const db = require('../../config/db');
const { applyEventToProfile } = require('./interest-profile.service');
const { syncUpdateFeatures } = require('./content-features.service');

async function trackEvent(payload) {
  const {
    user_id,
    anonymous_id,
    event_name,
    content_type,
    content_id,
    hero_ids = [],
    movie_ids = [],
    category,
    trust_status,
    source_screen,
    position,
    session_id,
    metadata = {},
    device,
  } = payload;

  const { rows } = await db.query(
    `INSERT INTO recommendation_events (
      user_id, anonymous_id, event_name, content_type, content_id,
      hero_ids, movie_ids, category, trust_status, source_screen,
      position, session_id, metadata, device
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) RETURNING id`,
    [
      user_id || null,
      anonymous_id || null,
      event_name,
      content_type || null,
      content_id || null,
      hero_ids,
      movie_ids,
      category || null,
      trust_status || null,
      source_screen || null,
      position ?? null,
      session_id || null,
      JSON.stringify(metadata),
      device || null,
    ]
  );

  if (user_id && content_type && content_id) {
    if (['update_opened', 'update_card_viewed', 'movie_opened', 'hero_opened', 'poll_viewed', 'wallpaper_viewed'].includes(event_name)) {
      await db.query(
        `INSERT INTO user_content_views (user_id, content_type, content_id, view_count, last_viewed_at)
         VALUES ($1,$2,$3,1,NOW())
         ON CONFLICT (user_id, content_type, content_id)
         DO UPDATE SET view_count = user_content_views.view_count + 1, last_viewed_at = NOW()`,
        [user_id, content_type, content_id]
      );
    }
    if (event_name === 'update_dwell_20s' && metadata.dwell_seconds) {
      await db.query(
        `UPDATE user_content_views SET dwell_seconds = dwell_seconds + $4
         WHERE user_id = $1 AND content_type = $2 AND content_id = $3`,
        [user_id, content_type, content_id, metadata.dwell_seconds]
      );
    }
  }

  if (user_id) {
    await applyEventToProfile(user_id, {
      event_name,
      hero_ids,
      movie_ids,
      category,
      content_type,
      metadata,
    });
  }

  if (content_type === 'update' && content_id && ['update_opened', 'update_reacted', 'update_shared'].includes(event_name)) {
    const col = event_name === 'update_opened' ? 'view_count'
      : event_name === 'update_shared' ? 'share_count' : null;
    if (col) {
      await db.query(`UPDATE tfi_updates SET ${col} = ${col} + 1 WHERE id = $1`, [content_id]);
      syncUpdateFeatures(content_id).catch(() => {});
    }
  }

  return { event_id: rows[0].id };
}

async function markNotInterested(userId, contentType, contentId) {
  await db.query(
    `INSERT INTO not_interested (user_id, content_type, content_id) VALUES ($1,$2,$3)
     ON CONFLICT DO NOTHING`,
    [userId, contentType, contentId]
  );
  await trackEvent({
    user_id: userId,
    event_name: 'not_interested_clicked',
    content_type: contentType,
    content_id: contentId,
  });
  return { ok: true };
}

async function hideContent(userId, contentType, contentId, reason = 'hide') {
  await db.query(
    `INSERT INTO hidden_content (user_id, content_type, content_id, reason) VALUES ($1,$2,$3,$4)
     ON CONFLICT DO NOTHING`,
    [userId, contentType, contentId, reason]
  );
  await trackEvent({
    user_id: userId,
    event_name: 'content_hidden',
    content_type: contentType,
    content_id: contentId,
  });
  return { ok: true };
}

module.exports = { trackEvent, markNotInterested, hideContent };
