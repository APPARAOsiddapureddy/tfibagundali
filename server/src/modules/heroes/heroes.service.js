const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const events = require('../recommendations/events.service');

async function list() {
  const { rows } = await db.query(
    'SELECT * FROM heroes WHERE is_active IS NOT FALSE ORDER BY sort_order, name'
  );
  return rows;
}

async function getOne(id, userId) {
  const { rows } = await db.query('SELECT * FROM heroes WHERE id = $1', [id]);
  if (!rows.length) throw new AppError('Hero not found', 404);
  const hero = rows[0];

  const { rows: updates } = await db.query(
    `SELECT id, title, COALESCE(short_summary, summary) as short_summary, category, trust_status, published_at
     FROM tfi_updates WHERE hero_id = $1 AND is_active ORDER BY published_at DESC LIMIT 10`,
    [id]
  );
  const { rows: movies } = await db.query(
    `SELECT id, title, title_telugu, release_date, status FROM movies
     WHERE hero_id = $1 ORDER BY release_date ASC NULLS LAST LIMIT 8`,
    [id]
  );
  const { rows: wallpapers } = await db.query('SELECT id, title, image_url FROM wallpapers WHERE hero_id = $1 LIMIT 6', [id]);
  const { rows: cards } = await db.query('SELECT id, title, image_url FROM status_cards WHERE hero_id = $1 LIMIT 6', [id]);

  let following = false;
  if (userId) {
    const { rows: f } = await db.query('SELECT 1 FROM hero_follows WHERE user_id = $1 AND hero_id = $2', [userId, id]);
    following = f.length > 0;
  }

  return { ...hero, latest_updates: updates, upcoming_movies: movies, wallpapers, status_cards: cards, following };
}

async function follow(userId, heroId) {
  await db.query(
    `INSERT INTO hero_follows (user_id, hero_id) VALUES ($1,$2) ON CONFLICT DO NOTHING`,
    [userId, heroId]
  );
  await db.query('UPDATE heroes SET follower_count = COALESCE(follower_count, 0) + 1 WHERE id = $1', [heroId]);
  await events.trackEvent({ user_id: userId, event_name: 'hero_followed', content_type: 'hero', content_id: heroId, hero_ids: [heroId] });
  return { followed: true };
}

async function unfollow(userId, heroId) {
  await db.query('DELETE FROM hero_follows WHERE user_id = $1 AND hero_id = $2', [userId, heroId]);
  return { followed: false };
}

module.exports = { list, getOne, follow, unfollow };
