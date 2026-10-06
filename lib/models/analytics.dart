class AnalyticsPeriodModel {
  final String range;
  final String startDate;
  final String endDate;
  final String startISO;
  final String endISO;
  final String timezone;

  const AnalyticsPeriodModel({
    this.range = '30d',
    this.startDate = '',
    this.endDate = '',
    this.startISO = '',
    this.endISO = '',
    this.timezone = 'Asia/Kolkata',
  });

  factory AnalyticsPeriodModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsPeriodModel(
      range: json['range'] as String? ?? '30d',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      startISO: json['startISO'] as String? ?? '',
      endISO: json['endISO'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'startDate': startDate,
      'endDate': endDate,
      'startISO': startISO,
      'endISO': endISO,
      'timezone': timezone,
    };
  }
}

class DailyTrendModel {
  final String date;
  final double revenue;
  final int ordersCount;
  final int completedOrdersCount;
  final int cancelledOrdersCount;

  const DailyTrendModel({
    required this.date,
    this.revenue = 0.0,
    this.ordersCount = 0,
    this.completedOrdersCount = 0,
    this.cancelledOrdersCount = 0,
  });

  factory DailyTrendModel.fromJson(Map<String, dynamic> json) {
    return DailyTrendModel(
      date: json['date'] as String? ?? '',
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      ordersCount: (json['ordersCount'] as num? ?? 0).toInt(),
      completedOrdersCount:
          (json['completedOrdersCount'] as num? ?? 0).toInt(),
      cancelledOrdersCount:
          (json['cancelledOrdersCount'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'ordersCount': ordersCount,
      'completedOrdersCount': completedOrdersCount,
      'cancelledOrdersCount': cancelledOrdersCount,
    };
  }
}

class SalesAnalyticsModel {
  final double totalRevenue;
  final int completedOrdersCount;
  final double averageOrderValue;
  final double cancelledRevenue;
  final int cancelledOrdersCount;
  final List<DailyTrendModel> dailyTrends;

  const SalesAnalyticsModel({
    this.totalRevenue = 0.0,
    this.completedOrdersCount = 0,
    this.averageOrderValue = 0.0,
    this.cancelledRevenue = 0.0,
    this.cancelledOrdersCount = 0,
    this.dailyTrends = const [],
  });

  factory SalesAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SalesAnalyticsModel(
      totalRevenue: (json['totalRevenue'] as num? ?? 0.0).toDouble(),
      completedOrdersCount:
          (json['completedOrdersCount'] as num? ?? 0).toInt(),
      averageOrderValue:
          (json['averageOrderValue'] as num? ?? 0.0).toDouble(),
      cancelledRevenue:
          (json['cancelledRevenue'] as num? ?? 0.0).toDouble(),
      cancelledOrdersCount:
          (json['cancelledOrdersCount'] as num? ?? 0).toInt(),
      dailyTrends: (json['dailyTrends'] as List<dynamic>? ?? [])
          .map((item) =>
              DailyTrendModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'completedOrdersCount': completedOrdersCount,
      'averageOrderValue': averageOrderValue,
      'cancelledRevenue': cancelledRevenue,
      'cancelledOrdersCount': cancelledOrdersCount,
      'dailyTrends': dailyTrends.map((d) => d.toJson()).toList(),
    };
  }
}

class TopProductAnalyticsModel {
  final String productId;
  final String name;
  final String sku;
  final int quantitySold;
  final double revenue;
  final double shareOfRevenue;

  const TopProductAnalyticsModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.quantitySold = 0,
    this.revenue = 0.0,
    this.shareOfRevenue = 0.0,
  });

  factory TopProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return TopProductAnalyticsModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      quantitySold: (json['quantitySold'] as num? ?? 0).toInt(),
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      shareOfRevenue: (json['shareOfRevenue'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'quantitySold': quantitySold,
      'revenue': revenue,
      'shareOfRevenue': shareOfRevenue,
    };
  }
}

class WeakProductAnalyticsModel {
  final String productId;
  final String name;
  final String sku;
  final String category;
  final int currentStock;
  final int quantitySold;
  final double revenue;

  const WeakProductAnalyticsModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.category = 'General',
    this.currentStock = 0,
    this.quantitySold = 0,
    this.revenue = 0.0,
  });

  factory WeakProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return WeakProductAnalyticsModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      currentStock: (json['currentStock'] as num? ?? 0).toInt(),
      quantitySold: (json['quantitySold'] as num? ?? 0).toInt(),
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'category': category,
      'currentStock': currentStock,
      'quantitySold': quantitySold,
      'revenue': revenue,
    };
  }
}

class CategorySalesModel {
  final String category;
  final double revenue;
  final int quantitySold;
  final double shareOfRevenue;

