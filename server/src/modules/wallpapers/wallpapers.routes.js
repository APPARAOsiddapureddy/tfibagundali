const router = require('express').Router();
const svc = require('./wallpapers.service');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.list({ category: req.query.category, heroId: req.query.hero_id }) });
  } catch (e) { next(e); }
});

router.get('/:id', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.getOne(req.params.id) });
  } catch (e) { next(e); }
});

router.post('/:id/download', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.download(req.user?.id, req.params.id) });
  } catch (e) { next(e); }
});

router.post('/:id/share', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.share(req.user?.id, req.params.id) });
  } catch (e) { next(e); }
});

router.post('/:id/save', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.save(req.user.id, req.params.id) });
  } catch (e) { next(e); }
});

router.delete('/:id/save', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.unsave(req.user.id, req.params.id) });
  } catch (e) { next(e); }
});

module.exports = router;
