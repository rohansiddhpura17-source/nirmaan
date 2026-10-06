const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const {
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateBusinessSetup,
} = require('../validators/authValidators');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { sendSuccess } = require('../utils/responseFormatter');

// Public Authentication Endpoints
router.post('/register', validateRegister, (req, res, next) =>
  authController.register(req, res, next)
);

router.post('/login', validateLogin, (req, res, next) =>
  authController.login(req, res, next)
);

router.post('/forgot-password', validateForgotPassword, (req, res, next) =>
  authController.forgotPassword(req, res, next)
);

// Protected Authentication & Profile Endpoints
router.get('/me', authenticate, (req, res, next) =>
  authController.getProfile(req, res, next)
);

router.post('/business-setup', authenticate, validateBusinessSetup, (req, res, next) =>
  authController.completeBusinessSetup(req, res, next)
);

router.get('/business', authenticate, (req, res, next) =>
  authController.getBusiness(req, res, next)
);

router.post('/logout', authenticate, (req, res, next) =>
  authController.logout(req, res, next)
);

router.post('/seed-demo', authenticate, (req, res, next) =>
  authController.seedDemo(req, res, next)
);

// RBAC Role Verification Test Endpoints
router.get(
  '/owner-dashboard',
  authenticate,
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.ADMINISTRATOR]),
  (req, res) => {
    return sendSuccess(res, {
      access: 'GRANTED',
      message: 'Owner Business Intelligence Access',
      userRole: req.user.role,
    });
  }
);

router.get(
  '/manager-operations',
  authenticate,
  requireRoles([ROLES.STORE_MANAGER, ROLES.BUSINESS_OWNER, ROLES.ADMINISTRATOR]),
  (req, res) => {
    return sendSuccess(res, {
      access: 'GRANTED',
      message: 'Store Operations & Inventory Access',
      userRole: req.user.role,
    });
  }
);

router.get(
  '/admin-governance',
  authenticate,
  requireRoles([ROLES.ADMINISTRATOR]),
  (req, res) => {
    return sendSuccess(res, {
      access: 'GRANTED',
      message: 'System Administration & Governance Access',
      userRole: req.user.role,
    });
  }
);

module.exports = router;
