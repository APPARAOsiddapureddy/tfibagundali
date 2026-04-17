const router = require('express').Router();
const { requireAuth } = require('../../middleware/auth.middleware');
const ctrl = require('./premium.controller');

router.use(requireAuth);
router.post('/verify', ctrl.verify);

module.exports = router;
