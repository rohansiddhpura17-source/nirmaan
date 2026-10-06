class ProductModel {
  final String id;
  final String name;
  final String category;
  final String? sku;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? unit;
  final String? imageUrl;
  final String? description;
  final String status; // ACTIVE, ARCHIVED, INACTIVE
  final bool isActive;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.sku,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    int? stockQuantity,
    int? currentStock,
    int? lowStockThreshold,
    int? minStockThreshold,
    this.unit = 'pcs',
    this.imageUrl,
    this.description,
    String? status,
    bool? isActive,
    required this.createdAt,
  })  : stockQuantity = currentStock ?? stockQuantity ?? 0,
        lowStockThreshold = minStockThreshold ?? lowStockThreshold ?? 10,
        status = status ?? (isActive == false ? 'ARCHIVED' : 'ACTIVE'),
        isActive = isActive ?? (status != 'ARCHIVED' && status != 'INACTIVE');

  int get currentStock => stockQuantity;
  int get minStockThreshold => lowStockThreshold;

  bool get isLowStock =>
      stockQuantity > 0 && stockQuantity <= lowStockThreshold;
  bool get isOutOfStock => stockQuantity <= 0;
  double get profitMargin => sellingPrice > 0
      ? ((sellingPrice - purchasePrice) / sellingPrice) * 100
      : 0.0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? 'ACTIVE').toUpperCase();
    final isActiveVal = json['isActive'] as bool? ?? (statusStr == 'ACTIVE');

    return ProductModel(
      id: json['id'] as String? ??
          json['productId'] as String? ??
          json['product_id'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      purchasePrice: (json['purchasePrice'] as num? ??
              json['costPrice'] as num? ??
              json['purchase_price'] as num? ??
              0.0)
          .toDouble(),
      sellingPrice: (json['sellingPrice'] as num? ??
              json['selling_price'] as num? ??
              0.0)
          .toDouble(),
      stockQuantity: (json['currentStock'] as num? ??
              json['stockQuantity'] as num? ??
              json['stock_quantity'] as num? ??
              0)
          .toInt(),
      lowStockThreshold: (json['minStockThreshold'] as num? ??
              json['lowStockThreshold'] as num? ??
              10)
          .toInt(),
      unit: json['unit'] as String? ?? 'pcs',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      status: statusStr,
      isActive: isActiveVal,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': id,
      'name': name,
      'category': category,
      'sku': sku,
      'barcode': barcode,
      'purchasePrice': purchasePrice,
      'costPrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'currentStock': stockQuantity,
      'stockQuantity': stockQuantity,
      'minStockThreshold': lowStockThreshold,
      'lowStockThreshold': lowStockThreshold,
      'unit': unit,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? sku,
    String? barcode,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    String? unit,
    String? imageUrl,
    String? description,
    String? status,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
