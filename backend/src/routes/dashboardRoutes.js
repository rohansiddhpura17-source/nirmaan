/**
 * Dashboard Routes for Nirmaan Web (Phase 5).
 * 
 * Provides aggregated business metrics for the authenticated business.
 * Strictly enforces authentication, tenant isolation, and RBAC.
 */

const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');

// All operational roles have read access to the dashboard metrics
const ALLOWED_DASHBOARD_ROLES = [
  ROLES.BUSINESS_OWNER,
  ROLES.STORE_MANAGER,
  ROLES.SALES_STAFF,
  ROLES.ADMINISTRATOR,
];

router.use(authenticate);
router.use(enforceTenant);

/**
 * @route   GET /api/v1/dashboard
 * @desc    Get aggregated real-time dashboard data for the authenticated business
 * @access  Protected (All authenticated business roles)
 */
router.get('/', requireRoles(ALLOWED_DASHBOARD_ROLES), (req, res, next) =>
  dashboardController.getDashboard(req, res, next)
);

module.exports = router;
