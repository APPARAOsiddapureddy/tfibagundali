const router = require('express').Router();
const service = require('./movies.service');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', async (req, res, next) => {
  try {
    const data = await service.list(req.query);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/:id', optionalAuth, async (req, res, next) => {
  try {
    const data = await service.getOne(req.params.id, req.user?.id);
    res.json({ success: true, data });
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

router.post('/:id/reminder', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.setReminder(req.user.id, req.params.id, req.body) });
  } catch (e) { next(e); }
});

router.delete('/:id/reminder', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.removeReminder(req.user.id, req.params.id) });
  } catch (e) { next(e); }
});

router.post('/:id/watch-intent', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.watchIntent(req.user?.id, req.params.id) });
  } catch (e) { next(e); }
});

module.exports = router;
