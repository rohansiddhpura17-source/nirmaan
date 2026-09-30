import '../../models/customer.dart';
import '../../models/order.dart';
import '../../models/product.dart';

/// ============================================================================
/// PRESENTATION SEED DATA (FIGMA VISUAL COMPLIANCE)
/// ============================================================================
/// This file centralizes all static mock/seed data used strictly to reproduce
/// the visual layouts, cards, and metrics depicted in the approved Figma design.
///
/// ARCHITECTURAL SEPARATION NOTICE:
/// - Presentation Seed Data: Only used for visual verification and UI testing.
/// - Live Application Data: Will flow through Repositories, Streams, and Firestore
///   once Phase 4 (Core Operations) and Phase 5 (Dashboard) are implemented.
/// - Never treat this data as the production persistence layer.
/// ============================================================================

class PresentationSeedData {
  PresentationSeedData._();

  // --------------------------------------------------------------------------
  // Dashboard Metrics & Signals (Figma Frame 1: Home Dashboard)
  // --------------------------------------------------------------------------
  static const double todaySales = 18450.0;
  static const double salesGrowthPercent = 14.2;
  static const int totalOrdersToday = 42;
  static const int pendingOrders = 5;
  static const int lowStockCount = 3;
  static const int businessHealthScore = 88;

  static const List<Map<String, dynamic>> dashboardAlerts = [
    {
      'title': 'Fortune Sunflower Oil (1L)',
      'subtitle': 'Only 2 units remaining (Min threshold: 10)',
      'severity': 'critical',
      'icon': 'inventory_2',
    },
    {
      'title': 'Royal Basmati Rice (5kg)',
      'subtitle': '4 units remaining (Velocity: 3/day)',
      'severity': 'warning',
      'icon': 'inventory_2',
    },
    {
      'title': '12 Inactive Customers',
      'subtitle': 'No purchases in > 21 days (Prev. avg: ₹1,200/mo)',
      'severity': 'info',
      'icon': 'people_alt',
    },
  ];

