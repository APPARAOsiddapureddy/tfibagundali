const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const events = require('../recommendations/events.service');

async function list({ status, heroId, genre, q, sort = 'upcoming' } = {}) {
  let where = 'WHERE 1=1';
  const params = [];
  let i = 1;
  if (status) { where += ` AND m.status = $${i++}`; params.push(status.toLowerCase()); }
  if (heroId) { where += ` AND m.hero_id = $${i++}`; params.push(heroId); }
  if (genre) { where += ` AND m.genre ILIKE $${i++}`; params.push(genre); }
  if (q) { where += ` AND (m.title ILIKE $${i} OR m.title_telugu ILIKE $${i})`; params.push(`%${q}%`); i += 1; }
  const order = sort === 'popular'
    ? 'ORDER BY m.follower_count DESC'
    : sort === 'latest'
      ? 'ORDER BY m.created_at DESC'
      : 'ORDER BY m.release_date ASC NULLS LAST';
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji FROM movies m
     LEFT JOIN heroes h ON h.id = m.hero_id ${where} ${order}`,
    params
  );
  return rows.map((m) => formatMovie(m));
}

async function getOne(id, userId) {
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
    `SELECT id, title, COALESCE(short_summary, summary) as short_summary, category, trust_status, published_at
     FROM tfi_updates WHERE movie_id = $1 AND is_active = TRUE ORDER BY published_at DESC LIMIT 10`,
    [id]
  );
  const { rows: wallpapers } = await db.query(
    'SELECT id, title, image_url, category FROM wallpapers WHERE movie_id = $1 LIMIT 6',
    [id]
  );
  const { rows: cards } = await db.query(
    'SELECT id, title, image_url, category FROM status_cards WHERE movie_id = $1 LIMIT 6',
    [id]
  );
  const { rows: polls } = await db.query(
    'SELECT id, question, poll_type FROM polls WHERE movie_id = $1 AND is_active LIMIT 3',
    [id]
  );

  let following = false;
  let has_reminder = false;
  if (userId) {
    const { rows: f } = await db.query('SELECT 1 FROM movie_follows WHERE user_id = $1 AND movie_id = $2', [userId, id]);
    following = f.length > 0;
    const { rows: r } = await db.query('SELECT 1 FROM reminders WHERE user_id = $1 AND movie_id = $2', [userId, id]);
    has_reminder = r.length > 0;
  }

  return {
    ...movie,
    timeline,
    latest_updates: updates,
    wallpapers,
    status_cards: cards,
    related_polls: polls,
    following,
    has_reminder,
  };
}

async function follow(userId, movieId) {
  await db.query(
    `INSERT INTO movie_follows (user_id, movie_id) VALUES ($1,$2) ON CONFLICT DO NOTHING`,
    [userId, movieId]
  );
  await db.query('UPDATE movies SET follower_count = follower_count + 1 WHERE id = $1', [movieId]);
  await events.trackEvent({ user_id: userId, event_name: 'movie_followed', content_type: 'movie', content_id: movieId, movie_ids: [movieId] });
  return { followed: true };
}

async function unfollow(userId, movieId) {
  await db.query('DELETE FROM movie_follows WHERE user_id = $1 AND movie_id = $2', [userId, movieId]);
  return { followed: false };
}

async function setReminder(userId, movieId, body = {}) {
  const movie = await getOne(movieId);
  const reminders = require('../reminders/reminders.service');
  return reminders.create(userId, {
    reminder_type: body.reminder_type || 'MOVIE_RELEASE',
    title: body.title || `${movie.title} release`,
    movie_id: movieId,
    event_datetime: body.event_datetime || movie.release_date,
    notification_enabled: true,
  });
}

async function removeReminder(userId, movieId) {
  await db.query('DELETE FROM reminders WHERE user_id = $1 AND movie_id = $2', [userId, movieId]);
  return { reminder_set: false };
}

async function watchIntent(userId, movieId) {
  if (userId) {
    await events.trackEvent({ user_id: userId, event_name: 'movie_opened', content_type: 'movie', content_id: movieId, movie_ids: [movieId] });
  }
  return { tracked: true };
}

function formatMovie(m) {
  const days = m.release_date
    ? Math.max(0, Math.ceil((new Date(m.release_date) - new Date()) / 86400000))
    : null;
  return {
    id: m.id,
    title: m.title,
    title_telugu: m.title_telugu,
    slug: m.slug,
    hero_id: m.hero_id,
    hero_name: m.hero_name,
    hero_telugu: m.hero_telugu,
    icon_emoji: m.icon_emoji,
    director: m.director,
    genre: m.genre,
    release_date: m.release_date,
    days_to_release: days,
    synopsis: m.synopsis,
    poster_url: m.poster_url,
    trailer_url: m.trailer_url || (m.trailer_youtube_id ? `https://youtube.com/watch?v=${m.trailer_youtube_id}` : null),
    status: (m.status || 'upcoming').toUpperCase(),
    follower_count: m.follower_count,
    reminder_count: m.reminder_count,
  };
}

module.exports = { list, getOne, follow, unfollow, setReminder, removeReminder, watchIntent };
