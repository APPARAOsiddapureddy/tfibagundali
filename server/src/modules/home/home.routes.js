const router = require('express').Router();
const homeService = require('./home.service');
const { optionalAuth } = require('../../middleware/auth.middleware');

async function feedHandler(req, res, next) {
  try {
    const data = await homeService.getHome(req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

router.get('/feed', optionalAuth, feedHandler);
router.get('/', optionalAuth, feedHandler);

module.exports = router;
