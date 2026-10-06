class HealthDimensionModel {
  final int score;
  final String weight;
  final String status;
  final Map<String, dynamic> details;

  const HealthDimensionModel({
    this.score = 0,
    this.weight = '20%',
    this.status = 'MODERATE',
    this.details = const {},
  });

  factory HealthDimensionModel.fromJson(Map<String, dynamic> json) {
    return HealthDimensionModel(
      score: (json['score'] as num? ?? 0).toInt(),
      weight: json['weight'] as String? ?? '20%',
      status: (json['status'] as String? ?? 'MODERATE').toUpperCase(),
      details: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'weight': weight,
      'status': status,
      ...details,
    };
  }
}

class BusinessHealthScoreModel {
  final int overallScore;
  final String healthLevel;
  final String summaryHeadline;
  final String explanation;
  final List<String> positiveSignals;
  final List<String> negativeSignals;
  final Map<String, HealthDimensionModel> dimensions;

  const BusinessHealthScoreModel({
    this.overallScore = 0,
    this.healthLevel = 'CRITICAL',
    this.summaryHeadline = '',
    this.explanation = '',
    this.positiveSignals = const [],
    this.negativeSignals = const [],
    this.dimensions = const {},
  });

  factory BusinessHealthScoreModel.fromJson(Map<String, dynamic> json) {
    final rawDims = json['dimensions'] as Map<String, dynamic>? ?? {};
    final parsedDims = <String, HealthDimensionModel>{};
    for (final entry in rawDims.entries) {
      if (entry.value is Map) {
        parsedDims[entry.key] = HealthDimensionModel.fromJson(
            Map<String, dynamic>.from(entry.value as Map));
      }
    }

    return BusinessHealthScoreModel(
      overallScore: (json['overallScore'] as num? ?? 0).toInt(),
      healthLevel: (json['healthLevel'] as String? ?? 'CRITICAL').toUpperCase(),
      summaryHeadline: json['summaryHeadline'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      positiveSignals: (json['positiveSignals'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      negativeSignals: (json['negativeSignals'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      dimensions: parsedDims,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'healthLevel': healthLevel,
      'summaryHeadline': summaryHeadline,
      'explanation': explanation,
      'positiveSignals': positiveSignals,
      'negativeSignals': negativeSignals,
      'dimensions': dimensions.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}

class DailyForecastModel {
  final String date;
  final int dayOffset;
  final double projectedRevenue;
  final int projectedOrders;

  const DailyForecastModel({
    required this.date,
    this.dayOffset = 1,
    this.projectedRevenue = 0.0,
    this.projectedOrders = 0,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: json['date'] as String? ?? '',
      dayOffset: (json['dayOffset'] as num? ?? 1).toInt(),
      projectedRevenue: (json['projectedRevenue'] as num? ?? 0.0).toDouble(),
      projectedOrders: (json['projectedOrders'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayOffset': dayOffset,
      'projectedRevenue': projectedRevenue,
      'projectedOrders': projectedOrders,
    };
  }
}

class ProductForecastModel {
  final String productId;
  final String name;
  final String sku;
  final int currentStock;
  final double dailyVelocity;
  final int projected7DayDemand;
  final String daysOfSupply;
  final String stockRisk;

  const ProductForecastModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.currentStock = 0,
    this.dailyVelocity = 0.0,
    this.projected7DayDemand = 0,
    this.daysOfSupply = '',
    this.stockRisk = 'ADEQUATE',
  });

  factory ProductForecastModel.fromJson(Map<String, dynamic> json) {
    return ProductForecastModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      currentStock: (json['currentStock'] as num? ?? 0).toInt(),
      dailyVelocity: (json['dailyVelocity'] as num? ?? 0.0).toDouble(),
      projected7DayDemand: (json['projected7DayDemand'] as num? ?? 0).toInt(),
      daysOfSupply: json['daysOfSupply'] as String? ?? '',
      stockRisk: (json['stockRisk'] as String? ?? 'ADEQUATE').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'currentStock': currentStock,
      'dailyVelocity': dailyVelocity,
      'projected7DayDemand': projected7DayDemand,
      'daysOfSupply': daysOfSupply,
      'stockRisk': stockRisk,
    };
  }
}

class SalesForecastModel {
  final String status;
  final String confidence;
  final String confidenceReason;
  final bool isGuaranteed;
  final String disclaimer;
  final String methodology;
  final int historicalDataDaysAnalyzed;
  final String trendDirection;
  final int projectedPeriodDays;
  final double projectedTotalRevenue;
  final int projectedTotalOrders;
  final List<DailyForecastModel> dailyForecasts;
  final List<ProductForecastModel> productForecasts;

  const SalesForecastModel({
    this.status = 'HEALTHY',
    this.confidence = 'LOW',
    this.confidenceReason = '',
    this.isGuaranteed = false,
    this.disclaimer = '',
    this.methodology = '',
    this.historicalDataDaysAnalyzed = 0,
    this.trendDirection = 'STABLE',
    this.projectedPeriodDays = 7,
    this.projectedTotalRevenue = 0.0,
    this.projectedTotalOrders = 0,
    this.dailyForecasts = const [],
    this.productForecasts = const [],
  });

  factory SalesForecastModel.fromJson(Map<String, dynamic> json) {
    return SalesForecastModel(
      status: (json['status'] as String? ?? 'HEALTHY').toUpperCase(),
      confidence: (json['confidence'] as String? ?? 'LOW').toUpperCase(),
      confidenceReason: json['confidenceReason'] as String? ?? '',
      isGuaranteed: json['isGuaranteed'] as bool? ?? false,
      disclaimer: json['disclaimer'] as String? ?? '',
      methodology: json['methodology'] as String? ?? '',
      historicalDataDaysAnalyzed:
          (json['historicalDataDaysAnalyzed'] as num? ?? 0).toInt(),
      trendDirection:
          (json['trendDirection'] as String? ?? 'STABLE').toUpperCase(),
      projectedPeriodDays: (json['projectedPeriodDays'] as num? ?? 7).toInt(),
      projectedTotalRevenue:
          (json['projectedTotalRevenue'] as num? ?? 0.0).toDouble(),
      projectedTotalOrders:
          (json['projectedTotalOrders'] as num? ?? 0).toInt(),
      dailyForecasts: (json['dailyForecasts'] as List<dynamic>? ?? [])
          .map((item) => DailyForecastModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      productForecasts: (json['productForecasts'] as List<dynamic>? ?? [])
          .map((item) => ProductForecastModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'confidence': confidence,
      'confidenceReason': confidenceReason,
      'isGuaranteed': isGuaranteed,
      'disclaimer': disclaimer,
      'methodology': methodology,
      'historicalDataDaysAnalyzed': historicalDataDaysAnalyzed,
      'trendDirection': trendDirection,
      'projectedPeriodDays': projectedPeriodDays,
      'projectedTotalRevenue': projectedTotalRevenue,
      'projectedTotalOrders': projectedTotalOrders,
      'dailyForecasts': dailyForecasts.map((d) => d.toJson()).toList(),
      'productForecasts': productForecasts.map((p) => p.toJson()).toList(),
    };
  }
}

class StockAlertModel {
  final String productId;
  final String name;
  final String sku;
  final String category;
  final int currentStock;
  final int minStockThreshold;
  final String urgency;

  const StockAlertModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.category = 'General',
    this.currentStock = 0,
    this.minStockThreshold = 5,
    this.urgency = 'HIGH',
  });

  factory StockAlertModel.fromJson(Map<String, dynamic> json) {
    return StockAlertModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      currentStock: (json['currentStock'] as num? ?? 0).toInt(),
      minStockThreshold: (json['minStockThreshold'] as num? ?? 5).toInt(),
      urgency: (json['urgency'] as String? ?? 'HIGH').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'category': category,
      'currentStock': currentStock,
      'minStockThreshold': minStockThreshold,
      'urgency': urgency,
    };
  }
}

class ReplenishmentRecommendationModel {
  final String productId;
  final String name;
  final String sku;
  final int currentStock;
  final int suggestedReorderQuantity;
  final String urgency;
  final String reason;

  const ReplenishmentRecommendationModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.currentStock = 0,
    this.suggestedReorderQuantity = 10,
    this.urgency = 'HIGH',
    this.reason = '',
  });

  factory ReplenishmentRecommendationModel.fromJson(Map<String, dynamic> json) {
    return ReplenishmentRecommendationModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      currentStock: (json['currentStock'] as num? ?? 0).toInt(),
      suggestedReorderQuantity:
          (json['suggestedReorderQuantity'] as num? ?? 10).toInt(),
      urgency: (json['urgency'] as String? ?? 'HIGH').toUpperCase(),
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'currentStock': currentStock,
      'suggestedReorderQuantity': suggestedReorderQuantity,
      'urgency': urgency,
      'reason': reason,
    };
  }
}

class VelocityProductModel {
  final String productId;
  final String name;
  final String sku;
  final int quantitySold;
  final int currentStock;
  final double capitalTiedUp;
  final String status;

  const VelocityProductModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.quantitySold = 0,
    this.currentStock = 0,
    this.capitalTiedUp = 0.0,
    this.status = 'NORMAL',
  });

