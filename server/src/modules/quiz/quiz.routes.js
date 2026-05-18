const router = require('express').Router();
const service = require('./quiz.service');
const { requireAuth } = require('../../middleware/auth.middleware');

router.get('/home', async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getHome() });
  } catch (e) { next(e); }
});

router.get('/today', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getToday(req.user.id) });
  } catch (e) { next(e); }
});

router.post('/start', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.startSession(req.user.id) });
  } catch (e) { next(e); }
});

router.post('/answer', requireAuth, async (req, res, next) => {
  try {
    const { session_id, question_id, selected_option } = req.body;
    res.json({ success: true, data: await service.submitAnswer(req.user.id, session_id, question_id, selected_option) });
  } catch (e) { next(e); }
});

router.post('/complete', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.complete(req.user.id, req.body.session_id) });
  } catch (e) { next(e); }
});

module.exports = router;
