const db = require('../../config/db');
const env = require('../../config/env');
const { generateOtp, hashOtp, hashToken, sendOtpSms } = require('../../utils/otp');
const { signAccess, signRefresh, verifyRefresh } = require('../../utils/jwt');
const { AppError } = require('../../middleware/error.middleware');
const { normalizePhone } = require('../../lib/phone');

function formatUser(u) {
  const onboarded = u.is_onboarded ?? !!u.favourite_hero_id;
  return {
    id: u.id,
    phone: u.phone,
    display_name: u.display_name,
    username: u.username,
    avatar_url: u.avatar_url,
    favourite_hero_id: u.favourite_hero_id,
    language_preference: (u.language_preference || 'MIXED').toUpperCase(),
    is_onboarded: onboarded,
    notification_preferences: u.notification_preferences || {},
    favourite_hero: u.hero_name
      ? { id: u.favourite_hero_id, name: u.hero_name, telugu_name: u.hero_telugu, icon_emoji: u.icon_emoji, avatar_url: u.hero_avatar_url }
      : null,
    created_at: u.created_at,
    updated_at: u.updated_at,
  };
}

async function sendOtp(phone) {
  const fullPhone = normalizePhone(phone);
  if (!fullPhone) throw new AppError('Invalid phone number', 400, 'INVALID_PHONE');

  const code = env.OTP_BYPASS_CODE && env.NODE_ENV === 'development'
    ? env.OTP_BYPASS_CODE
    : generateOtp();
  const expires = new Date(Date.now() + 10 * 60 * 1000);
  await db.query(
    `INSERT INTO otp_codes (phone, code_hash, expires_at) VALUES ($1, $2, $3)`,
    [fullPhone, hashOtp(code), expires]
  );
  await sendOtpSms(fullPhone, code);
  return { expires_in: 600 };
}

async function verifyOtp(phone, code) {
  const fullPhone = normalizePhone(phone) || (phone.startsWith('+') ? phone : null);
  if (!fullPhone) throw new AppError('Invalid phone number', 400, 'INVALID_PHONE');

  const { rows } = await db.query(
    `SELECT * FROM otp_codes WHERE phone = $1 AND used = FALSE ORDER BY created_at DESC LIMIT 1`,
    [fullPhone]
  );
  const otp = rows[0];
  if (!otp || otp.expires_at < new Date()) throw new AppError('OTP expired', 400, 'OTP_EXPIRED');
  if (otp.attempts >= 5) throw new AppError('Too many attempts', 429, 'OTP_LOCKED');

  const valid = hashOtp(code) === otp.code_hash
    || (env.OTP_BYPASS_CODE && env.NODE_ENV === 'development' && code === env.OTP_BYPASS_CODE);
  if (!valid) {
    await db.query('UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1', [otp.id]);
    throw new AppError('Invalid OTP', 400, 'INVALID_OTP');
  }
  await db.query('UPDATE otp_codes SET used = TRUE WHERE id = $1', [otp.id]);

  let { rows: userRows } = await db.query('SELECT * FROM users WHERE phone = $1', [fullPhone]);
  let isNewUser = false;
  if (!userRows.length) {
    isNewUser = true;
    userRows = (await db.query(
      `INSERT INTO users (phone, display_name, is_onboarded) VALUES ($1, $2, FALSE) RETURNING *`,
      [fullPhone, 'TFI Fan']
    )).rows;
  } else {
    await db.query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [userRows[0].id]);
  }

  const user = userRows[0];
  const accessToken = signAccess({ sub: user.id, phone: user.phone });
  const refreshToken = signRefresh({ sub: user.id });
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, NOW() + INTERVAL '30 days')`,
    [user.id, hashToken(refreshToken)]
  );

  const fullUser = await getMe(user.id);
  const needsOnboarding = !fullUser.is_onboarded && !fullUser.favourite_hero_id;

  return {
    accessToken,
    refreshToken,
    user: fullUser,
    isNewUser: isNewUser || needsOnboarding,
    needsOnboarding,
  };
}

async function refreshSession(refreshToken) {
  if (!refreshToken) throw new AppError('Refresh token required', 400, 'VALIDATION_ERROR');
  let payload;
  try {
    payload = verifyRefresh(refreshToken);
  } catch {
    throw new AppError('Invalid refresh token', 401, 'INVALID_REFRESH');
  }
  const tokenHash = hashToken(refreshToken);
  const { rows } = await db.query(
    `SELECT * FROM refresh_tokens WHERE token_hash = $1 AND revoked_at IS NULL AND expires_at > NOW()`,
    [tokenHash]
  );
  if (!rows.length) throw new AppError('Refresh token revoked or expired', 401, 'INVALID_REFRESH');

  const accessToken = signAccess({ sub: payload.sub, phone: payload.phone });
  const newRefresh = signRefresh({ sub: payload.sub });
  const newHash = hashToken(newRefresh);
  await db.query('UPDATE refresh_tokens SET revoked_at = NOW() WHERE id = $1', [rows[0].id]);
  // Remove stale rows so token_hash unique constraint cannot block rotation
  await db.query(
    `DELETE FROM refresh_tokens WHERE user_id = $1 AND (revoked_at IS NOT NULL OR expires_at <= NOW())`,
    [payload.sub]
  );
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, NOW() + INTERVAL '30 days')
     ON CONFLICT (token_hash) DO UPDATE SET user_id = EXCLUDED.user_id, expires_at = EXCLUDED.expires_at, revoked_at = NULL`,
    [payload.sub, newHash]
  );
  const user = await getMe(payload.sub);
  return { accessToken, refreshToken: newRefresh, user };
}

async function logout(userId, refreshToken) {
  if (refreshToken) {
    await db.query(
      `UPDATE refresh_tokens SET revoked_at = NOW() WHERE user_id = $1 AND token_hash = $2`,
      [userId, hashToken(refreshToken)]
    );
  } else {
    await db.query(
      `UPDATE refresh_tokens SET revoked_at = NOW() WHERE user_id = $1 AND revoked_at IS NULL`,
      [userId]
    );
  }
  return { logged_out: true };
}

async function getMe(userId) {
  const { rows } = await db.query(
    `SELECT u.*, h.name as hero_name, h.telugu_name as hero_telugu, h.icon_emoji, h.avatar_url as hero_avatar_url
     FROM users u LEFT JOIN heroes h ON h.id = u.favourite_hero_id WHERE u.id = $1`,
    [userId]
  );
  if (!rows.length) throw new AppError('User not found', 404, 'NOT_FOUND');
  return formatUser(rows[0]);
}

async function updateMe(userId, fields) {
  const allowed = ['display_name', 'username', 'avatar_url', 'favourite_hero_id', 'language_preference', 'fcm_token', 'notification_preferences', 'is_onboarded'];
  const sets = [];
  const vals = [];
  let i = 1;
  for (const key of allowed) {
    if (fields[key] !== undefined) {
      sets.push(`${key} = $${i++}`);
      vals.push(fields[key]);
    }
  }
  if (fields.favourite_hero_id !== undefined) {
    sets.push(`is_onboarded = $${i++}`);
    vals.push(!!fields.favourite_hero_id);
  }
  if (!sets.length) return getMe(userId);
  vals.push(userId);
  await db.query(`UPDATE users SET ${sets.join(', ')}, updated_at = NOW() WHERE id = $${i}`, vals);
  return getMe(userId);
}

module.exports = { sendOtp, verifyOtp, refreshSession, logout, getMe, updateMe, formatUser };
