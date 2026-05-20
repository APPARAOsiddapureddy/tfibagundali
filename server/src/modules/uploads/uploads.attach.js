const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const { syncUpdateFeatures } = require('../recommendations/content-features.service');
const {
  syncWallpaperFeatures,
  syncStatusCardFeatures,
  syncPollFeatures,
  syncQuizQuestionFeatures,
} = require('./media-features.service');

const ENTITY_MAP = {
  TFI_UPDATE: {
    table: 'tfi_updates',
    fields: ['image_url'],
    afterSync: (id) => syncUpdateFeatures(id),
  },
  MOVIE: {
    table: 'movies',
    fields: ['poster_url'],
    afterSync: null,
  },
  HERO: {
    table: 'heroes',
    fields: ['avatar_url'],
    afterSync: null,
  },
  WALLPAPER: {
    table: 'wallpapers',
    fields: ['image_url', 'thumbnail_url'],
    afterSync: (id) => syncWallpaperFeatures(id),
  },
  STATUS_CARD: {
    table: 'status_cards',
    fields: ['image_url', 'thumbnail_url', 'template_url'],
    afterSync: (id) => syncStatusCardFeatures(id),
  },
  POLL: {
    table: 'polls',
    fields: ['image_url'],
    afterSync: (id) => syncPollFeatures(id),
  },
  QUIZ_QUESTION: {
    table: 'quiz_questions',
    fields: ['image_url'],
    afterSync: (id) => syncQuizQuestionFeatures(id),
  },
  NOTIFICATION: {
    table: 'user_notifications',
    fields: ['image_url', 'thumbnail_url'],
    afterSync: null,
  },
  TIMELINE: {
    table: 'movie_timeline',
    fields: ['image_url'],
    afterSync: null,
  },
};

async function attachAssetToEntity(asset, { entity_type, entity_id, field }) {
  const config = ENTITY_MAP[entity_type];
  if (!config) throw new AppError('Unsupported entity_type', 400, 'INVALID_ENTITY');
  if (!config.fields.includes(field)) {
    throw new AppError(`Field ${field} not allowed for ${entity_type}`, 400, 'INVALID_FIELD');
  }

  const url = field.includes('thumbnail') && asset.thumbnail_url
    ? asset.thumbnail_url
    : asset.image_url;

  const { rows } = await db.query(
    `UPDATE ${config.table} SET ${field} = $1, updated_at = NOW() WHERE id = $2 RETURNING *`,
    [url, entity_id]
  );
  if (!rows.length) throw new AppError('Entity not found', 404, 'NOT_FOUND');

  if (config.afterSync) await config.afterSync(entity_id);

  return { entity: rows[0], entity_type, field, image_url: url };
}

module.exports = { ENTITY_MAP, attachAssetToEntity };
