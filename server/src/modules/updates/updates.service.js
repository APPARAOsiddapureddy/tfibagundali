const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');

function formatUpdate(row) {
  return {
    id: row.id,
    title: row.title,
    summary: row.summary,
    body: row.body,
    category: row.category,
    trust_status: row.trust_status,
    hero: row.hero_name ? { id: row.hero_id, name: row.hero_name, icon_emoji: row.hero_emoji } : null,
    movie: row.movie_title ? { id: row.movie_id, title: row.movie_title } : null,
    image_url: row.image_url,
    source_name: row.source_name,
    priority: row.priority,
    is_breaking: row.is_breaking,
    is_trending: row.is_trending,
    reactions: {
      fire: row.reaction_fire,
      mass: row.reaction_mass,
      love: row.reaction_love,
      wait: row.reaction_wait,
    },
    published_at: row.published_at,
  };
}

const updateSelect = `
  u.*, h.name as hero_name, h.icon_emoji as hero_emoji, m.title as movie_title
  FROM tfi_updates u
  LEFT JOIN heroes h ON h.id = u.hero_id
  LEFT JOIN movies m ON m.id = u.movie_id
`;

async function listUpdates({ category, trust, sort = 'latest', heroId, limit = 20, offset = 0 }) {
  let where = 'WHERE u.is_active = TRUE';
  const params = [];
  let i = 1;
  if (category && category !== 'all') {
    where += ` AND u.category = $${i++}`;
    params.push(category);
  }
  if (trust) {
    where += ` AND u.trust_status = $${i++}`;
    params.push(trust);
  }
  if (heroId) {
    where += ` AND u.hero_id = $${i++}`;
    params.push(heroId);
  }
  const order = sort === 'trending'
    ? 'ORDER BY u.is_trending DESC, (u.reaction_fire + u.reaction_mass) DESC, u.published_at DESC'
    : 'ORDER BY u.is_breaking DESC, u.published_at DESC';
  params.push(limit, offset);
  const { rows } = await db.query(
    `SELECT ${updateSelect} ${where} ${order} LIMIT $${i++} OFFSET $${i}`,
    params
  );
  return rows.map(formatUpdate);
}

async function getUpdate(id) {
  const { rows } = await db.query(`SELECT ${updateSelect} WHERE u.id = $1`, [id]);
  if (!rows.length) throw new AppError('Update not found', 404, 'NOT_FOUND');
  return formatUpdate(rows[0]);
}

async function react(userId, updateId, reaction) {
  const valid = ['fire', 'mass', 'love', 'wait'];
  if (!valid.includes(reaction)) throw new AppError('Invalid reaction', 400);
  await db.query(
    `INSERT INTO update_reactions (user_id, update_id, reaction) VALUES ($1,$2,$3)
     ON CONFLICT (user_id, update_id) DO UPDATE SET reaction = $3`,
    [userId, updateId, reaction]
  );
  await db.query(`UPDATE tfi_updates SET reaction_${reaction} = reaction_${reaction} + 1 WHERE id = $1`, [updateId]);
  return getUpdate(updateId);
}

async function save(userId, updateId) {
  await db.query(
    `INSERT INTO bookmarks (user_id, item_type, item_id) VALUES ($1,'update',$2) ON CONFLICT DO NOTHING`,
    [userId, updateId]
  );
  return { saved: true };
}

module.exports = { listUpdates, getUpdate, react, save };
