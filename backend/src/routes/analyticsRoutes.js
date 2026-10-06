/**
 * Analytics & Reports Routes for Nirmaan (Phase 6).
 *
 * Provides historical operational analytics and report generation.
 * Strictly enforces authentication, tenant isolation, and RBAC.
 */

const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');

const ALLOWED_ANALYTICS_ROLES = [
  ROLES.BUSINESS_OWNER,
  ROLES.STORE_MANAGER,
  ROLES.ADMINISTRATOR,
];

router.use(authenticate);
router.use(enforceTenant);

/**
 * @route   GET /api/v1/analytics
 * @desc    Get operational analytics overview for the authenticated business
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/', requireRoles(ALLOWED_ANALYTICS_ROLES), (req, res, next) =>
  analyticsController.getAnalytics(req, res, next)
);

/**
 * @route   GET /api/v1/analytics/reports
 * @desc    Generate formal report (SALES, PRODUCTS, INVENTORY, CUSTOMERS)
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/reports', requireRoles(ALLOWED_ANALYTICS_ROLES), (req, res, next) =>
  analyticsController.getReport(req, res, next)
);

module.exports = router;
