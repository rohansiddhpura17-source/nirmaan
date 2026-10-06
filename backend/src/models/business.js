/**
 * Business Entity Model
 * Firestore Schema Representation
 * Minimum Required Fields:
 * - businessId
 * - businessName
 * - businessCategory
 * - ownerId
 * - contact information
 * - currency
 * - setupComplete
 * - createdAt
 * - updatedAt
 */
class Business {
  constructor({
    businessId,
    id,
    businessName,
    name,
    businessCategory,
    category,
    ownerId,
    contact = {},
    phone,
    address,
    email,
    currency = 'INR',
    gstNumber = null,
    setupComplete = false,
    createdAt = new Date(),
    updatedAt = new Date(),
  }) {
    this.businessId = businessId || id || `biz_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.id = this.businessId;
    this.businessName = businessName || name || 'My Business';
    this.businessCategory = businessCategory || category || 'General Retail';
    this.ownerId = ownerId;
    this.contact = {
      phone: contact.phone || phone || '',
      address: contact.address || address || '',
      email: contact.email || email || '',
    };
    this.currency = currency || 'INR';
    this.gstNumber = gstNumber || null;
    this.setupComplete = Boolean(setupComplete);
    this.createdAt = createdAt instanceof Date ? createdAt : new Date(createdAt);
    this.updatedAt = updatedAt instanceof Date ? updatedAt : new Date(updatedAt);
  }

  toFirestore() {
    return {
      businessId: this.businessId,
      businessName: this.businessName,
      businessCategory: this.businessCategory,
      ownerId: this.ownerId,
      contact: this.contact,
      currency: this.currency,
      gstNumber: this.gstNumber,
      setupComplete: this.setupComplete,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  toSafeJSON() {
    return {
      businessId: this.businessId,
      id: this.businessId,
      businessName: this.businessName,
      businessCategory: this.businessCategory,
      ownerId: this.ownerId,
      contact: this.contact,
      currency: this.currency,
      gstNumber: this.gstNumber,
      setupComplete: this.setupComplete,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = Business;
