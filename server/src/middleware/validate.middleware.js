const { AppError } = require('./error.middleware');

function validate(schema) {
  return (req, res, next) => {
    const target = { body: req.body, query: req.query, params: req.params };
    const parsed = schema.safeParse(target);
    if (!parsed.success) {
      const msg = parsed.error.errors.map((e) => `${e.path.join('.')}: ${e.message}`).join('; ');
      return next(new AppError(msg, 400, 'VALIDATION_ERROR'));
    }
    if (parsed.data.body) req.body = parsed.data.body;
    if (parsed.data.query) req.query = parsed.data.query;
    if (parsed.data.params) req.params = parsed.data.params;
    next();
  };
}

module.exports = { validate };
