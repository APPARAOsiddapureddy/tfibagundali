const db = require('../../config/db');

const UPDATE_SELECT = `
  u.*, h.name as hero_name, h.icon_emoji as hero_emoji, m.title as movie_title,
  m.release_date as movie_release_date
  FROM tfi_updates u
  LEFT JOIN heroes h ON h.id = u.hero_id
  LEFT JOIN movies m ON m.id = u.movie_id
`;

function mapUpdate(row) {
  return {
    content_type: 'update',
    id: row.id,
    title: row.title,
    summary: row.summary,
    body: row.body,
    category: row.category,
    trust_status: row.trust_status,
    hero_id: row.hero_id,
    movie_id: row.movie_id,
    hero: row.hero_name ? { id: row.hero_id, name: row.hero_name, icon_emoji: row.hero_emoji } : null,
    movie: row.movie_title ? { id: row.movie_id, title: row.movie_title } : null,
    image_url: row.image_url,
    source_name: row.source_name,
    priority: row.priority,
    is_breaking: row.is_breaking,
    is_trending: row.is_trending,
    is_pinned: row.is_pinned,
    editorial_score: row.editorial_score,
    published_at: row.published_at,
    event_datetime: row.event_datetime,
    expires_at: row.expires_at,
    reaction_fire: row.reaction_fire,
    reaction_mass: row.reaction_mass,
    reaction_love: row.reaction_love,
    reaction_wait: row.reaction_wait,
    view_count: row.view_count,
    save_count: row.save_count,
    share_count: row.share_count,
    release_date: row.movie_release_date,
  };
}

async function fetchUpdates(where = '', params = [], limit = 50) {
  const { rows } = await db.query(
    `SELECT ${UPDATE_SELECT} WHERE u.is_active = TRUE ${where}
     ORDER BY u.is_pinned DESC, u.is_breaking DESC, u.published_at DESC LIMIT ${limit}`,
    params
  );
  return rows.map(mapUpdate);
}

async function generateUpdateCandidates(ctx) {
  const candidates = [];
  const seen = new Set();

  const add = (items) => {
    for (const item of items) {
      if (!seen.has(item.id)) {
        seen.add(item.id);
        candidates.push(item);
      }
    }
  };

  add(await fetchUpdates(`AND u.is_breaking = TRUE AND u.trust_status IN ('official','verified')`, [], 8));
  add(await fetchUpdates(`AND u.published_at > NOW() - INTERVAL '72 hours'`, [], 40));
  add(await fetchUpdates(`AND u.is_trending = TRUE`, [], 15));

  if (ctx?.favouriteHeroId) {
    add(await fetchUpdates(`AND u.hero_id = $1`, [ctx.favouriteHeroId], 15));
  }
  if (ctx?.followedHeroIds?.length) {
    add(await fetchUpdates(`AND u.hero_id = ANY($1::uuid[])`, [ctx.followedHeroIds], 15));
  }
  if (ctx?.followedMovieIds?.length) {
    add(await fetchUpdates(`AND u.movie_id = ANY($1::uuid[])`, [ctx.followedMovieIds], 15));
  }

  add(await fetchUpdates(`AND u.event_datetime IS NOT NULL AND u.event_datetime > NOW() - INTERVAL '1 day'`, [], 10));
  add(await fetchUpdates(`AND u.is_pinned = TRUE`, [], 5));

  return candidates;
}

