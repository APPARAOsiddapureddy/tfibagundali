const router = require('express').Router();
const svc = require('./search.service');
const { optionalAuth } = require('../../middleware/auth.middleware');

router.get('/', optionalAuth, async (req, res, next) => {
  try {
    const data = await svc.search(req.query.q, Math.min(20, parseInt(req.query.limit, 10) || 10));
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.get('/trending', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.trendingSearches() });
  } catch (e) { next(e); }
});

module.exports = router;
