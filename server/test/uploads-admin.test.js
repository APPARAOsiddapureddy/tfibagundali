/**
 * Admin upload API tests — requires migrated DB, seeded data, running server.
 * Run: ADMIN_API_KEY=dev_admin_key_change_me npm test
 */
const { test, before } = require('node:test');
const assert = require('node:assert');
const http = require('http');
const fs = require('fs');
const path = require('path');

const BASE = process.env.API_BASE || 'http://localhost:3001';
const ADMIN_KEY = process.env.ADMIN_API_KEY || 'dev_admin_key_change_me';

function httpRequest(method, urlPath, { headers = {}, body } = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(`${BASE}${urlPath}`);
    const opts = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method,
      headers,
    };
    const req = http.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => { data += c; });
      res.on('end', () => {
        let parsed = {};
        try { parsed = JSON.parse(data); } catch { parsed = { raw: data }; }
        resolve({ status: res.statusCode, body: parsed });
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

function buildMultipart(fields, fileField, fileBuffer, filename, mime) {
  const boundary = '----tfi' + Date.now();
  const parts = [];
  for (const [k, v] of Object.entries(fields)) {
    parts.push(
      `--${boundary}\r\nContent-Disposition: form-data; name="${k}"\r\n\r\n${v}\r\n`
    );
  }
  parts.push(
    `--${boundary}\r\nContent-Disposition: form-data; name="${fileField}"; filename="${filename}"\r\nContent-Type: ${mime}\r\n\r\n`
  );
  const tail = `\r\n--${boundary}--\r\n`;
  const header = Buffer.from(parts.join(''));
  const footer = Buffer.from(tail);
  return {
    boundary,
    buffer: Buffer.concat([header, fileBuffer, footer]),
  };
}

// 64x64 PNG (valid dimensions for sharp validation)
const TINY_PNG = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAPoAAAD6AG1e1JrAAAAn0lEQVR4nO2SUQkAQBSDlsn+ARbrQtyHPBgsgMpSOL3oBJ0AesXuQtxddIJOAL1idyHuLjpBJ4BesbsQdxedoBNAr9hdiLuLTtAJoFfsLsTdRSfoBNArdhfi7qITdALoFbsLcXfRCToB9Irdhbi76ASdAHrF7kLcXXSCTgC9Ynch7i46QSeAXrG7EHcXnaATQK/YXYi7i07QCaBX/LnQAxOEwQ/kMKY5AAAAAElFTkSuQmCC',
  'base64'
);

before(async () => {
  const h = await httpRequest('GET', '/health');
  if (h.status !== 200) throw new Error('Server not running on ' + BASE);
});

test('reject upload without admin key', async () => {
  const { boundary, buffer } = buildMultipart(
    { name: 'Test', asset_type: 'GENERAL' },
    'image',
    TINY_PNG,
    't.png',
    'image/png'
  );
  const { status } = await httpRequest('POST', '/v1/admin/uploads/image', {
    headers: { 'Content-Type': `multipart/form-data; boundary=${boundary}` },
    body: buffer,
  });
  assert.equal(status, 403);
});

test('reject missing file with admin key', async () => {
  const { status } = await httpRequest('POST', '/v1/admin/uploads/image', {
    headers: { 'x-admin-key': ADMIN_KEY, 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'x', asset_type: 'GENERAL' }),
  });
  assert.ok(status === 400 || status === 500);
});

test('upload valid png with metadata', async () => {
  const { boundary, buffer } = buildMultipart(
    {
      name: 'Test Upload Asset',
      asset_type: 'GENERAL',
      category: 'TEST',
      tags: 'test,upload',
      is_public: 'true',
      is_active: 'true',
    },
    'image',
    TINY_PNG,
    'test.png',
    'image/png'
  );
  const { status, body } = await httpRequest('POST', '/v1/admin/uploads/image', {
    headers: {
      'x-admin-key': ADMIN_KEY,
      'Content-Type': `multipart/form-data; boundary=${boundary}`,
    },
    body: buffer,
  });
  assert.equal(status, 201, JSON.stringify(body));
  assert.equal(body.success, true);
  assert.ok(body.data.image_url);
  assert.ok(body.data.asset?.id);
});

test('list uploads with admin key', async () => {
  const { status, body } = await httpRequest('GET', '/v1/admin/uploads?limit=5', {
    headers: { 'x-admin-key': ADMIN_KEY },
  });
  assert.equal(status, 200);
  assert.ok(Array.isArray(body.data.items));
});

test('reject from-url without https', async () => {
  const { status } = await httpRequest('POST', '/v1/admin/uploads/from-url', {
    headers: { 'x-admin-key': ADMIN_KEY, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: 'Bad',
      image_url: 'ftp://example.com/x.jpg',
      asset_type: 'GENERAL',
    }),
  });
  assert.equal(status, 400);
});
