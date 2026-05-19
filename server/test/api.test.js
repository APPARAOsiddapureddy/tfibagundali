/**
 * Critical API tests — run: npm test
 * Requires PostgreSQL migrated + seeded.
 */
const { test, before } = require('node:test');
const assert = require('node:assert');
const request = require('http');

const BASE = process.env.API_BASE || 'http://localhost:3001';

function httpGet(path) {
  return new Promise((resolve, reject) => {
    request.get(`${BASE}${path}`, (res) => {
      let data = '';
      res.on('data', (c) => { data += c; });
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(data) }));
    }).on('error', reject);
  });
}

function httpPost(path, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(body);
    const url = new URL(`${BASE}${path}`);
    const req = request.request(
      { hostname: url.hostname, port: url.port, path: url.pathname, method: 'POST', headers: { 'Content-Type': 'application/json', ...headers } },
      (res) => {
        let data = '';
        res.on('data', (c) => { data += c; });
        res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(data) }));
      }
    );
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

before(async () => {
  const h = await httpGet('/health');
  if (h.status !== 200) throw new Error('Server not running on ' + BASE);
});

test('health returns ok', async () => {
  const { body } = await httpGet('/health');
  assert.equal(body.success, true);
});

test('OTP send accepts phone only (no region)', async () => {
  const { status, body } = await httpPost('/v1/auth/otp/send', { phone: '9876543291' });
  assert.equal(status, 200);
  assert.equal(body.success, true);
});

test('OTP verify returns tokens and user', async () => {
  const { body } = await httpPost('/v1/auth/otp/verify', { phone: '9876543291', code: '123456' });
  assert.equal(body.success, true);
  assert.ok(body.data.accessToken);
  assert.ok(body.data.refreshToken);
  assert.ok(body.data.user);
  assert.ok('needsOnboarding' in body.data);
});

test('home feed is sectioned', async () => {
  const { body } = await httpGet('/v1/home/feed');
  assert.equal(body.success, true);
  assert.ok(Array.isArray(body.data.sections));
  assert.ok(body.data.sections.length > 0);
});

test('wallpapers are free', async () => {
  const { body } = await httpGet('/v1/wallpapers');
  assert.equal(body.success, true);
  if (body.data.length) {
    assert.equal(body.data[0].is_free, true);
    assert.notEqual(body.data[0].premium_only, true);
  }
});

test('updates list returns items', async () => {
  const { body } = await httpGet('/v1/updates?limit=5');
  assert.equal(body.success, true);
  assert.ok(body.data.items);
});
