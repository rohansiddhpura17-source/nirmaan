/**
 * AI Assistant Routes for Nirmaan (Phase 8).
 *
 * Implements endpoints for:
 * - POST /api/v1/ai/coach (Natural-language AI Coach)
 * - GET  /api/v1/ai/daily-brief (Today's Business AI Executive Briefing)
 *
 * Strictly enforces:
 * - Authentication (Firebase JWT)
 * - Multi-tenant isolation (enforceTenant)
 * - RBAC (Owner, Store Manager, Administrator)
 * - Rate Limiting (aiRateLimiter)
 */

const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { aiRateLimiter } = require('../middleware/aiRateLimiter');

const ALLOWED_AI_ROLES = [
  ROLES.BUSINESS_OWNER,
  ROLES.STORE_MANAGER,
  ROLES.ADMINISTRATOR,
];

router.use(authenticate);
router.use(enforceTenant);
router.use(aiRateLimiter);

/**
 * @route   POST /api/v1/ai/coach
 * @desc    Ask natural-language business question to AI Business Coach
 * @access  Protected (Owner, Manager, Admin)
 */
router.post('/coach', requireRoles(ALLOWED_AI_ROLES), (req, res, next) =>
  aiController.askCoach(req, res, next)
);

/**
 * @route   GET /api/v1/ai/daily-brief
 * @desc    Get Today's Business AI Executive Briefing
 * @access  Protected (Owner, Manager, Admin)
 */
router.get('/daily-brief', requireRoles(ALLOWED_AI_ROLES), (req, res, next) =>
  aiController.getDailyBrief(req, res, next)
);

module.exports = router;
