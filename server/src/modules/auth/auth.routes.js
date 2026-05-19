const router = require('express').Router();
const { z } = require('zod');
const ctrl = require('./auth.controller');
const { requireAuth } = require('../../middleware/auth.middleware');
const { validate } = require('../../middleware/validate.middleware');
const { otpSendLimiter, otpVerifyLimiter } = require('../../middleware/rate-limit.middleware');

const phoneSchema = z.object({
  body: z.object({ phone: z.string().min(10).max(15) }),
});

const verifySchema = z.object({
  body: z.object({
    phone: z.string().min(10).max(15),
    code: z.string().length(6),
  }),
});

const refreshSchema = z.object({
  body: z.object({ refreshToken: z.string().min(10) }),
});

router.post('/otp/send', otpSendLimiter, validate(phoneSchema), ctrl.sendOtpHandler);
router.post('/otp/verify', otpVerifyLimiter, validate(verifySchema), ctrl.verifyOtpHandler);
router.post('/refresh', validate(refreshSchema), ctrl.refreshHandler);
router.post('/logout', requireAuth, ctrl.logoutHandler);
router.get('/me', requireAuth, ctrl.getMeHandler);
router.patch('/me', requireAuth, ctrl.updateMeHandler);

module.exports = router;
