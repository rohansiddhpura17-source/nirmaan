/**
 * Dashboard Controller for Nirmaan Web (Phase 5).
 */

const dashboardService = require('../services/dashboardService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');

class DashboardController {
  async getDashboard(req, res) {
    try {
      const businessId = req.tenantId || req.user?.businessId;
      if (!businessId) {
        return sendError(res, 'User is not associated with any business', 403);
      }

      const data = await dashboardService.getDashboardData(businessId);
      return sendSuccess(res, data, 'Dashboard aggregated successfully');
    } catch (err) {
      console.error('[DashboardController] Error:', err);
      return sendError(res, err.message || 'Failed to aggregate dashboard metrics', 500);
    }
  }
}

module.exports = new DashboardController();
