# Admin image uploads & media assets

TFI Bagundali stores cinematic images on the server (dev) or cloud storage (production). Flutter loads `image_url`, `poster_url`, `avatar_url`, and related fields from API responses — never from bundled assets (except app branding).

## Upload flow

1. Admin uploads image via **file** or **external URL**.
2. Server validates MIME/size, optionally converts to WebP, generates thumbnail (Sharp).
3. File saved under `server/uploads/<category>/` via `LocalStorageService`.
4. Row created in `media_assets` with metadata (heroes, movies, tags, category).
5. `content_features` updated for recommendation (`content_type = media_asset`).
6. Optionally **create** wallpaper/status card or **attach** to update/movie/hero.
7. Public APIs return the stored URL on entities (`GET /v1/home/feed`, `/v1/wallpapers`, etc.).

## Local storage (development)

| Item | Value |
|------|--------|
| Disk path | `server/uploads/` |
| Public URL | `{PUBLIC_BASE_URL}/uploads/...` (default `http://localhost:3001/uploads/...`) |
| Max size | 5MB (`UPLOAD_MAX_BYTES`) |
| MIME | `image/jpeg`, `image/png`, `image/webp` |

Folders: `updates/`, `movies/`, `heroes/`, `wallpapers/`, `status-cards/`, `polls/`, `quiz/`, `timeline/`, `notifications/`, `thumbnails/`.

## Production storage (TODO)

Swap implementation in `src/services/storage/index.js`:

- AWS S3 + CloudFront
- Cloudinary
- Firebase Storage
- Supabase Storage

Set `STORAGE_PROVIDER` and implement a new class with:

- `uploadImage(buffer, { relativePath })`
- `deleteImage(storagePath)`
- `getPublicUrl(relativePath)`

## Admin UI

Open: **http://localhost:3001/admin/upload**

Enter `ADMIN_API_KEY`, choose file or URL, fill metadata, upload.

## API endpoints (all require `x-admin-key`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/admin/uploads` | List assets (filters: `asset_type`, `category`, `hero_id`, `movie_id`, `q`, `is_active`, `page`, `limit`) |
| GET | `/v1/admin/uploads/:id` | Get one asset |
| POST | `/v1/admin/uploads/image` | Multipart file upload |
| POST | `/v1/admin/uploads/from-url` | Register or import external URL |
| POST | `/v1/admin/uploads/:id/attach` | Attach to entity field |
| PATCH | `/v1/admin/uploads/:id` | Edit metadata |
| DELETE | `/v1/admin/uploads/:id` | Soft delete (`?force=true` removes file) |

Supporting lists: `GET /v1/admin/heroes`, `GET /v1/admin/movies`.

## Metadata fields (multipart or JSON)

| Field | Notes |
|-------|--------|
| `name` | Required display name |
| `description` | Optional |
| `asset_type` | `TFI_UPDATE`, `MOVIE_POSTER`, `HERO_AVATAR`, `WALLPAPER`, `STATUS_CARD`, `POLL_IMAGE`, `QUIZ_IMAGE`, `TIMELINE_IMAGE`, `NOTIFICATION_IMAGE`, `GENERAL` |
| `content_type`, `category`, `usage` | Taxonomy for CMS & rec engine |
| `related_hero_id`, `related_movie_id` | UUID (repeatable via comma/JSON for multiples) |
| `tags` | Comma-separated or array |
| `language` | `TELUGU`, `ENGLISH`, `MIXED` |
| `alt_text`, `source_name`, `source_url` | Accessibility & attribution |
| `is_public`, `is_active`, `priority` | Visibility & ranking |
| `create_record` | `true` → create wallpaper/status card (or update if extra fields) |
| `attach_to_entity`, `entity_type`, `entity_id`, `entity_field` | Attach after upload |

### URL fields

| Field | Meaning |
|-------|---------|
| `image_url` | Public URL the app displays |
| `storage_path` | Internal path under `uploads/` |
| `external_url` | Original remote source when imported |

