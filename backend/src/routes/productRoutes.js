const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { authenticate } = require('../middleware/authMiddleware');
const { enforceTenant } = require('../middleware/tenantMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { validateCreateProduct, validateUpdateProduct } = require('../validators/operationalValidators');

router.use(authenticate);
router.use(enforceTenant);

router.get(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => productController.list(req, res, next)
);

router.get(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.SALES_STAFF, ROLES.ADMINISTRATOR]),
  (req, res, next) => productController.getById(req, res, next)
);

router.post(
  '/',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  validateCreateProduct,
  (req, res, next) => productController.create(req, res, next)
);

router.put(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  validateUpdateProduct,
  (req, res, next) => productController.update(req, res, next)
);

router.delete(
  '/:id',
  requireRoles([ROLES.BUSINESS_OWNER, ROLES.STORE_MANAGER, ROLES.ADMINISTRATOR]),
  (req, res, next) => productController.archive(req, res, next)
);

module.exports = router;
