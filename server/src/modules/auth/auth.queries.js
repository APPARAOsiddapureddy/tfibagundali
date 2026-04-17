const db = require('../../config/db');

async function findUserByPhone(phone) {
  const { rows } = await db.query('SELECT * FROM users WHERE phone = $1 AND deleted_at IS NULL', [phone]);
  return rows[0] || null;
}

async function findUserById(id) {
  const { rows } = await db.query('SELECT * FROM users WHERE id = $1 AND deleted_at IS NULL', [id]);
  return rows[0] || null;
}

async function createUser(phone) {
  const username = `fan_${Date.now().toString(36)}`;
  const { rows } = await db.query(
    `INSERT INTO users (phone, username) VALUES ($1, $2) RETURNING *`,
    [phone, username]
  );
  return rows[0];
}

async function updateUser(id, fields) {
  const keys = Object.keys(fields);
  if (keys.length === 0) return findUserById(id);
  const setClauses = keys.map((k, i) => `${k} = $${i + 2}`).join(', ');
  const { rows } = await db.query(
    `UPDATE users SET ${setClauses}, updated_at = NOW() WHERE id = $1 RETURNING *`,
    [id, ...Object.values(fields)]
  );
  return rows[0];
}

async function saveOtp(phone, codeHash, expiresAt) {
  await db.query(`UPDATE otp_codes SET used = TRUE WHERE phone = $1 AND used = FALSE`, [phone]);
  const { rows } = await db.query(
    `INSERT INTO otp_codes (phone, code_hash, expires_at) VALUES ($1, $2, $3) RETURNING id`,
    [phone, codeHash, expiresAt]
  );
  return rows[0];
}

async function findValidOtp(phone) {
  const { rows } = await db.query(
    `SELECT * FROM otp_codes WHERE phone = $1 AND used = FALSE AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1`,
    [phone]
  );
  return rows[0] || null;
}

async function markOtpUsed(id) {
  await db.query(`UPDATE otp_codes SET used = TRUE WHERE id = $1`, [id]);
}

async function incrementOtpAttempts(id) {
  await db.query(`UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1`, [id]);
}

async function saveRefreshToken(userId, tokenHash, deviceId, expiresAt) {
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token_hash, device_id, expires_at) VALUES ($1, $2, $3, $4)`,
    [userId, tokenHash, deviceId, expiresAt]
  );
}

async function findRefreshToken(tokenHash) {
  const { rows } = await db.query(
    `SELECT * FROM refresh_tokens WHERE token_hash = $1 AND expires_at > NOW()`,
    [tokenHash]
  );
  return rows[0] || null;
}

async function deleteRefreshToken(tokenHash) {
  await db.query(`DELETE FROM refresh_tokens WHERE token_hash = $1`, [tokenHash]);
}

async function updateLastLogin(userId) {
  await db.query(
    `UPDATE users SET last_login_at = NOW() WHERE id = $1`,
    [userId]
  );
}

module.exports = {
  findUserByPhone, findUserById, createUser, updateUser,
  saveOtp, findValidOtp, markOtpUsed, incrementOtpAttempts,
  saveRefreshToken, findRefreshToken, deleteRefreshToken, updateLastLogin,
};
