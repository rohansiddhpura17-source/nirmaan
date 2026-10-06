import { apiClient } from './apiClient';
import { DashboardData } from '@/models/dashboard';

export const dashboardService = {
  /**
   * Fetches aggregated live metrics, recent orders, stock alerts, and top products
   * for the authenticated business.
   */
  async getDashboard(): Promise<DashboardData> {
    const res = await apiClient.get<{ success: boolean; data: DashboardData }>('/dashboard');
    return res.data;
  },
};
