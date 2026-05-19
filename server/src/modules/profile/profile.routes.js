const router = require('express').Router();
const { z } = require('zod');
const svc = require('./profile.service');
const { requireAuth } = require('../../middleware/auth.middleware');
const { validate } = require('../../middleware/validate.middleware');

router.get('/', requireAuth, async (req, res, next) => {
  try {
    const data = await svc.getProfile(req.user.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.patch('/', requireAuth, async (req, res, next) => {
  try {
    const data = await svc.updateProfile(req.user.id, req.body);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.post('/favourite-hero', requireAuth, validate(z.object({
  body: z.object({ hero_id: z.string().uuid().nullable().optional() }),
})), async (req, res, next) => {
  try {
    const data = await svc.setFavouriteHero(req.user.id, req.body.hero_id ?? null);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.post('/fcm-token', requireAuth, validate(z.object({
  body: z.object({ fcm_token: z.string().min(1) }),
})), async (req, res, next) => {
  try {
    const data = await svc.setFcmToken(req.user.id, req.body.fcm_token);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/saved', requireAuth, async (req, res, next) => {
  try {
    const data = await svc.getSaved(req.user.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/reminders', requireAuth, async (req, res, next) => {
  try {
    const data = await svc.getReminders(req.user.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/downloads', requireAuth, async (req, res, next) => {
  try {
    const data = await svc.getDownloads(req.user.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/quiz-history', requireAuth, async (req, res, next) => {
  try {
    const data = await svc.getQuizHistory(req.user.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

module.exports = router;
