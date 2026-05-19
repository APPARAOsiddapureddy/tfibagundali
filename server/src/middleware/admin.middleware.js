const env = require('../config/env');
const { AppError } = require('./error.middleware');

function requireAdmin(req, res, next) {
  const key = req.headers['x-admin-key'];
  if (!env.ADMIN_API_KEY || key !== env.ADMIN_API_KEY) {
    return res.status(403).json({
      success: false,
      error: { code: 'FORBIDDEN', message: 'Admin access required', statusCode: 403 },
    });
  }
  next();
}

module.exports = { requireAdmin };
