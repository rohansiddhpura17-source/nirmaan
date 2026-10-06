class SupplierModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String category;
  final String status; // ACTIVE, INACTIVE
  final DateTime createdAt;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.category = 'General',
    this.status = 'ACTIVE',
    required this.createdAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String? ??
          json['supplierId'] as String? ??
          json['supplier_id'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      category: json['category'] as String? ?? 'General',
      status: (json['status'] as String? ?? 'ACTIVE').toUpperCase(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? category,
    String? status,
    DateTime? createdAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
