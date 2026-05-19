# TFI Bagundali API v2.1

Base URL: `http://localhost:3001`

All responses: `{ success, data?, error?, message? }`

## Auth (no region required)

| Method | Path | Body |
|--------|------|------|
| POST | `/v1/auth/otp/send` | `{ "phone": "9876543210" }` |
| POST | `/v1/auth/otp/verify` | `{ "phone": "9876543210", "code": "123456" }` |
| POST | `/v1/auth/refresh` | `{ "refreshToken": "..." }` |
| POST | `/v1/auth/logout` | `{ "refreshToken": "..." }` (Bearer) |

Verify response: `accessToken`, `refreshToken`, `user`, `isNewUser`, `needsOnboarding`

## Home (content-first, sectioned)

| GET | `/v1/home/feed` |

Sections: `today_in_tfi`, `breaking_updates`, `my_hero_updates`, `trending_updates`, `upcoming_releases`, `quiz_preview`, `poll_preview`, `explore_preview`, `movie_calendar`

## TFI Updates

| GET | `/v1/updates?category=&status=&hero_id=&movie_id=&sort=&page=&limit=` |
| GET | `/v1/updates/:id` |
| POST | `/v1/updates/:id/view` |
| POST | `/v1/updates/:id/react` | `{ "reaction": "FIRE" }` |
| POST | `/v1/updates/:id/save` |
| DELETE | `/v1/updates/:id/save` |
| POST | `/v1/updates/:id/share` |
| POST | `/v1/updates/:id/not-interested` |
| GET | `/v1/updates/:id/related` |

## Profile

| GET/PATCH | `/v1/profile` |
| POST | `/v1/profile/favourite-hero` | `{ "hero_id": "uuid" \| null }` |
| POST | `/v1/profile/fcm-token` |
| GET | `/v1/profile/saved` |
| GET | `/v1/profile/reminders` |
| GET | `/v1/profile/downloads` |
| GET | `/v1/profile/quiz-history` |

## Movies · Heroes · Quiz · Polls · Explore

See module routes in `src/app.js`. All wallpapers/status cards return `is_free: true`.

## Recommendations & Events

| GET | `/v1/recommendations/home` |
| POST | `/v1/events` | event tracking body |

## Admin (`x-admin-key` header)

| GET | `/v1/admin/stats` |
| CRUD | `/v1/admin/updates` … |

## Dev

- OTP bypass: `OTP_BYPASS_CODE=123456` in `.env`
- Admin: `ADMIN_API_KEY` in `.env`
