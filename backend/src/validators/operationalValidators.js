/**
 * Operational Input Validators
 * Enforces field validations and boundary constraints for Products, Inventory, Customers, Suppliers, and Orders
 */
const { sendError } = require('../utils/responseFormatter');

function validateCreateProduct(req, res, next) {
  const { name, category, sellingPrice, purchasePrice, costPrice, currentStock, stockQuantity, minStockThreshold, minThreshold } = req.body;
  const errors = {};

  if (!name || typeof name !== 'string' || name.trim().length === 0) {
    errors.name = 'Product name is required and cannot be empty';
  }

  if (!category || typeof category !== 'string' || category.trim().length === 0) {
    errors.category = 'Category is required';
  }

  const pPrice = purchasePrice !== undefined ? Number(purchasePrice) : (costPrice !== undefined ? Number(costPrice) : 0);
  if (isNaN(pPrice) || pPrice < 0) {
    errors.purchasePrice = 'Purchase / Cost price must be a valid number greater than or equal to 0';
  }

  const sPrice = Number(sellingPrice);
  if (sellingPrice === undefined || isNaN(sPrice) || sPrice < 0) {
    errors.sellingPrice = 'Selling price must be a valid number greater than or equal to 0';
  }

  const stock = currentStock !== undefined ? Number(currentStock) : (stockQuantity !== undefined ? Number(stockQuantity) : 0);
  if (isNaN(stock) || stock < 0) {
    errors.currentStock = 'Stock quantity cannot be negative';
  }

  const minStock = minStockThreshold !== undefined ? Number(minStockThreshold) : (minThreshold !== undefined ? Number(minThreshold) : 5);
  if (isNaN(minStock) || minStock < 0) {
    errors.minStockThreshold = 'Minimum stock threshold cannot be negative';
  }

  if (Object.keys(errors).length > 0) {
    return sendError(res, 'Validation failed: Invalid product details', 400, errors);
  }

  next();
}

function validateUpdateProduct(req, res, next) {
  const { name, sellingPrice, purchasePrice, costPrice, currentStock, stockQuantity } = req.body;
  const errors = {};

  if (name !== undefined && (typeof name !== 'string' || name.trim().length === 0)) {
    errors.name = 'Product name cannot be empty';
  }

  if (sellingPrice !== undefined) {
    const sPrice = Number(sellingPrice);
    if (isNaN(sPrice) || sPrice < 0) {
      errors.sellingPrice = 'Selling price must be >= 0';
    }
  }

  const pPrice = purchasePrice !== undefined ? purchasePrice : costPrice;
  if (pPrice !== undefined) {
    const parsed = Number(pPrice);
    if (isNaN(parsed) || parsed < 0) {
      errors.purchasePrice = 'Purchase price must be >= 0';
    }
  }

  const stock = currentStock !== undefined ? currentStock : stockQuantity;
  if (stock !== undefined) {
    const parsed = Number(stock);
    if (isNaN(parsed) || parsed < 0) {
      errors.currentStock = 'Stock quantity cannot be negative';
    }
  }

  if (Object.keys(errors).length > 0) {
    return sendError(res, 'Validation failed', 400, errors);
  }

  next();
}

function validateAdjustStock(req, res, next) {
  const { productId, type, quantity, reason } = req.body;
  const errors = {};

  if (!productId || typeof productId !== 'string') {
    errors.productId = 'Product ID is required';
  }

  const validTypes = ['RESTOCK', 'ADJUSTMENT', 'RETURN'];
  if (!type || !validTypes.includes(type.toUpperCase())) {
    errors.type = `Movement type must be one of: ${validTypes.join(', ')}`;
  }

  const qty = Number(quantity);
  if (quantity === undefined || isNaN(qty) || qty <= 0) {
    errors.quantity = 'Quantity must be a positive number greater than 0';
  }

  if (!reason || typeof reason !== 'string' || reason.trim().length < 3) {
    errors.reason = 'Reason is required (min 3 characters)';
  }

  if (Object.keys(errors).length > 0) {
    return sendError(res, 'Validation failed: Invalid stock adjustment', 400, errors);
  }

  next();
}

function validateCreateCustomer(req, res, next) {
  const { name, phone } = req.body;
  const errors = {};

  if (!name || typeof name !== 'string' || name.trim().length === 0) {
    errors.name = 'Customer name is required';
  }

  const phoneRegex = /^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]{6,15}$/;
  if (!phone || typeof phone !== 'string' || !phoneRegex.test(phone.trim())) {
    errors.phone = 'Valid phone number is required (7-15 digits)';
  }

  if (Object.keys(errors).length > 0) {
    return sendError(res, 'Validation failed: Invalid customer details', 400, errors);
  }

  next();
}

function validateCreateSupplier(req, res, next) {
  const { name, phone } = req.body;
  const errors = {};

  if (!name || typeof name !== 'string' || name.trim().length === 0) {
    errors.name = 'Supplier name is required';
  }

  const phoneRegex = /^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]{6,15}$/;
  if (!phone || typeof phone !== 'string' || !phoneRegex.test(phone.trim())) {
    errors.phone = 'Valid supplier phone number is required';
  }

  if (Object.keys(errors).length > 0) {
    return sendError(res, 'Validation failed: Invalid supplier details', 400, errors);
  }

  next();
}

function validateCreateOrder(req, res, next) {
  const { items, paymentMethod } = req.body;
  const errors = {};

  if (!items || !Array.isArray(items) || items.length === 0) {
    errors.items = 'Order must contain at least one product item';
  } else {
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      if (!it.productId || typeof it.productId !== 'string') {
        errors[`items[${i}].productId`] = 'Product ID is required for each line item';
      }
      const qty = Number(it.quantity);
      if (it.quantity === undefined || isNaN(qty) || qty <= 0) {
        errors[`items[${i}].quantity`] = 'Quantity must be a positive integer greater than 0';
      }
    }
  }

  const validPayment = ['CASH', 'UPI', 'CARD', 'CREDIT'];
  if (paymentMethod && !validPayment.includes(paymentMethod.toUpperCase())) {
    errors.paymentMethod = `Payment method must be one of: ${validPayment.join(', ')}`;
  }

  if (Object.keys(errors).length > 0) {
    return sendError(res, 'Validation failed: Invalid order submission', 400, errors);
  }

  next();
}

module.exports = {
  validateCreateProduct,
  validateUpdateProduct,
  validateAdjustStock,
  validateCreateCustomer,
  validateCreateSupplier,
  validateCreateOrder,
};
