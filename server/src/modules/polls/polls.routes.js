const router = require('express').Router();
const service = require('./polls.service');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.list(req.query.type) });
  } catch (e) { next(e); }
});

router.get('/:id', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getOne(req.params.id, req.user?.id) });
  } catch (e) { next(e); }
});

router.post('/:id/vote', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.vote(req.user.id, req.params.id, req.body.option_id) });
  } catch (e) { next(e); }
});

module.exports = router;
