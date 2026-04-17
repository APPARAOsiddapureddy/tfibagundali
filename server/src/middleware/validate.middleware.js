const { AppError } = require('./error.middleware');

function validate(schema) {
  return (req, res, next) => {
    const result = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
    });
    if (!result.success) {
      const messages = result.error.errors.map(e => `${e.path.slice(1).join('.')}: ${e.message}`).join(', ');
      return next(new AppError(messages, 400, 'VALIDATION_ERROR'));
    }
    req.validated = result.data;
    next();
  };
}

module.exports = { validate };
