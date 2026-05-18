const router = require('express').Router();
const ctrl = require('./updates.controller');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', optionalAuth, ctrl.list);
router.get('/:id', optionalAuth, ctrl.getOne);
router.post('/:id/react', requireAuth, ctrl.react);
router.post('/:id/save', requireAuth, ctrl.save);

module.exports = router;
