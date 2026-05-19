const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const { syncUpdateFeatures } = require('../recommendations/content-features.service');

async function stats() {
  const [
    users,
    updates,
    views,
    topUpdates,
    pollVotes,
    quizPlays,
    downloads,
  ] = await Promise.all([
    db.query('SELECT COUNT(*)::int as c FROM users'),
    db.query('SELECT COUNT(*)::int as c FROM tfi_updates WHERE is_active'),
    db.query('SELECT COALESCE(SUM(view_count),0)::int as c FROM tfi_updates'),
    db.query(
      `SELECT id, title, view_count, reaction_count FROM tfi_updates
       WHERE is_active ORDER BY view_count DESC LIMIT 5`
    ),
    db.query('SELECT COALESCE(SUM(total_votes),0)::int as c FROM polls'),
    db.query('SELECT COUNT(*)::int as c FROM quiz_sessions WHERE completed = TRUE'),
    db.query('SELECT COALESCE(SUM(download_count),0)::int as c FROM wallpapers'),
  ]);
  return {
    total_users: users.rows[0].c,
    total_updates: updates.rows[0].c,
    total_update_views: views.rows[0].c,
    top_updates: topUpdates.rows,
    total_poll_votes: pollVotes.rows[0].c,
    quiz_plays: quizPlays.rows[0].c,
    wallpaper_downloads: downloads.rows[0].c,
  };
}

async function crudList(table, limit = 50) {
  const allowed = ['tfi_updates', 'movies', 'heroes', 'wallpapers', 'status_cards', 'polls', 'quiz_questions'];
  if (!allowed.includes(table)) throw new AppError('Invalid resource', 400);
  const { rows } = await db.query(`SELECT * FROM ${table} ORDER BY created_at DESC LIMIT $1`, [limit]);
  return rows;
}

async function createUpdate(body) {
  const {
    title, short_summary, full_summary, category, status, priority,
    source_name, source_url, image_url, hero_ids, movie_ids,
    related_director_names, tags, published_at, event_datetime, expires_at,
    is_pinned, is_active, push_notification_enabled,
  } = body;
  const { rows } = await db.query(
    `INSERT INTO tfi_updates (
      title, summary, short_summary, full_summary, body, category, trust_status, priority,
      source_name, source_url, image_url, related_director_names, tags, published_at,
      event_datetime, expires_at, is_pinned, is_active, hero_id, movie_id
    ) VALUES ($1,$2,$3,$4,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19)
    RETURNING *`,
    [
      title, short_summary, short_summary, full_summary,
      category?.toLowerCase(), status?.toLowerCase(), priority?.toLowerCase(),
      source_name, source_url, image_url,
      JSON.stringify(related_director_names || []),
      JSON.stringify(tags || []),
      published_at || new Date(),
      event_datetime, expires_at, !!is_pinned, is_active !== false,
      hero_ids?.[0] || null, movie_ids?.[0] || null,
    ]
  );
  const update = rows[0];
  for (const hid of hero_ids || []) {
    await db.query('INSERT INTO update_heroes (update_id, hero_id) VALUES ($1,$2) ON CONFLICT DO NOTHING', [update.id, hid]);
  }
  for (const mid of movie_ids || []) {
    await db.query('INSERT INTO update_movies (update_id, movie_id) VALUES ($1,$2) ON CONFLICT DO NOTHING', [update.id, mid]);
  }
  await syncUpdateFeatures(update.id);
  if (push_notification_enabled) {
    // TODO: queue FCM broadcast for breaking official updates
  }
  return update;
}

async function patchUpdate(id, body) {
  const fields = ['title', 'short_summary', 'full_summary', 'category', 'trust_status', 'priority', 'is_pinned', 'is_active', 'is_breaking', 'is_trending'];
  const sets = [];
  const vals = [];
  let i = 1;
  for (const f of fields) {
    if (body[f] !== undefined) {
      const col = f === 'trust_status' ? 'trust_status' : f;
      sets.push(`${col} = $${i++}`);
      vals.push(typeof body[f] === 'string' && ['category', 'trust_status', 'priority'].includes(f) ? body[f].toLowerCase() : body[f]);
    }
  }
  if (!sets.length) throw new AppError('No fields', 400);
  vals.push(id);
  const { rows } = await db.query(
    `UPDATE tfi_updates SET ${sets.join(', ')}, updated_at = NOW() WHERE id = $${i} RETURNING *`,
    vals
  );
  if (!rows.length) throw new AppError('Not found', 404);
  await syncUpdateFeatures(id);
  return rows[0];
}

async function deleteUpdate(id) {
  await db.query('UPDATE tfi_updates SET is_active = FALSE WHERE id = $1', [id]);
  return { deleted: true };
}

module.exports = { stats, crudList, createUpdate, patchUpdate, deleteUpdate };
