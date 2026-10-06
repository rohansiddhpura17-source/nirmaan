class DashboardMetricsModel {
  final double todayRevenue;
  final int todayOrdersCount;
  final int todayCancelledOrdersCount;
  final double averageOrderValue;
  final double totalRevenue;
  final int completedOrdersCount;
  final int cancelledOrdersCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int inStockCount;
  final int totalStockAlerts;
  final int totalStockUnits;
  final double inventoryValuation;
  final int totalCustomers;
  final int totalProducts;
  final int activeKhataCustomers;
  final double totalOutstandingKhata;

  const DashboardMetricsModel({
    this.todayRevenue = 0.0,
    this.todayOrdersCount = 0,
    this.todayCancelledOrdersCount = 0,
    this.averageOrderValue = 0.0,
    this.totalRevenue = 0.0,
    this.completedOrdersCount = 0,
    this.cancelledOrdersCount = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.inStockCount = 0,
    this.totalStockAlerts = 0,
    this.totalStockUnits = 0,
    this.inventoryValuation = 0.0,
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.activeKhataCustomers = 0,
    this.totalOutstandingKhata = 0.0,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      todayRevenue: (json['todayRevenue'] as num? ?? 0.0).toDouble(),
      todayOrdersCount: (json['todayOrdersCount'] as num? ?? 0).toInt(),
      todayCancelledOrdersCount:
          (json['todayCancelledOrdersCount'] as num? ?? 0).toInt(),
      averageOrderValue:
          (json['averageOrderValue'] as num? ?? 0.0).toDouble(),
      totalRevenue: (json['totalRevenue'] as num? ?? 0.0).toDouble(),
      completedOrdersCount:
          (json['completedOrdersCount'] as num? ?? 0).toInt(),
      cancelledOrdersCount:
          (json['cancelledOrdersCount'] as num? ?? 0).toInt(),
      lowStockCount: (json['lowStockCount'] as num? ?? 0).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num? ?? 0).toInt(),
      inStockCount: (json['inStockCount'] as num? ?? 0).toInt(),
      totalStockAlerts: (json['totalStockAlerts'] as num? ?? 0).toInt(),
      totalStockUnits: (json['totalStockUnits'] as num? ?? 0).toInt(),
      inventoryValuation: (json['inventoryValuation'] as num? ??
              json['totalCostValue'] as num? ??
              0.0)
          .toDouble(),
      totalCustomers: (json['totalCustomers'] as num? ?? 0).toInt(),
      totalProducts: (json['totalProducts'] as num? ?? 0).toInt(),
      activeKhataCustomers:
          (json['activeKhataCustomers'] as num? ?? 0).toInt(),
      totalOutstandingKhata:
          (json['totalOutstandingKhata'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayRevenue': todayRevenue,
      'todayOrdersCount': todayOrdersCount,
      'todayCancelledOrdersCount': todayCancelledOrdersCount,
      'averageOrderValue': averageOrderValue,
      'totalRevenue': totalRevenue,
      'completedOrdersCount': completedOrdersCount,
      'cancelledOrdersCount': cancelledOrdersCount,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'inStockCount': inStockCount,
      'totalStockAlerts': totalStockAlerts,
      'totalStockUnits': totalStockUnits,
      'inventoryValuation': inventoryValuation,
      'totalCustomers': totalCustomers,
      'totalProducts': totalProducts,
      'activeKhataCustomers': activeKhataCustomers,
      'totalOutstandingKhata': totalOutstandingKhata,
    };
  }
}

class DashboardOrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final int itemCount;
  final DateTime createdAt;

  const DashboardOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.customerPhone,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.itemCount,
    required this.createdAt,
  });

  factory DashboardOrderModel.fromJson(Map<String, dynamic> json) {
    return DashboardOrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Walk-in Customer',
      customerPhone: json['customerPhone'] as String?,
      totalAmount: (json['totalAmount'] as num? ?? 0.0).toDouble(),
      status: (json['status'] as String? ?? 'COMPLETED').toUpperCase(),
      paymentMethod: (json['paymentMethod'] as String? ?? 'CASH').toUpperCase(),
      itemCount: (json['itemCount'] as num? ?? 0).toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'itemCount': itemCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DashboardTopProductModel {
  final String productId;
  final String name;
  final String sku;
  final int quantitySold;
  final double revenue;

  const DashboardTopProductModel({
    required this.productId,
    required this.name,
    required this.sku,
    required this.quantitySold,
    required this.revenue,
  });

  factory DashboardTopProductModel.fromJson(Map<String, dynamic> json) {
    return DashboardTopProductModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      quantitySold: (json['quantitySold'] as num? ?? 0).toInt(),
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'quantitySold': quantitySold,
      'revenue': revenue,
    };
  }
}

