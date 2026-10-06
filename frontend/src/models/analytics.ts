export interface DailyMetrics {
  totalRevenue: number;
  revenueChangePercent: number;
  orderCount: number;
  orderCountChangePercent: number;
  averageOrderValue: number;
  lowStockItemsCount: number;
  totalCustomers: number;
}

export interface BusinessHealthMetrics {
  overallScore: number; // 0 - 100
  profitabilityScore: number;
  inventoryEfficiencyScore: number;
  customerRetentionScore: number;
  cashFlowScore: number;
  insights: string[];
  recommendations: string[];
}
