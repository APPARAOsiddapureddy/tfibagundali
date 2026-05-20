const dns = require('dns').promises;
const net = require('net');
const { AppError } = require('../middleware/error.middleware');

function isPrivateIp(ip) {
  if (net.isIPv4(ip)) {
    const parts = ip.split('.').map(Number);
    if (parts[0] === 10) return true;
    if (parts[0] === 127) return true;
    if (parts[0] === 169 && parts[1] === 254) return true;
    if (parts[0] === 172 && parts[1] >= 16 && parts[1] <= 31) return true;
    if (parts[0] === 192 && parts[1] === 168) return true;
    if (parts[0] === 0) return true;
  }
  if (net.isIPv6(ip)) {
    const n = ip.toLowerCase();
    if (n === '::1' || n.startsWith('fc') || n.startsWith('fd') || n.startsWith('fe80')) return true;
  }
  return false;
}

function validateHttpUrl(urlString) {
  let parsed;
  try {
    parsed = new URL(urlString);
  } catch {
    throw new AppError('Invalid image URL', 400, 'INVALID_URL');
  }
  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new AppError('URL must use http or https', 400, 'INVALID_URL');
  }
  const host = parsed.hostname.toLowerCase();
  if (host === 'localhost' || host.endsWith('.localhost') || host === '127.0.0.1' || host === '0.0.0.0') {
    throw new AppError('URL host not allowed', 400, 'INVALID_URL');
  }
  return parsed;
}

async function assertSafeRemoteHost(hostname) {
  const host = hostname.toLowerCase();
  if (host === 'localhost' || host.endsWith('.localhost')) {
    throw new AppError('URL host not allowed', 400, 'INVALID_URL');
  }
  const addresses = await dns.lookup(host, { all: true });
  for (const { address } of addresses) {
    if (isPrivateIp(address)) {
      throw new AppError('URL resolves to private network', 400, 'INVALID_URL');
    }
  }
}

/**
 * Download remote image with SSRF protections.
 */
async function fetchRemoteImage(urlString, { maxBytes, timeoutMs }) {
  const parsed = validateHttpUrl(urlString);
  await assertSafeRemoteHost(parsed.hostname);

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const res = await fetch(urlString, {
      signal: controller.signal,
      redirect: 'follow',
      headers: { 'User-Agent': 'TFI-Bagundali-Admin/1.0' },
    });

    if (!res.ok) {
      throw new AppError('Failed to download image', 400, 'DOWNLOAD_FAILED');
    }

    const contentType = (res.headers.get('content-type') || '').split(';')[0].trim().toLowerCase();
    if (!contentType.startsWith('image/')) {
      throw new AppError('Remote URL is not an image', 400, 'INVALID_CONTENT');
    }

    const contentLength = Number(res.headers.get('content-length') || 0);
    if (contentLength > maxBytes) {
      throw new AppError('Remote image too large', 400, 'FILE_TOO_LARGE');
    }

    const buffer = Buffer.from(await res.arrayBuffer());
    if (!buffer.length) throw new AppError('Empty remote image', 400, 'EMPTY_FILE');
    if (buffer.length > maxBytes) throw new AppError('Remote image too large', 400, 'FILE_TOO_LARGE');

    return { buffer, mimeType: contentType };
  } catch (e) {
    if (e.name === 'AbortError') {
      throw new AppError('Remote download timed out', 408, 'TIMEOUT');
    }
    if (e instanceof AppError) throw e;
    throw new AppError('Failed to download image', 400, 'DOWNLOAD_FAILED');
  } finally {
    clearTimeout(timer);
  }
}

module.exports = { validateHttpUrl, fetchRemoteImage, isPrivateIp };
