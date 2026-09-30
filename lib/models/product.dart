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
    this.isActive = true,
    required this.createdAt,
  })  : stockQuantity = currentStock ?? stockQuantity ?? 0,
        lowStockThreshold = minStockThreshold ?? lowStockThreshold ?? 10;

  int get currentStock => stockQuantity;
  int get minStockThreshold => lowStockThreshold;

  bool get isLowStock =>
      stockQuantity > 0 && stockQuantity <= lowStockThreshold;
  bool get isOutOfStock => stockQuantity <= 0;
  double get profitMargin => sellingPrice > 0
      ? ((sellingPrice - purchasePrice) / sellingPrice) * 100
      : 0.0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      purchasePrice: (json['purchasePrice'] as num? ??
              json['purchase_price'] as num? ??
              0.0)
          .toDouble(),
      sellingPrice:
          (json['sellingPrice'] as num? ?? json['selling_price'] as num? ?? 0.0)
              .toDouble(),
      stockQuantity:
          (json['stockQuantity'] as num? ?? json['stock_quantity'] as num? ?? 0)
              .toInt(),
      lowStockThreshold: (json['lowStockThreshold'] as num? ?? 10).toInt(),
      unit: json['unit'] as String? ?? 'pcs',
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sku': sku,
      'barcode': barcode,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'unit': unit,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
