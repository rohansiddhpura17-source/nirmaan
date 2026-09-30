class ApiEndpoints {
  static const String health = '/health';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String ownerDashboard = '/auth/owner-dashboard';
  static const String adminGovernance = '/auth/admin-governance';

  // Core Operations (Phase 3-4 endpoints)
  static const String businessProfile = '/business/profile';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String orders = '/orders';
  static const String customers = '/customers';

  // Analytics & AI
  static const String analytics = '/analytics';
  static const String businessHealth = '/business/health';
  static const String aiCoach = '/ai/coach';
  static const String dailyBrief = '/ai/daily-brief';
}
