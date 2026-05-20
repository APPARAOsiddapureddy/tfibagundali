const sharp = require('sharp');
const { AppError } = require('../middleware/error.middleware');
const {
  isAllowedMime,
  extensionFromMime,
  sanitizeFilename,
} = require('./image-utils');

async function validateImageBuffer(buffer, { maxBytes, originalName }) {
  if (!buffer?.length) throw new AppError('Empty file', 400, 'EMPTY_FILE');
  if (buffer.length > maxBytes) throw new AppError('File too large (max 5MB)', 400, 'FILE_TOO_LARGE');

  let meta;
  try {
    meta = await sharp(buffer).metadata();
  } catch {
    throw new AppError('Invalid image file', 400, 'INVALID_IMAGE');
  }

  if (!meta.width || !meta.height || meta.width < 16 || meta.height < 16) {
    throw new AppError('Image dimensions too small', 400, 'INVALID_IMAGE');
  }

  const format = meta.format;
  const mimeMap = { jpeg: 'image/jpeg', png: 'image/png', webp: 'image/webp' };
  const mimeType = mimeMap[format];
  if (!mimeType || !isAllowedMime(mimeType)) {
    throw new AppError('Unsupported image format', 400, 'INVALID_FORMAT');
  }

  const ext = extensionFromMime(mimeType);
  const filename = sanitizeFilename(originalName || 'upload', ext);

  return {
    width: meta.width,
    height: meta.height,
    mimeType,
    format,
    filename,
    extension: ext,
  };
}

async function processMainImage(buffer, meta) {
  try {
    const out = await sharp(buffer)
      .rotate()
      .webp({ quality: 85 })
      .toBuffer();
    return {
      buffer: out,
      mimeType: 'image/webp',
      extension: '.webp',
      filename: meta.filename.replace(/\.[^.]+$/, '.webp'),
      width: meta.width,
      height: meta.height,
    };
  } catch {
    return {
      buffer,
      mimeType: meta.mimeType,
      extension: meta.extension,
      filename: meta.filename,
      width: meta.width,
      height: meta.height,
    };
  }
}

function thumbSizeForAssetType(assetType) {
  switch (assetType) {
    case 'MOVIE_POSTER':
      return { width: 300, height: 450, fit: 'cover' };
    case 'HERO_AVATAR':
      return { width: 300, height: 300, fit: 'cover' };
    case 'WALLPAPER':
    case 'STATUS_CARD':
      return { width: 300, height: 533, fit: 'cover' };
    case 'TFI_UPDATE':
    case 'POLL_IMAGE':
    case 'QUIZ_IMAGE':
    case 'NOTIFICATION_IMAGE':
    case 'TIMELINE_IMAGE':
      return { width: 320, height: 180, fit: 'cover' };
    default:
      return { width: 320, height: 320, fit: 'inside' };
  }
}

async function generateThumbnail(buffer, assetType, baseFilename) {
  const size = thumbSizeForAssetType(assetType);
  const thumbName = baseFilename.replace(/\.[^.]+$/, '-thumb.webp');
  try {
    const out = await sharp(buffer)
      .rotate()
      .resize(size.width, size.height, { fit: size.fit, withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer();
    return { buffer: out, filename: thumbName, mimeType: 'image/webp' };
  } catch {
    return null;
  }
}

module.exports = {
  validateImageBuffer,
  processMainImage,
  generateThumbnail,
};
