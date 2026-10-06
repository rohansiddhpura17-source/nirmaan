const User = require('../models/user');
const { ROLES } = require('../middleware/rbacMiddleware');
const { getFirestore } = require('../config/firebaseAdmin');
const config = require('../config/environment');

// Ephemeral test-only credential store strictly isolated from entity models and production
const testOnlyCredentialStore = new Map();

/**
 * User Repository
 * Manages Firestore `users` collection with memory cache/fallback
 * SECURITY: User credentials (passwords) are strictly managed by Firebase Auth and NEVER stored here.
 */
class UserRepository {
  constructor() {
    this.memoryUsers = new Map();
    this._seedDemoUsers();
  }

  _seedDemoUsers() {
    if (config.env === 'production') return;

    const demoAccounts = [
      {
        uid: 'usr_business_owner',
        email: 'owner@nirmaan.com',
        displayName: 'Rohan Siddhpura',
        role: ROLES.BUSINESS_OWNER,
        phone: '+91 98765 43210',
        businessId: 'biz_nirmaan_demo',
        setupComplete: true,
      },
      {
        uid: 'usr_store_manager',
        email: 'manager@nirmaan.com',
        displayName: 'Digvijaysinh Vaghela',
        role: ROLES.STORE_MANAGER,
        phone: '+91 98765 43211',
        businessId: 'biz_nirmaan_demo',
        setupComplete: true,
      },
      {
        uid: 'usr_sales_staff',
        email: 'staff@nirmaan.com',
        displayName: 'Meet Kotecha',
        role: ROLES.SALES_STAFF,
        phone: '+91 98765 43212',
        businessId: 'biz_nirmaan_demo',
        setupComplete: true,
      },
      {
        uid: 'usr_administrator',
        email: 'admin@nirmaan.com',
        displayName: 'System Administrator',
        role: ROLES.ADMINISTRATOR,
        phone: '+91 98765 43213',
        businessId: 'biz_nirmaan_sys',
        setupComplete: true,
      },
    ];

    for (const demo of demoAccounts) {
      const user = new User(demo);
      this.memoryUsers.set(user.email, user);
      this.memoryUsers.set(user.uid, user);
      testOnlyCredentialStore.set(user.email, 'Password@123');
    }
  }

  async findByEmail(email) {
    if (!email) return null;
    const normalized = email.toLowerCase().trim();

    const db = getFirestore();
    if (db) {
      try {
        const snap = await db.collection('users').where('email', '==', normalized).limit(1).get();
        if (!snap.empty) {
          const doc = snap.docs[0];
          return new User({ uid: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    return this.memoryUsers.get(normalized) || null;
  }

  async findById(uid) {
    if (!uid) return null;

    const db = getFirestore();
    if (db) {
      try {
        const doc = await db.collection('users').doc(uid).get();
        if (doc.exists) {
          return new User({ uid: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    for (const user of this.memoryUsers.values()) {
      if (user.uid === uid || user.id === uid) return user;
    }
    return null;
  }

  async create(userData) {
    // SECURITY: Passwords must NEVER be stored in User entities or Firestore
    const { password, ...safeUserData } = userData;
    const user = new User(safeUserData);

    if (config.env !== 'production' && password) {
      testOnlyCredentialStore.set(user.email, password);
    }

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('users').doc(user.uid).set(user.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryUsers.set(user.email, user);
    this.memoryUsers.set(user.uid, user);
    return user;
  }

  verifyTestPassword(email, candidatePassword) {
    if (config.env === 'production') return false;
    const stored = testOnlyCredentialStore.get(email?.toLowerCase().trim());
    return Boolean(stored && stored === candidatePassword);
  }

  async update(uid, updateData) {
    const user = await this.findById(uid);
    if (!user) return null;

    if (updateData.displayName !== undefined) {
      user.displayName = updateData.displayName;
      user.name = updateData.displayName;
    }
    if (updateData.phone !== undefined) user.phone = updateData.phone;
    if (updateData.businessId !== undefined) user.businessId = updateData.businessId;
    if (updateData.setupComplete !== undefined) user.setupComplete = Boolean(updateData.setupComplete);
    if (updateData.role !== undefined) user.role = updateData.role.toUpperCase();
    if (updateData.isActive !== undefined) user.isActive = Boolean(updateData.isActive);
    user.updatedAt = new Date();

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('users').doc(user.uid).set(user.toFirestore(), { merge: true });
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryUsers.set(user.email, user);
    this.memoryUsers.set(user.uid, user);
    return user;
  }

  async list() {
    return Array.from(new Set(this.memoryUsers.values())).map((u) => u.toSafeJSON());
  }
}

module.exports = new UserRepository();
