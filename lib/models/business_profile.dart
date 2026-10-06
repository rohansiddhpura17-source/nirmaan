class BusinessProfile {
  final String id;
  final String businessName;
  final String category;
  final String ownerName;
  final String phone;
  final String? address;
  final String? gstNumber;
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
    this.gstNumber,
    this.currency = '₹',
    this.isSetupCompleted = false,
    required this.createdAt,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    String phone = json['phone'] as String? ?? '';
    String? address = json['address'] as String?;
    if (json['contact'] is Map) {
      final contact = json['contact'] as Map<String, dynamic>;
      if (phone.isEmpty && contact['phone'] != null) {
        phone = contact['phone'].toString();
      }
      if (address == null && contact['address'] != null) {
        address = contact['address'].toString();
      }
    }

    return BusinessProfile(
      id: json['id'] as String? ?? json['businessId'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      category: json['category'] as String? ??
          json['businessCategory'] as String? ??
          '',
      ownerName: json['ownerName'] as String? ?? '',
      phone: phone,
      address: address,
      gstNumber: json['gstNumber'] as String?,
      currency: json['currency'] as String? ?? '₹',
      isSetupCompleted: json['isSetupCompleted'] as bool? ??
          json['setupComplete'] as bool? ??
          false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': id,
      'businessName': businessName,
      'category': category,
      'businessCategory': category,
      'ownerName': ownerName,
      'phone': phone,
      'address': address,
      'gstNumber': gstNumber,
      'currency': currency,
      'isSetupCompleted': isSetupCompleted,
      'setupComplete': isSetupCompleted,
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
    String? gstNumber,
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
      gstNumber: gstNumber ?? this.gstNumber,
      currency: currency ?? this.currency,
      isSetupCompleted: isSetupCompleted ?? this.isSetupCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
