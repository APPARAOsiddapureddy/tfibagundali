const { verifyAccessToken } = require('../utils/jwt');
const { AppError } = require('./error.middleware');
const db = require('../config/db');

async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Missing authorization header', 401, 'UNAUTHORIZED');
    }

    const token = authHeader.split(' ')[1];
    const payload = verifyAccessToken(token);

    // Attach minimal user info — avoid DB hit on every request
    req.user = {
      id: payload.sub,
      phone: payload.phone,
      is_premium: payload.is_premium,
    };

    next();
  } catch (err) {
    if (err instanceof AppError) return next(err);
    next(new AppError('Invalid or expired token', 401, 'TOKEN_EXPIRED'));
  }
}

async function requirePremium(req, res, next) {
  if (!req.user) return next(new AppError('Unauthorized', 401, 'UNAUTHORIZED'));

  if (req.user.is_premium) return next();

  // Double-check DB (JWT might be stale after upgrade)
  const { rows } = await db.query(
    'SELECT is_premium, premium_expires_at FROM users WHERE id = $1',
    [req.user.id]
  );
  const user = rows[0];
  if (user && user.is_premium && (!user.premium_expires_at || new Date(user.premium_expires_at) > new Date())) {
    req.user.is_premium = true;
    return next();
  }

  next(new AppError('Premium subscription required', 403, 'PREMIUM_REQUIRED'));
}

async function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) return next();
  try {
    const token = authHeader.split(' ')[1];
    const payload = verifyAccessToken(token);
    req.user = { id: payload.sub, phone: payload.phone, is_premium: payload.is_premium };
  } catch (_) {
    // silently ignore invalid token for optional auth
  }
  next();
}

module.exports = { requireAuth, requirePremium, optionalAuth };
