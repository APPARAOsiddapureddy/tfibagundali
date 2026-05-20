const db = require('../../config/db');

async function search(q, limit = 10) {
  if (!q || q.length < 2) {
    return {
      updates: [], movies: [], heroes: [], wallpapers: [], status_cards: [],
      media_assets: [], polls: [], quizzes: [],
    };
  }
  const pattern = `%${q}%`;

  const [updates, movies, heroes, wallpapers, cards, mediaAssets, polls, quizzes] = await Promise.all([
    db.query(
      `SELECT u.id, u.title, u.short_summary, u.summary, u.category, u.trust_status, u.published_at
       FROM tfi_updates u WHERE u.is_active AND (u.title ILIKE $1 OR u.summary ILIKE $1 OR u.short_summary ILIKE $1)
       ORDER BY u.published_at DESC LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, title, title_telugu, release_date, status FROM movies
       WHERE title ILIKE $1 OR title_telugu ILIKE $1 ORDER BY release_date DESC NULLS LAST LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, name, telugu_name, icon_emoji FROM heroes
       WHERE name ILIKE $1 OR telugu_name ILIKE $1 ORDER BY sort_order LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, title, category, image_url FROM wallpapers
       WHERE is_active IS NOT FALSE AND (title ILIKE $1 OR tags::text ILIKE $1)
       ORDER BY download_count DESC LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, title, category, image_url FROM status_cards
       WHERE is_active IS NOT FALSE AND (title ILIKE $1 OR tags::text ILIKE $1)
       ORDER BY download_count DESC LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, name, asset_type, category, image_url FROM media_assets
       WHERE is_active AND is_public AND (name ILIKE $1 OR tags::text ILIKE $1 OR slug ILIKE $1)
       ORDER BY created_at DESC LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, question, poll_type, total_votes FROM polls
       WHERE is_active AND question ILIKE $1 ORDER BY total_votes DESC LIMIT $2`,
      [pattern, limit]
    ),
    db.query(
      `SELECT id, question_text, type FROM quiz_questions
       WHERE is_active AND question_text ILIKE $1 LIMIT $2`,
      [pattern, limit]
    ),
  ]);

  return {
    updates: updates.rows,
    movies: movies.rows,
    heroes: heroes.rows,
    wallpapers: wallpapers.rows,
    status_cards: cards.rows,
    media_assets: mediaAssets.rows,
    polls: polls.rows,
    quizzes: quizzes.rows,
  };
}

async function trendingSearches() {
  return {
    trending: [
      'Peddi', 'Devara 2', 'Pushpa 3', 'Ram Charan', 'Trailer updates', 'OTT releases',
      'Allu Arjun', 'Prabhas', 'Jr NTR', 'Mahesh Babu',
    ],
  };
}

module.exports = { search, trendingSearches };
