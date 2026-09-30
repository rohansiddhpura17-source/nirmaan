class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? json['item_id'] as String? ?? '',
      productId:
          json['productId'] as String? ?? json['product_id'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Product',
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      unitPrice:
          (json['unitPrice'] as num? ?? json['unit_price'] as num? ?? 0.0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

class OrderModel {
  final String id;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String paymentStatus; // PAID, PENDING, FAILED
  final String orderStatus; // COMPLETED, PROCESSING, CANCELLED
  final String? paymentMethod; // CASH, UPI, CARD
  final DateTime orderDate;

  const OrderModel({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.paymentStatus = 'PAID',
    this.orderStatus = 'COMPLETED',
    this.paymentMethod = 'UPI',
    required this.orderDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? json['order_id'] as String? ?? '',
      customerId:
          json['customerId'] as String? ?? json['customer_id'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalAmount:
          (json['totalAmount'] as num? ?? json['total_amount'] as num? ?? 0.0)
              .toDouble(),
      paymentStatus: json['paymentStatus'] as String? ??
          json['payment_status'] as String? ??
          'PAID',
      orderStatus: json['orderStatus'] as String? ??
          json['order_status'] as String? ??
          'COMPLETED',
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}
