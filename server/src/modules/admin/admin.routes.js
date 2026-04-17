const router = require('express').Router();
const ctrl = require('./admin.controller');
const { requireAuth } = require('../../middleware/auth.middleware');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

// Simple API key auth for admin endpoints
function requireAdminKey(req, res, next) {
  const key = req.headers['x-admin-key'];
  if (!key || key !== process.env.ADMIN_API_KEY) {
    return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: 'Invalid admin key', statusCode: 403 } });
  }
  next();
}

router.use(requireAdminKey);

// Quiz question management
router.get('/questions', ctrl.listQuestions);
router.post('/questions', ctrl.createQuestion);
router.put('/questions/:id', ctrl.updateQuestion);
router.delete('/questions/:id', ctrl.deleteQuestion);

// Movie management
router.get('/movies', ctrl.listMovies);
router.post('/movies', ctrl.createMovie);
router.put('/movies/:id', ctrl.updateMovie);

// Share card management
router.get('/share-cards', ctrl.listShareCards);
router.post('/share-cards', upload.single('image'), ctrl.createShareCard);
router.put('/share-cards/:id', ctrl.updateShareCard);

// Hero management
router.post('/heroes', upload.single('image'), ctrl.createHero);
router.put('/heroes/:id', ctrl.updateHero);

// Poll management
router.post('/polls', ctrl.createPoll);
router.put('/polls/:id', ctrl.updatePoll);

// Quiz generation
router.post('/quiz/generate', ctrl.generateTodayQuiz);

// Stats
router.get('/stats', ctrl.getStats);

module.exports = router;
