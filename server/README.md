# TFI Bagundali — API Server

Content-first Telugu cinema fan backend. **Free only** — no premium gating, no daily missions, no fan-army grind.

## Stack

- Node.js 20+ · Express · PostgreSQL · Zod validation
- Hybrid rule-based recommendations (`src/modules/recommendations/`)

## Quick start

```bash
cp ../.env.example .env   # set JWT secrets (32+ chars)
npm install
npm run migrate
npm run seed
npm run dev
```

API: http://localhost:3001/health

**Dev login:** phone `9876543291`, OTP `123456`

### Image uploads (admin)

- Local storage: `server/uploads/` served at `http://localhost:3001/uploads/...`
- Admin UI: http://localhost:3001/admin/upload
- Max file size: **5MB** · requires header `x-admin-key` (`ADMIN_API_KEY` in `.env`)
- Docs: [UPLOADS.md](./docs/UPLOADS.md)

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Nodemon server |
| `npm run migrate` | Apply SQL migrations |
| `npm run seed` | Dev sample data |
| `npm run db:reset` | Drop schema (dev only) |
| `npm test` | API tests (server must be running) |

## Docs

- [API.md](./docs/API.md) — route list
- [RECOMMENDATIONS.md](./docs/RECOMMENDATIONS.md) — scoring & personalization
- [UPLOADS.md](./docs/UPLOADS.md) — admin media upload & storage

## Architecture

```
src/
  modules/
    auth/          OTP, JWT, refresh, logout
    profile/       User profile & saved items
    updates/       TFI updates (core content)
    home/          Sectioned home feed
    recommendations/  Scoring, events, feeds
    movies/ heroes/ quiz/ polls/
    wallpapers/ status-cards/
    explore/ search/ reminders/ notifications/
    admin/         CMS (x-admin-key)
  middleware/    auth, admin, rate-limit, validate
  lib/           phone normalize, enums
migrations/      001 schema, 002 recommendations, 003 content-first
```

## Product rules (enforced in code)

- No premium-only content paths
- Wallpapers/cards always `is_free: true`
- Home feed is sectioned updates — not mission checklists
- Favourite hero optional; no region on login
- Fan army identity only — not recommendation-dominant
