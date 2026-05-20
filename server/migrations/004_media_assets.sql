-- Media assets / admin upload system

ALTER TABLE polls ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE movie_timeline ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE user_notifications ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE user_notifications ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

CREATE TABLE IF NOT EXISTS media_assets (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                VARCHAR(300) NOT NULL,
  slug                VARCHAR(320),
  description         TEXT,
  asset_type          VARCHAR(40) NOT NULL,
  content_type        VARCHAR(60),
  category            VARCHAR(60),
  usage               VARCHAR(60),
  image_url           TEXT NOT NULL,
  thumbnail_url       TEXT,
  storage_provider    VARCHAR(20) NOT NULL DEFAULT 'LOCAL',
  storage_path        TEXT,
  external_url        TEXT,
  mime_type           VARCHAR(80),
  extension           VARCHAR(12),
  size_bytes          INTEGER,
  width               INTEGER,
  height              INTEGER,
  alt_text            TEXT,
  source_name         VARCHAR(120),
  source_url          TEXT,
  language            VARCHAR(20) DEFAULT 'MIXED',
  tags                JSONB DEFAULT '[]'::jsonb,
  related_hero_ids    JSONB DEFAULT '[]'::jsonb,
  related_movie_ids   JSONB DEFAULT '[]'::jsonb,
  related_update_id   UUID REFERENCES tfi_updates(id) ON DELETE SET NULL,
  related_poll_id     UUID REFERENCES polls(id) ON DELETE SET NULL,
  related_quiz_id     UUID REFERENCES quiz_questions(id) ON DELETE SET NULL,
  is_public           BOOLEAN DEFAULT TRUE,
  is_active           BOOLEAN DEFAULT TRUE,
  priority            VARCHAR(20) DEFAULT 'NORMAL',
  uploaded_by_admin_id UUID,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_assets_type ON media_assets(asset_type);
CREATE INDEX IF NOT EXISTS idx_media_assets_category ON media_assets(category);
CREATE INDEX IF NOT EXISTS idx_media_assets_active ON media_assets(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_media_assets_public ON media_assets(is_public) WHERE is_public = TRUE;
CREATE INDEX IF NOT EXISTS idx_media_assets_created ON media_assets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_media_assets_heroes ON media_assets USING GIN (related_hero_ids);
CREATE INDEX IF NOT EXISTS idx_media_assets_movies ON media_assets USING GIN (related_movie_ids);
CREATE INDEX IF NOT EXISTS idx_media_assets_tags ON media_assets USING GIN (tags);
