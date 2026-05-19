-- Content-first refactor: profile fields, update metadata, junction tables, notifications

-- Users
ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(40);
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS language_preference VARCHAR(20) DEFAULT 'MIXED';
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_onboarded BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "movie_updates": true,
  "my_hero_updates": true,
  "trailer_alerts": true,
  "song_alerts": true,
  "release_reminders": true,
  "event_reminders": true,
  "quiz_reminders": true,
  "poll_results": true,
  "wallpaper_drops": true,
  "ott_updates": true
}'::jsonb;

-- Heroes / Movies metadata
ALTER TABLE heroes ADD COLUMN IF NOT EXISTS slug VARCHAR(120);
ALTER TABLE heroes ADD COLUMN IF NOT EXISTS aliases JSONB DEFAULT '[]'::jsonb;
ALTER TABLE heroes ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE heroes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE movies ADD COLUMN IF NOT EXISTS slug VARCHAR(200);
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "cast" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS trailer_url TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS latest_update_id UUID REFERENCES tfi_updates(id);
ALTER TABLE movies ADD COLUMN IF NOT EXISTS interest_count INTEGER DEFAULT 0;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- TFI Updates extended
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS slug VARCHAR(320);
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS short_summary TEXT;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS full_summary TEXT;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS language VARCHAR(20) DEFAULT 'MIXED';
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS related_director_names JSONB DEFAULT '[]'::jsonb;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS is_correction BOOLEAN DEFAULT FALSE;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS correction_of_update_id UUID REFERENCES tfi_updates(id);
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS reaction_count INTEGER DEFAULT 0;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS created_by_admin_id UUID;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

UPDATE tfi_updates SET short_summary = summary WHERE short_summary IS NULL;
UPDATE tfi_updates SET full_summary = COALESCE(body, summary) WHERE full_summary IS NULL;

CREATE INDEX IF NOT EXISTS idx_updates_status ON tfi_updates(trust_status) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_updates_priority ON tfi_updates(priority, published_at DESC) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_updates_pinned ON tfi_updates(is_pinned) WHERE is_pinned = TRUE;

CREATE TABLE IF NOT EXISTS update_heroes (
  update_id UUID NOT NULL REFERENCES tfi_updates(id) ON DELETE CASCADE,
  hero_id UUID NOT NULL REFERENCES heroes(id) ON DELETE CASCADE,
  PRIMARY KEY (update_id, hero_id)
);

CREATE TABLE IF NOT EXISTS update_movies (
  update_id UUID NOT NULL REFERENCES tfi_updates(id) ON DELETE CASCADE,
  movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  PRIMARY KEY (update_id, movie_id)
);

-- Backfill junction from legacy columns
INSERT INTO update_heroes (update_id, hero_id)
SELECT id, hero_id FROM tfi_updates WHERE hero_id IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO update_movies (update_id, movie_id)
SELECT id, movie_id FROM tfi_updates WHERE movie_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- Wallpapers / Status cards
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS slug VARCHAR(200);
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS slug VARCHAR(200);
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS template_url TEXT;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

UPDATE status_cards SET template_url = image_url WHERE template_url IS NULL;

-- Polls
ALTER TABLE poll_votes ALTER COLUMN option_id DROP NOT NULL;
ALTER TABLE poll_votes ADD COLUMN IF NOT EXISTS word_text VARCHAR(80);
ALTER TABLE polls ADD COLUMN IF NOT EXISTS starts_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE polls ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'ACTIVE';
ALTER TABLE polls ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Reminders extended
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS movie_id UUID REFERENCES movies(id);
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS hero_id UUID REFERENCES heroes(id);
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS update_id UUID REFERENCES tfi_updates(id);
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS event_datetime TIMESTAMPTZ;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS notification_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

UPDATE reminders SET event_datetime = remind_at WHERE event_datetime IS NULL AND remind_at IS NOT NULL;

-- Movie timeline
ALTER TABLE movie_timeline ADD COLUMN IF NOT EXISTS update_id UUID REFERENCES tfi_updates(id);
ALTER TABLE movie_timeline ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE movie_timeline ADD COLUMN IF NOT EXISTS timeline_type VARCHAR(40) DEFAULT 'OTHER';
ALTER TABLE movie_timeline ADD COLUMN IF NOT EXISTS event_date DATE;

-- User downloads tracking
CREATE TABLE IF NOT EXISTS user_downloads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_type VARCHAR(30) NOT NULL,
  content_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, content_type, content_id)
);

-- In-app notifications
CREATE TABLE IF NOT EXISTS user_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  body TEXT,
  category VARCHAR(40),
  content_type VARCHAR(30),
  content_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_user_notifications_user ON user_notifications(user_id, created_at DESC);

-- Status card customizations
CREATE TABLE IF NOT EXISTS status_card_customizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  card_id UUID NOT NULL REFERENCES status_cards(id) ON DELETE CASCADE,
  name VARCHAR(80),
  custom_text VARCHAR(200),
  hero_id UUID REFERENCES heroes(id),
  style VARCHAR(40) DEFAULT 'default',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Refresh token revocation
ALTER TABLE refresh_tokens ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMPTZ;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON users(username) WHERE username IS NOT NULL;
