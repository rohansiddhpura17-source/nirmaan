const supplierService = require('../services/supplierService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');

class SupplierController {
  async list(req, res, next) {
    try {
      const { q, status, page, limit } = req.query;
      const result = await supplierService.listSuppliers(req.businessId, {
        query: q,
        status,
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 50,
      });

      return sendSuccess(res, result.items, 'Suppliers retrieved successfully', 200, {
        total: result.total,
        page: result.page,
        limit: result.limit,
        totalPages: result.totalPages,
      });
    } catch (error) {
      next(error);
    }
  }

  async getById(req, res, next) {
    try {
      const supplier = await supplierService.getSupplier(req.businessId, req.params.id);
      return sendSuccess(res, supplier, 'Supplier details retrieved', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const { businessId, id, supplierId, ...safeData } = req.body;
      const supplier = await supplierService.createSupplier(req.businessId, safeData);
      return sendSuccess(res, supplier, 'Supplier added successfully', 201);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const { businessId, id, supplierId, ...safeData } = req.body;
      const supplier = await supplierService.updateSupplier(
        req.businessId,
        req.params.id,
        safeData
      );
      return sendSuccess(res, supplier, 'Supplier details updated', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async deactivate(req, res, next) {
    try {
      const supplier = await supplierService.deactivateSupplier(req.businessId, req.params.id);
      return sendSuccess(res, supplier, 'Supplier deactivated', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }
}

module.exports = new SupplierController();
