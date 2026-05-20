const fs = require('fs');
const path = require('path');
const db = require('../../config/db');
const env = require('../../config/env');
const { AppError } = require('../../middleware/error.middleware');
const { getStorageService } = require('../../services/storage');
const {
  parseTags,
  parseUuidList,
  folderForAssetType,
  THUMB_FOLDER,
  slugFromName,
  isSuspiciousFilename,
} = require('../../lib/image-utils');
const {
  validateImageBuffer,
  processMainImage,
  generateThumbnail,
} = require('../../lib/image-processor');
const { fetchRemoteImage, validateHttpUrl } = require('../../lib/url-fetch');
const { attachAssetToEntity } = require('./uploads.attach');
const {
  syncMediaAssetFeatures,
  syncWallpaperFeatures,
  syncStatusCardFeatures,
} = require('./media-features.service');
const { syncUpdateFeatures } = require('../recommendations/content-features.service');
const events = require('../recommendations/events.service');

const VALID_ASSET_TYPES = new Set([
  'TFI_UPDATE', 'MOVIE_POSTER', 'HERO_AVATAR', 'WALLPAPER', 'STATUS_CARD',
  'POLL_IMAGE', 'QUIZ_IMAGE', 'TIMELINE_IMAGE', 'NOTIFICATION_IMAGE', 'GENERAL',
]);

function formatAsset(row) {
  if (!row) return null;
  const tags = row.tags;
  const heroes = row.related_hero_ids;
  const movies = row.related_movie_ids;
  return {
    ...row,
    tags: Array.isArray(tags) ? tags : parseUuidList(tags),
    related_hero_ids: Array.isArray(heroes) ? heroes : parseUuidList(heroes),
    related_movie_ids: Array.isArray(movies) ? movies : parseUuidList(movies),
  };
}

async function storeImageBuffers({ buffer, originalName, assetType }) {
  const meta = await validateImageBuffer(buffer, {
    maxBytes: env.UPLOAD_MAX_BYTES,
    originalName,
  });
  const processed = await processMainImage(buffer, meta);
  const storage = getStorageService();
  const folder = folderForAssetType(assetType);
  const mainRel = `${folder}/${processed.filename}`;
  const mainStored = await storage.uploadImage(processed.buffer, { relativePath: mainRel });

  let thumbUrl = mainStored.public_url;
  let thumbPath = mainStored.storage_path;
  const thumb = await generateThumbnail(processed.buffer, assetType, processed.filename);
  if (thumb) {
    const thumbRel = `${THUMB_FOLDER}/${thumb.filename}`;
    const thumbStored = await storage.uploadImage(thumb.buffer, { relativePath: thumbRel });
    thumbUrl = thumbStored.public_url;
    thumbPath = thumbStored.storage_path;
  }

  return {
    image_url: mainStored.public_url,
    thumbnail_url: thumbUrl,
    storage_path: mainStored.storage_path,
    thumbnail_storage_path: thumbPath,
    mime_type: processed.mimeType,
    extension: processed.extension,
    size_bytes: processed.buffer.length,
    width: processed.width,
    height: processed.height,
    storage_provider: mainStored.provider,
  };
}

function buildAssetPayload(fields, stored) {
  const heroIds = parseUuidList(fields.related_hero_id || fields.related_hero_ids);
  const movieIds = parseUuidList(fields.related_movie_id || fields.related_movie_ids);
  if (fields.related_hero_id && !heroIds.includes(fields.related_hero_id)) {
    heroIds.push(fields.related_hero_id);
  }
  if (fields.related_movie_id && !movieIds.includes(fields.related_movie_id)) {
    movieIds.push(fields.related_movie_id);
  }

  return {
    name: fields.name || 'Untitled asset',
    slug: slugFromName(fields.name || 'asset'),
    description: fields.description || null,
    asset_type: fields.asset_type,
    content_type: fields.content_type || null,
    category: fields.category || null,
    usage: fields.usage || null,
    image_url: stored.image_url,
    thumbnail_url: stored.thumbnail_url,
    storage_provider: stored.storage_provider,
    storage_path: stored.storage_path,
    external_url: fields.external_url || fields.source_url || null,
    mime_type: stored.mime_type,
    extension: stored.extension,
    size_bytes: stored.size_bytes,
    width: stored.width,
    height: stored.height,
    alt_text: fields.alt_text || null,
    source_name: fields.source_name || null,
    source_url: fields.source_url || null,
    language: (fields.language || 'MIXED').toUpperCase(),
    tags: JSON.stringify(parseTags(fields.tags)),
    related_hero_ids: JSON.stringify(heroIds),
    related_movie_ids: JSON.stringify(movieIds),
    related_update_id: fields.related_update_id || null,
    related_poll_id: fields.related_poll_id || null,
    related_quiz_id: fields.related_quiz_id || null,
    is_public: fields.is_public !== 'false' && fields.is_public !== false,
    is_active: fields.is_active !== 'false' && fields.is_active !== false,
    priority: (fields.priority || 'NORMAL').toUpperCase(),
  };
}

