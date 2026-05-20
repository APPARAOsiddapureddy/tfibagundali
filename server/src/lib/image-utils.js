const path = require('path');
const crypto = require('crypto');

const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);
const ALLOWED_EXT = new Set(['.jpg', '.jpeg', '.png', '.webp']);

const ASSET_FOLDER_MAP = {
  TFI_UPDATE: 'updates',
  MOVIE_POSTER: 'movies',
  HERO_AVATAR: 'heroes',
  WALLPAPER: 'wallpapers',
  STATUS_CARD: 'status-cards',
  POLL_IMAGE: 'polls',
  QUIZ_IMAGE: 'quiz',
  TIMELINE_IMAGE: 'timeline',
  NOTIFICATION_IMAGE: 'notifications',
  GENERAL: 'thumbnails',
};

const THUMB_FOLDER = 'thumbnails';

function parseTags(input) {
  if (!input) return [];
  if (Array.isArray(input)) return input.map((t) => String(t).trim().toLowerCase()).filter(Boolean);
  return String(input)
    .split(',')
    .map((t) => t.trim().toLowerCase())
    .filter(Boolean);
}

function parseUuidList(input) {
  if (!input) return [];
  if (Array.isArray(input)) return input.filter(Boolean);
  const s = String(input).trim();
  if (!s) return [];
  try {
    const parsed = JSON.parse(s);
    if (Array.isArray(parsed)) return parsed;
  } catch (_) { /* comma-separated */ }
  return s.split(',').map((x) => x.trim()).filter(Boolean);
}

function sanitizeFilename(name, ext = '.webp') {
  const base = path.basename(name, path.extname(name));
  const cleaned = base
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80) || 'asset';
  const suffix = Date.now().toString(36);
  const hash = crypto.randomBytes(3).toString('hex');
  const safeExt = ALLOWED_EXT.has(ext.toLowerCase()) ? ext.toLowerCase() : '.webp';
  return `${cleaned}-${suffix}-${hash}${safeExt}`;
}

function folderForAssetType(assetType) {
  return ASSET_FOLDER_MAP[assetType] || 'thumbnails';
}

function extensionFromMime(mime) {
  if (mime === 'image/jpeg') return '.jpg';
  if (mime === 'image/png') return '.png';
  if (mime === 'image/webp') return '.webp';
  return '.jpg';
}

function isAllowedMime(mime) {
  return ALLOWED_MIME.has(mime);
}

function isAllowedExtension(filename) {
  return ALLOWED_EXT.has(path.extname(filename).toLowerCase());
}

function isSuspiciousFilename(filename) {
  const lower = filename.toLowerCase();
  if (lower.includes('..') || lower.includes('/') || lower.includes('\\')) return true;
  if (/\.(exe|sh|bat|cmd|php|js|html|svg)$/i.test(lower)) return true;
  return false;
}

function slugFromName(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 200);
}

module.exports = {
  ALLOWED_MIME,
  ALLOWED_EXT,
  ASSET_FOLDER_MAP,
  THUMB_FOLDER,
  parseTags,
  parseUuidList,
  sanitizeFilename,
  folderForAssetType,
  extensionFromMime,
  isAllowedMime,
  isAllowedExtension,
  isSuspiciousFilename,
  slugFromName,
};
