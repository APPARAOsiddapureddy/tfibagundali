const router = require('express').Router();
const ctrl = require('./auth.controller');
const { requireAuth } = require('../../middleware/auth.middleware');

router.post('/otp/send', ctrl.sendOtpHandler);
router.post('/otp/verify', ctrl.verifyOtpHandler);
router.get('/me', requireAuth, ctrl.getMeHandler);
router.patch('/me', requireAuth, ctrl.updateMeHandler);

module.exports = router;
