/**
 * Customer Domain Model
 */
class Customer {
  constructor(data = {}) {
    this.customerId = data.customerId || data.id || `cust_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.id = this.customerId;
    this.businessId = data.businessId;
    this.name = (data.name || '').trim();
    this.phone = (data.phone || '').trim();
    this.email = data.email ? data.email.trim() : null;
    this.address = data.address ? data.address.trim() : '';
    this.totalSpend = Number(data.totalSpend || 0);
    this.orderCount = Number(data.orderCount || 0);
    this.loyaltyPoints = Number(data.loyaltyPoints || 0);
    this.outstandingCredit = Number(data.outstandingCredit || 0);
    this.lastVisitDate = data.lastVisitDate ? new Date(data.lastVisitDate) : new Date();
    this.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
    this.updatedAt = data.updatedAt ? new Date(data.updatedAt) : new Date();
  }

  toJSON() {
    return {
      customerId: this.customerId,
      id: this.customerId,
      businessId: this.businessId,
      name: this.name,
      phone: this.phone,
      email: this.email,
      address: this.address,
      totalSpend: this.totalSpend,
      totalPurchases: this.totalSpend, // Compatibility with UI
      orderCount: this.orderCount,
      loyaltyPoints: this.loyaltyPoints,
      outstandingCredit: this.outstandingCredit,
      lastVisitDate: this.lastVisitDate.toISOString(),
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  toFirestore() {
    return {
      customerId: this.customerId,
      businessId: this.businessId,
      name: this.name,
      phone: this.phone,
      email: this.email,
      address: this.address,
      totalSpend: this.totalSpend,
      orderCount: this.orderCount,
      loyaltyPoints: this.loyaltyPoints,
      outstandingCredit: this.outstandingCredit,
      lastVisitDate: this.lastVisitDate.toISOString(),
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = Customer;
