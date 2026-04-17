const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');

/**
 * Production: verify Android subscription via Google Play Developer API
 * and iOS via App Store Server API. This stub activates premium for successful
 * client calls so Flutter integration can be tested end-to-end.
 */
async function verifyAndActivatePremium(userId, { productId, platform }) {
  if (!productId) {
    throw new AppError('product_id required', 400, 'INVALID_REQUEST');
  }

  const expiresAt = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000);

  await db.query(
    `UPDATE users
     SET is_premium = true, premium_expires_at = $1, updated_at = NOW()
     WHERE id = $2`,
    [expiresAt, userId],
  );

  return {
    is_premium: true,
    premium_expires_at: expiresAt.toISOString(),
    product_id: productId,
    platform,
  };
}

module.exports = { verifyAndActivatePremium };
