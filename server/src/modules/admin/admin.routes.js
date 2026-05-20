const router = require('express').Router();
const svc = require('./admin.service');
const { requireAdmin } = require('../../middleware/admin.middleware');
const uploadsRoutes = require('../uploads/uploads.routes');

router.use(requireAdmin);
router.use('/uploads', uploadsRoutes);

router.get('/stats', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.stats() });
  } catch (e) { next(e); }
});

router.get('/updates', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('tfi_updates') });
  } catch (e) { next(e); }
});

router.post('/updates', async (req, res, next) => {
  try {
    res.status(201).json({ success: true, data: await svc.createUpdate(req.body) });
  } catch (e) { next(e); }
});

router.patch('/updates/:id', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.patchUpdate(req.params.id, req.body) });
  } catch (e) { next(e); }
});

router.delete('/updates/:id', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.deleteUpdate(req.params.id) });
  } catch (e) { next(e); }
});

router.get('/movies', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('movies') });
  } catch (e) { next(e); }
});

router.get('/heroes', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('heroes') });
  } catch (e) { next(e); }
});

router.get('/wallpapers', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('wallpapers') });
  } catch (e) { next(e); }
});

router.get('/status-cards', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('status_cards') });
  } catch (e) { next(e); }
});

router.get('/polls', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('polls') });
  } catch (e) { next(e); }
});

router.get('/quiz/questions', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.crudList('quiz_questions') });
  } catch (e) { next(e); }
});

module.exports = router;