async function insertAsset(payload) {
  const { rows } = await db.query(
    `INSERT INTO media_assets (
      name, slug, description, asset_type, content_type, category, usage,
      image_url, thumbnail_url, storage_provider, storage_path, external_url,
      mime_type, extension, size_bytes, width, height, alt_text,
      source_name, source_url, language, tags, related_hero_ids, related_movie_ids,
      related_update_id, related_poll_id, related_quiz_id,
      is_public, is_active, priority
    ) VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30
    ) RETURNING *`,
    [
      payload.name, payload.slug, payload.description, payload.asset_type,
      payload.content_type, payload.category, payload.usage,
      payload.image_url, payload.thumbnail_url, payload.storage_provider,
      payload.storage_path, payload.external_url,
      payload.mime_type, payload.extension, payload.size_bytes,
      payload.width, payload.height, payload.alt_text,
      payload.source_name, payload.source_url, payload.language,
      payload.tags, payload.related_hero_ids, payload.related_movie_ids,
      payload.related_update_id, payload.related_poll_id, payload.related_quiz_id,
      payload.is_public, payload.is_active, payload.priority,
    ]
  );
  return formatAsset(rows[0]);
}

async function trackAdminUpload(asset, extra = {}) {
  try {
    await events.trackEvent({
      event_name: 'admin_media_uploaded',
      content_type: 'media_asset',
      content_id: asset.id,
      category: asset.category,
      hero_ids: asset.related_hero_ids || [],
      movie_ids: asset.related_movie_ids || [],
      metadata: {
        asset_id: asset.id,
        asset_type: asset.asset_type,
        category: asset.category,
        related_hero_ids: asset.related_hero_ids,
        related_movie_ids: asset.related_movie_ids,
        ...extra,
      },
    });
  } catch {
    /* non-blocking */
  }
}

async function createWallpaperFromAsset(asset, fields) {
  const heroId = parseUuidList(asset.related_hero_ids)[0] || fields.related_hero_id || null;
  const movieId = parseUuidList(asset.related_movie_ids)[0] || fields.related_movie_id || null;
  const { rows } = await db.query(
    `INSERT INTO wallpapers (
      title, slug, category, hero_id, movie_id, image_url, thumbnail_url, tags, is_active, is_trending
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,TRUE,FALSE) RETURNING *`,
    [
      asset.name,
      asset.slug,
      asset.category || 'GENERAL',
      heroId,
      movieId,
      asset.image_url,
      asset.thumbnail_url,
      JSON.stringify(asset.tags || []),
    ]
  );
  await syncWallpaperFeatures(rows[0].id);
  return rows[0];
}

async function createStatusCardFromAsset(asset, fields) {
  const heroId = parseUuidList(asset.related_hero_ids)[0] || null;
  const movieId = parseUuidList(asset.related_movie_ids)[0] || null;
  const customizable = fields.customizable !== 'false';
  const { rows } = await db.query(
    `INSERT INTO status_cards (
      title, slug, category, hero_id, movie_id, image_url, thumbnail_url, template_url, tags, is_active, customizable
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,TRUE,$10) RETURNING *`,
    [
      asset.name,
      asset.slug,
      asset.category || 'GENERAL',
      heroId,
      movieId,
      asset.image_url,
      asset.thumbnail_url,
      asset.image_url,
      JSON.stringify(asset.tags || []),
      customizable,
    ]
  );
  await syncStatusCardFeatures(rows[0].id);
  return rows[0];
}

