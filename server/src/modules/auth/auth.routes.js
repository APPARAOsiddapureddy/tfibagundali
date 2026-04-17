const router = require('express').Router();
const ctrl = require('./auth.controller');
const { requireAuth } = require('../../middleware/auth.middleware');
const { otpSendLimiter, otpVerifyLimiter } = require('../../middleware/ratelimit.middleware');

router.post('/otp/send', otpSendLimiter, ctrl.sendOtp);
router.post('/otp/verify', otpVerifyLimiter, ctrl.verifyOtp);
router.post('/token/refresh', ctrl.refreshToken);
router.post('/logout', ctrl.logout);
router.get('/me', requireAuth, ctrl.getMe);
router.patch('/me', requireAuth, ctrl.updateMe);

module.exports = router;