  // --------------------------------------------------------------------------
  // Catalog & Inventory Seed Products (Figma Frames: Products & Inventory)
  // --------------------------------------------------------------------------
  static final List<ProductModel> seedProducts = [
    ProductModel(
      id: 'prod_001',
      name: 'Fortune Sunflower Oil 1L',
      sku: 'SKU-OIL-001',
      barcode: '8901234567890',
      category: 'Edible Oils',
      purchasePrice: 135.0,
      sellingPrice: 165.0,
      currentStock: 2,
      minStockThreshold: 10,
      unit: 'bottle',
      description: 'Refined sunflower oil for cooking',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    ProductModel(
      id: 'prod_002',
      name: 'Royal Basmati Rice 5kg',
      sku: 'SKU-RICE-002',
      barcode: '8901234567891',
      category: 'Grains & Staples',
      purchasePrice: 380.0,
      sellingPrice: 475.0,
      currentStock: 4,
      minStockThreshold: 15,
      unit: 'bag',
      description: 'Premium aged long-grain basmati rice',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    ProductModel(
      id: 'prod_003',
      name: 'Aashirvaad Atta 10kg',
      sku: 'SKU-ATTA-003',
      barcode: '8901234567892',
      category: 'Grains & Staples',
      purchasePrice: 410.0,
      sellingPrice: 480.0,
      currentStock: 18,
      minStockThreshold: 8,
      unit: 'bag',
      description: '100% whole wheat chakki atta',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    ProductModel(
      id: 'prod_004',
      name: 'Tata Salt 1kg',
      sku: 'SKU-SALT-004',
      barcode: '8901234567893',
      category: 'Spices & Essentials',
      purchasePrice: 22.0,
      sellingPrice: 28.0,
      currentStock: 45,
      minStockThreshold: 20,
      unit: 'packet',
      description: 'Vacuum evaporated iodized salt',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    ProductModel(
      id: 'prod_005',
      name: 'Everest Garam Masala 100g',
      sku: 'SKU-SPICE-005',
      barcode: '8901234567894',
      category: 'Spices & Essentials',
      purchasePrice: 62.0,
      sellingPrice: 85.0,
      currentStock: 28,
      minStockThreshold: 12,
      unit: 'box',
      description: 'Authentic aromatic spice blend',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  // --------------------------------------------------------------------------
  // Orders Seed Data (Figma Frame 2: Sales & Orders)
  // --------------------------------------------------------------------------
  static final List<OrderModel> seedOrders = [
    OrderModel(
      id: 'ord_1001',
      orderNumber: 'ORD-1001',
      customerName: 'Rajesh Kumar',
      customerPhone: '+91 98234 56781',
      items: [
        const OrderItem(
          productId: 'prod_003',
          productName: 'Aashirvaad Atta 10kg',
          quantity: 1,
          unitPrice: 480.0,
        ),
        const OrderItem(
          productId: 'prod_004',
          productName: 'Tata Salt 1kg',
          quantity: 2,
          unitPrice: 28.0,
        ),
      ],
      totalAmount: 536.0,
      status: OrderStatus.completed,
      paymentMethod: 'UPI',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    OrderModel(
      id: 'ord_1002',
      orderNumber: 'ORD-1002',
      customerName: 'Priya Sharma',
      customerPhone: '+91 97123 45678',
      items: [
        const OrderItem(
          productId: 'prod_001',
          productName: 'Fortune Sunflower Oil 1L',
          quantity: 2,
          unitPrice: 165.0,
        ),
      ],
      totalAmount: 330.0,
      status: OrderStatus.pending,
      paymentMethod: 'Cash',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    OrderModel(
      id: 'ord_1003',
      orderNumber: 'ORD-1003',
      customerName: 'Amit Patel',
      customerPhone: '+91 99012 34567',
      items: [
        const OrderItem(
          productId: 'prod_002',
          productName: 'Royal Basmati Rice 5kg',
          quantity: 1,
          unitPrice: 475.0,
        ),
        const OrderItem(
          productId: 'prod_005',
          productName: 'Everest Garam Masala 100g',
          quantity: 2,
          unitPrice: 85.0,
        ),
      ],
      totalAmount: 645.0,
      status: OrderStatus.completed,
      paymentMethod: 'Card',
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
    ),
  ];

  // --------------------------------------------------------------------------
  // Customers Seed Data (Figma Frame 4: Customers)
  // --------------------------------------------------------------------------
  static final List<CustomerModel> seedCustomers = [
    CustomerModel(
      id: 'cust_001',
      name: 'Rajesh Kumar',
      phone: '+91 98234 56781',
      email: 'rajesh.k@gmail.com',
      loyaltyPoints: 340,
      totalOrders: 18,
      totalSpend: 14250.0,
      isChurnRisk: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CustomerModel(
      id: 'cust_002',
      name: 'Priya Sharma',
      phone: '+91 97123 45678',
      email: 'priya.s@outlook.com',
      loyaltyPoints: 120,
      totalOrders: 8,
      totalSpend: 6800.0,
      isChurnRisk: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CustomerModel(
      id: 'cust_003',
      name: 'Amit Patel',
      phone: '+91 99012 34567',
      loyaltyPoints: 50,
      totalOrders: 3,
      totalSpend: 2450.0,
      isChurnRisk: true,
      lastVisit: DateTime.now().subtract(const Duration(days: 24)),
    ),
    CustomerModel(
      id: 'cust_004',
      name: 'Sunita Verma',
      phone: '+91 98765 12345',
      loyaltyPoints: 510,
      totalOrders: 29,
      totalSpend: 28900.0,
      isChurnRisk: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // --------------------------------------------------------------------------
  // Business Health Pillars (Figma Frame: Business Health)
  // --------------------------------------------------------------------------
  static const List<Map<String, dynamic>> healthPillars = [
    {
      'title': 'Cash Flow & Margins',
      'score': 92,
      'status': 'Excellent',
      'details': 'Gross margin at 29.4%, ₹1.2L operating surplus this month.',
      'color': 0xFF10B981,
    },
    {
      'title': 'Inventory Velocity',
      'score': 84,
      'status': 'Good',
      'details': 'Turnover cycle is 18.2 days. 3 low-stock items require PO.',
      'color': 0xFF0284C7,
    },
    {
      'title': 'Customer Retention',
      'score': 79,
      'status': 'Fair',
      'details': 'Repeat rate is 68%. 12 inactive accounts flagged for churn.',
      'color': 0xFFF59E0B,
    },
    {
      'title': 'Operational Compliance',
      'score': 96,
      'status': 'Optimal',
      'details': 'Zero billing discrepancies, audit logs up to date.',
      'color': 0xFF10B981,
    },
  ];

  // --------------------------------------------------------------------------
  // Today's Business Recommendations (Figma Frame: Today's Business)
  // --------------------------------------------------------------------------
  static const List<Map<String, dynamic>> dailyRecommendations = [
    {
      'category': 'Procurement Alert',
      'text': 'Reorder 24 bottles of Fortune Sunflower Oil before Thursday.',
      'impact': 'Prevents ₹3,960 in estimated stockout sales loss.',
      'icon': 'inventory',
    },
    {
      'category': 'Margin Optimization',
      'text': 'Bundle Garam Masala (38% margin) with Basmati Rice.',
      'impact': 'Projected +₹120 lift on average basket size.',
      'icon': 'trending_up',
    },
    {
      'category': 'Customer Recovery',
      'text': 'Send WhatsApp 5% loyalty coupon to 12 dormant customers.',
      'impact': 'Estimated ~40% recovery rate based on store history.',
      'icon': 'people',
    },
  ];

  // --------------------------------------------------------------------------
  // Notification Feed (Figma Frame: Notifications)
  // --------------------------------------------------------------------------
  static const List<Map<String, dynamic>> initialNotifications = [
    {
      'title': 'Critical Stock Warning',
      'body': 'Fortune Sunflower Oil 1L is down to 2 units.',
      'time': '10 mins ago',
      'isUnread': true,
      'type': 'inventory',
    },
    {
      'title': 'New High-Value Order',
      'body': 'Order ORD-1003 received for ₹645 from Amit Patel.',
      'time': '2 hours ago',
      'isUnread': true,
      'type': 'order',
    },
    {
      'title': 'Daily AI Brief Ready',
      'body': 'Your store intelligence summary for today is available.',
      'time': '4 hours ago',
      'isUnread': false,
      'type': 'ai',
    },
  ];
}
