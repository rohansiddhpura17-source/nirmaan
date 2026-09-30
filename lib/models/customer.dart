class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final int loyaltyPoints;
  final double totalSpent;
  final int totalOrders;
  final DateTime? lastVisit;
  final String? churnRisk; // Low, Medium, High
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.loyaltyPoints = 0,
    double? totalSpent,
    double? totalSpend,
    this.totalOrders = 0,
    this.lastVisit,
    String? churnRisk,
    bool? isChurnRisk,
    DateTime? createdAt,
  })  : totalSpent = totalSpend ?? totalSpent ?? 0.0,
        churnRisk = churnRisk ?? (isChurnRisk == true ? 'High' : 'Low'),
        createdAt = createdAt ?? DateTime.now();

  double get totalSpend => totalSpent;
  bool get isChurnRisk => churnRisk?.toLowerCase() == 'high';

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String? ?? json['customer_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      loyaltyPoints:
          (json['loyaltyPoints'] as num? ?? json['loyalty_points'] as num? ?? 0)
              .toInt(),
      totalSpent:
          (json['totalSpent'] as num? ?? json['total_spent'] as num? ?? 0.0)
              .toDouble(),
      totalOrders: (json['totalOrders'] as num? ?? 0).toInt(),
      lastVisit: json['lastVisit'] != null
          ? DateTime.tryParse(json['lastVisit'] as String)
          : null,
      churnRisk: json['churnRisk'] as String? ?? 'Low',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'loyaltyPoints': loyaltyPoints,
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
      'lastVisit': lastVisit?.toIso8601String(),
      'churnRisk': churnRisk,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
