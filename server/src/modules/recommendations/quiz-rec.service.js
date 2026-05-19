const db = require('../../config/db');
const { loadUserContext } = require('./user-context');
const { QUIZ_SCORE_WEIGHTS } = require('./constants');
const { computePersonalAffinity } = require('./scoring/personal-affinity');
const candidates = require('./candidates');

const QUIZ_SECTIONS = [
  { type: 'daily_trivia', title: "Today's TFI Trivia" },
  { type: 'favourite_hero', title: 'For Your Favourite Hero' },
  { type: 'from_updates', title: 'From Latest Updates' },
  { type: 'dialogue', title: 'Dialogue Guess' },
  { type: 'release_year', title: 'Release Year' },
  { type: 'movie', title: 'Movie Quiz' },
  { type: 'classic', title: 'Classic TFI' },
];

function scoreQuizCategory(cat, ctx, completedTypes) {
  const personal = computePersonalAffinity(
    { content_type: 'quiz_category', category: cat.id, hero_id: cat.hero_id, movie_id: cat.movie_id },
    ctx
  );
  const freshness = 0.7;
  const popularity = 0.5;
  const completed = completedTypes.has(cat.id) ? 0.2 : 1.0;
  const w = QUIZ_SCORE_WEIGHTS;
  return (
    personal * w.relevance +
    freshness * w.freshness_from_updates +
    popularity * w.popularity +
    completed * w.novelty
  );
}

async function getQuizRecommendations(userId) {
  const ctx = await loadUserContext(userId);
  const { daily, categories } = await candidates.fetchQuizPreviews(ctx);

  let completedTypes = new Set();
  if (userId) {
    const { rows } = await db.query(
      `SELECT DISTINCT qq.type FROM quiz_answers qa
       JOIN quiz_sessions qs ON qs.id = qa.session_id
       JOIN quiz_questions qq ON qq.id = qa.question_id
       WHERE qs.user_id = $1 AND qs.completed = TRUE`,
      [userId]
    );
    completedTypes = new Set(rows.map((r) => r.type));
  }

  const ranked = categories
    .map((c) => ({ ...c, _score: scoreQuizCategory(c, ctx, completedTypes) }))
    .sort((a, b) => b._score - a._score);

  const sections = [];
  if (daily) {
    sections.push({
      type: 'daily_trivia',
      title: "Today's TFI Trivia",
      items: [{ quiz_date: daily.quiz_date, question_count: daily.question_ids?.length || 5 }],
    });
  }

  if (ctx?.favouriteHeroId) {
    const heroCats = ranked.filter((c) => String(c.hero_id) === String(ctx.favouriteHeroId)).slice(0, 4);
    if (heroCats.length) {
      sections.push({ type: 'favourite_hero', title: 'For Your Favourite Hero', items: heroCats });
    }
  }

  sections.push({
    type: 'from_updates',
    title: 'From Latest Updates',
    items: ranked.slice(0, 5),
  });

  const byType = {};
  for (const c of ranked) {
    if (!byType[c.id]) byType[c.id] = c;
  }
  for (const def of QUIZ_SECTIONS.slice(3)) {
    const item = byType[def.type];
    if (item) sections.push({ type: def.type, title: def.title, items: [item] });
  }

  return { sections, meta: { algorithm: 'quiz_hybrid_v1' } };
}

module.exports = { getQuizRecommendations };
