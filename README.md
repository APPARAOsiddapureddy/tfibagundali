# TFI Bagundali

**Mana Cinema. Mana Updates. Mana Pride.**

Free Telugu cinema fan app — daily TFI updates, quizzes, share cards, fan army, and profile.

## Stack

| Path | Tech |
|------|------|
| `mobile/` | **Flutter** (iOS, Android, Web) — primary app |
| `server/` | Node.js + Express + PostgreSQL |

## Quick start

```bash
# Optional: Docker Postgres (start Docker Desktop first)
docker compose up -d

# Server — run each line separately (do not paste comment lines into terminal)
cd server
cp ../.env.example .env
npm install
npm run db:reset    # only if migrate fails (old database schema)
npm run migrate
npm run seed
npm run dev

# Flutter (new terminal)
cd mobile && flutter pub get && flutter run -d chrome
```

- **API:** http://localhost:3001  
- **Dev OTP:** `123456` (see [Testing login](#testing-login) below)

## Testing login

With the API running in **development** (`NODE_ENV=development` in `.env`):

| Step | What to do |
|------|------------|
| Phone | Any valid **10-digit** Indian number (e.g. `9876543291` — pre-filled in the Flutter login screen) |
| Send OTP | Tap **Send OTP** — no real SMS is sent |
| OTP | Enter **`123456`** (from `OTP_BYPASS_CODE` in `.env.example`) |
| Server log | Terminal running `npm run dev` prints `📱 OTP for +91…: 123456` |
| New user | After verify → pick a fan army → Home |
| Returning user | Same phone + `123456` → Home |

**Requirements:** PostgreSQL up, `npm run migrate` + `npm run seed`, JWT secrets set (256-bit strings in `.env`).

## Product

- **Tabs:** Home · Quiz · Share · Army · Profile  
- **Design:** Fire/gold cinema theme, 8 hero armies, missions, trust badges  
- **API:** Auth, home feed, quiz, polls, explore, profile (`/v1`)

See `mobile/README.md` for Flutter testing and platform API URLs.
