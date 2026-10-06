/**
 * Supplier Domain Model
 */
class Supplier {
  constructor(data = {}) {
    this.supplierId = data.supplierId || data.id || `sup_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.businessId = data.businessId;
    this.name = (data.name || '').trim();
    this.phone = (data.phone || '').trim();
    this.email = data.email ? data.email.trim() : null;
    this.address = data.address ? data.address.trim() : '';
    this.category = data.category || 'General';
    this.status = data.status || 'ACTIVE'; // ACTIVE | INACTIVE
    this.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
    this.updatedAt = data.updatedAt ? new Date(data.updatedAt) : new Date();
  }

  toJSON() {
    return {
      supplierId: this.supplierId,
      id: this.supplierId,
      businessId: this.businessId,
      name: this.name,
      phone: this.phone,
      email: this.email,
      address: this.address,
      category: this.category,
      status: this.status,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  toFirestore() {
    return {
      supplierId: this.supplierId,
      businessId: this.businessId,
      name: this.name,
      phone: this.phone,
      email: this.email,
      address: this.address,
      category: this.category,
      status: this.status,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = Supplier;