  factory VelocityProductModel.fromJson(Map<String, dynamic> json) {
    return VelocityProductModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      quantitySold: (json['quantitySold'] as num? ?? 0).toInt(),
      currentStock: (json['currentStock'] as num? ?? 0).toInt(),
      capitalTiedUp: (json['capitalTiedUp'] as num? ?? 0.0).toDouble(),
      status: (json['status'] as String? ?? 'NORMAL').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'quantitySold': quantitySold,
      'currentStock': currentStock,
      'capitalTiedUp': capitalTiedUp,
      'status': status,
    };
  }
}

class InventoryIntelligenceModel {
  final double inventoryValuation;
  final int totalUnits;
  final int catalogSize;
  final int outOfStockCount;
  final int lowStockCount;
  final List<StockAlertModel> outOfStockAlerts;
  final List<StockAlertModel> lowStockAlerts;
  final List<VelocityProductModel> fastMovingProducts;
  final List<VelocityProductModel> slowMovingProducts;
  final List<Map<String, dynamic>> overstockedProducts;
  final List<ReplenishmentRecommendationModel> replenishmentRecommendations;

  const InventoryIntelligenceModel({
    this.inventoryValuation = 0.0,
    this.totalUnits = 0,
    this.catalogSize = 0,
    this.outOfStockCount = 0,
    this.lowStockCount = 0,
    this.outOfStockAlerts = const [],
    this.lowStockAlerts = const [],
    this.fastMovingProducts = const [],
    this.slowMovingProducts = const [],
    this.overstockedProducts = const [],
    this.replenishmentRecommendations = const [],
  });

