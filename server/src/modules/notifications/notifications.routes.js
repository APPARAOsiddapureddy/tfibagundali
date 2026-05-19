const router = require('express').Router();
const svc = require('./notifications.service');
const { requireAuth } = require('../../middleware/auth.middleware');

router.get('/', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.list(req.user.id) });
  } catch (e) { next(e); }
});

router.get('/preferences', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.getPreferences(req.user.id) });
  } catch (e) { next(e); }
});

router.patch('/preferences', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.updatePreferences(req.user.id, req.body) });
  } catch (e) { next(e); }
});

router.post('/read', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.markRead(req.user.id, req.body.notification_ids) });
  } catch (e) { next(e); }
});

module.exports = router;
