const queries = require('./fanarmy.queries');
const { redis, getOrSet } = require('../../config/redis');
const { AppError } = require('../../middleware/error.middleware');

async function getAllArmies() {
  return getOrSet('fanarmy:all', 600, () => queries.getAllArmies());
}

async function getLeaderboard() {
  return getOrSet('fanarmy:leaderboard:weekly', 600, () => queries.getLeaderboard());
}

async function joinArmy(userId, armyId) {
  try {
    const result = await queries.joinArmy(userId, armyId);
    await redis.del('fanarmy:all', 'fanarmy:leaderboard:weekly');
    return result;
  } catch (err) {
    if (err.message.includes('3 months')) {
      throw new AppError(err.message, 409, 'ARMY_CHANGE_COOLDOWN');
    }
    throw err;
  }
}

async function getMyArmy(userId) {
  const membership = await queries.getUserMembership(userId);
  if (!membership) return null;
  return membership;
}

async function addActivityPoints(userId, points) {
  try {
    await queries.addArmyPoints(userId, points);
    // Update Redis sorted set
    const membership = await queries.getUserMembership(userId);
    if (membership) {
      await redis.zadd('fanarmy:points:weekly', membership.points, membership.army_id);
    }
  } catch (_) {
    // user may not be in an army — silently ignore
  }
}

async function getActivePoll(userId) {
  const cacheKey = 'polls:active';
  let poll = await redis.get(cacheKey);
  if (poll) {
    poll = JSON.parse(poll);
  } else {
    poll = await queries.getActivePoll();
    if (poll) {
      await redis.setex(cacheKey, 30, JSON.stringify(poll));
    }
  }
  if (!poll) return null;

  const userVote = userId ? await queries.getUserPollVote(userId, poll.id) : null;
  return { ...poll, user_vote: userVote?.option_id || null };
}

async function castVote(userId, pollId, optionId) {
  const existing = await queries.getUserPollVote(userId, pollId);
  if (existing) throw new AppError('Already voted', 409, 'ALREADY_VOTED');

  await queries.castPollVote(userId, pollId, optionId);
  await redis.del('polls:active');

  return { message: 'Vote cast', option_id: optionId };
}

module.exports = { getAllArmies, getLeaderboard, joinArmy, getMyArmy, addActivityPoints, getActivePoll, castVote };