class DashboardStockAlertModel {
  final String id;
  final String name;
  final String? sku;
  final String category;
  final int stockQuantity;
  final int minStockThreshold;
  final String unit;
  final String stockStatus;

  const DashboardStockAlertModel({
    required this.id,
    required this.name,
    this.sku,
    required this.category,
    required this.stockQuantity,
    required this.minStockThreshold,
    this.unit = 'pcs',
    required this.stockStatus,
  });

  bool get isOutOfStock => stockStatus == 'OUT_OF_STOCK';
  bool get isLowStock => stockStatus == 'LOW_STOCK';

  factory DashboardStockAlertModel.fromJson(Map<String, dynamic> json) {
    return DashboardStockAlertModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      category: json['category'] as String? ?? 'General',
      stockQuantity: (json['stockQuantity'] as num? ?? 0).toInt(),
      minStockThreshold: (json['minStockThreshold'] as num? ?? 5).toInt(),
      unit: json['unit'] as String? ?? 'pcs',
      stockStatus: (json['stockStatus'] as String? ?? 'IN_STOCK').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'stockQuantity': stockQuantity,
      'minStockThreshold': minStockThreshold,
      'unit': unit,
      'stockStatus': stockStatus,
    };
  }
}

class DashboardBusinessProfileModel {
  final String businessId;
  final String name;
  final String category;
  final String? address;
  final String? phone;

  const DashboardBusinessProfileModel({
    required this.businessId,
    required this.name,
    required this.category,
    this.address,
    this.phone,
  });

  factory DashboardBusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return DashboardBusinessProfileModel(
      businessId: json['businessId'] as String? ?? '',
      name: json['name'] as String? ?? 'Nirmaan Business',
      category: json['category'] as String? ?? 'Retail',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'name': name,
      'category': category,
      'address': address,
      'phone': phone,
    };
  }
}

class DashboardDataModel {
  final String businessId;
  final String timezone;
  final String today;
  final DashboardBusinessProfileModel? businessProfile;
  final DashboardMetricsModel metrics;
  final List<DashboardOrderModel> recentOrders;
  final List<DashboardStockAlertModel> stockAlerts;
  final List<DashboardTopProductModel> topProducts;
  final List<String> insights;

  const DashboardDataModel({
    required this.businessId,
    this.timezone = 'Asia/Kolkata',
    required this.today,
    this.businessProfile,
    this.metrics = const DashboardMetricsModel(),
    this.recentOrders = const [],
    this.stockAlerts = const [],
    this.topProducts = const [],
    this.insights = const [],
  });

    factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      businessId: json['businessId'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      today: json['today'] as String? ?? '',
      businessProfile: json['businessProfile'] != null
          ? DashboardBusinessProfileModel.fromJson(
              Map<String, dynamic>.from(json['businessProfile'] as Map))
          : null,
      metrics: json['metrics'] != null
          ? DashboardMetricsModel.fromJson(
              Map<String, dynamic>.from(json['metrics'] as Map))
          : const DashboardMetricsModel(),
      recentOrders: (json['recentOrders'] as List<dynamic>? ?? [])
          .map((item) => DashboardOrderModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      stockAlerts: (json['stockAlerts'] as List<dynamic>? ?? [])
          .map((item) => DashboardStockAlertModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      topProducts: (json['topProducts'] as List<dynamic>? ?? [])
          .map((item) => DashboardTopProductModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      insights: (json['insights'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'timezone': timezone,
      'today': today,
      'businessProfile': businessProfile?.toJson(),
      'metrics': metrics.toJson(),
      'recentOrders': recentOrders.map((e) => e.toJson()).toList(),
      'stockAlerts': stockAlerts.map((e) => e.toJson()).toList(),
      'topProducts': topProducts.map((e) => e.toJson()).toList(),
      'insights': insights,
    };
  }
}
