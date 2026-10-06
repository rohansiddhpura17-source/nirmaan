const productService = require('../services/productService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');

class ProductController {
  async list(req, res, next) {
    try {
      const { q, category, stockStatus, status, page, limit } = req.query;
      const result = await productService.listProducts(req.businessId, {
        query: q,
        category,
        stockStatus,
        status,
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 50,
      });

      return sendSuccess(res, result.items, 'Products retrieved successfully', 200, {
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
      const product = await productService.getProduct(req.businessId, req.params.id);
      return sendSuccess(res, product, 'Product details retrieved', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      // Discard any client-supplied businessId or id
      const { businessId, id, productId, ...safeData } = req.body;
      const product = await productService.createProduct(
        req.businessId,
        safeData,
        req.user.id || req.user.uid
      );
      return sendSuccess(res, product, 'Product created successfully in catalog', 201);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const { businessId, id, productId, ...safeData } = req.body;
      const product = await productService.updateProduct(
        req.businessId,
        req.params.id,
        safeData
      );
      return sendSuccess(res, product, 'Product updated successfully', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }

  async archive(req, res, next) {
    try {
      const product = await productService.archiveProduct(req.businessId, req.params.id);
      return sendSuccess(res, product, 'Product archived successfully', 200);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode, error.errors);
      }
      next(error);
    }
  }
}

module.exports = new ProductController();
