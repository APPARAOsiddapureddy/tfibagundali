const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');

async function list() {
  const { rows } = await db.query('SELECT * FROM heroes WHERE is_active = TRUE ORDER BY sort_order ASC');
  return rows;
}

async function getOne(id) {
  const { rows } = await db.query('SELECT * FROM heroes WHERE id = $1', [id]);
  if (!rows.length) throw new AppError('Hero not found', 404);
  const hero = rows[0];
  const { rows: movies } = await db.query(
    `SELECT id, title, title_telugu, release_date, status FROM movies WHERE hero_id = $1 ORDER BY release_date DESC`,
    [id]
  );
  const { rows: updates } = await db.query(
    `SELECT id, title, summary, category, trust_status, published_at
     FROM tfi_updates WHERE hero_id = $1 AND is_active = TRUE ORDER BY published_at DESC LIMIT 10`,
    [id]
  );
  return { ...hero, upcoming_movies: movies, latest_updates: updates };
}

async function follow(userId, heroId) {
  await db.query(
    `INSERT INTO hero_follows (user_id, hero_id) VALUES ($1,$2) ON CONFLICT DO NOTHING`,
    [userId, heroId]
  );
  return { followed: true };
}

module.exports = { list, getOne, follow };
