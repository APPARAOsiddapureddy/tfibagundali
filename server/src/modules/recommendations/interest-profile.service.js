const db = require('../../config/db');
const { EVENT_WEIGHTS, INTEREST_DECAY_DAILY } = require('./constants');

function applyDecay(scores) {
  const out = {};
  for (const [k, v] of Object.entries(scores || {})) {
    out[k] = (Number(v) || 0) * INTEREST_DECAY_DAILY;
  }
  return out;
}

async function applyEventToProfile(userId, event) {
  const weight = EVENT_WEIGHTS[event.event_name];
  if (weight === undefined || weight === 0) return;

  const { rows } = await db.query(
    'SELECT * FROM user_interest_profiles WHERE user_id = $1',
    [userId]
  );
  let profile = rows[0];
  if (!profile) {
    await db.query(
      `INSERT INTO user_interest_profiles (user_id) VALUES ($1) ON CONFLICT DO NOTHING`,
      [userId]
    );
    profile = { hero_scores: {}, movie_scores: {}, category_scores: {}, content_type_scores: {}, quiz_category_scores: {}, wallpaper_category_scores: {}, poll_category_scores: {}, session_boosts: {} };
  }

  const heroScores = applyDecay(profile.hero_scores);
  const movieScores = applyDecay(profile.movie_scores);
  const categoryScores = applyDecay(profile.category_scores);
  const contentTypeScores = applyDecay(profile.content_type_scores || {});
  const sessionBoosts = { ...(profile.session_boosts || {}) };

  for (const hid of event.hero_ids || []) {
    if (hid) heroScores[hid] = (heroScores[hid] || 0) + weight;
  }
  for (const mid of event.movie_ids || []) {
    if (mid) {
      movieScores[mid] = (movieScores[mid] || 0) + weight;
      sessionBoosts[`movie:${mid}`] = Math.min(0.2, (sessionBoosts[`movie:${mid}`] || 0) + 0.05);
    }
  }
  if (event.category) {
    categoryScores[event.category] = (categoryScores[event.category] || 0) + weight;
  }
  if (event.content_type) {
    contentTypeScores[event.content_type] = (contentTypeScores[event.content_type] || 0) + weight * 0.5;
  }

  if (event.event_name === 'quiz_completed' && event.metadata?.category) {
    const qc = profile.quiz_category_scores || {};
    qc[event.metadata.category] = (qc[event.metadata.category] || 0) + weight;
    profile.quiz_category_scores = qc;
  }

  await db.query(
    `UPDATE user_interest_profiles SET
      hero_scores = $2, movie_scores = $3, category_scores = $4,
      content_type_scores = $5, session_boosts = $6, updated_at = NOW()
     WHERE user_id = $1`,
    [userId, heroScores, movieScores, categoryScores, contentTypeScores, sessionBoosts]
  );
}

module.exports = { applyEventToProfile };
