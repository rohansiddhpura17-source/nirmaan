const Business = require('../models/business');
const { getFirestore } = require('../config/firebaseAdmin');

/**
 * Business Repository
 * Manages Firestore `businesses` collection with memory cache/fallback
 */
class BusinessRepository {
  constructor() {
    this.memoryBusinesses = new Map();
    this._seedDemoBusiness();
  }

  _seedDemoBusiness() {
    const demo = new Business({
      businessId: 'biz_nirmaan_demo',
      businessName: 'Kirana King Superstore',
      businessCategory: 'Groceries & Kirana',
      ownerId: 'usr_business_owner',
      contact: {
        phone: '+91 98765 43210',
        address: 'Shop 14, Main Market, Sector 12',
        email: 'owner@nirmaan.com',
      },
      gstNumber: '27AAAAA0000A1Z5',
      currency: 'INR',
      setupComplete: true,
    });

    this.memoryBusinesses.set(demo.businessId, demo);
    this.memoryBusinesses.set(demo.ownerId, demo);
  }

  async findById(businessId) {
    if (!businessId) return null;

    const db = getFirestore();
    if (db) {
      try {
        const doc = await db.collection('businesses').doc(businessId).get();
        if (doc.exists) {
          return new Business({ businessId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    return this.memoryBusinesses.get(businessId) || null;
  }

  async findByOwnerId(ownerId) {
    if (!ownerId) return null;

    const db = getFirestore();
    if (db) {
      try {
        const snap = await db.collection('businesses').where('ownerId', '==', ownerId).limit(1).get();
        if (!snap.empty) {
          const doc = snap.docs[0];
          return new Business({ businessId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    for (const b of this.memoryBusinesses.values()) {
      if (b.ownerId === ownerId) return b;
    }
    return null;
  }

  async create(data) {
    const business = new Business(data);

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('businesses').doc(business.businessId).set(business.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryBusinesses.set(business.businessId, business);
    if (business.ownerId) {
      this.memoryBusinesses.set(business.ownerId, business);
    }
    return business;
  }

  async update(businessId, updateData) {
    const business = await this.findById(businessId);
    if (!business) return null;

    if (updateData.businessName !== undefined) business.businessName = updateData.businessName;
    if (updateData.businessCategory !== undefined) business.businessCategory = updateData.businessCategory;
    if (updateData.contact !== undefined) {
      business.contact = { ...business.contact, ...updateData.contact };
    }
    if (updateData.gstNumber !== undefined) business.gstNumber = updateData.gstNumber;
    if (updateData.currency !== undefined) business.currency = updateData.currency;
    if (updateData.setupComplete !== undefined) business.setupComplete = Boolean(updateData.setupComplete);
    business.updatedAt = new Date();

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('businesses').doc(business.businessId).set(business.toFirestore(), { merge: true });
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryBusinesses.set(business.businessId, business);
    if (business.ownerId) {
      this.memoryBusinesses.set(business.ownerId, business);
    }
    return business;
  }
}

module.exports = new BusinessRepository();
