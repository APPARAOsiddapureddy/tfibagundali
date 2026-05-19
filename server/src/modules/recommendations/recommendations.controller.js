const homeFeed = require('./home-feed.service');
const related = require('./related.service');
const quizRec = require('./quiz-rec.service');
const pollRec = require('./poll-rec.service');
const exploreRec = require('./explore-rec.service');
const notifications = require('./notifications.service');
const events = require('./events.service');
const contentFeatures = require('./content-features.service');

async function getHome(req, res, next) {
  try {
    const data = await homeFeed.getHomeFeed(req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getHomeFeedAlias(req, res, next) {
  return getHome(req, res, next);
}

async function getUpdates(req, res, next) {
  try {
    const limit = Math.min(50, parseInt(req.query.limit, 10) || 20);
    const offset = parseInt(req.query.offset, 10) || 0;
    const data = await homeFeed.getUpdatesFeed(req.user?.id, { limit, offset });
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getExplore(req, res, next) {
  try {
    const data = await exploreRec.getExploreRecommendations(req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getQuizzes(req, res, next) {
  try {
    const data = await quizRec.getQuizRecommendations(req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getPolls(req, res, next) {
  try {
    const data = await pollRec.getPollRecommendations(req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getRelated(req, res, next) {
  try {
    const { content_type, content_id } = req.query;
    if (!content_type || !content_id) {
      return res.status(400).json({
        success: false,
        error: { message: 'content_type and content_id required', code: 'BAD_REQUEST' },
      });
    }
    const data = await related.getRelatedContent(content_type, content_id, req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function postEvent(req, res, next) {
  try {
    const data = await events.trackEvent({ ...req.body, user_id: req.user?.id || req.body.user_id });
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function notInterested(req, res, next) {
  try {
    const { type, id } = req.params;
    const data = await events.markNotInterested(req.user.id, type, id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function hideContent(req, res, next) {
  try {
    const { type, id } = req.params;
    const data = await events.hideContent(req.user.id, type, id, req.body.reason);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getNotificationTargets(req, res, next) {
  try {
    const data = await notifications.getNotificationTargets(req.user.id, {
      limit: parseInt(req.query.limit, 10) || 10,
    });
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function syncFeatures(req, res, next) {
  try {
    const data = await contentFeatures.syncAllContentFeatures();
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

module.exports = {
  getHome,
  getHomeFeedAlias,
  getUpdates,
  getExplore,
  getQuizzes,
  getPolls,
  getRelated,
  postEvent,
  notInterested,
  hideContent,
  getNotificationTargets,
  syncFeatures,
};
