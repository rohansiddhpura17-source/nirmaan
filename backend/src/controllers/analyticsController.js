const analyticsService = require('../services/analyticsService');

class AnalyticsController {
  /**
   * GET /api/v1/analytics
   * Returns operational analytics overview for the authenticated business.
   */
  async getAnalytics(req, res) {
    try {
      const businessId = req.businessId;
      if (!businessId) {
        return res.status(403).json({
          success: false,
          message: 'Access forbidden: Business profile must be established.',
        });
      }

      const { range, startDate, endDate } = req.query;

      const data = await analyticsService.getAnalyticsOverview(businessId, {
        range,
        startDate,
        endDate,
      });

      return res.status(200).json({
        success: true,
        data,
      });
    } catch (err) {
      console.error('[AnalyticsController] getAnalytics error:', err);
      return res.status(500).json({
        success: false,
        message: err.message || 'Internal server error while fetching analytics',
      });
    }
  }

  /**
   * GET /api/v1/analytics/reports
   * Returns a structured report for sales, products, inventory, or customers.
   */
  async getReport(req, res) {
    try {
      const businessId = req.businessId;
      if (!businessId) {
        return res.status(403).json({
          success: false,
          message: 'Access forbidden: Business profile must be established.',
        });
      }

      const { type = 'SALES', range, startDate, endDate } = req.query;

      const report = await analyticsService.generateReport(businessId, type, {
        range,
        startDate,
        endDate,
      });

      return res.status(200).json({
        success: true,
        data: report,
      });
    } catch (err) {
      console.error('[AnalyticsController] getReport error:', err);
      return res.status(500).json({
        success: false,
        message: err.message || 'Internal server error while generating report',
      });
    }
  }
}

module.exports = new AnalyticsController();
