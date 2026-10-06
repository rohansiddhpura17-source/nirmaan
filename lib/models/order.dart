enum OrderStatus {
  completed,
  pending,
  processing,
  cancelled,
}

typedef OrderItem = OrderItemModel;

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const OrderItemModel({
    this.id = '',
    required this.productId,
    required this.productName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    double? lineTotal,
  }) : lineTotal = lineTotal ?? (quantity * unitPrice);

  double get totalPrice => lineTotal;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num? ?? 1).toInt();
    final price = (json['unitPrice'] as num? ??
            json['unit_price'] as num? ??
            json['price'] as num? ??
            0.0)
        .toDouble();
    final total = (json['lineTotal'] as num? ??
            json['line_total'] as num? ??
            (qty * price))
        .toDouble();

    return OrderItemModel(
      id: json['id'] as String? ?? json['item_id'] as String? ?? '',
      productId:
          json['productId'] as String? ?? json['product_id'] as String? ?? '',
      productName: json['productName'] as String? ??
          json['product_name'] as String? ??
          'Product',
      sku: json['sku'] as String?,
      quantity: qty,
      unitPrice: price,
      lineTotal: total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }

  OrderItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    int? quantity,
    double? unitPrice,
    double? lineTotal,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String paymentStatus; // PAID, PENDING, REFUNDED, FAILED
  final String orderStatus; // COMPLETED, PROCESSING, CANCELLED, PENDING
  final String? paymentMethod; // CASH, UPI, CARD
  final DateTime orderDate;

  OrderModel({
    required this.id,
    String? orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.userId = 'usr_system',
    required this.items,
    double? subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    this.paymentStatus = 'PAID',
    String? orderStatus,
    OrderStatus? status,
    this.paymentMethod = 'UPI',
    DateTime? orderDate,
    DateTime? createdAt,
  })  : orderNumber = orderNumber ?? id,
        subtotal = subtotal ?? totalAmount,
        orderStatus =
            orderStatus ?? (status != null ? status.name.toUpperCase() : 'COMPLETED'),
        orderDate = orderDate ?? (createdAt ?? DateTime.now());

  DateTime get createdAt => orderDate;

  OrderStatus get status {
    switch (orderStatus.toLowerCase()) {
      case 'completed':
        return OrderStatus.completed;
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.completed;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = (json['total'] as num? ??
            json['totalAmount'] as num? ??
            json['total_amount'] as num? ??
            0.0)
        .toDouble();
    final rawSubtotal = (json['subtotal'] as num? ?? rawTotal).toDouble();
    final rawDiscount = (json['discount'] as num? ?? 0.0).toDouble();
    final rawTax = (json['tax'] as num? ?? 0.0).toDouble();

    return OrderModel(
      id: json['id'] as String? ??
          json['orderId'] as String? ??
          json['order_id'] as String? ??
          '',
      orderNumber: json['orderNumber'] as String? ??
          json['order_number'] as String? ??
          json['id'] as String? ??
          '',
      customerId:
          json['customerId'] as String? ?? json['customer_id'] as String?,
      customerName: json['customerName'] as String? ??
          json['customer_name'] as String?,
      customerPhone: json['customerPhone'] as String? ??
          json['customer_phone'] as String?,
      userId: json['userId'] as String? ??
          json['user_id'] as String? ??
          json['createdBy'] as String? ??
          'usr_system',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: rawSubtotal,
      discount: rawDiscount,
      tax: rawTax,
      totalAmount: rawTotal,
      paymentStatus: (json['paymentStatus'] as String? ??
              json['payment_status'] as String? ??
              'PAID')
          .toUpperCase(),
      orderStatus: (json['orderStatus'] as String? ??
              json['order_status'] as String? ??
              'COMPLETED')
          .toUpperCase(),
      paymentMethod: (json['paymentMethod'] as String? ??
              json['payment_method'] as String? ??
              'UPI')
          .toUpperCase(),
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'] as String) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': totalAmount,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
      'createdAt': orderDate.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? userId,
    List<OrderItemModel>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? totalAmount,
    String? paymentStatus,
    String? orderStatus,
    String? paymentMethod,
    DateTime? orderDate,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
    );
  }
}
