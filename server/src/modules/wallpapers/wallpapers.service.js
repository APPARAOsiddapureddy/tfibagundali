const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const events = require('../recommendations/events.service');

async function list({ category, heroId, limit = 50 }) {
  let where = 'WHERE (w.is_active IS NULL OR w.is_active = TRUE)';
  const params = [];
  let i = 1;
  if (category) { where += ` AND w.category = $${i++}`; params.push(category); }
  if (heroId) { where += ` AND w.hero_id = $${i++}`; params.push(heroId); }
  params.push(limit);
  const { rows } = await db.query(
    `SELECT w.*, h.name as hero_name FROM wallpapers w
     LEFT JOIN heroes h ON h.id = w.hero_id ${where}
     ORDER BY w.is_trending DESC, w.download_count DESC, w.created_at DESC LIMIT $${i}`,
    params
  );
  return rows.map(freeWallpaper);
}

function freeWallpaper(w) {
  return {
    ...w,
    is_free: true,
    premium_only: false,
    price: 0,
  };
}

async function getOne(id) {
  const { rows } = await db.query(
    `SELECT w.*, h.name as hero_name FROM wallpapers w LEFT JOIN heroes h ON h.id = w.hero_id WHERE w.id = $1`,
    [id]
  );
  if (!rows.length) throw new AppError('Wallpaper not found', 404);
  return freeWallpaper(rows[0]);
}

async function download(userId, id) {
  await db.query('UPDATE wallpapers SET download_count = download_count + 1 WHERE id = $1', [id]);
  if (userId) {
    await db.query(
      `INSERT INTO user_downloads (user_id, content_type, content_id) VALUES ($1,'wallpaper',$2) ON CONFLICT DO NOTHING`,
      [userId, id]
    );
    await events.trackEvent({ user_id: userId, event_name: 'wallpaper_downloaded', content_type: 'wallpaper', content_id: id });
  }
  return getOne(id);
}

async function share(userId, id) {
  await db.query('UPDATE wallpapers SET share_count = share_count + 1 WHERE id = $1', [id]);
  if (userId) await events.trackEvent({ user_id: userId, event_name: 'wallpaper_shared', content_type: 'wallpaper', content_id: id });
  return { shared: true };
}

async function save(userId, id) {
  await db.query(
    `INSERT INTO bookmarks (user_id, item_type, item_id) VALUES ($1,'wallpaper',$2) ON CONFLICT DO NOTHING`,
    [userId, id]
  );
  await db.query('UPDATE wallpapers SET save_count = save_count + 1 WHERE id = $1', [id]);
  return { saved: true };
}

async function unsave(userId, id) {
  await db.query(`DELETE FROM bookmarks WHERE user_id = $1 AND item_type = 'wallpaper' AND item_id = $2`, [userId, id]);
  return { saved: false };
}

module.exports = { list, getOne, download, share, save, unsave };
