const service = require('./content.service');
const { respond, parsePagination, buildPaginatedResponse } = require('../../utils/pagination');
const { requireAuth, optionalAuth } = require('../../middleware/auth.middleware');

async function getHomeFeed(req, res, next) {
  try {
    const data = await service.getHomeFeed(req.user.id);
    respond(res, data);
  } catch (err) { next(err); }
}

async function getUpcomingMovies(req, res, next) {
  try {
    const movies = await service.getUpcomingMovies();
    respond(res, { movies });
  } catch (err) { next(err); }
}

async function getMovieById(req, res, next) {
  try {
    const movie = await service.getMovieById(req.params.id);
    respond(res, movie);
  } catch (err) { next(err); }
}

async function setMovieReminder(req, res, next) {
  try {
    const data = await service.setMovieReminder(req.user.id, req.params.id);
    respond(res, data);
  } catch (err) { next(err); }
}

async function getHeroes(req, res, next) {
  try {
    const heroes = await service.getHeroes();
    respond(res, { heroes });
  } catch (err) { next(err); }
}

async function getHeroById(req, res, next) {
  try {
    const hero = await service.getHeroById(req.params.id);
    respond(res, hero);
  } catch (err) { next(err); }
}

async function getShareCards(req, res, next) {
  try {
    const data = await service.getShareCards(req.query);
    respond(res, data);
  } catch (err) { next(err); }
}

async function getShareCardDownload(req, res, next) {
  try {
    const data = await service.getShareCardDownload(req.params.id, req.user.id);
    respond(res, data);
  } catch (err) { next(err); }
}

async function logShare(req, res, next) {
  try {
    const data = await service.logShare(req.user.id, req.params.id);
    respond(res, data);
  } catch (err) { next(err); }
}

module.exports = {
  getHomeFeed, getUpcomingMovies, getMovieById, setMovieReminder,
  getHeroes, getHeroById,
  getShareCards, getShareCardDownload, logShare,
};
