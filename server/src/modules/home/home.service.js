const db = require('../../config/db');
const updatesService = require('../updates/updates.service');

async function getHome(userId) {
  let favouriteHeroId = null;
  let displayName = 'Fan';
  if (userId) {
    const { rows } = await db.query('SELECT display_name, favourite_hero_id FROM users WHERE id = $1', [userId]);
    if (rows[0]) {
      displayName = rows[0].display_name || 'Fan';
      favouriteHeroId = rows[0].favourite_hero_id;
    }
  }

  const featured = await updatesService.listUpdates({ limit: 1, sort: 'trending' });
  const trending = await updatesService.listUpdates({ limit: 6, sort: 'trending' });
  const latest = await updatesService.listUpdates({ limit: 10 });

  let heroUpdates = [];
  if (favouriteHeroId) {
    heroUpdates = await updatesService.listUpdates({ heroId: favouriteHeroId, limit: 3 });
  }

  const { rows: movies } = await db.query(
    `SELECT m.*, h.name as hero_name, h.icon_emoji
     FROM movies m LEFT JOIN heroes h ON h.id = m.hero_id
     WHERE m.status = 'upcoming' ORDER BY m.release_date ASC LIMIT 8`
  );

  const { rows: polls } = await db.query(
    `SELECT * FROM polls WHERE is_active = TRUE ORDER BY created_at DESC LIMIT 2`
  );

  const { rows: wallpapers } = await db.query(
    `SELECT w.*, h.name as hero_name FROM wallpapers w
     LEFT JOIN heroes h ON h.id = w.hero_id
     WHERE w.is_trending = TRUE ORDER BY w.created_at DESC LIMIT 6`
  );

  const { rows: cards } = await db.query(
    `SELECT s.*, h.name as hero_name FROM status_cards s
     LEFT JOIN heroes h ON h.id = s.hero_id
     WHERE s.is_trending = TRUE ORDER BY s.created_at DESC LIMIT 6`
  );

  const { rows: quizRow } = await db.query(
    `SELECT quiz_date FROM daily_quiz_sets ORDER BY quiz_date DESC LIMIT 1`
  );

  let quizCompleted = false;
  if (userId && quizRow[0]) {
    const { rows: sess } = await db.query(
      `SELECT completed FROM quiz_sessions WHERE user_id = $1 AND quiz_date = $2`,
      [userId, quizRow[0].quiz_date]
    );
    quizCompleted = sess[0]?.completed || false;
  }

  return {
    greeting: { display_name: displayName, tagline: 'Eeroju TFI lo em jarigindhi?' },
    featured_update: featured[0] || null,
    hero_updates: heroUpdates,
    trending_updates: trending,
    upcoming_movies: movies.map(formatMovie),
    trending_poll: polls[0] ? formatPoll(polls[0]) : null,
    trending_wallpapers: wallpapers,
    trending_cards: cards,
    latest_updates: latest,
    quiz: { available: !!quizRow.length, completed_today: quizCompleted },
  };
}

function formatMovie(m) {
  const days = m.release_date
    ? Math.max(0, Math.ceil((new Date(m.release_date) - new Date()) / 86400000))
    : null;
  return {
    id: m.id,
    title: m.title,
    title_telugu: m.title_telugu,
    hero_name: m.hero_name,
    icon_emoji: m.icon_emoji,
    release_date: m.release_date,
    days_to_release: days,
    genre: m.genre,
  };
}

function formatPoll(p) {
  return {
    id: p.id,
    question: p.question,
    poll_type: p.poll_type,
    options: p.options,
    ends_at: p.ends_at,
    total_votes: p.total_votes,
  };
}

module.exports = { getHome };
