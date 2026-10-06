const express = require('express');
const router = express.Router();
const supplierController = require('../controllers/supplierController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { validateCreateSupplier } = require('../validators/operationalValidators');

router.use(authenticate);
router.use(enforceTenant);

router.get(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => supplierController.list(req, res, next)
);

router.get(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => supplierController.getById(req, res, next)
);

router.post(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  validateCreateSupplier,
  (req, res, next) => supplierController.create(req, res, next)
);

router.put(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => supplierController.update(req, res, next)
);

router.delete(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => supplierController.deactivate(req, res, next)
);

module.exports = router;
