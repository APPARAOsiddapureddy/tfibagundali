-- TFI Bagundali — Initial Schema
-- Extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── HEROES ─────────────────────────────────────────────────────────────────
CREATE TABLE heroes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(80) NOT NULL,
  telugu_name     VARCHAR(80),
  army_name       VARCHAR(80),
  icon_emoji      VARCHAR(10),
  image_s3_key    TEXT,
  bio             TEXT,
  birth_date      DATE,
  is_active       BOOLEAN DEFAULT TRUE,
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── USERS ───────────────────────────────────────────────────────────────────
CREATE TABLE users (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone               VARCHAR(15) UNIQUE NOT NULL,
  username            VARCHAR(40) UNIQUE,
  display_name        VARCHAR(80),
  avatar_hero_id      UUID REFERENCES heroes(id),
  region              VARCHAR(40),
  is_premium          BOOLEAN DEFAULT FALSE,
  premium_expires_at  TIMESTAMPTZ,
  fcm_token           TEXT,
  login_streak        INTEGER DEFAULT 0,
  last_login_at       TIMESTAMPTZ,
  updated_at          TIMESTAMPTZ DEFAULT NOW(),
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  deleted_at          TIMESTAMPTZ
);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_premium ON users(is_premium, premium_expires_at);

-- ─── AUTH ─────────────────────────────────────────────────────────────────────
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  VARCHAR(64) UNIQUE NOT NULL,
  device_id   VARCHAR(100),
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_rt_user ON refresh_tokens(user_id);

CREATE TABLE otp_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone       VARCHAR(15) NOT NULL,
  code_hash   VARCHAR(64) NOT NULL,
  attempts    INTEGER DEFAULT 0,
  expires_at  TIMESTAMPTZ NOT NULL,
  used        BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_otp_phone ON otp_codes(phone, expires_at);

-- ─── MOVIES ──────────────────────────────────────────────────────────────────
CREATE TABLE movies (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             VARCHAR(200) NOT NULL,
  title_telugu      VARCHAR(200),
  hero_id           UUID REFERENCES heroes(id),
  director          VARCHAR(100),
  production_house  VARCHAR(100),
  music_director    VARCHAR(100),
  release_date      DATE,
  genre             VARCHAR(80),
  rating            VARCHAR(5),
  synopsis          TEXT,
  poster_s3_key     TEXT,
  trailer_youtube_id VARCHAR(20),
  status            VARCHAR(20) DEFAULT 'upcoming',
  tmdb_id           INTEGER,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_movies_release ON movies(release_date, status);
CREATE INDEX idx_movies_hero ON movies(hero_id);

CREATE TABLE movie_reminders (
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  movie_id  UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, movie_id)
);

