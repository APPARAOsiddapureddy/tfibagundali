const service = require('./coins.service');
const { respond, parsePagination, buildPaginatedResponse } = require('../../utils/pagination');

async function getBalance(req, res, next) {
  try {
    const balance = await service.getBalance(req.user.id);
    respond(res, { balance });
  } catch (err) { next(err); }
}

async function getHistory(req, res, next) {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { rows, total } = await service.getHistory(req.user.id, req.query);
    respond(res, buildPaginatedResponse(rows, total, page, limit));
  } catch (err) { next(err); }
}

async function getStore(req, res, next) {
  try {
    const items = await service.getStore();
    respond(res, { items });
  } catch (err) { next(err); }
}

async function redeem(req, res, next) {
  try {
    const result = await service.redeem(req.user.id, req.body.item_id);
    respond(res, result);
  } catch (err) { next(err); }
}

module.exports = { getBalance, getHistory, getStore, redeem };
