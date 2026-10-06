class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final int loyaltyPoints;
  final double totalSpent;
  final int totalOrders;
  final double outstandingCredit;
  final DateTime? lastVisit;
  final String? churnRisk; // Low, Medium, High
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.loyaltyPoints = 0,
    double? totalSpent,
    double? totalSpend,
    int? totalOrders,
    int? orderCount,
    this.outstandingCredit = 0.0,
    DateTime? lastVisit,
    DateTime? lastVisitDate,
    String? churnRisk,
    bool? isChurnRisk,
    DateTime? createdAt,
  })  : totalSpent = totalSpend ?? totalSpent ?? 0.0,
        totalOrders = orderCount ?? totalOrders ?? 0,
        lastVisit = lastVisitDate ?? lastVisit,
        churnRisk = churnRisk ?? (isChurnRisk == true ? 'High' : 'Low'),
        createdAt = createdAt ?? DateTime.now();

  double get totalSpend => totalSpent;
  int get orderCount => totalOrders;
  bool get isChurnRisk => churnRisk?.toLowerCase() == 'high';

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String? ??
          json['customerId'] as String? ??
          json['customer_id'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      loyaltyPoints:
          (json['loyaltyPoints'] as num? ?? json['loyalty_points'] as num? ?? 0)
              .toInt(),
      totalSpent: (json['totalSpend'] as num? ??
              json['totalSpent'] as num? ??
              json['total_spent'] as num? ??
              0.0)
          .toDouble(),
      totalOrders: (json['orderCount'] as num? ??
              json['totalOrders'] as num? ??
              json['order_count'] as num? ??
              0)
          .toInt(),
      outstandingCredit: (json['outstandingCredit'] as num? ?? 0.0).toDouble(),
      lastVisit: json['lastVisitDate'] != null
          ? DateTime.tryParse(json['lastVisitDate'] as String)
          : (json['lastVisit'] != null
              ? DateTime.tryParse(json['lastVisit'] as String)
              : null),
      churnRisk: json['churnRisk'] as String? ?? 'Low',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'loyaltyPoints': loyaltyPoints,
      'totalSpent': totalSpent,
      'totalSpend': totalSpent,
      'totalOrders': totalOrders,
      'orderCount': totalOrders,
      'outstandingCredit': outstandingCredit,
      'lastVisit': lastVisit?.toIso8601String(),
      'lastVisitDate': lastVisit?.toIso8601String(),
      'churnRisk': churnRisk,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    int? loyaltyPoints,
    double? totalSpent,
    int? totalOrders,
    double? outstandingCredit,
    DateTime? lastVisit,
    String? churnRisk,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrders: totalOrders ?? this.totalOrders,
      outstandingCredit: outstandingCredit ?? this.outstandingCredit,
      lastVisit: lastVisit ?? this.lastVisit,
      churnRisk: churnRisk ?? this.churnRisk,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
