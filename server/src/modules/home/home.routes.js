const router = require('express').Router();
const homeService = require('./home.service');
const { optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', optionalAuth, async (req, res, next) => {
  try {
    const data = await homeService.getHome(req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

module.exports = router;