-- ─── SHARE CARDS ─────────────────────────────────────────────────────────────
CREATE TABLE share_cards (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            VARCHAR(200),
  category         VARCHAR(40) NOT NULL,
  hero_id          UUID REFERENCES heroes(id),
  movie_id         UUID REFERENCES movies(id),
  image_s3_key     TEXT NOT NULL DEFAULT '',
  thumbnail_s3_key TEXT,
  is_premium       BOOLEAN DEFAULT FALSE,
  share_count      INTEGER DEFAULT 0,
  publish_date     DATE,
  is_active        BOOLEAN DEFAULT TRUE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_cards_category ON share_cards(category, is_active, publish_date DESC);
CREATE INDEX idx_cards_hero ON share_cards(hero_id, is_active);

-- ─── QUIZ ─────────────────────────────────────────────────────────────────────
CREATE TABLE quiz_questions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_text   TEXT NOT NULL,
  question_telugu TEXT,
  type            VARCHAR(30) NOT NULL,
  difficulty      VARCHAR(10) NOT NULL DEFAULT 'medium',
  image_s3_key    TEXT,
  option_a        VARCHAR(200) NOT NULL,
  option_b        VARCHAR(200) NOT NULL,
  option_c        VARCHAR(200) NOT NULL,
  option_d        VARCHAR(200) NOT NULL,
  correct_option  CHAR(1) NOT NULL,
  coins_reward    INTEGER DEFAULT 5,
  movie_id        UUID REFERENCES movies(id),
  hero_id         UUID REFERENCES heroes(id),
  is_active       BOOLEAN DEFAULT TRUE,
  times_served    INTEGER DEFAULT 0,
  times_correct   INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_qq_type_diff ON quiz_questions(type, difficulty, is_active);

CREATE TABLE daily_quiz_sets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_date       DATE UNIQUE NOT NULL,
  question_ids    UUID[] NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_dqs_date ON daily_quiz_sets(quiz_date);

CREATE TABLE quiz_sessions (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES users(id),
  quiz_date       DATE NOT NULL,
  score           INTEGER DEFAULT 0,
  coins_earned    INTEGER DEFAULT 0,
  time_taken_ms   INTEGER,
  completed       BOOLEAN DEFAULT FALSE,
  started_at      TIMESTAMPTZ DEFAULT NOW(),
  completed_at    TIMESTAMPTZ,
  UNIQUE(user_id, quiz_date)
);
CREATE INDEX idx_qs_user ON quiz_sessions(user_id, quiz_date DESC);
CREATE INDEX idx_qs_date ON quiz_sessions(quiz_date, score DESC);

CREATE TABLE quiz_answers (
  id              BIGSERIAL PRIMARY KEY,
  session_id      BIGINT NOT NULL REFERENCES quiz_sessions(id),
  question_id     UUID NOT NULL REFERENCES quiz_questions(id),
  selected_option CHAR(1),
  is_correct      BOOLEAN NOT NULL,
  time_taken_ms   INTEGER,
  answered_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(session_id, question_id)
);

-- ─── COINS ───────────────────────────────────────────────────────────────────
CREATE TABLE coin_ledger (
  id            BIGSERIAL PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES users(id),
  amount        INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  type          VARCHAR(40) NOT NULL,
  reference_id  TEXT,
  note          TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_cl_user ON coin_ledger(user_id, created_at DESC);

CREATE TABLE user_coin_balances (
  user_id     UUID PRIMARY KEY REFERENCES users(id),
  balance     INTEGER DEFAULT 0 NOT NULL,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── FAN ARMY ─────────────────────────────────────────────────────────────────
CREATE TABLE fan_armies (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hero_id       UUID UNIQUE NOT NULL REFERENCES heroes(id),
  army_name     VARCHAR(80) NOT NULL,
  member_count  INTEGER DEFAULT 0,
  weekly_points BIGINT DEFAULT 0,
  total_points  BIGINT DEFAULT 0,
  rank          INTEGER,
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE army_members (
  user_id    UUID NOT NULL REFERENCES users(id),
  army_id    UUID NOT NULL REFERENCES fan_armies(id),
  tier       VARCHAR(20) DEFAULT 'silver',
  points     BIGINT DEFAULT 0,
  joined_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, army_id)
);

CREATE TABLE polls (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question      TEXT NOT NULL,
  options       JSONB NOT NULL,
  starts_at     TIMESTAMPTZ,
  ends_at       TIMESTAMPTZ,
  is_active     BOOLEAN DEFAULT TRUE,
  total_votes   INTEGER DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE poll_votes (
  user_id   UUID NOT NULL REFERENCES users(id),
  poll_id   UUID NOT NULL REFERENCES polls(id),
  option_id VARCHAR(10) NOT NULL,
  voted_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, poll_id)
);

-- ─── FCM TOKENS ──────────────────────────────────────────────────────────────
CREATE TABLE fcm_tokens (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT NOT NULL,
  platform   VARCHAR(10) DEFAULT 'android',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id)
);

-- ─── PREMIUM / PAYMENTS ───────────────────────────────────────────────────────
CREATE TABLE premium_orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id),
  razorpay_order_id TEXT UNIQUE,
  razorpay_payment_id TEXT,
  plan            VARCHAR(30) NOT NULL,
  amount_paise    INTEGER NOT NULL,
  status          VARCHAR(20) DEFAULT 'pending',
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);
