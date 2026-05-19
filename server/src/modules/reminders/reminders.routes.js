const router = require('express').Router();
const svc = require('./reminders.service');
const { requireAuth } = require('../../middleware/auth.middleware');

router.get('/', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.list(req.user.id) });
  } catch (e) { next(e); }
});

router.post('/', requireAuth, async (req, res, next) => {
  try {
    res.status(201).json({ success: true, data: await svc.create(req.user.id, req.body) });
  } catch (e) { next(e); }
});

router.patch('/:id', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.patch(req.user.id, req.params.id, req.body) });
  } catch (e) { next(e); }
});

router.delete('/:id', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.remove(req.user.id, req.params.id) });
  } catch (e) { next(e); }
});

module.exports = router;