## Upload file (curl)

```bash
curl -X POST http://localhost:3001/v1/admin/uploads/image \
  -H "x-admin-key: YOUR_ADMIN_KEY" \
  -F "image=@/path/to/image.jpg" \
  -F "name=Peddi Countdown Wallpaper" \
  -F "asset_type=WALLPAPER" \
  -F "category=COUNTDOWN" \
  -F "related_movie_id=MOVIE_UUID" \
  -F "related_hero_id=HERO_UUID" \
  -F "tags=peddi,ram charan,countdown,fdfs" \
  -F "create_record=true"
```

## Upload from image address / URL

```bash
curl -X POST http://localhost:3001/v1/admin/uploads/from-url \
  -H "x-admin-key: YOUR_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Peddi Update Image",
    "image_url": "https://example.com/image.jpg",
    "asset_type": "TFI_UPDATE",
    "category": "RELEASE_DATE",
    "related_hero_id": "HERO_UUID",
    "related_movie_id": "MOVIE_UUID",
    "tags": ["peddi", "release"],
    "save_remote_copy": true
  }'
```

Set `"save_remote_copy": false` to store only the external URL (`storage_provider = EXTERNAL`).

## Attach to update / movie / hero

```bash
curl -X POST http://localhost:3001/v1/admin/uploads/ASSET_ID/attach \
  -H "x-admin-key: YOUR_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "entity_type": "MOVIE",
    "entity_id": "MOVIE_UUID",
    "field": "poster_url"
  }'
```

| entity_type | Allowed fields |
|-------------|----------------|
| TFI_UPDATE | `image_url` |
| MOVIE | `poster_url` |
| HERO | `avatar_url` |
| WALLPAPER | `image_url`, `thumbnail_url` |
| STATUS_CARD | `image_url`, `thumbnail_url`, `template_url` |
| POLL | `image_url` |
| QUIZ_QUESTION | `image_url` |
| NOTIFICATION | `image_url`, `thumbnail_url` |
| TIMELINE | `image_url` |

## Create wallpaper / status card from upload

Set `create_record=true` with `asset_type=WALLPAPER` or `STATUS_CARD`. For TFI updates, also send `title`, `short_summary`, `full_summary`, `category`, `status`.

## Recommendation engine

On each upload:

- `content_features` row: `content_type = media_asset`, `content_id = asset.id`, with `hero_ids`, `movie_ids`, `keywords` (tags), `category`, `priority`, `freshness_score`.

On attach or record create:

- Entity sync runs (`syncUpdateFeatures`, `syncWallpaperFeatures`, etc.).

Event: `admin_media_uploaded` in `recommendation_events` (best-effort).

Home/explore/search use existing entity URLs and tag matching on wallpapers/status cards/media_assets.

## Flutter consumption

No app changes required when APIs already expose URL fields, e.g.:

- `update.image_url` from `GET /v1/home/feed`
- `movie.poster_url` from `GET /v1/movies/:id`
- `wallpaper.image_url` / `thumbnail_url` from `GET /v1/wallpapers`

Use `TfiNetworkImage(url: ...)` with returned absolute URLs.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| 403 Forbidden | Set `ADMIN_API_KEY` in `.env` and send matching `x-admin-key` |
| 400 Invalid image | Use JPEG/PNG/WebP under 5MB |
| 400 URL blocked | Remote URL must be public https; no localhost/private IPs when downloading |
| Image 404 | Ensure server running; check `PUBLIC_BASE_URL`; file under `server/uploads/` |
| Thumbnail same as main | Sharp failed non-fatally; check server logs |
| DB error on upload | Run `npm run migrate` (migration `004_media_assets.sql`) |

## Tests

```bash
npm run migrate
npm run dev   # separate terminal
npm test      # includes image-utils + upload tests if server up
```

Unit only: `node --test test/image-utils.test.js`