async function fetchMovies(limit = 12) {
  const { rows } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji
     FROM movies m LEFT JOIN heroes h ON h.id = m.hero_id
     WHERE m.status = 'upcoming' ORDER BY m.release_date ASC NULLS LAST LIMIT $1`,
    [limit]
  );
  return rows.map((m) => ({
    content_type: 'movie',
    id: m.id,
    title: m.title,
    title_telugu: m.title_telugu,
    hero_id: m.hero_id,
    hero_name: m.hero_name,
    icon_emoji: m.icon_emoji,
    release_date: m.release_date,
    genre: m.genre,
    status: m.status,
    poster_url: m.poster_url,
    follower_count: m.follower_count,
    reminder_count: m.reminder_count,
    published_at: m.created_at,
    category: 'release',
    trust_status: 'official',
  }));
}

async function fetchPolls(ctx, limit = 10) {
  let where = 'WHERE p.is_active = TRUE AND (p.ends_at IS NULL OR p.ends_at > NOW())';
  const params = [];
  if (ctx?.votedPollIds?.size) {
    where += ` AND p.id != ALL($1::uuid[])`;
    params.push([...ctx.votedPollIds]);
  }
  params.push(limit);
  const { rows } = await db.query(
    `SELECT p.*, h.name as hero_name FROM polls p
     LEFT JOIN heroes h ON h.id = p.hero_id
     ${where} ORDER BY p.trending_score DESC, p.total_votes DESC, p.created_at DESC
     LIMIT $${params.length}`,
    params
  );
  return rows.map((p) => ({
    content_type: 'poll',
    id: p.id,
    question: p.question,
    poll_type: p.poll_type,
    category: p.category,
    options: p.options,
    hero_id: p.hero_id,
    movie_id: p.movie_id,
    ends_at: p.ends_at,
    starts_at: p.starts_at,
    total_votes: p.total_votes,
    trending_score: p.trending_score,
    published_at: p.created_at,
    trust_status: 'verified',
  }));
}

async function fetchWallpapersAndCards(ctx, limit = 12) {
  const heroFilter = ctx?.favouriteHeroId ? 'AND w.hero_id = $1' : '';
  const params = ctx?.favouriteHeroId ? [ctx.favouriteHeroId, limit] : [limit];
  const { rows: wallpapers } = await db.query(
    `SELECT w.*, 'wallpaper' as content_type, h.name as hero_name FROM wallpapers w
     LEFT JOIN heroes h ON h.id = w.hero_id
     WHERE TRUE ${heroFilter}
     ORDER BY w.is_trending DESC, w.download_count DESC, w.created_at DESC LIMIT $${params.length}`,
    params
  );
  const cardParams = ctx?.favouriteHeroId ? [ctx.favouriteHeroId, limit] : [limit];
  const { rows: cards } = await db.query(
    `SELECT s.*, 'status_card' as content_type, h.name as hero_name FROM status_cards s
     LEFT JOIN heroes h ON h.id = s.hero_id
     WHERE TRUE ${ctx?.favouriteHeroId ? 'AND s.hero_id = $1' : ''}
     ORDER BY s.is_trending DESC, s.download_count DESC, s.created_at DESC LIMIT $${cardParams.length}`,
    cardParams
  );
  return [
    ...wallpapers.map((w) => ({
      content_type: 'wallpaper',
      id: w.id,
      title: w.title,
      category: w.category,
      hero_id: w.hero_id,
      movie_id: w.movie_id,
      image_url: w.image_url,
      download_count: w.download_count,
      published_at: w.published_at || w.created_at,
      trust_status: 'verified',
    })),
    ...cards.map((s) => ({
      content_type: 'status_card',
      id: s.id,
      title: s.title,
      category: s.category,
      hero_id: s.hero_id,
      movie_id: s.movie_id,
      image_url: s.image_url,
      download_count: s.download_count,
      published_at: s.published_at || s.created_at,
      customizable: s.customizable,
      trust_status: 'verified',
    })),
  ];
}

async function fetchQuizPreviews(ctx) {
  const { rows: daily } = await db.query(
    `SELECT quiz_date, question_ids FROM daily_quiz_sets ORDER BY quiz_date DESC LIMIT 1`
  );
  const categories = ['dialogue', 'release_year', 'movie', 'hero'];
  const { rows: questions } = await db.query(
    `SELECT DISTINCT ON (type) id, question_text, type, difficulty, hero_id, movie_id, created_at
     FROM quiz_questions WHERE is_active = TRUE
     ORDER BY type, created_at DESC LIMIT 8`
  );
  return {
    daily: daily[0] || null,
    categories: questions.map((q) => ({
      content_type: 'quiz_category',
      id: q.type,
      title: q.type.replace(/_/g, ' '),
      question_id: q.id,
      difficulty: q.difficulty,
      hero_id: q.hero_id,
      movie_id: q.movie_id,
      published_at: q.created_at,
      trust_status: 'verified',
    })),
  };
}

module.exports = {
  generateUpdateCandidates,
  fetchUpdates,
  fetchMovies,
  fetchPolls,
  fetchWallpapersAndCards,
  fetchQuizPreviews,
  mapUpdate,
};
