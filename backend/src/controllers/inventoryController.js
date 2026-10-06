const inventoryService = require('../services/inventoryService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');

class InventoryController {
  async getSummary(req, res, next) {
    try {
      const summary = await inventoryService.getInventorySummary(req.businessId);
      return sendSuccess(res, summary, 'Inventory summary metrics retrieved', 200);
    } catch (error) {
      next(error);
    }
  }

  async listItems(req, res, next) {
    try {
      const { q, category, stockStatus, page, limit } = req.query;
      const result = await inventoryService.listInventoryItems(req.businessId, {
        query: q,
        category,
        stockStatus,
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 50,
      });

      return sendSuccess(res, result.items, 'Inventory items retrieved', 200, {
        total: result.total,
        page: result.page,
        limit: result.limit,
        totalPages: result.totalPages,
      });
    } catch (error) {
      next(error);
    }
  }

  async adjustStock(req, res, next) {
    try {
      const { businessId, ...safeData } = req.body;
      const result = await inventoryService.adjustStock(
        req.businessId,
        safeData,
        req.user.id || req.user.uid
      );
      return sendSuccess(res, result, 'Stock adjustment completed and movement recorded', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async getMovements(req, res, next) {
    try {
      const { productId, type, page, limit } = req.query;
      const result = await inventoryService.getMovements(req.businessId, {
        productId,
        type,
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 50,
      });

      return sendSuccess(res, result.items, 'Inventory movements retrieved', 200, {
        total: result.total,
        page: result.page,
        limit: result.limit,
        totalPages: result.totalPages,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new InventoryController();
