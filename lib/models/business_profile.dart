class BusinessProfile {
  final String id;
  final String businessName;
  final String category;
  final String ownerName;
  final String phone;
  final String? address;
  final String currency;
  final bool isSetupCompleted;
  final DateTime createdAt;

  const BusinessProfile({
    required this.id,
    required this.businessName,
    required this.category,
    required this.ownerName,
    required this.phone,
    this.address,
    this.currency = '₹',
    this.isSetupCompleted = false,
    required this.createdAt,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String?,
      currency: json['currency'] as String? ?? '₹',
      isSetupCompleted: json['isSetupCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      'category': category,
      'ownerName': ownerName,
      'phone': phone,
      'address': address,
      'currency': currency,
      'isSetupCompleted': isSetupCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BusinessProfile copyWith({
    String? id,
    String? businessName,
    String? category,
    String? ownerName,
    String? phone,
    String? address,
    String? currency,
    bool? isSetupCompleted,
    DateTime? createdAt,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      currency: currency ?? this.currency,
      isSetupCompleted: isSetupCompleted ?? this.isSetupCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
