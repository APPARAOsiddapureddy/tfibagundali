const router = require('express').Router();
const service = require('./profile.service');
const { requireAuth } = require('../../middleware/auth.middleware');

router.get('/', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getProfile(req.user.id) });
  } catch (e) { next(e); }
});

module.exports = router;
