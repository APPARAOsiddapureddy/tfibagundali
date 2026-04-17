const router = require('express').Router();
const ctrl = require('./content.controller');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');
const { shareLimiter } = require('../../middleware/ratelimit.middleware');

router.get('/home/feed', requireAuth, ctrl.getHomeFeed);
router.get('/movies/upcoming', ctrl.getUpcomingMovies);
router.get('/movies/:id', ctrl.getMovieById);
router.post('/movies/:id/reminder', requireAuth, ctrl.setMovieReminder);
router.get('/heroes', ctrl.getHeroes);
router.get('/heroes/:id', ctrl.getHeroById);
router.get('/share-cards', requireAuth, ctrl.getShareCards);
router.get('/share-cards/:id/download', requireAuth, ctrl.getShareCardDownload);
router.post('/share-cards/:id/share', requireAuth, shareLimiter, ctrl.logShare);

module.exports = router;
