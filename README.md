# TFI Bagundali

Telugu-first fan engagement stack: **Node.js** API, **Vite + React** web client, and **Docker** for local infra.

**Repository:** [github.com/APPARAOsiddapureddy/tfibagundali](https://github.com/APPARAOsiddapureddy/tfibagundali)

---

## Repository layout

| Path | Description |
|------|-------------|
| `server/` | Express API, PostgreSQL migrations, Redis, jobs. |
| `client/` | Vite + React web UI. |
| `docker-compose.yml` | Postgres, Redis, API wiring for local dev. |
| `start.sh` | Helper script to bring services up. |

---

## Prerequisites

- **Node.js** 18+ (for `server/` and `client/`)
- **PostgreSQL** & **Redis** (or use Docker Compose)

---

## Quick start

### Backend (API)

```bash
cd server
cp .env.example .env   # edit DATABASE_URL, JWT secrets, etc.
npm install
node src/server.js     # or npm start — see server/package.json
```

Default API port is often **3001** (see `server` config / `.env`).

### Web client

```bash
cd client
npm install
npm run dev
```

### Docker (full stack)

From repo root:

```bash
docker compose up -d
```

Adjust services per `docker-compose.yml` and your `.env` files.

---

## Configuration & secrets

- **Never commit** `.env` files. Root `.gitignore` excludes them.
- Copy **`.env.example`** (where present) and fill in DB, JWT, SMS, S3, etc.

---

## Git branches

Default branch: **`main`**.

```bash
git add -A
git commit -m "Your message"
git push origin main
```

---

## License

Proprietary / internal unless you add an explicit OSS license.
