const express = require('express');
const { AppError } = require('../../middleware/error.middleware');

const router = express.Router();

const ALLOWED_IMAGE_HOSTS = new Set([
  'commons.wikimedia.org',
  'upload.wikimedia.org',
]);

router.get('/image', async (req, res, next) => {
  try {
    const rawUrl = req.query.url;
    if (!rawUrl || typeof rawUrl !== 'string') {
      throw new AppError('Image URL is required', 400, 'VALIDATION_ERROR');
    }

    let url;
    try {
      url = new URL(rawUrl);
    } catch {
      throw new AppError('Invalid image URL', 400, 'VALIDATION_ERROR');
    }

    if (url.protocol !== 'https:' || !ALLOWED_IMAGE_HOSTS.has(url.hostname)) {
      throw new AppError('Image host is not allowed', 400, 'VALIDATION_ERROR');
    }

    const upstream = await fetch(url, {
      redirect: 'follow',
      signal: AbortSignal.timeout(10000),
      headers: {
        'User-Agent': 'TFI-Bagundali/2.1 image proxy',
      },
    });

    if (!upstream.ok) {
      throw new AppError('Image could not be fetched', 502, 'IMAGE_FETCH_FAILED');
    }

    const contentType = upstream.headers.get('content-type') || '';
    if (!contentType.startsWith('image/')) {
      throw new AppError('URL did not return an image', 400, 'VALIDATION_ERROR');
    }

    const bytes = Buffer.from(await upstream.arrayBuffer());
    res.set({
      'Content-Type': contentType,
      'Cache-Control': 'public, max-age=86400',
      'X-Content-Type-Options': 'nosniff',
    });
    res.send(bytes);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
