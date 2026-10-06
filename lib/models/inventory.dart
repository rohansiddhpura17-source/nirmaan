class InventorySummaryModel {
  final int totalProducts;
  final int totalStockUnits;
  final int lowStockCount;
  final int outOfStockCount;
  final double inventoryValuation;

  const InventorySummaryModel({
    this.totalProducts = 0,
    this.totalStockUnits = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.inventoryValuation = 0.0,
  });

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) {
    return InventorySummaryModel(
      totalProducts: (json['totalProducts'] as num? ?? 0).toInt(),
      totalStockUnits: (json['totalStockUnits'] as num? ?? 0).toInt(),
      lowStockCount: (json['lowStockCount'] as num? ?? 0).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num? ?? 0).toInt(),
      inventoryValuation: (json['inventoryValuation'] as num? ??
              json['totalCostValue'] as num? ??
              0.0)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'totalStockUnits': totalStockUnits,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'inventoryValuation': inventoryValuation,
    };
  }
}

class InventoryItemModel {
  final String productId;
  final String name;
  final String? sku;
  final String category;
  final int currentStock;
  final int minStockThreshold;
  final String stockStatus; // IN_STOCK, LOW_STOCK, OUT_OF_STOCK
  final String unit;
  final double valuation;

  const InventoryItemModel({
    required this.productId,
    required this.name,
    this.sku,
    required this.category,
    required this.currentStock,
    this.minStockThreshold = 5,
    required this.stockStatus,
    this.unit = 'pcs',
    this.valuation = 0.0,
  });

  bool get isLowStock => stockStatus == 'LOW_STOCK';
  bool get isOutOfStock => stockStatus == 'OUT_OF_STOCK';

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      productId: json['productId'] as String? ??
          json['id'] as String? ??
          json['product_id'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      category: json['category'] as String? ?? 'General',
      currentStock: (json['currentStock'] as num? ??
              json['stockQuantity'] as num? ??
              0)
          .toInt(),
      minStockThreshold: (json['minStockThreshold'] as num? ??
              json['lowStockThreshold'] as num? ??
              5)
          .toInt(),
      stockStatus:
          (json['stockStatus'] as String? ?? 'IN_STOCK').toUpperCase(),
      unit: json['unit'] as String? ?? 'pcs',
      valuation: (json['valuation'] as num? ?? 0.0).toDouble(),
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
      'stockStatus': stockStatus,
      'unit': unit,
      'valuation': valuation,
    };
  }
}

class InventoryMovementModel {
  final String movementId;
  final String productId;
  final String productName;
  final String type; // SALE, RESTOCK, ADJUSTMENT, RETURN
  final int quantity;
  final int previousStock;
  final int resultingStock;
  final String reason;
  final String? referenceId;
  final DateTime createdAt;

  const InventoryMovementModel({
    required this.movementId,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.resultingStock,
    required this.reason,
    this.referenceId,
    required this.createdAt,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      movementId: json['movementId'] as String? ??
          json['id'] as String? ??
          json['movement_id'] as String? ??
          '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      type: (json['type'] as String? ?? 'ADJUSTMENT').toUpperCase(),
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      previousStock: (json['previousStock'] as num? ?? 0).toInt(),
      resultingStock: (json['resultingStock'] as num? ?? 0).toInt(),
      reason: json['reason'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movementId': movementId,
      'productId': productId,
      'productName': productName,
      'type': type,
      'quantity': quantity,
      'previousStock': previousStock,
      'resultingStock': resultingStock,
      'reason': reason,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
