const service = require('./quiz.service');
const { respond } = require('../../utils/pagination');

async function getToday(req, res, next) {
  try {
    const data = await service.getToday(req.user.id);
    respond(res, data);
  } catch (err) { next(err); }
}

async function startSession(req, res, next) {
  try {
    const data = await service.startSession(req.user.id);
    respond(res, data);
  } catch (err) { next(err); }
}

async function submitAnswer(req, res, next) {
  try {
    const { question_id, selected_option, time_taken_ms } = req.body;
    const data = await service.submitAnswer(
      req.user.id, req.params.id, question_id, selected_option, time_taken_ms
    );
    respond(res, data);
  } catch (err) { next(err); }
}

async function completeSession(req, res, next) {
  try {
    const data = await service.completeSession(
      req.user.id, req.params.id, req.body.total_time_taken_ms
    );
    respond(res, data);
  } catch (err) { next(err); }
}

async function getDailyLeaderboard(req, res, next) {
  try {
    const rows = await service.getDailyLeaderboard();
    respond(res, { leaderboard: rows });
  } catch (err) { next(err); }
}

async function getWeeklyLeaderboard(req, res, next) {
  try {
    const rows = await service.getWeeklyLeaderboard();
    respond(res, { leaderboard: rows });
  } catch (err) { next(err); }
}

async function getHistory(req, res, next) {
  try {
    const rows = await service.getUserHistory(req.user.id);
    respond(res, { history: rows });
  } catch (err) { next(err); }
}

async function getStreak(req, res, next) {
  try {
    const data = await service.getStreak(req.user.id);
    respond(res, data);
  } catch (err) { next(err); }
}

module.exports = { getToday, startSession, submitAnswer, completeSession, getDailyLeaderboard, getWeeklyLeaderboard, getHistory, getStreak };
