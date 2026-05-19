const router = require('express').Router();
const service = require('./explore.service');
const wallpapersSvc = require('../wallpapers/wallpapers.service');
const cardsSvc = require('../status-cards/status-cards.service');
const { optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getExplore(req.user?.id) });
  } catch (e) { next(e); }
});

router.get('/wallpapers', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await wallpapersSvc.list({ category: req.query.category }) });
  } catch (e) { next(e); }
});

router.get('/status-cards', optionalAuth, async (req, res, next) => {
  try {
    res.json({ success: true, data: await cardsSvc.list({ category: req.query.category }) });
  } catch (e) { next(e); }
});

module.exports = router;
