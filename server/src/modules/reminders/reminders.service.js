const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const events = require('../recommendations/events.service');

async function list(userId) {
  const { rows } = await db.query(
    `SELECT * FROM reminders WHERE user_id = $1 ORDER BY event_datetime ASC NULLS LAST`,
    [userId]
  );
  return rows;
}

async function create(userId, body) {
  const { reminder_type, title, subtitle, movie_id, hero_id, update_id, event_datetime, notification_enabled } = body;
  if (!reminder_type || !title) throw new AppError('reminder_type and title required', 400);

  if (movie_id) {
    const dup = await db.query(
      `SELECT id FROM reminders WHERE user_id = $1 AND reminder_type = $2 AND movie_id = $3`,
      [userId, reminder_type, movie_id]
    );
    if (dup.rows.length) return dup.rows[0];
  }

  const { rows } = await db.query(
    `INSERT INTO reminders (
      user_id, reminder_type, title, subtitle, related_id, movie_id, hero_id, update_id,
      event_datetime, remind_at, notification_enabled
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$9,$10) RETURNING *`,
    [
      userId, reminder_type, title, subtitle || null,
      movie_id || update_id || hero_id, movie_id, hero_id, update_id,
      event_datetime, notification_enabled !== false,
    ]
  );
  await events.trackEvent({
    user_id: userId,
    event_name: 'movie_reminder_set',
    content_type: 'reminder',
    content_id: rows[0].id,
    movie_ids: movie_id ? [movie_id] : [],
  });
  if (movie_id) {
    await db.query('UPDATE movies SET reminder_count = reminder_count + 1 WHERE id = $1', [movie_id]);
  }
  return rows[0];
}

async function remove(userId, id) {
  const { rowCount } = await db.query('DELETE FROM reminders WHERE id = $1 AND user_id = $2', [id, userId]);
  if (!rowCount) throw new AppError('Reminder not found', 404);
  return { deleted: true };
}

async function patch(userId, id, fields) {
  const allowed = ['title', 'subtitle', 'event_datetime', 'notification_enabled'];
  const sets = [];
  const vals = [];
  let i = 1;
  for (const k of allowed) {
    if (fields[k] !== undefined) {
      sets.push(`${k} = $${i++}`);
      vals.push(fields[k]);
      if (k === 'event_datetime') sets.push(`remind_at = $${i - 1}`);
    }
  }
  if (!sets.length) throw new AppError('No fields to update', 400);
  vals.push(id, userId);
  const { rows } = await db.query(
    `UPDATE reminders SET ${sets.join(', ')}, updated_at = NOW() WHERE id = $${i++} AND user_id = $${i} RETURNING *`,
    vals
  );
  if (!rows.length) throw new AppError('Reminder not found', 404);
  return rows[0];
}

module.exports = { list, create, remove, patch };
