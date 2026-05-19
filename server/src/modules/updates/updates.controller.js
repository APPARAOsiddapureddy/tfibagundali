const service = require('./updates.service');

async function list(req, res, next) {
  try {
    const { category, status, hero_id, movie_id, priority, q, sort, page, limit } = req.query;
    const data = await service.listUpdates({
      category,
      status,
      heroId: hero_id,
      movieId: movie_id,
      priority,
      q,
      sort,
      page: parseInt(page, 10) || 1,
      limit: Math.min(50, parseInt(limit, 10) || 20),
    }, req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getOne(req, res, next) {
  try {
    const data = await service.getUpdate(req.params.id, req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function view(req, res, next) {
  try {
    const data = await service.recordView(req.user?.id, req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function react(req, res, next) {
  try {
    const data = await service.react(req.user.id, req.params.id, req.body.reaction);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function save(req, res, next) {
  try {
    const data = await service.save(req.user.id, req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function unsave(req, res, next) {
  try {
    const data = await service.unsave(req.user.id, req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function share(req, res, next) {
  try {
    const data = await service.share(req.user.id, req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function notInterested(req, res, next) {
  try {
    const data = await service.notInterested(req.user.id, req.params.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getRelated(req, res, next) {
  try {
    const related = require('../recommendations/related.service');
    const data = await related.getRelatedContent('update', req.params.id, req.user?.id);
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

module.exports = { list, getOne, view, react, save, unsave, share, notInterested, getRelated };
