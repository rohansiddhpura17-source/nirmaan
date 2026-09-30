/**
 * Request Validation Helpers
 */
const { sendError } = require('../utils/responseFormatter');

function validateRequiredFields(fields = []) {
  return (req, res, next) => {
    const missing = [];
    for (const field of fields) {
      if (req.body[field] === undefined || req.body[field] === null || req.body[field] === '') {
        missing.push(field);
      }
    }

    if (missing.length > 0) {
      return sendError(
        res,
        `Validation failed: missing required fields [${missing.join(', ')}]`,
        400,
        missing.map((f) => ({ field: f, message: `${f} is required` }))
      );
    }

    next();
  };
}

module.exports = {
  validateRequiredFields,
};
