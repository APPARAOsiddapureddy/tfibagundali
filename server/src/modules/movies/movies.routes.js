const router = require('express').Router();
const service = require('./movies.service');
const { requireAuth } = require('../../middleware/auth.middleware');

router.get('/', async (req, res, next) => {
  try {
    const data = await service.list(req.query.status);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const data = await service.getOne(req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.post('/:id/follow', requireAuth, async (req, res, next) => {
  try {
    const data = await service.follow(req.user.id, req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.post('/:id/reminder', requireAuth, async (req, res, next) => {
  try {
    const data = await service.addReminder(req.user.id, req.params.id, req.body.type);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

module.exports = router;
