const db = require('../../config/db');

async function getUpcomingMovies(limit = 20) {
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji, h.army_name
     FROM movies m LEFT JOIN heroes h ON h.id = m.hero_id
     WHERE m.status = 'upcoming' AND m.release_date >= CURRENT_DATE
     ORDER BY m.release_date ASC LIMIT $1`,
    [limit]
  );
  return rows;
}

async function getMovieById(id) {
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji, h.image_s3_key as hero_image
     FROM movies m LEFT JOIN heroes h ON h.id = m.hero_id
     WHERE m.id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function getFeaturedRelease() {
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji,
      (m.release_date - CURRENT_DATE) AS days_remaining
     FROM movies m LEFT JOIN heroes h ON h.id = m.hero_id
     WHERE m.status = 'upcoming' AND m.release_date >= CURRENT_DATE
     ORDER BY m.release_date ASC LIMIT 1`
  );
  return rows[0] || null;
}

async function getHeroes(activeOnly = true) {
  const { rows } = await db.query(
    `SELECT * FROM heroes WHERE ($1 = FALSE OR is_active = TRUE) ORDER BY sort_order, name`,
    [activeOnly]
  );
  return rows;
}

async function getHeroById(id) {
  const { rows } = await db.query(`SELECT * FROM heroes WHERE id = $1`, [id]);
  return rows[0] || null;
}

async function getShareCards(category, isActive = true, limit = 20, offset = 0) {
  const categoryFilter = category && category !== 'All' ? `AND sc.category = $4` : '';
  const params = [isActive, limit, offset];
  if (category && category !== 'All') params.push(category);

  const { rows } = await db.query(
    `SELECT sc.*, h.name as hero_name, h.icon_emoji
     FROM share_cards sc LEFT JOIN heroes h ON h.id = sc.hero_id
     WHERE sc.is_active = $1 ${categoryFilter}
     ORDER BY sc.publish_date DESC, sc.share_count DESC
     LIMIT $2 OFFSET $3`,
    params
  );

  const { rows: countRows } = await db.query(
    `SELECT COUNT(*)::int as total FROM share_cards WHERE is_active = $1 ${category && category !== 'All' ? 'AND category = $2' : ''}`,
    category && category !== 'All' ? [isActive, category] : [isActive]
  );

  return { rows, total: countRows[0].total };
}

async function getShareCardById(id) {
  const { rows } = await db.query(
    `SELECT sc.*, h.name as hero_name FROM share_cards sc
     LEFT JOIN heroes h ON h.id = sc.hero_id WHERE sc.id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function incrementShareCount(cardId) {
  await db.query(`UPDATE share_cards SET share_count = share_count + 1 WHERE id = $1`, [cardId]);
}

async function getSharePreviews(limit = 6) {
  const { rows } = await db.query(
    `SELECT id, title, category, hero_id, thumbnail_s3_key, share_count
     FROM share_cards WHERE is_active = TRUE ORDER BY share_count DESC LIMIT $1`,
    [limit]
  );
  return rows;
}

async function getHeroOfWeek() {
  // Rotate based on week number
  const week = Math.floor(Date.now() / (7 * 24 * 60 * 60 * 1000));
  const { rows } = await db.query(`SELECT * FROM heroes WHERE is_active = TRUE ORDER BY sort_order`);
  if (!rows.length) return null;
  return rows[week % rows.length];
}

async function setMovieReminder(userId, movieId) {
  await db.query(
    `INSERT INTO movie_reminders (user_id, movie_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
    [userId, movieId]
  );
}

module.exports = {
  getUpcomingMovies, getMovieById, getFeaturedRelease,
  getHeroes, getHeroById,
  getShareCards, getShareCardById, incrementShareCount, getSharePreviews,
  getHeroOfWeek, setMovieReminder,
};
