const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { validateCreateOrder } = require('../validators/operationalValidators');

router.use(authenticate);
router.use(enforceTenant);

router.get(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => orderController.list(req, res, next)
);

router.get(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => orderController.getById(req, res, next)
);

router.post(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  validateCreateOrder,
  (req, res, next) => orderController.create(req, res, next)
);

router.post(
  '/:id/cancel',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => orderController.cancel(req, res, next)
);

module.exports = router;