  factory InventoryIntelligenceModel.fromJson(Map<String, dynamic> json) {
    return InventoryIntelligenceModel(
      inventoryValuation:
          (json['inventoryValuation'] as num? ?? 0.0).toDouble(),
      totalUnits: (json['totalUnits'] as num? ?? 0).toInt(),
      catalogSize: (json['catalogSize'] as num? ?? 0).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num? ?? 0).toInt(),
      lowStockCount: (json['lowStockCount'] as num? ?? 0).toInt(),
      outOfStockAlerts: (json['outOfStockAlerts'] as List<dynamic>? ?? [])
          .map((item) =>
              StockAlertModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      lowStockAlerts: (json['lowStockAlerts'] as List<dynamic>? ?? [])
          .map((item) =>
              StockAlertModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      fastMovingProducts: (json['fastMovingProducts'] as List<dynamic>? ?? [])
          .map((item) => VelocityProductModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      slowMovingProducts: (json['slowMovingProducts'] as List<dynamic>? ?? [])
          .map((item) => VelocityProductModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      overstockedProducts: (json['overstockedProducts'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      replenishmentRecommendations:
          (json['replenishmentRecommendations'] as List<dynamic>? ?? [])
              .map((item) => ReplenishmentRecommendationModel.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryValuation': inventoryValuation,
      'totalUnits': totalUnits,
      'catalogSize': catalogSize,
      'outOfStockCount': outOfStockCount,
      'lowStockCount': lowStockCount,
      'outOfStockAlerts': outOfStockAlerts.map((e) => e.toJson()).toList(),
      'lowStockAlerts': lowStockAlerts.map((e) => e.toJson()).toList(),
      'fastMovingProducts': fastMovingProducts.map((e) => e.toJson()).toList(),
      'slowMovingProducts': slowMovingProducts.map((e) => e.toJson()).toList(),
      'overstockedProducts': overstockedProducts,
      'replenishmentRecommendations':
          replenishmentRecommendations.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerRiskSignalModel {
  final String customerId;
  final String customerName;
  final String phone;
  final int orderCount;
  final double totalSpend;
  final dynamic daysSinceLastOrder; // int or String ("No orders")
  final String? lastOrderDate;
  final int? averageCadenceDays;
  final String riskLevel;
  final String reason;

  const CustomerRiskSignalModel({
    required this.customerId,
    required this.customerName,
    this.phone = '',
    this.orderCount = 0,
    this.totalSpend = 0.0,
    this.daysSinceLastOrder = 0,
    this.lastOrderDate,
    this.averageCadenceDays,
    this.riskLevel = 'LOW_RISK',
    this.reason = '',
  });

  factory CustomerRiskSignalModel.fromJson(Map<String, dynamic> json) {
    return CustomerRiskSignalModel(
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Patron',
      phone: json['phone'] as String? ?? '',
      orderCount: (json['orderCount'] as num? ?? 0).toInt(),
      totalSpend: (json['totalSpend'] as num? ?? 0.0).toDouble(),
      daysSinceLastOrder: json['daysSinceLastOrder'] ?? 0,
      lastOrderDate: json['lastOrderDate'] as String?,
      averageCadenceDays: (json['averageCadenceDays'] as num?)?.toInt(),
      riskLevel: (json['riskLevel'] as String? ?? 'LOW_RISK').toUpperCase(),
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'phone': phone,
      'orderCount': orderCount,
      'totalSpend': totalSpend,
      'daysSinceLastOrder': daysSinceLastOrder,
      'lastOrderDate': lastOrderDate,
      'averageCadenceDays': averageCadenceDays,
      'riskLevel': riskLevel,
      'reason': reason,
    };
  }
}

class CustomerRiskSummaryModel {
  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;

  const CustomerRiskSummaryModel({
    this.highRiskCount = 0,
    this.mediumRiskCount = 0,
    this.lowRiskCount = 0,
  });

  factory CustomerRiskSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerRiskSummaryModel(
      highRiskCount: (json['highRiskCount'] as num? ?? 0).toInt(),
      mediumRiskCount: (json['mediumRiskCount'] as num? ?? 0).toInt(),
      lowRiskCount: (json['lowRiskCount'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'lowRiskCount': lowRiskCount,
    };
  }
}

class CustomerRiskModel {
  final int totalTrackedCustomers;
  final CustomerRiskSummaryModel riskSummary;
  final List<CustomerRiskSignalModel> customerRiskSignals;

  const CustomerRiskModel({
    this.totalTrackedCustomers = 0,
    this.riskSummary = const CustomerRiskSummaryModel(),
    this.customerRiskSignals = const [],
  });

  factory CustomerRiskModel.fromJson(Map<String, dynamic> json) {
    return CustomerRiskModel(
      totalTrackedCustomers:
          (json['totalTrackedCustomers'] as num? ?? 0).toInt(),
      riskSummary: json['riskSummary'] != null
          ? CustomerRiskSummaryModel.fromJson(
              Map<String, dynamic>.from(json['riskSummary'] as Map))
          : const CustomerRiskSummaryModel(),
      customerRiskSignals: (json['customerRiskSignals'] as List<dynamic>? ?? [])
          .map((item) => CustomerRiskSignalModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrackedCustomers': totalTrackedCustomers,
      'riskSummary': riskSummary.toJson(),
      'customerRiskSignals':
          customerRiskSignals.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductPerformanceModel {
  final String productId;
  final String name;
  final String sku;
  final String category;
  final int quantitySold;
  final double revenue;
  final double shareOfRevenue;
  final int currentStock;
  final double tiedUpCapital;
  final String diagnosis;

  const ProductPerformanceModel({
    required this.productId,
    required this.name,
    this.sku = '',
    this.category = 'General',
    this.quantitySold = 0,
    this.revenue = 0.0,
    this.shareOfRevenue = 0.0,
    this.currentStock = 0,
    this.tiedUpCapital = 0.0,
    this.diagnosis = '',
  });

  factory ProductPerformanceModel.fromJson(Map<String, dynamic> json) {
    return ProductPerformanceModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Product',
      sku: json['sku'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      quantitySold: (json['quantitySold'] as num? ?? 0).toInt(),
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      shareOfRevenue: (json['shareOfRevenue'] as num? ?? 0.0).toDouble(),
      currentStock: (json['currentStock'] as num? ?? 0).toInt(),
      tiedUpCapital: (json['tiedUpCapital'] as num? ?? 0.0).toDouble(),
      diagnosis: json['diagnosis'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'category': category,
      'quantitySold': quantitySold,
      'revenue': revenue,
      'shareOfRevenue': shareOfRevenue,
      'currentStock': currentStock,
      'tiedUpCapital': tiedUpCapital,
      'diagnosis': diagnosis,
    };
  }
}

class ProductIntelligenceModel {
  final int totalAnalyzedProducts;
  final List<ProductPerformanceModel> topPerformers;
  final List<ProductPerformanceModel> dormantProducts;
  final List<ProductPerformanceModel> highRevenueDrivers;
  final List<ProductPerformanceModel> highVolumeDrivers;

  const ProductIntelligenceModel({
    this.totalAnalyzedProducts = 0,
    this.topPerformers = const [],
    this.dormantProducts = const [],
    this.highRevenueDrivers = const [],
    this.highVolumeDrivers = const [],
  });

  factory ProductIntelligenceModel.fromJson(Map<String, dynamic> json) {
    return ProductIntelligenceModel(
      totalAnalyzedProducts:
          (json['totalAnalyzedProducts'] as num? ?? 0).toInt(),
      topPerformers: (json['topPerformers'] as List<dynamic>? ?? [])
          .map((item) => ProductPerformanceModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      dormantProducts: (json['dormantProducts'] as List<dynamic>? ?? [])
          .map((item) => ProductPerformanceModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      highRevenueDrivers: (json['highRevenueDrivers'] as List<dynamic>? ?? [])
          .map((item) => ProductPerformanceModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      highVolumeDrivers: (json['highVolumeDrivers'] as List<dynamic>? ?? [])
          .map((item) => ProductPerformanceModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAnalyzedProducts': totalAnalyzedProducts,
      'topPerformers': topPerformers.map((e) => e.toJson()).toList(),
      'dormantProducts': dormantProducts.map((e) => e.toJson()).toList(),
      'highRevenueDrivers': highRevenueDrivers.map((e) => e.toJson()).toList(),
      'highVolumeDrivers': highVolumeDrivers.map((e) => e.toJson()).toList(),
    };
  }
}

class BiRecommendationModel {
  final String id;
  final String priority; // HIGH | MEDIUM | LOW
  final String category; // INVENTORY | CUSTOMER | PRODUCTS | OPERATIONS
  final String title;
  final String description;
  final String actionLabel;

  const BiRecommendationModel({
    required this.id,
    this.priority = 'MEDIUM',
    this.category = 'OPERATIONS',
    required this.title,
    required this.description,
    this.actionLabel = 'Review',
  });

  factory BiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return BiRecommendationModel(
      id: json['id'] as String? ?? '',
      priority: (json['priority'] as String? ?? 'MEDIUM').toUpperCase(),
      category: (json['category'] as String? ?? 'OPERATIONS').toUpperCase(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? 'Review',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priority': priority,
      'category': category,
      'title': title,
      'description': description,
      'actionLabel': actionLabel,
    };
  }
}

class BiOverviewModel {
  final String businessId;
  final String generatedAt;
  final BusinessHealthScoreModel healthScore;
  final SalesForecastModel forecast;
  final InventoryIntelligenceModel inventoryIntelligence;
  final CustomerRiskModel customerRisk;
  final ProductIntelligenceModel productIntelligence;
  final List<BiRecommendationModel> recommendations;

  const BiOverviewModel({
    required this.businessId,
    required this.generatedAt,
    this.healthScore = const BusinessHealthScoreModel(),
    this.forecast = const SalesForecastModel(),
    this.inventoryIntelligence = const InventoryIntelligenceModel(),
    this.customerRisk = const CustomerRiskModel(),
    this.productIntelligence = const ProductIntelligenceModel(),
    this.recommendations = const [],
  });

  factory BiOverviewModel.fromJson(Map<String, dynamic> json) {
    return BiOverviewModel(
      businessId: json['businessId'] as String? ?? '',
      generatedAt: json['generatedAt'] as String? ?? '',
      healthScore: json['healthScore'] != null
          ? BusinessHealthScoreModel.fromJson(
              Map<String, dynamic>.from(json['healthScore'] as Map))
          : const BusinessHealthScoreModel(),
      forecast: json['forecast'] != null
          ? SalesForecastModel.fromJson(
              Map<String, dynamic>.from(json['forecast'] as Map))
          : const SalesForecastModel(),
      inventoryIntelligence: json['inventoryIntelligence'] != null
          ? InventoryIntelligenceModel.fromJson(
              Map<String, dynamic>.from(json['inventoryIntelligence'] as Map))
          : const InventoryIntelligenceModel(),
      customerRisk: json['customerRisk'] != null
          ? CustomerRiskModel.fromJson(
              Map<String, dynamic>.from(json['customerRisk'] as Map))
          : const CustomerRiskModel(),
      productIntelligence: json['productIntelligence'] != null
          ? ProductIntelligenceModel.fromJson(
              Map<String, dynamic>.from(json['productIntelligence'] as Map))
          : const ProductIntelligenceModel(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((item) => BiRecommendationModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'generatedAt': generatedAt,
      'healthScore': healthScore.toJson(),
      'forecast': forecast.toJson(),
      'inventoryIntelligence': inventoryIntelligence.toJson(),
      'customerRisk': customerRisk.toJson(),
      'productIntelligence': productIntelligence.toJson(),
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
    };
  }
}
