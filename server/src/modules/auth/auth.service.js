const crypto = require('crypto');
const queries = require('./auth.queries');
const { generateOtp, hashOtp, hashToken, sendOtpSms } = require('../../utils/otp');
const { signAccessToken, signRefreshToken, verifyRefreshToken } = require('../../utils/jwt');
const { AppError } = require('../../middleware/error.middleware');
const { redis } = require('../../config/redis');
const env = require('../../config/env');
const coinService = require('../coins/coins.service');
const { COIN_RULES } = require('../../utils/coins');

async function sendOtp(phone) {
  const rateLimitKey = `ratelimit:otp:${phone}`;
  const count = await redis.incr(rateLimitKey);
  if (count === 1) await redis.expire(rateLimitKey, 600);
  if (count > 3) throw new AppError('Too many OTP requests. Wait 10 minutes.', 429, 'RATE_LIMITED');

  const otp = env.OTP_BYPASS_CODE || generateOtp();
  const codeHash = hashOtp(otp);
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

  await queries.saveOtp(phone, codeHash, expiresAt);
  await sendOtpSms(phone, otp);

  return { message: 'OTP sent successfully' };
}

async function verifyOtp(phone, code, deviceId) {
  const otpRecord = await queries.findValidOtp(phone);
  if (!otpRecord) throw new AppError('OTP expired or not found', 400, 'OTP_EXPIRED');

  if (otpRecord.attempts >= 3) throw new AppError('Too many wrong attempts', 429, 'OTP_MAX_ATTEMPTS');

  const isMatch = otpRecord.code_hash === hashOtp(code);
  if (!isMatch) {
    await queries.incrementOtpAttempts(otpRecord.id);
    throw new AppError('Invalid OTP', 400, 'OTP_INVALID');
  }

  await queries.markOtpUsed(otpRecord.id);

  let user = await queries.findUserByPhone(phone);
  const isNewUser = !user;
  if (isNewUser) {
    user = await queries.createUser(phone);
  }

  await queries.updateLastLogin(user.id);

  // Award daily login coins (idempotent via Redis key)
  const loginKey = `daily:login:${user.id}:${new Date().toISOString().slice(0, 10)}`;
  const alreadyAwarded = await redis.exists(loginKey);
  if (!alreadyAwarded) {
    await coinService.awardCoins(user.id, COIN_RULES.DAILY_LOGIN, 'daily_login', null, 'Daily login bonus');
    await redis.setex(loginKey, 86400, '1');
  }

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user.id);
  const tokenHash = hashToken(refreshToken);
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

  await queries.saveRefreshToken(user.id, tokenHash, deviceId, expiresAt);

  const coinBalance = await coinService.getBalance(user.id);

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    user: {
      id: user.id,
      phone: user.phone,
      username: user.username,
      display_name: user.display_name,
      is_new_user: isNewUser,
      is_premium: user.is_premium,
      coin_balance: coinBalance,
    },
  };
}

async function refreshTokens(refreshToken) {
  let payload;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch (_) {
    throw new AppError('Invalid refresh token', 401, 'TOKEN_INVALID');
  }

  const tokenHash = hashToken(refreshToken);
  const record = await queries.findRefreshToken(tokenHash);
  if (!record) throw new AppError('Refresh token not found or expired', 401, 'TOKEN_INVALID');

  const user = await queries.findUserById(payload.sub);
  if (!user) throw new AppError('User not found', 401, 'USER_NOT_FOUND');

  await queries.deleteRefreshToken(tokenHash);

  const newAccessToken = signAccessToken(user);
  const newRefreshToken = signRefreshToken(user.id);
  const newHash = hashToken(newRefreshToken);
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

  await queries.saveRefreshToken(user.id, newHash, record.device_id, expiresAt);

  return { access_token: newAccessToken, refresh_token: newRefreshToken };
}

async function logout(refreshToken) {
  const tokenHash = hashToken(refreshToken);
  await queries.deleteRefreshToken(tokenHash);
}

async function getMe(userId) {
  const user = await queries.findUserById(userId);
  if (!user) throw new AppError('User not found', 404, 'USER_NOT_FOUND');
  const coinBalance = await coinService.getBalance(userId);
  return { ...user, coin_balance: coinBalance };
}

async function updateMe(userId, fields) {
  const allowed = ['display_name', 'username', 'region', 'fcm_token', 'avatar_hero_id'];
  const filtered = Object.fromEntries(Object.entries(fields).filter(([k]) => allowed.includes(k)));
  return queries.updateUser(userId, filtered);
}

module.exports = { sendOtp, verifyOtp, refreshTokens, logout, getMe, updateMe };
