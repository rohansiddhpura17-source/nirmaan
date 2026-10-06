/**
 * Business Intelligence (BI) Routes for Nirmaan (Phase 7).
 *
 * Provides deterministic, explainable decision-support intelligence.
 * Strictly enforces authentication, tenant isolation, and RBAC.
 */

const express = require('express');
const router = express.Router();
const biController = require('../controllers/biController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');

const ALLOWED_BI_ROLES = [
  ROLES.BUSINESS_OWNER,
  ROLES.STORE_MANAGER,
  ROLES.ADMINISTRATOR,
];

router.use(authenticate);
router.use(enforceTenant);

/**
 * @route   GET /api/v1/bi
 * @route   GET /api/v1/bi/overview
 * @desc    Comprehensive BI overview payload
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/', requireRoles(ALLOWED_BI_ROLES), (req, res, next) =>
  biController.getOverview(req, res, next)
);

router.get('/overview', requireRoles(ALLOWED_BI_ROLES), (req, res, next) =>
  biController.getOverview(req, res, next)
);

/**
 * @route   GET /api/v1/bi/health-score
 * @desc    Dedicated Business Health Score calculation & factor breakdown
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/health-score', requireRoles(ALLOWED_BI_ROLES), (req, res, next) =>
  biController.getHealthScore(req, res, next)
);

/**
 * @route   GET /api/v1/bi/forecast
 * @desc    Sales & demand statistical forecasting
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/forecast', requireRoles(ALLOWED_BI_ROLES), (req, res, next) =>
  biController.getForecast(req, res, next)
);

/**
 * @route   GET /api/v1/bi/inventory-intelligence
 * @desc    Stockouts, low-stock, velocity, and replenishment signals
 * @access  Protected (Owner, Manager, Admin)
 */
router.get(
  '/inventory-intelligence',
  requireRoles(ALLOWED_BI_ROLES),
  (req, res, next) => biController.getInventoryIntelligence(req, res, next)
);

/**
 * @route   GET /api/v1/bi/customer-risk
 * @desc    Customer churn risk & inactivity signals
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/customer-risk', requireRoles(ALLOWED_BI_ROLES), (req, res, next) =>
  biController.getCustomerRisk(req, res, next)
);

/**
 * @route   GET /api/v1/bi/product-intelligence
 * @desc    Product ranking, velocity, and dormancy analysis
 * @access  Protected (Owner, Manager, Admin)
 */
router.get(
  '/product-intelligence',
  requireRoles(ALLOWED_BI_ROLES),
  (req, res, next) => biController.getProductIntelligence(req, res, next)
);

module.exports = router;
