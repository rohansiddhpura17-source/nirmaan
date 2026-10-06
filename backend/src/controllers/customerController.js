const customerService = require('../services/customerService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');

class CustomerController {
  async list(req, res, next) {
    try {
      const { q, page, limit } = req.query;
      const result = await customerService.listCustomers(req.businessId, {
        query: q,
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 50,
      });

      return sendSuccess(res, result.items, 'Customers retrieved successfully', 200, {
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
      const customer = await customerService.getCustomer(req.businessId, req.params.id);
      return sendSuccess(res, customer, 'Customer details retrieved', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const { businessId, id, customerId, ...safeData } = req.body;
      const customer = await customerService.createCustomer(req.businessId, safeData);
      return sendSuccess(res, customer, 'Customer record created successfully', 201);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const { businessId, id, customerId, ...safeData } = req.body;
      const customer = await customerService.updateCustomer(
        req.businessId,
        req.params.id,
        safeData
      );
      return sendSuccess(res, customer, 'Customer details updated', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      await customerService.deleteCustomer(req.businessId, req.params.id);
      return sendSuccess(res, { deleted: true }, 'Customer removed successfully', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }
}

module.exports = new CustomerController();
