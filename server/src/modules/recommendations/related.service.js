const db = require('../../config/db');
const { loadUserContext } = require('./user-context');
const { rankItems } = require('./scoring');
const candidates = require('./candidates');

async function getRelatedContent(contentType, contentId, userId) {
  const ctx = await loadUserContext(userId);
  const result = {
    updates: [],
    movies: [],
    heroes: [],
    polls: [],
    quizzes: [],
    wallpapers: [],
    status_cards: [],
    actions: [],
  };

  let heroId = null;
  let movieId = null;
  let category = null;

  if (contentType === 'update') {
    const { rows } = await db.query(
      'SELECT hero_id, movie_id, category, title FROM tfi_updates WHERE id = $1',
      [contentId]
    );
    if (!rows[0]) return result;
    ({ hero_id: heroId, movie_id: movieId, category } = rows[0]);

    const relatedUpdates = await candidates.fetchUpdates(
      `AND u.id != $1 AND (u.hero_id = $2 OR u.movie_id = $3 OR u.category = $4)`,
      [contentId, heroId, movieId, category],
      8
    );
    result.updates = rankItems(relatedUpdates, ctx).slice(0, 5).map(formatRelatedUpdate);

    if (movieId) {
      const { rows: movies } = await db.query(
        `SELECT m.*, h.name as hero_name, h.icon_emoji FROM movies m
         LEFT JOIN heroes h ON h.id = m.hero_id WHERE m.id = $1`,
        [movieId]
      );
      if (movies[0]) result.movies = [formatRelatedMovie(movies[0])];
    }
    if (heroId) {
      const { rows: heroes } = await db.query('SELECT * FROM heroes WHERE id = $1', [heroId]);
      if (heroes[0]) result.heroes = [heroes[0]];
    }

    const { rows: polls } = await db.query(
      `SELECT * FROM polls WHERE is_active = TRUE AND (movie_id = $1 OR hero_id = $2 OR update_id = $3)
       AND (ends_at IS NULL OR ends_at > NOW()) LIMIT 3`,
      [movieId, heroId, contentId]
    );
    result.polls = polls;

    const { rows: questions } = await db.query(
      `SELECT id, question_text, type, difficulty FROM quiz_questions
       WHERE is_active = TRUE AND (hero_id = $1 OR movie_id = $2) LIMIT 3`,
      [heroId, movieId]
    );
    result.quizzes = questions.map((q) => ({
      id: q.id,
      title: q.question_text,
      category: q.type,
      difficulty: q.difficulty,
    }));

    const { rows: wallpapers } = await db.query(
      `SELECT * FROM wallpapers WHERE hero_id = $1 OR movie_id = $2 ORDER BY is_trending DESC LIMIT 4`,
      [heroId, movieId]
    );
    result.wallpapers = wallpapers;

    const { rows: cards } = await db.query(
      `SELECT * FROM status_cards WHERE hero_id = $1 OR movie_id = $2 ORDER BY is_trending DESC LIMIT 4`,
      [heroId, movieId]
    );
    result.status_cards = cards;

    result.actions = buildActions(category, movieId, heroId);
  }

  if (contentType === 'movie') {
    const { rows } = await db.query('SELECT * FROM movies WHERE id = $1', [contentId]);
    if (!rows[0]) return result;
    movieId = contentId;
    heroId = rows[0].hero_id;

    result.updates = rankItems(
      await candidates.fetchUpdates('AND u.movie_id = $1', [movieId], 10),
      ctx
    ).slice(0, 6).map(formatRelatedUpdate);

    const { rows: similar } = await db.query(
      `SELECT m.*, h.name as hero_name FROM movies m
       LEFT JOIN heroes h ON h.id = m.hero_id
       WHERE m.id != $1 AND m.status = 'upcoming' AND (m.hero_id = $2 OR m.genre = $3)
       ORDER BY m.release_date ASC LIMIT 5`,
      [movieId, heroId, rows[0].genre]
    );
    result.movies = similar.map(formatRelatedMovie);
    result.actions = ['set_alert', 'follow_movie', 'share', 'vote_poll', 'play_quiz', 'download_card'];
  }

  if (contentType === 'hero') {
    heroId = contentId;
    const { rows: heroes } = await db.query('SELECT * FROM heroes WHERE id = $1', [heroId]);
    result.heroes = heroes;

    result.updates = rankItems(
      await candidates.fetchUpdates('AND u.hero_id = $1', [heroId], 10),
      ctx
    ).slice(0, 6).map(formatRelatedUpdate);

    const { rows: movies } = await db.query(
      `SELECT m.*, h.name as hero_name FROM movies m
       LEFT JOIN heroes h ON h.id = m.hero_id
       WHERE m.hero_id = $1 ORDER BY m.release_date ASC LIMIT 6`,
      [heroId]
    );
    result.movies = movies.map(formatRelatedMovie);

    const { rows: wallpapers } = await db.query(
      'SELECT * FROM wallpapers WHERE hero_id = $1 ORDER BY download_count DESC LIMIT 6',
      [heroId]
    );
    result.wallpapers = wallpapers;
    result.actions = ['follow_hero', 'download_wallpaper', 'play_quiz', 'vote_poll'];
  }

  return result;
}

function buildActions(category, movieId, heroId) {
  const actions = ['share', 'save'];
  if (movieId) actions.push('set_alert', 'follow_movie');
  if (heroId) actions.push('follow_hero');
  if (['trailer', 'teaser', 'song'].includes(category)) actions.push('watch_trailer');
  actions.push('vote_poll', 'play_quiz', 'download_card');
  return actions;
}

function formatRelatedUpdate(item) {
  return {
    id: item.id,
    title: item.title,
    summary: item.summary,
    category: item.category,
    trust_status: item.trust_status,
    hero: item.hero,
    movie: item.movie,
    published_at: item.published_at,
    reason: item._reason,
  };
}

function formatRelatedMovie(m) {
  return {
    id: m.id,
    title: m.title,
    title_telugu: m.title_telugu,
    hero_name: m.hero_name,
    release_date: m.release_date,
    status: m.status,
  };
}

module.exports = { getRelatedContent };
