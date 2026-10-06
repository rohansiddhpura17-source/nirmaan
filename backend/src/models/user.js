/**
 * User Entity Model
 * Firestore Schema Representation
 * Minimum Required Fields:
 * - uid
 * - email
 * - displayName
 * - role
 * - businessId
 * - createdAt
 * - updatedAt
 */
class User {
  constructor({
    uid,
    id,
    email,
    displayName,
    name,
    role = 'BUSINESS_OWNER',
    businessId = null,
    phone = null,
    setupComplete = false,
    isActive = true,
    createdAt = new Date(),
    updatedAt = new Date(),
  }) {
    this.uid = uid || id || `usr_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.id = this.uid;
    this.email = (email || '').toLowerCase().trim();
    this.displayName = displayName || name || 'Nirmaan User';
    this.name = this.displayName;
    this.role = (role || 'BUSINESS_OWNER').toUpperCase();
    this.businessId = businessId;
    this.phone = phone;
    this.setupComplete = Boolean(setupComplete);
    this.isActive = Boolean(isActive);
    this.createdAt = createdAt instanceof Date ? createdAt : new Date(createdAt);
    this.updatedAt = updatedAt instanceof Date ? updatedAt : new Date(updatedAt);
  }

  toFirestore() {
    return {
      uid: this.uid,
      email: this.email,
      displayName: this.displayName,
      role: this.role,
      businessId: this.businessId,
      phone: this.phone,
      setupComplete: this.setupComplete,
      isActive: this.isActive,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  toSafeJSON() {
    return {
      uid: this.uid,
      id: this.uid,
      email: this.email,
      displayName: this.displayName,
      name: this.displayName,
      role: this.role,
      businessId: this.businessId,
      phone: this.phone,
      setupComplete: this.setupComplete,
      isActive: this.isActive,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = User;
