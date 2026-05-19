#!/usr/bin/env node
/**
 * Dev API smoke test — run: node scripts/smoke-test.js
 * Requires: server on PORT 3001, migrated DB, OTP_BYPASS_CODE=123456
 */
const http = require('http');

const BASE = process.env.API_BASE || 'http://localhost:3001';
const PHONE = `98765${String(Date.now()).slice(-5)}`;

const results = [];

function req(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const url = new URL(`${BASE}${path}`);
    const opts = {
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname + url.search,
      method,
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    };
    const r = http.request(opts, (res) => {
      let data = '';
      res.on('data', (c) => { data += c; });
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: data ? JSON.parse(data) : {} });
        } catch {
          resolve({ status: res.statusCode, body: { raw: data } });
        }
      });
    });
    r.on('error', reject);
    if (payload) r.write(payload);
    r.end();
  });
}

function pass(name) {
  results.push({ name, ok: true });
  console.log(`✅ ${name}`);
}
function fail(name, detail) {
  results.push({ name, ok: false, detail });
  console.log(`❌ ${name}: ${detail}`);
}

async function main() {
  console.log(`\nTFI Bagundali smoke test → ${BASE}\n`);

  try {
    const health = await req('GET', '/health');
    if (health.body.success) pass('GET /health');
    else fail('GET /health', JSON.stringify(health.body));

    await req('POST', '/v1/auth/otp/send', { phone: PHONE });
    const auth = await req('POST', '/v1/auth/otp/verify', { phone: PHONE, code: '123456' });
    if (!auth.body.success || !auth.body.data?.accessToken) {
      fail('POST /v1/auth/otp/verify', JSON.stringify(auth.body));
      process.exit(1);
    }
    pass('POST /v1/auth/otp/verify (accessToken, needsOnboarding)');
    const token = auth.body.data.accessToken;
    const refresh = auth.body.data.refreshToken;

    const home = await req('GET', '/v1/home/feed', null, token);
    if (home.body.success && Array.isArray(home.body.data?.sections) && home.body.data.sections.length) {
      pass('GET /v1/home/feed (sections)');
    } else fail('GET /v1/home/feed', JSON.stringify(home.body).slice(0, 120));

    const updates = await req('GET', '/v1/updates?limit=3', null, token);
    if (updates.body.success && updates.body.data?.items?.length) {
      pass('GET /v1/updates (items)');
    } else fail('GET /v1/updates', JSON.stringify(updates.body).slice(0, 120));

    const updateId = updates.body.data?.items?.[0]?.id;
    if (updateId) {
      const detail = await req('GET', `/v1/updates/${updateId}`, null, token);
      if (detail.body.success && detail.body.data?.update) pass('GET /v1/updates/:id');
      else fail('GET /v1/updates/:id', JSON.stringify(detail.body).slice(0, 120));

      await req('POST', `/v1/updates/${updateId}/view`, {}, token);
      pass('POST /v1/updates/:id/view');

      const react = await req('POST', `/v1/updates/${updateId}/react`, { reaction: 'FIRE' }, token);
      if (react.body.success) pass('POST /v1/updates/:id/react');
      else fail('POST /v1/updates/:id/react', JSON.stringify(react.body.error));
    }

    const wallpapers = await req('GET', '/v1/wallpapers');
    if (wallpapers.body.success && wallpapers.body.data?.length) {
      pass('GET /v1/wallpapers');
      const wid = wallpapers.body.data[0].id;
      const dl = await req('POST', `/v1/wallpapers/${wid}/download`, {}, token);
      if (dl.body.success) pass('POST /v1/wallpapers/:id/download');
      else fail('POST /v1/wallpapers/:id/download', JSON.stringify(dl.body.error));
    } else fail('GET /v1/wallpapers', 'empty or error');

    const polls = await req('GET', '/v1/polls');
    if (polls.body.success && polls.body.data?.length) pass('GET /v1/polls');
    else fail('GET /v1/polls', 'empty');

    const quizHome = await req('GET', '/v1/quiz/home', null, token);
    if (quizHome.body.success) pass('GET /v1/quiz/home');
    else fail('GET /v1/quiz/home', JSON.stringify(quizHome.body.error));

    const profile = await req('GET', '/v1/profile', null, token);
    if (profile.body.success && profile.body.data?.id) pass('GET /v1/profile');
    else fail('GET /v1/profile', JSON.stringify(profile.body).slice(0, 80));

    const search = await req('GET', '/v1/search?q=peddi', null, token);
    if (search.body.success && search.body.data?.updates !== undefined) pass('GET /v1/search');
    else fail('GET /v1/search', JSON.stringify(search.body).slice(0, 80));

    const ev = await req('POST', '/v1/events', { event_name: 'app_opened', source_screen: 'smoke' }, token);
    if (ev.body.success) pass('POST /v1/events');
    else fail('POST /v1/events', JSON.stringify(ev.body.error));

    const ref = await req('POST', '/v1/auth/refresh', { refreshToken: refresh });
    if (ref.body.success && ref.body.data?.accessToken) pass('POST /v1/auth/refresh');
    else fail('POST /v1/auth/refresh', JSON.stringify(ref.body.error));

    const logout = await req('POST', '/v1/auth/logout', { refreshToken: refresh }, token);
    if (logout.body.success) pass('POST /v1/auth/logout');
    else fail('POST /v1/auth/logout', JSON.stringify(logout.body.error));
  } catch (e) {
    console.error('Fatal:', e.message);
    process.exit(1);
  }

  const failed = results.filter((r) => !r.ok);
  console.log(`\n${results.length - failed.length}/${results.length} passed`);
  if (failed.length) process.exit(1);
}

main();
