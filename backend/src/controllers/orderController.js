const orderService = require('../services/orderService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');

class OrderController {
  async list(req, res, next) {
    try {
      const { q, status, paymentStatus, page, limit } = req.query;
      const result = await orderService.listOrders(req.businessId, {
        query: q,
        status,
        paymentStatus,
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 50,
      });

      return sendSuccess(res, result.items, 'Orders retrieved successfully', 200, {
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
      const order = await orderService.getOrder(req.businessId, req.params.id);
      return sendSuccess(res, order, 'Order details retrieved', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      // Discard client-supplied businessId
      const { businessId, id, orderId, ...orderData } = req.body;
      const idempotencyKey = req.headers['idempotency-key'] || req.body.idempotencyKey || null;

      const result = await orderService.createOrder(
        req.businessId,
        { ...orderData, idempotencyKey },
        req.user.id || req.user.uid
      );

      const status = result.isDuplicate ? 200 : 201;
      const message = result.isDuplicate
        ? 'Duplicate order prevented (idempotency key matched existing order)'
        : 'Order processed successfully, inventory updated, movements recorded';

      return sendSuccess(res, result.order, message, status, {
        isDuplicate: result.isDuplicate,
        movementsCount: result.movementsCount,
      });
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async cancel(req, res, next) {
    try {
      const order = await orderService.cancelOrder(
        req.businessId,
        req.params.id,
        req.user.id || req.user.uid
      );
      return sendSuccess(res, order, 'Order cancelled and stock restored successfully', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }
}

module.exports = new OrderController();
