const service = require('./premium.service');
const { respond } = require('../../utils/pagination');

async function verify(req, res, next) {
  try {
    const { product_id: productId, purchase_token: purchaseToken, platform, transaction_id: transactionId } = req.body;
    const data = await service.verifyAndActivatePremium(req.user.id, {
      productId,
      purchaseToken,
      platform,
      transactionId,
    });
    respond(res, data);
  } catch (err) {
    next(err);
  }
}

module.exports = { verify };
