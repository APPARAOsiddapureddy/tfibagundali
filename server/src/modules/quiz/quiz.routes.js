const router = require('express').Router();
const service = require('./quiz.service');
const recQuiz = require('../recommendations/quiz-rec.service');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');
const { writeLimiter } = require('../../middleware/rate-limit.middleware');

router.get('/home', optionalAuth, async (req, res, next) => {
  try {
    const base = await service.getHome();
    const rec = await recQuiz.getQuizRecommendations(req.user?.id);
    res.json({ success: true, data: { ...base, recommended: rec } });
  } catch (e) { next(e); }
});

router.get('/history', requireAuth, async (req, res, next) => {
  try {
    const profile = require('../profile/profile.service');
    res.json({ success: true, data: await profile.getQuizHistory(req.user.id) });
  } catch (e) { next(e); }
});

router.get('/leaderboard', async (req, res, next) => {
  try {
    res.json({ success: true, data: { leaderboard: [] } });
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

router.post('/answer', requireAuth, writeLimiter, async (req, res, next) => {
  try {
    const { session_id, question_id, selected_option } = req.body;
    res.json({ success: true, data: await service.submitAnswer(req.user.id, session_id, question_id, selected_option) });
  } catch (e) { next(e); }
});

router.post('/:sessionId/answer', requireAuth, writeLimiter, async (req, res, next) => {
  try {
    const { question_id, selected_option } = req.body;
    res.json({
      success: true,
      data: await service.submitAnswer(req.user.id, req.params.sessionId, question_id, selected_option),
    });
  } catch (e) { next(e); }
});

router.post('/complete', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.complete(req.user.id, req.body.session_id) });
  } catch (e) { next(e); }
});

router.post('/:sessionId/complete', requireAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.complete(req.user.id, req.params.sessionId) });
  } catch (e) { next(e); }
});

module.exports = router;