async function createUpdateFromFields(fields, imageUrl) {
  const { title, short_summary, full_summary, category, status } = fields;
  if (!title || !short_summary || !full_summary || !category || !status) {
    return null;
  }
  const heroIds = parseUuidList(fields.related_hero_id || fields.related_hero_ids);
  const movieIds = parseUuidList(fields.related_movie_id || fields.related_movie_ids);
  const { rows } = await db.query(
    `INSERT INTO tfi_updates (
      title, summary, short_summary, full_summary, body, category, trust_status, priority,
      image_url, tags, hero_id, movie_id, is_active
    ) VALUES ($1,$2,$3,$4,$4,$5,$6,$7,$8,$9,$10,$11,TRUE) RETURNING *`,
    [
      title,
      short_summary,
      short_summary,
      full_summary,
      category.toLowerCase(),
      status.toLowerCase(),
      (fields.priority || 'normal').toLowerCase(),
      imageUrl,
      JSON.stringify(parseTags(fields.tags)),
      heroIds[0] || null,
      movieIds[0] || null,
    ]
  );
  const update = rows[0];
  for (const hid of heroIds) {
    await db.query('INSERT INTO update_heroes (update_id, hero_id) VALUES ($1,$2) ON CONFLICT DO NOTHING', [update.id, hid]);
  }
  for (const mid of movieIds) {
    await db.query('INSERT INTO update_movies (update_id, movie_id) VALUES ($1,$2) ON CONFLICT DO NOTHING', [update.id, mid]);
  }
  await syncUpdateFeatures(update.id);
  return update;
}

async function maybeCreateRecord(asset, fields) {
  const createRecord = fields.create_record === 'true' || fields.create_record === true;
  if (!createRecord) return { created_record: null };

  switch (asset.asset_type) {
    case 'WALLPAPER': {
      const w = await createWallpaperFromAsset(asset, fields);
      return { created_record: { type: 'wallpaper', id: w.id, entity: w } };
    }
    case 'STATUS_CARD': {
      const c = await createStatusCardFromAsset(asset, fields);
      return { created_record: { type: 'status_card', id: c.id, entity: c } };
    }
    case 'TFI_UPDATE': {
      const u = await createUpdateFromFields(fields, asset.image_url);
      if (u) return { created_record: { type: 'update', id: u.id, entity: u } };
      return { created_record: null, message: 'Update not created — provide title, short_summary, full_summary, category, status' };
    }
    case 'MOVIE_POSTER': {
      const entityId = fields.entity_id;
      if (entityId) {
        const attached = await attachAssetToEntity(asset, {
          entity_type: 'MOVIE',
          entity_id: entityId,
          field: 'poster_url',
        });
        return { created_record: null, attached };
      }
      return { created_record: null };
    }
    case 'HERO_AVATAR': {
      const entityId = fields.entity_id;
      if (entityId) {
        const attached = await attachAssetToEntity(asset, {
          entity_type: 'HERO',
          entity_id: entityId,
          field: 'avatar_url',
        });
        return { created_record: null, attached };
      }
      return { created_record: null };
    }
    default:
      return { created_record: null };
  }
}

async function maybeAttach(asset, fields) {
  const attach = fields.attach_to_entity === 'true' || fields.attach_to_entity === true;
  if (!attach && !fields.entity_type) return null;
  const entityType = fields.entity_type;
  const entityId = fields.entity_id;
  const field = fields.entity_field || fields.field || 'image_url';
  if (!entityType || !entityId) return null;
  return attachAssetToEntity(asset, {
    entity_type: entityType,
    entity_id: entityId,
    field,
  });
}

