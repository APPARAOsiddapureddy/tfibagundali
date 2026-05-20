const { test } = require('node:test');
const assert = require('node:assert');
const {
  sanitizeFilename,
  parseTags,
  isAllowedMime,
  isSuspiciousFilename,
  folderForAssetType,
} = require('../src/lib/image-utils');

test('sanitizeFilename lowercases and hyphenates', () => {
  const name = sanitizeFilename('Peddi Release Countdown Card.png', '.png');
  assert.match(name, /^peddi-release-countdown-card-/);
  assert.ok(name.endsWith('.png'));
});

test('parseTags splits comma string', () => {
  assert.deepEqual(parseTags('peddi, ram charan, countdown'), ['peddi', 'ram charan', 'countdown']);
});

test('isAllowedMime accepts webp jpeg png', () => {
  assert.equal(isAllowedMime('image/webp'), true);
  assert.equal(isAllowedMime('application/pdf'), false);
});

test('isSuspiciousFilename blocks path traversal', () => {
  assert.equal(isSuspiciousFilename('../etc/passwd'), true);
  assert.equal(isSuspiciousFilename('safe-name.jpg'), false);
});

test('folderForAssetType maps wallpaper folder', () => {
  assert.equal(folderForAssetType('WALLPAPER'), 'wallpapers');
});
