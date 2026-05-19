const router = require('express').Router();
const service = require('./heroes.service');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.list() });
  } catch (e) { next(e); }
});

router.get('/:id', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getOne(req.params.id, req.user?.id) });
  } catch (e) { next(e); }
});

router.post('/:id/follow', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.follow(req.user.id, req.params.id) });
  } catch (e) { next(e); }
});

router.delete('/:id/follow', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.unfollow(req.user.id, req.params.id) });
  } catch (e) { next(e); }
});

module.exports = router;