async function uploadFromFile(file, fields) {
  if (!file) throw new AppError('Image file required', 400, 'MISSING_FILE');
  if (isSuspiciousFilename(file.originalname)) {
    throw new AppError('Invalid filename', 400, 'INVALID_FILENAME');
  }
  if (!VALID_ASSET_TYPES.has(fields.asset_type)) {
    throw new AppError('Invalid asset_type', 400, 'INVALID_ASSET_TYPE');
  }
  if (!fields.name) throw new AppError('name is required', 400);

  const buffer = file.buffer || (file.path ? fs.readFileSync(file.path) : null);
  const stored = await storeImageBuffers({
    buffer,
    originalName: file.originalname,
    assetType: fields.asset_type,
  });
  if (file.path) {
    try { fs.unlinkSync(file.path); } catch { /* ignore */ }
  }

  const payload = buildAssetPayload(fields, stored);
  const asset = await insertAsset(payload);
  await syncMediaAssetFeatures(asset.id);

  const createResult = await maybeCreateRecord(asset, fields);
  const attachResult = await maybeAttach(asset, fields);

  await trackAdminUpload(asset, {
    created_record: !!createResult?.created_record,
    attached_entity: !!attachResult,
  });

  return {
    asset,
    image_url: asset.image_url,
    thumbnail_url: asset.thumbnail_url,
    ...createResult,
    attached: attachResult,
  };
}

async function uploadFromUrl(body) {
  const {
    name,
    image_url: imageUrl,
    asset_type: assetType,
    save_remote_copy: saveRemoteCopy = true,
  } = body;

  if (!name || !imageUrl || !assetType) {
    throw new AppError('name, image_url, and asset_type are required', 400);
  }
  if (!VALID_ASSET_TYPES.has(assetType)) {
    throw new AppError('Invalid asset_type', 400);
  }

  validateHttpUrl(imageUrl);

  let stored;
  let storageProvider = 'EXTERNAL';
  let storagePath = null;

  if (saveRemoteCopy !== false && saveRemoteCopy !== 'false') {
    const { buffer, mimeType } = await fetchRemoteImage(imageUrl, {
      maxBytes: env.UPLOAD_MAX_BYTES,
      timeoutMs: env.REMOTE_IMAGE_TIMEOUT_MS,
    });
    stored = await storeImageBuffers({
      buffer,
      originalName: path.basename(new URL(imageUrl).pathname) || 'remote.jpg',
      assetType,
    });
    storageProvider = stored.storage_provider;
    storagePath = stored.storage_path;
  } else {
    stored = {
      image_url: imageUrl,
      thumbnail_url: imageUrl,
      storage_path: null,
      storage_provider: 'EXTERNAL',
      mime_type: null,
      extension: null,
      size_bytes: null,
      width: null,
      height: null,
    };
    storageProvider = 'EXTERNAL';
  }

  const payload = buildAssetPayload(
    { ...body, asset_type: assetType, external_url: imageUrl },
    { ...stored, storage_provider: storageProvider, storage_path: storagePath }
  );
  payload.external_url = imageUrl;
  if (storageProvider === 'EXTERNAL' && !storagePath) {
    payload.storage_path = null;
  }

  const asset = await insertAsset(payload);
  await syncMediaAssetFeatures(asset.id);

  const createResult = await maybeCreateRecord(asset, body);
  const attachResult = await maybeAttach(asset, body);

  await trackAdminUpload(asset, { from_url: true, save_remote_copy: !!storagePath });

  return {
    asset,
    image_url: asset.image_url,
    thumbnail_url: asset.thumbnail_url,
    ...createResult,
    attached: attachResult,
  };
}

