/**
 * Business Intelligence (BI) Controller - Phase 7
 */

const biService = require('../services/biService');

class BiController {
  async getOverview(req, res, next) {
    try {
      const businessId = req.businessId;
      const data = await biService.getBiOverview(businessId);
      return res.status(200).json({
        success: true,
        message: 'Business Intelligence overview generated successfully',
        data,
      });
    } catch (err) {
      return next(err);
    }
  }

  async getHealthScore(req, res, next) {
    try {
      const businessId = req.businessId;
      const data = await biService.getBiOverview(businessId);
      return res.status(200).json({
        success: true,
        message: 'Business Health Score calculated successfully',
        data: {
          businessId,
          businessProfile: data.businessProfile,
          generatedAt: data.generatedAt,
          healthScore: data.healthScore,
        },
      });
    } catch (err) {
      return next(err);
    }
  }

  async getForecast(req, res, next) {
    try {
      const businessId = req.businessId;
      const data = await biService.getBiOverview(businessId);
      return res.status(200).json({
        success: true,
        message: 'Sales forecast generated successfully',
        data: {
          businessId,
          generatedAt: data.generatedAt,
          forecast: data.forecast,
        },
      });
    } catch (err) {
      return next(err);
    }
  }

  async getInventoryIntelligence(req, res, next) {
    try {
      const businessId = req.businessId;
      const data = await biService.getBiOverview(businessId);
      return res.status(200).json({
        success: true,
        message: 'Inventory intelligence generated successfully',
        data: {
          businessId,
          generatedAt: data.generatedAt,
          inventoryIntelligence: data.inventoryIntelligence,
        },
      });
    } catch (err) {
      return next(err);
    }
  }

  async getCustomerRisk(req, res, next) {
    try {
      const businessId = req.businessId;
      const data = await biService.getBiOverview(businessId);
      return res.status(200).json({
        success: true,
        message: 'Customer churn risk signals generated successfully',
        data: {
          businessId,
          generatedAt: data.generatedAt,
          customerRisk: data.customerRisk,
        },
      });
    } catch (err) {
      return next(err);
    }
  }

  async getProductIntelligence(req, res, next) {
    try {
      const businessId = req.businessId;
      const data = await biService.getBiOverview(businessId);
      return res.status(200).json({
        success: true,
        message: 'Product performance intelligence generated successfully',
        data: {
          businessId,
          generatedAt: data.generatedAt,
          productIntelligence: data.productIntelligence,
        },
      });
    } catch (err) {
      return next(err);
    }
  }
}

module.exports = new BiController();
