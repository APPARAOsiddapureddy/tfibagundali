const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const related = require('../recommendations/related.service');
const events = require('../recommendations/events.service');
const { syncUpdateFeatures } = require('../recommendations/content-features.service');

const UPDATE_SELECT = `
  u.*, h.name as hero_name, h.icon_emoji as hero_emoji, m.title as movie_title
  FROM tfi_updates u
  LEFT JOIN heroes h ON h.id = u.hero_id
  LEFT JOIN movies m ON m.id = u.movie_id
`;

async function loadRelatedIds(updateId) {
  const { rows: heroes } = await db.query('SELECT hero_id FROM update_heroes WHERE update_id = $1', [updateId]);
  const { rows: movies } = await db.query('SELECT movie_id FROM update_movies WHERE update_id = $1', [updateId]);
  return {
    hero_ids: heroes.map((r) => r.hero_id),
    movie_ids: movies.map((r) => r.movie_id),
  };
}

function formatUpdate(row, extras = {}) {
  const short = row.short_summary || row.summary;
  return {
    id: row.id,
    title: row.title,
    slug: row.slug,
    short_summary: short,
    full_summary: row.full_summary || row.body || short,
    category: (row.category || '').toUpperCase(),
    status: (row.trust_status || 'BUZZ').toUpperCase(),
    priority: (row.priority || 'NORMAL').toUpperCase(),
    image_url: row.image_url,
    source_name: row.source_name,
    source_url: row.source_url,
    tags: row.tags || [],
    language: (row.language || 'MIXED').toUpperCase(),
    hero: row.hero_name ? { id: row.hero_id, name: row.hero_name, icon_emoji: row.hero_emoji } : null,
    movie: row.movie_title ? { id: row.movie_id, title: row.movie_title } : null,
    related_hero_ids: extras.hero_ids || (row.hero_id ? [row.hero_id] : []),
    related_movie_ids: extras.movie_ids || (row.movie_id ? [row.movie_id] : []),
    related_director_names: row.related_director_names || [],
    published_at: row.published_at,
    event_datetime: row.event_datetime,
    expires_at: row.expires_at,
    is_pinned: row.is_pinned,
    is_correction: row.is_correction,
    reactions: {
      fire: row.reaction_fire,
      mass: row.reaction_mass,
      love: row.reaction_love,
      wait: row.reaction_wait,
      total: row.reaction_count || (row.reaction_fire + row.reaction_mass + row.reaction_love + row.reaction_wait),
    },
    view_count: row.view_count,
    save_count: row.save_count,
    share_count: row.share_count,
    available_actions: ['READ', 'SAVE', 'SHARE', 'SET_ALERT', 'FOLLOW', 'VOTE', 'PLAY_QUIZ'],
    ...extras.user_state,
  };
}

async function listUpdates({ category, status, heroId, movieId, priority, q, sort = 'latest', page = 1, limit = 20 }, userId) {
  let where = 'WHERE u.is_active = TRUE';
  const params = [];
  let i = 1;

  if (category && category !== 'all') {
    where += ` AND LOWER(u.category) = LOWER($${i++})`;
    params.push(category);
  }
  if (status) {
    where += ` AND LOWER(u.trust_status) = LOWER($${i++})`;
    params.push(status);
  }
  if (heroId) {
    where += ` AND (u.hero_id = $${i} OR EXISTS (SELECT 1 FROM update_heroes uh WHERE uh.update_id = u.id AND uh.hero_id = $${i}))`;
    params.push(heroId);
    i += 1;
  }
  if (movieId) {
    where += ` AND (u.movie_id = $${i} OR EXISTS (SELECT 1 FROM update_movies um WHERE um.update_id = u.id AND um.movie_id = $${i}))`;
    params.push(movieId);
    i += 1;
  }
  if (priority) {
    where += ` AND LOWER(u.priority) = LOWER($${i++})`;
    params.push(priority);
  }
  if (q) {
    where += ` AND (u.title ILIKE $${i} OR u.summary ILIKE $${i} OR u.short_summary ILIKE $${i})`;
    params.push(`%${q}%`);
    i += 1;
  }

  const order = sort === 'trending'
    ? 'ORDER BY u.is_trending DESC, u.reaction_count DESC, u.published_at DESC'
    : sort === 'most_reacted'
      ? 'ORDER BY (u.reaction_fire + u.reaction_mass + u.reaction_love + u.reaction_wait) DESC'
      : 'ORDER BY u.is_pinned DESC, u.is_breaking DESC, u.published_at DESC';

  const offset = (page - 1) * limit;
  params.push(limit, offset);
  const { rows } = await db.query(
    `SELECT ${UPDATE_SELECT} ${where} ${order} LIMIT $${i++} OFFSET $${i}`,
    params
  );

  const items = [];
  for (const row of rows) {
    const rel = await loadRelatedIds(row.id);
    const userState = userId ? await getUserState(userId, row.id) : {};
    items.push(formatUpdate(row, { ...rel, user_state: userState }));
  }
  return { items, page, limit };
}

