const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');

async function list(status) {
  let where = 'WHERE 1=1';
  const params = [];
  if (status) {
    where += ' AND m.status = $1';
    params.push(status);
  }
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji FROM movies m
     LEFT JOIN heroes h ON h.id = m.hero_id ${where}
     ORDER BY m.release_date ASC NULLS LAST`,
    params
  );
  return rows.map(formatMovie);
}

async function getOne(id) {
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.telugu_name as hero_telugu, h.icon_emoji
     FROM movies m LEFT JOIN heroes h ON h.id = m.hero_id WHERE m.id = $1`,
    [id]
  );
  if (!rows.length) throw new AppError('Movie not found', 404);
  const movie = formatMovie(rows[0]);
  const { rows: timeline } = await db.query(
    `SELECT * FROM movie_timeline WHERE movie_id = $1 ORDER BY sort_order ASC`,
    [id]
  );
  const { rows: updates } = await db.query(
    `SELECT id, title, summary, category, trust_status, published_at
     FROM tfi_updates WHERE movie_id = $1 AND is_active = TRUE
     ORDER BY published_at DESC LIMIT 10`,
    [id]
  );
  return { ...movie, timeline, related_updates: updates };
}

async function follow(userId, movieId) {
  await db.query(
    `INSERT INTO movie_follows (user_id, movie_id) VALUES ($1,$2) ON CONFLICT DO NOTHING`,
    [userId, movieId]
  );
  return { followed: true };
}

async function addReminder(userId, movieId, type = 'release') {
  const movie = await getOne(movieId);
  await db.query(
    `INSERT INTO reminders (user_id, reminder_type, title, subtitle, related_id, remind_at)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [userId, type, movie.title, movie.release_date, movieId, movie.release_date]
  );
  return { reminder_set: true };
}

function formatMovie(m) {
  const days = m.release_date
    ? Math.max(0, Math.ceil((new Date(m.release_date) - new Date()) / 86400000))
    : null;
  return {
    id: m.id,
    title: m.title,
    title_telugu: m.title_telugu,
    hero_name: m.hero_name,
    hero_telugu: m.hero_telugu,
    icon_emoji: m.icon_emoji,
    director: m.director,
    genre: m.genre,
    release_date: m.release_date,
    days_to_release: days,
    synopsis: m.synopsis,
    poster_url: m.poster_url,
    status: m.status,
    trailer_youtube_id: m.trailer_youtube_id,
  };
}

module.exports = { list, getOne, follow, addReminder };
