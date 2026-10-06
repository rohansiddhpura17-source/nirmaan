export interface DashboardMetrics {
  todayRevenue: number;
  todayOrdersCount: number;
  averageOrderValue: number;
  lowStockCount: number;
  outOfStockCount: number;
  totalStockAlerts: number;
  totalCustomers: number;
  totalProducts: number;
  activeKhataCustomers: number;
  totalOutstandingKhata: number;
}

export interface DashboardRecentOrder {
  id: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string | null;
  totalAmount: number;
  status: 'COMPLETED' | 'PENDING' | 'CANCELLED';
  paymentMethod: string;
  itemCount: number;
  createdAt: string;
}

export interface DashboardStockAlert {
  id: string;
  name: string;
  sku: string;
  category: string;
  stockQuantity: number;
  minStockThreshold: number;
  unit: string;
  stockStatus: 'LOW_STOCK' | 'OUT_OF_STOCK';
}

export interface DashboardTopProduct {
  productId: string;
  name: string;
  sku: string;
  quantitySold: number;
  revenue: number;
}

export interface DashboardBusinessHealth {
  status: 'UNAVAILABLE' | 'EVALUATING' | 'CONFIGURED';
  score: number | null;
  message: string;
  isConfigured: boolean;
}

export interface DashboardData {
  businessId: string;
  timezone: string;
  today: string;
  metrics: DashboardMetrics;
  recentOrders: DashboardRecentOrder[];
  stockAlerts: DashboardStockAlert[];
  topProducts: DashboardTopProduct[];
  businessHealth: DashboardBusinessHealth;
}
