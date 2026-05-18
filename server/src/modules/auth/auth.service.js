const db = require('../../config/db');
const env = require('../../config/env');
const { generateOtp, hashOtp, hashToken, sendOtpSms } = require('../../utils/otp');
const { signAccess, signRefresh } = require('../../utils/jwt');
const { AppError } = require('../../middleware/error.middleware');

async function sendOtp(phone) {
  const normalized = phone.replace(/\D/g, '').slice(-10);
  if (normalized.length !== 10) throw new AppError('Invalid phone number', 400, 'INVALID_PHONE');
  const fullPhone = `+91${normalized}`;
  const code = env.OTP_BYPASS_CODE && env.NODE_ENV === 'development'
    ? env.OTP_BYPASS_CODE
    : generateOtp();
  const expires = new Date(Date.now() + 10 * 60 * 1000);
  await db.query(
    `INSERT INTO otp_codes (phone, code_hash, expires_at) VALUES ($1, $2, $3)`,
    [fullPhone, hashOtp(code), expires]
  );
  await sendOtpSms(fullPhone, code);
  return { phone: fullPhone, expires_in: 600 };
}

async function verifyOtp(phone, code) {
  const fullPhone = phone.startsWith('+') ? phone : `+91${phone.replace(/\D/g, '').slice(-10)}`;
  const { rows } = await db.query(
    `SELECT * FROM otp_codes WHERE phone = $1 AND used = FALSE ORDER BY created_at DESC LIMIT 1`,
    [fullPhone]
  );
  const otp = rows[0];
  if (!otp || otp.expires_at < new Date()) throw new AppError('OTP expired', 400, 'OTP_EXPIRED');
  if (otp.attempts >= 5) throw new AppError('Too many attempts', 429, 'OTP_LOCKED');
  const valid = hashOtp(code) === otp.code_hash || (env.OTP_BYPASS_CODE && code === env.OTP_BYPASS_CODE);
  if (!valid) {
    await db.query('UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1', [otp.id]);
    throw new AppError('Invalid OTP', 400, 'INVALID_OTP');
  }
  await db.query('UPDATE otp_codes SET used = TRUE WHERE id = $1', [otp.id]);

  let userRows = await db.query('SELECT * FROM users WHERE phone = $1', [fullPhone]);
  if (!userRows.rows.length) {
    userRows = await db.query(
      `INSERT INTO users (phone, display_name) VALUES ($1, $2) RETURNING *`,
      [fullPhone, 'TFI Fan']
    );
  } else {
    await db.query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [userRows.rows[0].id]);
  }
  const user = userRows.rows[0];
  const access = signAccess({ sub: user.id, phone: user.phone });
  const refresh = signRefresh({ sub: user.id });
  const refreshHash = hashToken(refresh);
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, NOW() + INTERVAL '30 days')`,
    [user.id, refreshHash]
  );
  return {
    user: formatUser(user),
    access_token: access,
    refresh_token: refresh,
    is_new_user: !user.favourite_hero_id,
  };
}

async function getMe(userId) {
  const { rows } = await db.query(
    `SELECT u.*, h.name as hero_name, h.telugu_name as hero_telugu, h.icon_emoji
     FROM users u LEFT JOIN heroes h ON h.id = u.favourite_hero_id WHERE u.id = $1`,
    [userId]
  );
  if (!rows.length) throw new AppError('User not found', 404, 'NOT_FOUND');
  return formatUser(rows[0]);
}

async function updateMe(userId, fields) {
  const allowed = ['display_name', 'favourite_hero_id', 'fcm_token'];
  const sets = [];
  const vals = [];
  let i = 1;
  for (const key of allowed) {
    if (fields[key] !== undefined) {
      sets.push(`${key} = $${i++}`);
      vals.push(fields[key]);
    }
  }
  if (!sets.length) return getMe(userId);
  vals.push(userId);
  await db.query(`UPDATE users SET ${sets.join(', ')}, updated_at = NOW() WHERE id = $${i}`, vals);
  return getMe(userId);
}

function formatUser(u) {
  return {
    id: u.id,
    phone: u.phone,
    display_name: u.display_name,
    favourite_hero_id: u.favourite_hero_id,
    favourite_hero: u.hero_name ? { name: u.hero_name, telugu_name: u.hero_telugu, icon_emoji: u.icon_emoji } : null,
  };
}

module.exports = { sendOtp, verifyOtp, getMe, updateMe };
