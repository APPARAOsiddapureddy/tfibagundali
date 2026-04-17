const router = require('express').Router();
const ctrl = require('./coins.controller');
const { requireAuth } = require('../../middleware/auth.middleware');

router.use(requireAuth);
router.get('/balance', ctrl.getBalance);
router.get('/history', ctrl.getHistory);
router.get('/store', ctrl.getStore);
router.post('/redeem', ctrl.redeem);

module.exports = router;
