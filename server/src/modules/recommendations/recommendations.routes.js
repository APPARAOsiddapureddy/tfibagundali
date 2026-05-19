const router = require('express').Router();
const ctrl = require('./recommendations.controller');
const { optionalAuth, requireAuth } = require('../../middleware/auth.middleware');

router.get('/home', optionalAuth, ctrl.getHome);
router.get('/updates', optionalAuth, ctrl.getUpdates);
router.get('/explore', optionalAuth, ctrl.getExplore);
router.get('/quizzes', optionalAuth, ctrl.getQuizzes);
router.get('/polls', optionalAuth, ctrl.getPolls);
router.get('/related', optionalAuth, ctrl.getRelated);
router.get('/notifications/targets', requireAuth, ctrl.getNotificationTargets);

router.post('/events', optionalAuth, ctrl.postEvent);
router.post('/content/:type/:id/not-interested', requireAuth, ctrl.notInterested);
router.post('/content/:type/:id/hide', requireAuth, ctrl.hideContent);

router.post('/admin/sync-features', ctrl.syncFeatures);

module.exports = router;
