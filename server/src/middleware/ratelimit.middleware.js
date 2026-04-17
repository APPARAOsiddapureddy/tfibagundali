const rateLimit = require('express-rate-limit');
const { redis } = require('../config/redis');

function makeRateLimiter(options) {
  return rateLimit({
    windowMs: options.windowMs,
    max: options.max,
    message: {
      success: false,
      error: {
        code: 'RATE_LIMITED',
        message: options.message || 'Too many requests, please try again later',
        statusCode: 429,
      },
    },
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => process.env.NODE_ENV === 'test',
    keyGenerator: (req) => options.keyFn ? options.keyFn(req) : req.ip,
  });
}

const globalLimiter = makeRateLimiter({ windowMs: 60 * 1000, max: 200 });
const unauthLimiter = makeRateLimiter({ windowMs: 60 * 1000, max: 30 });

const otpSendLimiter = makeRateLimiter({
  windowMs: 10 * 60 * 1000,
  max: 3,
  message: 'Too many OTP requests. Wait 10 minutes.',
  keyGenerator: (req) => `otp:send:${req.body?.phone || req.ip}`,
});

const otpVerifyLimiter = makeRateLimiter({
  windowMs: 10 * 60 * 1000,
  max: 5,
  message: 'Too many OTP attempts. Wait 10 minutes.',
  keyGenerator: (req) => `otp:verify:${req.body?.phone || req.ip}`,
});

const quizAnswerLimiter = makeRateLimiter({
  windowMs: 60 * 1000,
  max: 10,
  keyGenerator: (req) => `quiz:answer:${req.user?.id || req.ip}`,
});

const shareLimiter = makeRateLimiter({
  windowMs: 60 * 1000,
  max: 10,
  keyGenerator: (req) => `share:${req.user?.id || req.ip}`,
});

module.exports = { globalLimiter, unauthLimiter, otpSendLimiter, otpVerifyLimiter, quizAnswerLimiter, shareLimiter };
