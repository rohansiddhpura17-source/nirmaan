const { sendError } = require('../utils/responseFormatter');
const { ROLES } = require('../middleware/rbacMiddleware');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PHONE_REGEX = /^[+]?[\d\s-]{10,15}$/;

/**
 * Validates registration input
 * SECURITY RULE: Public registration cannot create Administrator accounts.
 */
function validateRegister(req, res, next) {
  const { name, email, password, role, phone } = req.body;
  const errors = [];

  if (!name || typeof name !== 'string' || name.trim().length < 2) {
    errors.push({ field: 'name', message: 'Name must be at least 2 characters long' });
  }

  if (!email || typeof email !== 'string' || !EMAIL_REGEX.test(email.trim())) {
    errors.push({ field: 'email', message: 'Valid email address is required' });
  }

  if (!password || typeof password !== 'string' || password.length < 6) {
    errors.push({ field: 'password', message: 'Password must be at least 6 characters long' });
  }

  // Security enforcement: Administrator role escalation prevention
  if (role && role.toUpperCase() === ROLES.ADMINISTRATOR) {
    return sendError(
      res,
      'Administrator accounts cannot be created via public registration. System governance authorization is required.',
      403,
      [{ field: 'role', message: 'Unauthorized role assignment: ADMINISTRATOR' }]
    );
  }

  const validRoles = [ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF];
  if (role && !validRoles.includes(role.toUpperCase())) {
    errors.push({
      field: 'role',
      message: `Role must be one of: ${validRoles.join(', ')}`,
    });
  }

  if (phone && (typeof phone !== 'string' || !PHONE_REGEX.test(phone.trim()))) {
    errors.push({
      field: 'phone',
      message: 'Invalid phone number format. Provide 10-15 digits with optional country code',
    });
  }

  if (errors.length > 0) {
    return sendError(res, 'Registration validation failed', 400, errors);
  }

  next();
}

function validateLogin(req, res, next) {
  const { email, password } = req.body;
  const errors = [];

  if (!email || typeof email !== 'string' || !EMAIL_REGEX.test(email.trim())) {
    errors.push({ field: 'email', message: 'Valid email address is required' });
  }

  if (!password || typeof password !== 'string' || password.length === 0) {
    errors.push({ field: 'password', message: 'Password is required' });
  }

  if (errors.length > 0) {
    return sendError(res, 'Login validation failed', 400, errors);
  }

  next();
}

function validateForgotPassword(req, res, next) {
  const { email } = req.body;

  if (!email || typeof email !== 'string' || !EMAIL_REGEX.test(email.trim())) {
    return sendError(res, 'Valid email address is required for password reset', 400, [
      { field: 'email', message: 'Invalid or missing email' },
    ]);
  }

  next();
}

const GSTIN_REGEX = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;

function validateBusinessSetup(req, res, next) {
  const { businessName, businessCategory, category, phone, address, gstNumber, currency } = req.body;
  const errors = [];

  const name = businessName || req.body.name;
  if (!name || typeof name !== 'string' || name.trim().length < 2) {
    errors.push({ field: 'businessName', message: 'Business name must be at least 2 characters long' });
  }

  const cat = businessCategory || category;
  if (!cat || typeof cat !== 'string' || cat.trim().length < 2) {
    errors.push({ field: 'businessCategory', message: 'Business category is required' });
  }

  if (!phone || typeof phone !== 'string' || phone.trim().length < 7 || !PHONE_REGEX.test(phone.trim())) {
    errors.push({ field: 'phone', message: 'Valid store contact number is required' });
  }

  if (!address || typeof address !== 'string' || address.trim().length < 5) {
    errors.push({ field: 'address', message: 'Valid store address is required (minimum 5 characters)' });
  }

  if (gstNumber && typeof gstNumber === 'string' && gstNumber.trim().length > 0) {
    const trimmedGst = gstNumber.trim().toUpperCase();
    if (!GSTIN_REGEX.test(trimmedGst)) {
      errors.push({ field: 'gstNumber', message: 'Invalid GSTIN format. Example: 24ABCDE1234F1Z5' });
    }
  }

  if (currency && typeof currency === 'string' && !['INR', '₹', 'USD', '$', 'EUR', '€', 'GBP', '£'].includes(currency.trim())) {
    errors.push({ field: 'currency', message: 'Invalid currency code or symbol' });
  }

  if (errors.length > 0) {
    return sendError(res, 'Business setup validation failed', 400, errors);
  }

  next();
}

module.exports = {
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateBusinessSetup,
};
