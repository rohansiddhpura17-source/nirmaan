const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { validateAdjustStock } = require('../validators/operationalValidators');

router.use(authenticate);
router.use(enforceTenant);

router.get(
  '/summary',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => inventoryController.getSummary(req, res, next)
);

router.get(
  '/items',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => inventoryController.listItems(req, res, next)
);

router.get(
  '/movements',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => inventoryController.getMovements(req, res, next)
);

router.post(
  '/adjust',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  validateAdjustStock,
  (req, res, next) => inventoryController.adjustStock(req, res, next)
);

module.exports = router;
