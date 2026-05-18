const { verifyAccess } = require('../utils/jwt');
const { AppError } = require('./error.middleware');

function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'Login required', statusCode: 401 },
    });
  }
  try {
    const payload = verifyAccess(header.slice(7));
    req.user = { id: payload.sub, phone: payload.phone };
    next();
  } catch {
    return res.status(401).json({
      success: false,
      error: { code: 'TOKEN_EXPIRED', message: 'Session expired', statusCode: 401 },
    });
  }
}

function optionalAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) return next();
  try {
    const payload = verifyAccess(header.slice(7));
    req.user = { id: payload.sub, phone: payload.phone };
  } catch (_) {}
  next();
}

module.exports = { requireAuth, optionalAuth };