async function listAssets(query) {
  const {
    asset_type,
    category,
    hero_id,
    movie_id,
    q,
    is_active,
    page = 1,
    limit = 30,
  } = query;
  const conditions = ['1=1'];
  const params = [];
  let i = 1;

  if (asset_type) {
    conditions.push(`asset_type = $${i++}`);
    params.push(asset_type);
  }
  if (category) {
    conditions.push(`category = $${i++}`);
    params.push(category);
  }
  if (is_active !== undefined && is_active !== '') {
    conditions.push(`is_active = $${i++}`);
    params.push(is_active === 'true' || is_active === true);
  }
  if (hero_id) {
    conditions.push(`related_hero_ids @> $${i++}::jsonb`);
    params.push(JSON.stringify([hero_id]));
  }
  if (movie_id) {
    conditions.push(`related_movie_ids @> $${i++}::jsonb`);
    params.push(JSON.stringify([movie_id]));
  }
  if (q) {
    conditions.push(`(name ILIKE $${i} OR slug ILIKE $${i} OR tags::text ILIKE $${i})`);
    params.push(`%${q}%`);
    i += 1;
  }

  const offset = (Math.max(1, Number(page)) - 1) * Math.min(100, Number(limit) || 30);
  const lim = Math.min(100, Math.max(1, Number(limit) || 30));

  const { rows } = await db.query(
    `SELECT * FROM media_assets WHERE ${conditions.join(' AND ')}
     ORDER BY created_at DESC LIMIT $${i++} OFFSET $${i}`,
    [...params, lim, offset]
  );

  const { rows: countRows } = await db.query(
    `SELECT COUNT(*)::int as total FROM media_assets WHERE ${conditions.join(' AND ')}`,
    params
  );

  return {
    items: rows.map(formatAsset),
    page: Number(page) || 1,
    limit: lim,
    total: countRows[0]?.total || 0,
  };
}

async function getAsset(id) {
  const { rows } = await db.query('SELECT * FROM media_assets WHERE id = $1', [id]);
  if (!rows.length) throw new AppError('Asset not found', 404);
  return formatAsset(rows[0]);
}

async function patchAsset(id, body) {
  const allowed = [
    'name', 'description', 'category', 'usage', 'alt_text',
    'is_public', 'is_active', 'priority', 'language', 'content_type',
  ];
  const sets = [];
  const vals = [];
  let i = 1;

  for (const f of allowed) {
    if (body[f] !== undefined) {
      sets.push(`${f} = $${i++}`);
      if (f === 'is_public' || f === 'is_active') vals.push(!!body[f]);
      else if (f === 'priority' || f === 'language') vals.push(String(body[f]).toUpperCase());
      else vals.push(body[f]);
    }
  }
  if (body.tags !== undefined) {
    sets.push(`tags = $${i++}`);
    vals.push(JSON.stringify(parseTags(body.tags)));
  }
  if (body.related_hero_ids !== undefined) {
    sets.push(`related_hero_ids = $${i++}`);
    vals.push(JSON.stringify(parseUuidList(body.related_hero_ids)));
  }
  if (body.related_movie_ids !== undefined) {
    sets.push(`related_movie_ids = $${i++}`);
    vals.push(JSON.stringify(parseUuidList(body.related_movie_ids)));
  }
  if (!sets.length) throw new AppError('No fields to update', 400);

  sets.push('updated_at = NOW()');
  vals.push(id);
  const { rows } = await db.query(
    `UPDATE media_assets SET ${sets.join(', ')} WHERE id = $${i} RETURNING *`,
    vals
  );
  if (!rows.length) throw new AppError('Asset not found', 404);
  const asset = formatAsset(rows[0]);
  await syncMediaAssetFeatures(asset.id);
  return asset;
}

async function deleteAsset(id, { force = false } = {}) {
  const asset = await getAsset(id);
  await db.query('UPDATE media_assets SET is_active = FALSE, updated_at = NOW() WHERE id = $1', [id]);

  if (force && asset.storage_path && asset.storage_provider === 'LOCAL') {
    const storage = getStorageService();
    await storage.deleteImage(asset.storage_path);
    if (asset.thumbnail_url && asset.thumbnail_url !== asset.image_url) {
      const thumbPath = asset.thumbnail_url.split('/uploads/')[1];
      if (thumbPath) await storage.deleteImage(thumbPath);
    }
  }

  return { deleted: true, soft: !force, asset_id: id };
}

async function attachById(assetId, body) {
  const asset = await getAsset(assetId);
  const result = await attachAssetToEntity(asset, body);
  await syncMediaAssetFeatures(assetId);
  return { asset, ...result };
}

module.exports = {
  uploadFromFile,
  uploadFromUrl,
  listAssets,
  getAsset,
  patchAsset,
  deleteAsset,
  attachById,
  VALID_ASSET_TYPES,
};
