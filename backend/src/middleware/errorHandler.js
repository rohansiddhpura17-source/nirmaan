const { sendError } = require('../utils/responseFormatter');

function errorHandler(err, req, res, next) {
  console.error('[Error]', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  return sendError(res, message, statusCode, process.env.NODE_ENV === 'development' ? err.stack : undefined);
}

function notFoundHandler(req, res, next) {
  return sendError(res, `Route not found: ${req.method} ${req.originalUrl}`, 404);
}

module.exports = {
  errorHandler,
  notFoundHandler,
};
