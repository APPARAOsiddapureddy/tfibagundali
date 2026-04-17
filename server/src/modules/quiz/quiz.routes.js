const router = require('express').Router();
const ctrl = require('./quiz.controller');
const { requireAuth } = require('../../middleware/auth.middleware');
const { quizAnswerLimiter } = require('../../middleware/ratelimit.middleware');

router.use(requireAuth);
router.get('/today', ctrl.getToday);
router.post('/session/start', ctrl.startSession);
router.post('/session/:id/answer', quizAnswerLimiter, ctrl.submitAnswer);
router.post('/session/:id/complete', ctrl.completeSession);
router.get('/leaderboard/daily', ctrl.getDailyLeaderboard);
router.get('/leaderboard/weekly', ctrl.getWeeklyLeaderboard);
router.get('/history', ctrl.getHistory);
router.get('/streak', ctrl.getStreak);

module.exports = router;
