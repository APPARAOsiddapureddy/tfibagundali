const router = require('express').Router();
const multer = require('multer');
const os = require('os');
const path = require('path');
const fs = require('fs');
const env = require('../../config/env');
const { requireAdmin } = require('../../middleware/admin.middleware');
const { uploadLimiter } = require('../../middleware/rate-limit.middleware');
const svc = require('./uploads.service');

const uploadDir = path.join(os.tmpdir(), 'tfi-uploads');
fs.mkdirSync(uploadDir, { recursive: true });

const upload = multer({
  storage: multer.diskStorage({
    destination: uploadDir,
    filename: (_req, file, cb) => {
      cb(null, `${Date.now()}-${file.originalname.replace(/[^a-zA-Z0-9._-]/g, '_')}`);
    },
  }),
  limits: { fileSize: env.UPLOAD_MAX_BYTES, files: 1 },
  fileFilter: (_req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype);
    cb(ok ? null : new Error('Invalid file type'), ok);
  },
});

router.use(requireAdmin);

router.get('/', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.listAssets(req.query) });
  } catch (e) { next(e); }
});

router.get('/:id', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.getAsset(req.params.id) });
  } catch (e) { next(e); }
});

router.post(
  '/image',
  uploadLimiter,
  upload.single('image'),
  async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: { code: 'MISSING_FILE', message: 'Image file required', statusCode: 400 },
        });
      }
      const file = { ...req.file, buffer: fs.readFileSync(req.file.path) };
      const data = await svc.uploadFromFile(file, { ...req.body });
      res.status(201).json({ success: true, data });
    } catch (e) {
      if (req.file?.path) {
        try { fs.unlinkSync(req.file.path); } catch { /* ignore */ }
      }
      next(e);
    }
  }
);

router.post('/from-url', uploadLimiter, async (req, res, next) => {
  try {
    const data = await svc.uploadFromUrl(req.body);
    res.status(201).json({ success: true, data });
  } catch (e) { next(e); }
});

router.post('/:id/attach', async (req, res, next) => {
  try {
    const data = await svc.attachById(req.params.id, req.body);
    res.json({ success: true, data });
  } catch (e) { next(e); }
});

router.patch('/:id', async (req, res, next) => {
  try {
    res.json({ success: true, data: await svc.patchAsset(req.params.id, req.body) });
  } catch (e) { next(e); }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const force = req.query.force === 'true';
    res.json({ success: true, data: await svc.deleteAsset(req.params.id, { force }) });
  } catch (e) { next(e); }
});

router.use((err, req, res, next) => {
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({
      success: false,
      error: { code: 'FILE_TOO_LARGE', message: 'File exceeds 5MB limit', statusCode: 400 },
    });
  }
  if (err.message === 'Invalid file type') {
    return res.status(400).json({
      success: false,
      error: { code: 'INVALID_FORMAT', message: err.message, statusCode: 400 },
    });
  }
  next(err);
});

module.exports = router;
