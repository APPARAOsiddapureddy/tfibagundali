const env = require('../../config/env');
const LocalStorageService = require('./local-storage.service');

/**
 * Storage abstraction — swap LocalStorageService for S3/Cloudinary/Supabase later.
 * @see server/docs/UPLOADS.md
 */
function getStorageService() {
  // TODO: production — AWS S3 + CloudFront, Cloudinary, Firebase, or Supabase Storage
  const provider = process.env.STORAGE_PROVIDER || 'local';
  if (provider === 'local') {
    return new LocalStorageService({
      uploadDir: env.UPLOAD_DIR,
      publicBaseUrl: env.PUBLIC_BASE_URL.replace(/\/$/, ''),
    });
  }
  throw new Error(`Unsupported STORAGE_PROVIDER: ${provider}`);
}

module.exports = { getStorageService };
