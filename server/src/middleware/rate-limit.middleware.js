const rateLimit = require('express-rate-limit');

const otpSendLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 8,
  message: { success: false, error: { code: 'RATE_LIMIT', message: 'Too many OTP requests', statusCode: 429 } },
  standardHeaders: true,
  legacyHeaders: false,
});

const otpVerifyLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { success: false, error: { code: 'RATE_LIMIT', message: 'Too many verify attempts', statusCode: 429 } },
  standardHeaders: true,
  legacyHeaders: false,
});

const writeLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  message: { success: false, error: { code: 'RATE_LIMIT', message: 'Too many requests', statusCode: 429 } },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = { otpSendLimiter, otpVerifyLimiter, writeLimiter };
