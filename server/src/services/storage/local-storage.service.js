const fs = require('fs');
const path = require('path');

class LocalStorageService {
  constructor({ uploadDir, publicBaseUrl }) {
    this.uploadRoot = path.resolve(process.cwd(), uploadDir);
    this.publicBaseUrl = publicBaseUrl;
    this.provider = 'LOCAL';
  }

  ensureDir(relativeDir) {
    const dir = path.join(this.uploadRoot, relativeDir);
    fs.mkdirSync(dir, { recursive: true });
    return dir;
  }

  /**
   * @param {Buffer} buffer
   * @param {{ relativePath: string, mimeType?: string }} options
   */
  async uploadImage(buffer, options) {
    const { relativePath } = options;
    const safe = this._safeRelativePath(relativePath);
    const fullPath = path.join(this.uploadRoot, safe);
    const dir = path.dirname(fullPath);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(fullPath, buffer);
    return {
      storage_path: safe.replace(/\\/g, '/'),
      public_url: this.getPublicUrl(safe),
      provider: this.provider,
    };
  }

  getPublicUrl(relativePath) {
    const safe = this._safeRelativePath(relativePath);
    return `${this.publicBaseUrl}/uploads/${safe.replace(/\\/g, '/')}`;
  }

  /**
   * @param {string} storagePath - path relative to upload root (e.g. wallpapers/foo.webp)
   */
  async deleteImage(storagePath) {
    const safe = this._safeRelativePath(storagePath);
    const full = path.join(this.uploadRoot, safe);
    if (fs.existsSync(full)) {
      fs.unlinkSync(full);
      return true;
    }
    return false;
  }

  _safeRelativePath(relativePath) {
    const normalized = path.normalize(relativePath).replace(/^(\.\.(\/|\\|$))+/, '');
    if (normalized.includes('..')) {
      throw new Error('Invalid storage path');
    }
    return normalized;
  }
}

module.exports = LocalStorageService;
