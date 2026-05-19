-- Recommendation system tables & content metadata extensions

ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS event_datetime TIMESTAMPTZ;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS save_count INTEGER DEFAULT 0;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN DEFAULT FALSE;
ALTER TABLE tfi_updates ADD COLUMN IF NOT EXISTS editorial_score NUMERIC(4,2) DEFAULT 0;

ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS download_count INTEGER DEFAULT 0;
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS save_count INTEGER DEFAULT 0;
ALTER TABLE wallpapers ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS download_count INTEGER DEFAULT 0;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS save_count INTEGER DEFAULT 0;
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE status_cards ADD COLUMN IF NOT EXISTS customizable BOOLEAN DEFAULT TRUE;

ALTER TABLE polls ADD COLUMN IF NOT EXISTS category VARCHAR(40);
ALTER TABLE polls ADD COLUMN IF NOT EXISTS starts_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE polls ADD COLUMN IF NOT EXISTS trending_score NUMERIC(8,2) DEFAULT 0;

ALTER TABLE movies ADD COLUMN IF NOT EXISTS follower_count INTEGER DEFAULT 0;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS reminder_count INTEGER DEFAULT 0;

ALTER TABLE heroes ADD COLUMN IF NOT EXISTS follower_count INTEGER DEFAULT 0;

ALTER TABLE users ADD COLUMN IF NOT EXISTS language_preference VARCHAR(20) DEFAULT 'mixed';
ALTER TABLE users ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{}'::jsonb;

CREATE TABLE IF NOT EXISTS recommendation_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES users(id) ON DELETE SET NULL,
  anonymous_id  VARCHAR(64),
  event_name    VARCHAR(60) NOT NULL,
  content_type  VARCHAR(30),
  content_id    UUID,
  hero_ids      UUID[],
  movie_ids     UUID[],
  category      VARCHAR(40),
  trust_status  VARCHAR(20),
  source_screen VARCHAR(60),
  position      INTEGER,
  session_id    VARCHAR(64),
  metadata      JSONB DEFAULT '{}'::jsonb,
  device        VARCHAR(40),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_rec_events_user ON recommendation_events(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rec_events_name ON recommendation_events(event_name, created_at DESC);

CREATE TABLE IF NOT EXISTS user_interest_profiles (
  user_id                   UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  favourite_hero_id       UUID REFERENCES heroes(id),
  followed_hero_ids         UUID[] DEFAULT '{}',
  followed_movie_ids        UUID[] DEFAULT '{}',
  hero_scores               JSONB DEFAULT '{}'::jsonb,
  movie_scores              JSONB DEFAULT '{}'::jsonb,
  director_scores           JSONB DEFAULT '{}'::jsonb,
  category_scores           JSONB DEFAULT '{}'::jsonb,
  content_type_scores       JSONB DEFAULT '{}'::jsonb,
  quiz_category_scores      JSONB DEFAULT '{}'::jsonb,
  wallpaper_category_scores JSONB DEFAULT '{}'::jsonb,
  poll_category_scores      JSONB DEFAULT '{}'::jsonb,
  trust_preference_score    NUMERIC(4,2) DEFAULT 0.7,
  language_preference       VARCHAR(20) DEFAULT 'mixed',
  notification_preferences  JSONB DEFAULT '{}'::jsonb,
  notification_sensitivity  NUMERIC(4,2) DEFAULT 0.5,
  session_boosts            JSONB DEFAULT '{}'::jsonb,
  updated_at                TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS content_features (
  content_type      VARCHAR(30) NOT NULL,
  content_id        UUID NOT NULL,
  category          VARCHAR(40),
  trust_status      VARCHAR(20),
  hero_ids          UUID[] DEFAULT '{}',
  movie_ids         UUID[] DEFAULT '{}',
  director_ids      UUID[] DEFAULT '{}',
  keywords          TEXT[] DEFAULT '{}',
  language          VARCHAR(20) DEFAULT 'mixed',
  published_at      TIMESTAMPTZ,
  event_datetime    TIMESTAMPTZ,
  expires_at        TIMESTAMPTZ,
  engagement_score  NUMERIC(8,4) DEFAULT 0,
  trust_score       NUMERIC(4,2) DEFAULT 0.5,
  freshness_score   NUMERIC(4,2) DEFAULT 0.5,
  editorial_score   NUMERIC(4,2) DEFAULT 0,
  priority          VARCHAR(20),
  is_pinned         BOOLEAN DEFAULT FALSE,
  action_types      TEXT[] DEFAULT '{}',
  updated_at        TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (content_type, content_id)
);
CREATE INDEX IF NOT EXISTS idx_content_features_pub ON content_features(published_at DESC);

CREATE TABLE IF NOT EXISTS recommendation_impressions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID REFERENCES users(id) ON DELETE CASCADE,
  content_type      VARCHAR(30) NOT NULL,
  content_id        UUID NOT NULL,
  section_type      VARCHAR(40),
  position          INTEGER,
  final_score       NUMERIC(8,4),
  scoring_breakdown JSONB,
  reason            VARCHAR(120),
  shown_at          TIMESTAMPTZ DEFAULT NOW(),
  clicked           BOOLEAN DEFAULT FALSE,
  engaged           BOOLEAN DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS idx_impressions_user ON recommendation_impressions(user_id, shown_at DESC);

CREATE TABLE IF NOT EXISTS hidden_content (
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_type  VARCHAR(30) NOT NULL,
  content_id    UUID NOT NULL,
  reason        VARCHAR(40) DEFAULT 'hide',
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, content_type, content_id)
);

CREATE TABLE IF NOT EXISTS user_content_views (
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_type  VARCHAR(30) NOT NULL,
  content_id    UUID NOT NULL,
  view_count    INTEGER DEFAULT 1,
  dwell_seconds INTEGER DEFAULT 0,
  last_viewed_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, content_type, content_id)
);

CREATE TABLE IF NOT EXISTS not_interested (
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_type  VARCHAR(30) NOT NULL,
  content_id    UUID NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, content_type, content_id)
);

CREATE TABLE IF NOT EXISTS notification_log (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_type  VARCHAR(30),
  content_id    UUID,
  category      VARCHAR(40),
  title         VARCHAR(200),
  score         NUMERIC(8,4),
  sent_at       TIMESTAMPTZ DEFAULT NOW(),
  opened        BOOLEAN DEFAULT FALSE,
  dismissed     BOOLEAN DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS idx_notification_log_user ON notification_log(user_id, sent_at DESC);
