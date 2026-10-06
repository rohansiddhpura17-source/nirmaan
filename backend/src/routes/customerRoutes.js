const express = require('express');
const router = express.Router();
const customerController = require('../controllers/customerController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { validateCreateCustomer } = require('../validators/operationalValidators');

router.use(authenticate);
router.use(enforceTenant);

router.get(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => customerController.list(req, res, next)
);

router.get(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => customerController.getById(req, res, next)
);

router.post(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  validateCreateCustomer,
  (req, res, next) => customerController.create(req, res, next)
);

router.put(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => customerController.update(req, res, next)
);

router.delete(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => customerController.delete(req, res, next)
);

module.exports = router;
