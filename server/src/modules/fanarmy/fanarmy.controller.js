const service = require('./fanarmy.service');
const { respond } = require('../../utils/pagination');

async function getArmies(req, res, next) {
  try {
    const armies = await service.getAllArmies();
    respond(res, { armies });
  } catch (err) { next(err); }
}

async function getLeaderboard(req, res, next) {
  try {
    const leaderboard = await service.getLeaderboard();
    respond(res, { leaderboard });
  } catch (err) { next(err); }
}

async function joinArmy(req, res, next) {
  try {
    await service.joinArmy(req.user.id, req.params.id);
    respond(res, { message: 'Joined army successfully' });
  } catch (err) { next(err); }
}

async function getMyArmy(req, res, next) {
  try {
    const army = await service.getMyArmy(req.user.id);
    respond(res, army || { message: 'Not in any army' });
  } catch (err) { next(err); }
}

async function getActivePoll(req, res, next) {
  try {
    const poll = await service.getActivePoll(req.user?.id);
    respond(res, poll || { message: 'No active poll' });
  } catch (err) { next(err); }
}

async function castVote(req, res, next) {
  try {
    const result = await service.castVote(req.user.id, req.params.id, req.body.option_id);
    respond(res, result);
  } catch (err) { next(err); }
}

module.exports = { getArmies, getLeaderboard, joinArmy, getMyArmy, getActivePoll, castVote };
