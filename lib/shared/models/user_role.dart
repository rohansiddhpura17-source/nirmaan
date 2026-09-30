enum UserRole {
  businessOwner('BUSINESS_OWNER', 'Business Owner'),
  storeManager('STORE_MANAGER', 'Store Manager'),
  salesStaff('SALES_STAFF', 'Sales Staff'),
  administrator('ADMINISTRATOR', 'Administrator');

  final String code;
  final String label;

  const UserRole(this.code, this.label);

  static UserRole fromCode(String? code) {
    if (code == null) return UserRole.businessOwner;
    return UserRole.values.firstWhere(
      (role) => role.code.toUpperCase() == code.toUpperCase(),
      orElse: () => UserRole.businessOwner,
    );
  }

  // Permission Checks per SRS Roles
  bool get canAccessBusinessIntelligence =>
      this == UserRole.businessOwner || this == UserRole.administrator;

  bool get canAccessFinancials =>
      this == UserRole.businessOwner || this == UserRole.administrator;

  bool get canManageInventory =>
      this == UserRole.businessOwner ||
      this == UserRole.storeManager ||
      this == UserRole.administrator;

  bool get canManageProducts =>
      this == UserRole.businessOwner ||
      this == UserRole.storeManager ||
      this == UserRole.administrator;

  bool get canProcessOrders => true; // All roles can process orders

  bool get canAccessSystemGovernance => this == UserRole.administrator;

  bool get canRunBusinessTwin =>
      this == UserRole.businessOwner || this == UserRole.administrator;
}
