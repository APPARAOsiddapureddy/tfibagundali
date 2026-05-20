const db = require('../../config/db');
const { computeFreshness } = require('../recommendations/scoring/freshness');

function priorityToEditorial(priority) {
  const map = { LOW: 0, NORMAL: 0.2, HIGH: 0.5, FEATURED: 0.9 };
  return map[(priority || 'NORMAL').toUpperCase()] ?? 0.2;
}

function parseJsonIds(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val;
  try {
    return JSON.parse(val);
  } catch {
    return [];
  }
}

function parseTags(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val;
  try {
    return JSON.parse(val);
  } catch {
    return [];
  }
}

async function upsertContentFeatures({
  contentType,
  contentId,
  category,
  heroIds = [],
  movieIds = [],
  tags = [],
  language = 'mixed',
  priority = 'normal',
  publishedAt,
  trustStatus = 'verified',
  isPinned = false,
}) {
  const freshness = computeFreshness({ published_at: publishedAt || new Date() });
  const editorial = priorityToEditorial(priority);
  const keywords = tags.map(String);

  await db.query(
    `INSERT INTO content_features (
      content_type, content_id, category, trust_status, hero_ids, movie_ids,
      keywords, language, published_at, freshness_score, editorial_score,
      priority, is_pinned, updated_at
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,NOW())
    ON CONFLICT (content_type, content_id) DO UPDATE SET
      category = EXCLUDED.category,
      hero_ids = EXCLUDED.hero_ids,
      movie_ids = EXCLUDED.movie_ids,
      keywords = EXCLUDED.keywords,
      language = EXCLUDED.language,
      published_at = COALESCE(EXCLUDED.published_at, content_features.published_at),
      freshness_score = EXCLUDED.freshness_score,
      editorial_score = EXCLUDED.editorial_score,
      priority = EXCLUDED.priority,
      updated_at = NOW()`,
    [
      contentType,
      contentId,
      category || null,
      trustStatus,
      heroIds,
      movieIds,
      keywords,
      (language || 'mixed').toLowerCase(),
      publishedAt || new Date(),
      freshness,
      editorial,
      (priority || 'normal').toLowerCase(),
      isPinned,
    ]
  );
}

async function syncMediaAssetFeatures(assetId) {
  const { rows } = await db.query('SELECT * FROM media_assets WHERE id = $1', [assetId]);
  if (!rows[0] || !rows[0].is_active) return;
  const a = rows[0];
  await upsertContentFeatures({
    contentType: 'media_asset',
    contentId: a.id,
    category: a.category,
    heroIds: parseJsonIds(a.related_hero_ids),
    movieIds: parseJsonIds(a.related_movie_ids),
    tags: parseTags(a.tags),
    language: a.language,
    priority: a.priority,
    publishedAt: a.created_at,
    trustStatus: 'verified',
  });
}

async function syncWallpaperFeatures(wallpaperId) {
  const { rows } = await db.query('SELECT * FROM wallpapers WHERE id = $1', [wallpaperId]);
  if (!rows[0]) return;
  const w = rows[0];
  const heroIds = w.hero_id ? [w.hero_id] : [];
  const movieIds = w.movie_id ? [w.movie_id] : [];
  const tags = parseTags(w.tags);
  await upsertContentFeatures({
    contentType: 'wallpaper',
    contentId: w.id,
    category: w.category,
    heroIds,
    movieIds,
    tags,
    publishedAt: w.published_at || w.created_at,
    priority: 'normal',
  });
}

async function syncStatusCardFeatures(cardId) {
  const { rows } = await db.query('SELECT * FROM status_cards WHERE id = $1', [cardId]);
  if (!rows[0]) return;
  const c = rows[0];
  await upsertContentFeatures({
    contentType: 'status_card',
    contentId: c.id,
    category: c.category,
    heroIds: c.hero_id ? [c.hero_id] : [],
    movieIds: c.movie_id ? [c.movie_id] : [],
    tags: parseTags(c.tags),
    publishedAt: c.published_at || c.created_at,
    priority: 'normal',
  });
}

async function syncPollFeatures(pollId) {
  const { rows } = await db.query('SELECT * FROM polls WHERE id = $1', [pollId]);
  if (!rows[0]) return;
  const p = rows[0];
  await upsertContentFeatures({
    contentType: 'poll',
    contentId: p.id,
    category: p.category,
    heroIds: p.hero_id ? [p.hero_id] : [],
    movieIds: p.movie_id ? [p.movie_id] : [],
    publishedAt: p.starts_at || p.created_at,
    priority: 'normal',
  });
}

async function syncQuizQuestionFeatures(questionId) {
  const { rows } = await db.query('SELECT * FROM quiz_questions WHERE id = $1', [questionId]);
  if (!rows[0]) return;
  const q = rows[0];
  await upsertContentFeatures({
    contentType: 'quiz',
    contentId: q.id,
    category: q.type,
    heroIds: q.hero_id ? [q.hero_id] : [],
    movieIds: q.movie_id ? [q.movie_id] : [],
    publishedAt: q.created_at,
    priority: 'normal',
  });
}

module.exports = {
  upsertContentFeatures,
  syncMediaAssetFeatures,
  syncWallpaperFeatures,
  syncStatusCardFeatures,
  syncPollFeatures,
  syncQuizQuestionFeatures,
};
