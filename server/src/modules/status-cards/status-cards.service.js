const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const events = require('../recommendations/events.service');

function freeCard(c) {
  return { ...c, image_url: c.image_url || c.template_url, is_free: true, premium_only: false };
}

async function list({ category, heroId, limit = 50 }) {
  let where = 'WHERE (s.is_active IS NULL OR s.is_active = TRUE)';
  const params = [];
  let i = 1;
  if (category) { where += ` AND s.category = $${i++}`; params.push(category); }
  if (heroId) { where += ` AND s.hero_id = $${i++}`; params.push(heroId); }
  params.push(limit);
  const { rows } = await db.query(
    `SELECT s.*, h.name as hero_name FROM status_cards s
     LEFT JOIN heroes h ON h.id = s.hero_id ${where}
     ORDER BY s.is_trending DESC, s.download_count DESC LIMIT $${i}`,
    params
  );
  return rows.map(freeCard);
}

async function getOne(id) {
  const { rows } = await db.query(
    `SELECT s.*, h.name as hero_name FROM status_cards s LEFT JOIN heroes h ON h.id = s.hero_id WHERE s.id = $1`,
    [id]
  );
  if (!rows.length) throw new AppError('Status card not found', 404);
  return freeCard(rows[0]);
}

async function customize(userId, cardId, payload) {
  const name = (payload.name || payload.display_name || '').trim();
  const text = (payload.text || payload.custom_text || '').trim();
  const { rows } = await db.query(
    `INSERT INTO status_card_customizations (user_id, card_id, name, custom_text, hero_id, style)
     VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
    [userId, cardId, name, text, payload.hero_id, payload.style || 'default']
  );
  const card = await getOne(cardId);
  return {
    customization: rows[0],
    preview: {
      card,
      overlay: { name, text, style: payload.style || 'default' },
    },
  };
}

async function download(userId, id) {
  await db.query('UPDATE status_cards SET download_count = download_count + 1 WHERE id = $1', [id]);
  if (userId) {
    await db.query(
      `INSERT INTO user_downloads (user_id, content_type, content_id) VALUES ($1,'status_card',$2) ON CONFLICT DO NOTHING`,
      [userId, id]
    );
    await events.trackEvent({ user_id: userId, event_name: 'status_card_downloaded', content_type: 'status_card', content_id: id });
  }
  return getOne(id);
}

async function share(userId, id) {
  await db.query('UPDATE status_cards SET share_count = share_count + 1 WHERE id = $1', [id]);
  if (userId) await events.trackEvent({ user_id: userId, event_name: 'status_card_shared', content_type: 'status_card', content_id: id });
  return { shared: true };
}

async function save(userId, id) {
  await db.query(
    `INSERT INTO bookmarks (user_id, item_type, item_id) VALUES ($1,'status_card',$2) ON CONFLICT DO NOTHING`,
    [userId, id]
  );
  return { saved: true };
}

async function unsave(userId, id) {
  await db.query(`DELETE FROM bookmarks WHERE user_id = $1 AND item_type = 'status_card' AND item_id = $2`, [userId, id]);
  return { saved: false };
}

module.exports = { list, getOne, customize, download, share, save, unsave };
