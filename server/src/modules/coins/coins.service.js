const queries = require('./coins.queries');
const { redis } = require('../../config/redis');
const db = require('../../config/db');
const { AppError } = require('../../middleware/error.middleware');
const { parsePagination } = require('../../utils/pagination');

async function getBalance(userId) {
  const cacheKey = `user:coins:${userId}`;
  const cached = await redis.get(cacheKey);
  if (cached !== null) return parseInt(cached, 10);

  const balance = await queries.getBalance(userId);
  await redis.setex(cacheKey, 60, String(balance));
  return balance;
}

async function awardCoins(userId, amount, type, referenceId, note) {
  const newBalance = await db.transaction(async (client) => {
    return queries.addLedgerEntry(client, userId, amount, type, referenceId, note);
  });
  await redis.del(`user:coins:${userId}`);
  return newBalance;
}

async function spendCoins(userId, amount, type, referenceId, note) {
  const balance = await getBalance(userId);
  if (balance < amount) throw new AppError('Insufficient coins', 400, 'INSUFFICIENT_COINS');

  const newBalance = await db.transaction(async (client) => {
    return queries.addLedgerEntry(client, userId, -amount, type, referenceId, note);
  });
  await redis.del(`user:coins:${userId}`);
  return newBalance;
}

async function getHistory(userId, query) {
  const { limit, offset, page } = parsePagination(query);
  return queries.getHistory(userId, limit, offset);
}

async function getStore() {
  return queries.getRedemptions();
}

async function redeem(userId, itemId) {
  const items = await queries.getRedemptions();
  const item = items.find(i => i.id === itemId);
  if (!item) throw new AppError('Redemption item not found', 404, 'NOT_FOUND');

  const newBalance = await spendCoins(userId, item.cost, 'redeem_' + item.type, itemId, `Redeemed: ${item.name}`);
  return { message: 'Redeemed successfully', item, remaining_balance: newBalance };
}

module.exports = { getBalance, awardCoins, spendCoins, getHistory, getStore, redeem };
