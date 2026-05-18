CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE heroes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(80) NOT NULL,
  telugu_name     VARCHAR(80),
  icon_emoji      VARCHAR(10),
  bio             TEXT,
  birth_date      DATE,
  sort_order      INTEGER DEFAULT 0,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE users (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone               VARCHAR(15) UNIQUE NOT NULL,
  display_name        VARCHAR(80),
  favourite_hero_id   UUID REFERENCES heroes(id),
  fcm_token           TEXT,
  login_streak        INTEGER DEFAULT 0,
  last_login_at       TIMESTAMPTZ,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  VARCHAR(64) UNIQUE NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE otp_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone       VARCHAR(15) NOT NULL,
  code_hash   VARCHAR(64) NOT NULL,
  attempts    INTEGER DEFAULT 0,
  expires_at  TIMESTAMPTZ NOT NULL,
  used        BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE movies (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             VARCHAR(200) NOT NULL,
  title_telugu      VARCHAR(200),
  hero_id           UUID REFERENCES heroes(id),
  director          VARCHAR(100),
  genre             VARCHAR(80),
  release_date      DATE,
  synopsis          TEXT,
  poster_url        TEXT,
  trailer_youtube_id  VARCHAR(20),
  status            VARCHAR(20) DEFAULT 'upcoming',
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE movie_follows (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  movie_id   UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, movie_id)
);

CREATE TABLE hero_follows (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  hero_id    UUID NOT NULL REFERENCES heroes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, hero_id)
);

CREATE TABLE tfi_updates (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           VARCHAR(300) NOT NULL,
  summary         TEXT NOT NULL,
  body            TEXT,
  category        VARCHAR(40) NOT NULL,
  trust_status    VARCHAR(20) NOT NULL DEFAULT 'buzz',
  hero_id         UUID REFERENCES heroes(id),
  movie_id        UUID REFERENCES movies(id),
  director        VARCHAR(100),
  image_url       TEXT,
  source_name     VARCHAR(120),
  source_url      TEXT,
  priority        VARCHAR(20) DEFAULT 'normal',
  is_breaking     BOOLEAN DEFAULT FALSE,
  is_trending     BOOLEAN DEFAULT FALSE,
  reaction_fire   INTEGER DEFAULT 0,
  reaction_mass   INTEGER DEFAULT 0,
  reaction_love   INTEGER DEFAULT 0,
  reaction_wait   INTEGER DEFAULT 0,
  published_at    TIMESTAMPTZ DEFAULT NOW(),
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_updates_published ON tfi_updates(published_at DESC) WHERE is_active = TRUE;
CREATE INDEX idx_updates_category ON tfi_updates(category, published_at DESC);

CREATE TABLE update_reactions (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  update_id  UUID NOT NULL REFERENCES tfi_updates(id) ON DELETE CASCADE,
  reaction   VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, update_id)
);

CREATE TABLE bookmarks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item_type   VARCHAR(30) NOT NULL,
  item_id     UUID NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, item_type, item_id)
);

CREATE TABLE wallpapers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       VARCHAR(200),
  category    VARCHAR(40) NOT NULL,
  hero_id     UUID REFERENCES heroes(id),
  movie_id    UUID REFERENCES movies(id),
  image_url   TEXT NOT NULL,
  is_trending BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE status_cards (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       VARCHAR(200),
  category    VARCHAR(40) NOT NULL,
  hero_id     UUID REFERENCES heroes(id),
  movie_id    UUID REFERENCES movies(id),
  image_url   TEXT NOT NULL,
  is_trending BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE polls (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question      TEXT NOT NULL,
  poll_type     VARCHAR(30) DEFAULT 'normal',
  options       JSONB NOT NULL,
  hero_id       UUID REFERENCES heroes(id),
  movie_id      UUID REFERENCES movies(id),
  update_id     UUID REFERENCES tfi_updates(id),
  ends_at       TIMESTAMPTZ,
  is_active     BOOLEAN DEFAULT TRUE,
  total_votes   INTEGER DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE poll_votes (
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  poll_id   UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  option_id VARCHAR(10) NOT NULL,
  voted_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, poll_id)
);

CREATE TABLE quiz_questions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_text   TEXT NOT NULL,
  question_telugu TEXT,
  type            VARCHAR(30) NOT NULL,
  difficulty      VARCHAR(10) DEFAULT 'medium',
  option_a        VARCHAR(200) NOT NULL,
  option_b        VARCHAR(200) NOT NULL,
  option_c        VARCHAR(200) NOT NULL,
  option_d        VARCHAR(200) NOT NULL,
  correct_option  CHAR(1) NOT NULL,
  hero_id         UUID REFERENCES heroes(id),
  movie_id        UUID REFERENCES movies(id),
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE daily_quiz_sets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_date       DATE UNIQUE NOT NULL,
  question_ids    UUID[] NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE quiz_sessions (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES users(id),
  quiz_date       DATE NOT NULL,
  score           INTEGER DEFAULT 0,
  completed       BOOLEAN DEFAULT FALSE,
  started_at      TIMESTAMPTZ DEFAULT NOW(),
  completed_at    TIMESTAMPTZ,
  UNIQUE(user_id, quiz_date)
);

CREATE TABLE quiz_answers (
  id              BIGSERIAL PRIMARY KEY,
  session_id      BIGINT NOT NULL REFERENCES quiz_sessions(id),
  question_id     UUID NOT NULL REFERENCES quiz_questions(id),
  selected_option CHAR(1),
  is_correct      BOOLEAN NOT NULL,
  answered_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(session_id, question_id)
);

CREATE TABLE reminders (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reminder_type VARCHAR(40) NOT NULL,
  title       VARCHAR(200) NOT NULL,
  subtitle    VARCHAR(200),
  related_id  UUID,
  remind_at   TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE movie_timeline (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id    UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  label       VARCHAR(200) NOT NULL,
  status      VARCHAR(20) DEFAULT 'pending',
  sort_order  INTEGER DEFAULT 0,
  completed_at TIMESTAMPTZ
);
