const router = require('express').Router();
const ctrl = require('./fanarmy.controller');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

router.get('/fan-armies', ctrl.getArmies);
router.get('/fan-armies/leaderboard', ctrl.getLeaderboard);
router.post('/fan-armies/:id/join', requireAuth, ctrl.joinArmy);
router.get('/fan-armies/my', requireAuth, ctrl.getMyArmy);
router.get('/polls/active', optionalAuth, ctrl.getActivePoll);
router.post('/polls/:id/vote', requireAuth, ctrl.castVote);

module.exports = router;