  const CategorySalesModel({
    required this.category,
    this.revenue = 0.0,
    this.quantitySold = 0,
    this.shareOfRevenue = 0.0,
  });

  factory CategorySalesModel.fromJson(Map<String, dynamic> json) {
    return CategorySalesModel(
      category: json['category'] as String? ?? 'General',
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      quantitySold: (json['quantitySold'] as num? ?? 0).toInt(),
      shareOfRevenue: (json['shareOfRevenue'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'revenue': revenue,
      'quantitySold': quantitySold,
      'shareOfRevenue': shareOfRevenue,
    };
  }
}

class ProductAnalyticsModel {
  final List<TopProductAnalyticsModel> topProducts;
  final List<WeakProductAnalyticsModel> weakOrNoSalesProducts;
  final List<CategorySalesModel> categoryBreakdown;

  const ProductAnalyticsModel({
    this.topProducts = const [],
    this.weakOrNoSalesProducts = const [],
    this.categoryBreakdown = const [],
  });

  factory ProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return ProductAnalyticsModel(
      topProducts: (json['topProducts'] as List<dynamic>? ?? [])
          .map((item) => TopProductAnalyticsModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      weakOrNoSalesProducts:
          (json['weakOrNoSalesProducts'] as List<dynamic>? ?? [])
              .map((item) => WeakProductAnalyticsModel.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList(),
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>? ?? [])
          .map((item) => CategorySalesModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topProducts': topProducts.map((p) => p.toJson()).toList(),
      'weakOrNoSalesProducts':
          weakOrNoSalesProducts.map((p) => p.toJson()).toList(),
      'categoryBreakdown': categoryBreakdown.map((c) => c.toJson()).toList(),
    };
  }
}

class StockMovementSummaryModel {
  final int totalMovementsCount;
  final int inwardUnits;
  final int outwardUnits;

  const StockMovementSummaryModel({
    this.totalMovementsCount = 0,
    this.inwardUnits = 0,
    this.outwardUnits = 0,
  });

  factory StockMovementSummaryModel.fromJson(Map<String, dynamic> json) {
    return StockMovementSummaryModel(
      totalMovementsCount:
          (json['totalMovementsCount'] as num? ?? 0).toInt(),
      inwardUnits: (json['inwardUnits'] as num? ?? 0).toInt(),
      outwardUnits: (json['outwardUnits'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMovementsCount': totalMovementsCount,
      'inwardUnits': inwardUnits,
      'outwardUnits': outwardUnits,
    };
  }
}

class InventoryAnalyticsModel {
  final double inventoryValuation;
  final int totalStockUnits;
  final int totalProducts;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;
  final StockMovementSummaryModel stockMovementSummary;

  const InventoryAnalyticsModel({
    this.inventoryValuation = 0.0,
    this.totalStockUnits = 0,
    this.totalProducts = 0,
    this.inStockCount = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.stockMovementSummary = const StockMovementSummaryModel(),
  });

  factory InventoryAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return InventoryAnalyticsModel(
      inventoryValuation:
          (json['inventoryValuation'] as num? ?? 0.0).toDouble(),
      totalStockUnits: (json['totalStockUnits'] as num? ?? 0).toInt(),
      totalProducts: (json['totalProducts'] as num? ?? 0).toInt(),
      inStockCount: (json['inStockCount'] as num? ?? 0).toInt(),
      lowStockCount: (json['lowStockCount'] as num? ?? 0).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num? ?? 0).toInt(),
      stockMovementSummary: json['stockMovementSummary'] != null
          ? StockMovementSummaryModel.fromJson(
              Map<String, dynamic>.from(json['stockMovementSummary'] as Map))
          : const StockMovementSummaryModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryValuation': inventoryValuation,
      'totalStockUnits': totalStockUnits,
      'totalProducts': totalProducts,
      'inStockCount': inStockCount,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'stockMovementSummary': stockMovementSummary.toJson(),
    };
  }
}

class TopCustomerAnalyticsModel {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final int ordersCount;
  final double totalSpend;

  const TopCustomerAnalyticsModel({
    required this.customerId,
    required this.customerName,
    this.customerPhone = '',
    this.ordersCount = 0,
    this.totalSpend = 0.0,
  });

  factory TopCustomerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return TopCustomerAnalyticsModel(
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Customer',
      customerPhone: json['customerPhone'] as String? ?? '',
      ordersCount: (json['ordersCount'] as num? ?? 0).toInt(),
      totalSpend: (json['totalSpend'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'ordersCount': ordersCount,
      'totalSpend': totalSpend,
    };
  }
}

class CustomerAnalyticsModel {
  final int totalCustomers;
  final int activeCustomersCount;
  final List<TopCustomerAnalyticsModel> topCustomers;
  final double averageOrderFrequency;

  const CustomerAnalyticsModel({
    this.totalCustomers = 0,
    this.activeCustomersCount = 0,
    this.topCustomers = const [],
    this.averageOrderFrequency = 0.0,
  });

  factory CustomerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CustomerAnalyticsModel(
      totalCustomers: (json['totalCustomers'] as num? ?? 0).toInt(),
      activeCustomersCount:
          (json['activeCustomersCount'] as num? ?? 0).toInt(),
      topCustomers: (json['topCustomers'] as List<dynamic>? ?? [])
          .map((item) => TopCustomerAnalyticsModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      averageOrderFrequency:
          (json['averageOrderFrequency'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'activeCustomersCount': activeCustomersCount,
      'topCustomers': topCustomers.map((c) => c.toJson()).toList(),
      'averageOrderFrequency': averageOrderFrequency,
    };
  }
}

class AnalyticsBusinessProfileModel {
  final String businessId;
  final String name;
  final String category;
  final String? address;
  final String? phone;

  const AnalyticsBusinessProfileModel({
    required this.businessId,
    required this.name,
    this.category = 'Retail',
    this.address,
    this.phone,
  });

  factory AnalyticsBusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsBusinessProfileModel(
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

class AnalyticsDataModel {
  final String businessId;
  final AnalyticsBusinessProfileModel? businessProfile;
  final AnalyticsPeriodModel period;
  final SalesAnalyticsModel sales;
  final ProductAnalyticsModel products;
  final InventoryAnalyticsModel inventory;
  final CustomerAnalyticsModel customers;

  const AnalyticsDataModel({
    required this.businessId,
    this.businessProfile,
    this.period = const AnalyticsPeriodModel(),
    this.sales = const SalesAnalyticsModel(),
    this.products = const ProductAnalyticsModel(),
    this.inventory = const InventoryAnalyticsModel(),
    this.customers = const CustomerAnalyticsModel(),
  });

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDataModel(
      businessId: json['businessId'] as String? ?? '',
      businessProfile: json['businessProfile'] != null
          ? AnalyticsBusinessProfileModel.fromJson(
              Map<String, dynamic>.from(json['businessProfile'] as Map))
          : null,
      period: json['period'] != null
          ? AnalyticsPeriodModel.fromJson(
              Map<String, dynamic>.from(json['period'] as Map))
          : const AnalyticsPeriodModel(),
      sales: json['sales'] != null
          ? SalesAnalyticsModel.fromJson(
              Map<String, dynamic>.from(json['sales'] as Map))
          : const SalesAnalyticsModel(),
      products: json['products'] != null
          ? ProductAnalyticsModel.fromJson(
              Map<String, dynamic>.from(json['products'] as Map))
          : const ProductAnalyticsModel(),
      inventory: json['inventory'] != null
          ? InventoryAnalyticsModel.fromJson(
              Map<String, dynamic>.from(json['inventory'] as Map))
          : const InventoryAnalyticsModel(),
      customers: json['customers'] != null
          ? CustomerAnalyticsModel.fromJson(
              Map<String, dynamic>.from(json['customers'] as Map))
          : const CustomerAnalyticsModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'businessProfile': businessProfile?.toJson(),
      'period': period.toJson(),
      'sales': sales.toJson(),
      'products': products.toJson(),
      'inventory': inventory.toJson(),
      'customers': customers.toJson(),
    };
  }
}

class ReportDataModel {
  final String reportType;
  final AnalyticsBusinessProfileModel? businessProfile;
  final AnalyticsPeriodModel period;
  final String generatedAt;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> records;

  const ReportDataModel({
    required this.reportType,
    this.businessProfile,
    this.period = const AnalyticsPeriodModel(),
    required this.generatedAt,
    this.summary = const {},
    this.records = const [],
  });

  factory ReportDataModel.fromJson(Map<String, dynamic> json) {
    return ReportDataModel(
      reportType: (json['reportType'] as String? ?? 'SALES').toUpperCase(),
      businessProfile: json['businessProfile'] != null
          ? AnalyticsBusinessProfileModel.fromJson(
              Map<String, dynamic>.from(json['businessProfile'] as Map))
          : null,
      period: json['period'] != null
          ? AnalyticsPeriodModel.fromJson(
              Map<String, dynamic>.from(json['period'] as Map))
          : const AnalyticsPeriodModel(),
      generatedAt: json['generatedAt'] as String? ?? '',
      summary: json['summary'] != null
          ? Map<String, dynamic>.from(json['summary'] as Map)
          : const {},
      records: (json['records'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportType': reportType,
      'businessProfile': businessProfile?.toJson(),
      'period': period.toJson(),
      'generatedAt': generatedAt,
      'summary': summary,
      'records': records,
    };
  }
}
