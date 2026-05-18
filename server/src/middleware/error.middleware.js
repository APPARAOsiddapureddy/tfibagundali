class AppError extends Error {
  constructor(message, statusCode = 400, code = 'BAD_REQUEST') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

function errorMiddleware(err, req, res, _next) {
  const status = err.statusCode || 500;
  const code = err.code || 'INTERNAL_ERROR';
  if (process.env.NODE_ENV !== 'test') {
    console.error(err);
  }
  res.status(status).json({
    success: false,
    error: { code, message: err.message || 'Something went wrong', statusCode: status },
  });
}

module.exports = errorMiddleware;
module.exports.AppError = AppError;
