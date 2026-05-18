const db = require('../../config/db');

async function getExplore() {
  const { rows: wallpapers } = await db.query(
    `SELECT w.*, h.name as hero_name FROM wallpapers w
     LEFT JOIN heroes h ON h.id = w.hero_id ORDER BY w.is_trending DESC, w.created_at DESC LIMIT 20`
  );
  const { rows: cards } = await db.query(
    `SELECT s.*, h.name as hero_name FROM status_cards s
     LEFT JOIN heroes h ON h.id = s.hero_id ORDER BY s.is_trending DESC, s.created_at DESC LIMIT 20`
  );
  const { rows: heroes } = await db.query('SELECT id, name, telugu_name, icon_emoji FROM heroes ORDER BY sort_order');
  const { rows: movies } = await db.query(
    `SELECT id, title, title_telugu, status FROM movies ORDER BY release_date DESC LIMIT 12`
  );
  return {
    featured: { title: "This Week's Fan Picks", subtitle: 'Wallpapers, cards and updates fans loved' },
    wallpapers,
    status_cards: cards,
    hero_collections: heroes,
    movie_collections: movies,
  };
}

async function listWallpapers(category) {
  let q = 'SELECT w.*, h.name as hero_name FROM wallpapers w LEFT JOIN heroes h ON h.id = w.hero_id';
  const params = [];
  if (category) {
    q += ' WHERE w.category = $1';
    params.push(category);
  }
  q += ' ORDER BY w.created_at DESC LIMIT 50';
  const { rows } = await db.query(q, params);
  return rows;
}

async function listCards(category) {
  let q = 'SELECT s.*, h.name as hero_name FROM status_cards s LEFT JOIN heroes h ON h.id = s.hero_id';
  const params = [];
  if (category) {
    q += ' WHERE s.category = $1';
    params.push(category);
  }
  q += ' ORDER BY s.created_at DESC LIMIT 50';
  const { rows } = await db.query(q, params);
  return rows;
}

module.exports = { getExplore, listWallpapers, listCards };
