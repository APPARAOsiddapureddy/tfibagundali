const service = require('./updates.service');

async function list(req, res, next) {
  try {
    const data = await service.listUpdates({
      category: req.query.category,
      trust: req.query.trust,
      sort: req.query.sort,
      heroId: req.query.hero_id,
      limit: parseInt(req.query.limit || '20', 10),
      offset: parseInt(req.query.offset || '0', 10),
    });
    res.json({ success: true, data });
  } catch (e) { next(e); }
}

async function getOne(req, res, next) {
  try {
    const data = await service.getUpdate(req.params.id);
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

module.exports = { list, getOne, react, save };
