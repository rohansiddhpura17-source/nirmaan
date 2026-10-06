class ApiEndpoints {
  static const String health = '/health';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String ownerDashboard = '/auth/owner-dashboard';
  static const String adminGovernance = '/auth/admin-governance';
  static const String businessSetup = '/auth/business-setup';
  static const String business = '/auth/business';

  // Core Operations (Phase 3-4 endpoints)
  static const String businessProfile = '/business/profile';
  static const String products = '/products';
  static const String suppliers = '/suppliers';
  static const String customers = '/customers';
  static const String inventory = '/inventory';
  static const String inventorySummary = '/inventory/summary';
  static const String inventoryItems = '/inventory/items';
  static const String inventoryMovements = '/inventory/movements';
  static const String inventoryAdjust = '/inventory/adjust';
  static const String orders = '/orders';
  static const String dashboard = '/dashboard';

  // Analytics & AI
  static const String analytics = '/analytics';
  static const String reports = '/analytics/reports';
  static const String businessHealth = '/business/health';

  // Business Intelligence (Phase 7)
  static const String biOverview = '/bi/overview';
  static const String biHealthScore = '/bi/health-score';
  static const String biForecast = '/bi/forecast';
  static const String biInventoryIntelligence = '/bi/inventory-intelligence';
  static const String biCustomerRisk = '/bi/customer-risk';
  static const String biProductIntelligence = '/bi/product-intelligence';

  static const String aiCoach = '/ai/coach';
  static const String dailyBrief = '/ai/daily-brief';
}