async function getUserState(userId, updateId) {
  const { rows: react } = await db.query(
    'SELECT reaction FROM update_reactions WHERE user_id = $1 AND update_id = $2',
    [userId, updateId]
  );
  const { rows: saved } = await db.query(
    `SELECT 1 FROM bookmarks WHERE user_id = $1 AND item_type = 'update' AND item_id = $2`,
    [userId, updateId]
  );
  const { rows: rem } = await db.query(
    `SELECT 1 FROM reminders WHERE user_id = $1 AND update_id = $2 LIMIT 1`,
    [userId, updateId]
  );
  return {
    has_reacted: react[0]?.reaction?.toUpperCase() || null,
    is_saved: saved.length > 0,
    has_set_reminder: rem.length > 0,
  };
}

async function getUpdate(id, userId) {
  const { rows } = await db.query(`SELECT ${UPDATE_SELECT} WHERE u.id = $1`, [id]);
  if (!rows.length) throw new AppError('Update not found', 404, 'NOT_FOUND');
  const rel = await loadRelatedIds(id);
  const userState = userId ? await getUserState(userId, id) : {};
  const update = formatUpdate(rows[0], { ...rel, user_state: userState });

  const relatedContent = await related.getRelatedContent('update', id, userId);
  return { update, related: relatedContent };
}

async function recordView(userId, updateId) {
  await db.query('UPDATE tfi_updates SET view_count = view_count + 1 WHERE id = $1', [updateId]);
  if (userId) {
    await events.trackEvent({
      user_id: userId,
      event_name: 'update_opened',
      content_type: 'update',
      content_id: updateId,
    });
  }
  return { viewed: true };
}

const REACTION_MAP = {
  FIRE: 'fire',
  MASS: 'mass',
  EXCITED: 'mass',
  WAITING: 'wait',
  LOVE: 'love',
  SHOCK: 'fire',
};

async function react(userId, updateId, reaction) {
  const normalized = REACTION_MAP[reaction?.toUpperCase()] || reaction?.toLowerCase();
  const valid = ['fire', 'mass', 'love', 'wait'];
  if (!valid.includes(normalized)) throw new AppError('Invalid reaction', 400, 'VALIDATION_ERROR');

  const { rows: prev } = await db.query(
    'SELECT reaction FROM update_reactions WHERE user_id = $1 AND update_id = $2',
    [userId, updateId]
  );
  if (prev[0]?.reaction === normalized) {
    return getUpdate(updateId, userId);
  }
  if (prev[0]) {
    await db.query(`UPDATE tfi_updates SET reaction_${prev[0].reaction} = GREATEST(0, reaction_${prev[0].reaction} - 1) WHERE id = $1`, [updateId]);
  }

  await db.query(
    `INSERT INTO update_reactions (user_id, update_id, reaction) VALUES ($1,$2,$3)
     ON CONFLICT (user_id, update_id) DO UPDATE SET reaction = $3`,
    [userId, updateId, normalized]
  );
  await db.query(`UPDATE tfi_updates SET reaction_${normalized} = reaction_${normalized} + 1, reaction_count = reaction_count + 1 WHERE id = $1`, [updateId]);
  await events.trackEvent({ user_id: userId, event_name: 'update_reacted', content_type: 'update', content_id: updateId, metadata: { reaction: normalized } });
  syncUpdateFeatures(updateId).catch(() => {});
  return getUpdate(updateId, userId);
}

async function save(userId, updateId) {
  await db.query(
    `INSERT INTO bookmarks (user_id, item_type, item_id) VALUES ($1,'update',$2) ON CONFLICT DO NOTHING`,
    [userId, updateId]
  );
  await db.query('UPDATE tfi_updates SET save_count = save_count + 1 WHERE id = $1', [updateId]);
  await events.trackEvent({ user_id: userId, event_name: 'update_saved', content_type: 'update', content_id: updateId });
  return { saved: true };
}

async function unsave(userId, updateId) {
  await db.query(
    `DELETE FROM bookmarks WHERE user_id = $1 AND item_type = 'update' AND item_id = $2`,
    [userId, updateId]
  );
  return { saved: false };
}

async function share(userId, updateId) {
  await db.query('UPDATE tfi_updates SET share_count = share_count + 1 WHERE id = $1', [updateId]);
  if (userId) {
    await events.trackEvent({ user_id: userId, event_name: 'update_shared', content_type: 'update', content_id: updateId });
  }
  return { shared: true };
}

async function notInterested(userId, updateId) {
  return events.markNotInterested(userId, 'update', updateId);
}

module.exports = {
  listUpdates,
  getUpdate,
  recordView,
  react,
  save,
  unsave,
  share,
  notInterested,
};
