const router = require('express').Router();
const service = require('./explore.service');

router.get('/', async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.getExplore() });
  } catch (e) { next(e); }
});

router.get('/wallpapers', async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.listWallpapers(req.query.category) });
  } catch (e) { next(e); }
});

router.get('/status-cards', async (req, res, next) => {
  try {
    res.json({ success: true, data: await service.listCards(req.query.category) });
  } catch (e) { next(e); }
});

module.exports = router;
