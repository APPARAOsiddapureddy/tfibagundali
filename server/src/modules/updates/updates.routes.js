const router = require('express').Router();
const ctrl = require('./updates.controller');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');
const { writeLimiter } = require('../../middleware/rate-limit.middleware');

router.get('/', optionalAuth, ctrl.list);
router.get('/:id', optionalAuth, ctrl.getOne);
router.get('/:id/related', optionalAuth, ctrl.getRelated);
router.post('/:id/view', optionalAuth, ctrl.view);
router.post('/:id/react', requireAuth, writeLimiter, ctrl.react);
router.post('/:id/save', requireAuth, ctrl.save);
router.delete('/:id/save', requireAuth, ctrl.unsave);
router.post('/:id/share', optionalAuth, writeLimiter, ctrl.share);
router.post('/:id/not-interested', requireAuth, ctrl.notInterested);

module.exports = router;
