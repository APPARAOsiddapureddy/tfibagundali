const env = require('../config/env');

function errorMiddleware(err, req, res, _next) {
  const statusCode = err.statusCode || 500;
  const code = err.code || 'INTERNAL_ERROR';

  if (statusCode >= 500) {
    console.error(`[ERROR] ${req.method} ${req.path}:`, err);
  }

  res.status(statusCode).json({
    success: false,
    error: {
      code,
      message: err.message || 'An unexpected error occurred',
      statusCode,
      ...(env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
}

class AppError extends Error {
  constructor(message, statusCode = 400, code = 'BAD_REQUEST') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

function createError(message, statusCode, code) {
  return new AppError(message, statusCode, code);
}

module.exports = errorMiddleware;
module.exports.AppError = AppError;
module.exports.createError = createError;
