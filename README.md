# TFI Bagundali

Telugu-first fan engagement stack: **Flutter** mobile app, **Node.js** API, optional **Vite** web client, and **Docker** for local infra.

**Repository:** [github.com/APPARAOsiddapureddy/tfibagundali](https://github.com/APPARAOsiddapureddy/tfibagundali)

---

## Repository layout

| Path | Description |
|------|-------------|
| `tfi_bagundali/` | Flutter app (Android + iOS). Main production client. |
| `server/` | Express API, PostgreSQL migrations, Redis, jobs. |
| `client/` | Legacy Vite + React web UI (optional). |
| `docker-compose.yml` | Postgres, Redis, API wiring for local dev. |
| `start.sh` | Helper script to bring services up. |

---

## Prerequisites

- **Flutter** SDK (stable), **Dart** 3.3+
- **Node.js** 18+ (for `server/` and `client/`)
- **PostgreSQL** & **Redis** (or use Docker Compose)
- **CocoaPods** (`pod`) for iOS builds

---

## Quick start

### Backend (API)

```bash
cd server
cp .env.example .env   # edit DATABASE_URL, JWT secrets, etc.
npm install
npm run migrate         # if your package exposes it — see server/package.json
node src/server.js      # or npm start — per your scripts
```

Default API port in server config is often **3001**; the Flutter dev config points `10.0.2.2:3001` (Android emulator → host).

### Flutter app

```bash
cd tfi_bagundali
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after model/codegen changes
flutter run
```

Use `--dart-define=ENV=development|staging|production` and optional `--dart-define=API_URL=https://your-api/v1` as needed.

See **`tfi_bagundali/README.md`** for app-specific notes.

### Docker (full stack)

From repo root:

```bash
docker compose up -d
```

Adjust services per `docker-compose.yml` and your `.env` files.

---

## Configuration & secrets

- **Never commit** `.env` files. Root `.gitignore` excludes them.
- Copy **`.env.example`** (where present) and fill in DB, JWT, SMS, S3, Firebase keys.
- Add **`google-services.json`** (Android) and **`GoogleService-Info.plist`** (iOS) from Firebase locally; do not commit real secrets in public repos if the repo is public.

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
