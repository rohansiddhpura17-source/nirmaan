const Supplier = require('../models/supplier');
const { getFirestore } = require('../config/firebaseAdmin');

class SupplierRepository {
  constructor() {
    this.memorySuppliers = new Map();
    this._seedDemoData();
  }

  _seedDemoData() {
    const demoSuppliers = [
      {
        supplierId: 'sup_demo_001',
        businessId: 'biz_nirmaan_demo',
        name: 'Metro Cash & Carry Wholesale',
        phone: '+91 99000 11223',
        email: 'orders@metro-wholesale.in',
        address: 'APMC Yard, Sector 19, Vashi',
        category: 'FMCG & Staples',
        status: 'ACTIVE',
      },
      {
        supplierId: 'sup_demo_002',
        businessId: 'biz_nirmaan_demo',
        name: 'ITC Distributorship Mumbai Central',
        phone: '+91 99000 44556',
        email: 'supply@itc-dist.in',
        address: 'Godown 12, Industrial Estate',
        category: 'Packaged Foods',
        status: 'ACTIVE',
      },
      {
        supplierId: 'sup_demo_003',
        businessId: 'biz_nirmaan_demo',
        name: 'Hindustan Unilever Local Depot',
        phone: '+91 99000 77889',
        email: 'hul.depot@distributor.com',
        address: 'Building 3, Logistics Park',
        category: 'Personal Care & Homecare',
        status: 'ACTIVE',
      },
    ];

    for (const s of demoSuppliers) {
      const sup = new Supplier(s);
      this.memorySuppliers.set(sup.supplierId, sup);
    }
  }

  async findById(supplierId) {
    if (!supplierId) return null;
    const db = getFirestore();
    if (db) {
      try {
        const doc = await db.collection('suppliers').doc(supplierId).get();
        if (doc.exists) {
          return new Supplier({ supplierId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }
    return this.memorySuppliers.get(supplierId) || null;
  }

  async findByBusinessId(businessId, options = {}) {
    const { query = '', status = 'ALL', page = 1, limit = 50 } = options;

    let items = [];
    const db = getFirestore();
    if (db) {
      try {
        let q = db.collection('suppliers').where('businessId', '==', businessId);
        if (status && status !== 'ALL') {
          q = q.where('status', '==', status);
        }
        const snap = await q.get();
        items = snap.docs.map((doc) => new Supplier({ supplierId: doc.id, ...doc.data() }));
      } catch (err) {
        // Fallback to memory
      }
    }

    if (items.length === 0) {
      items = Array.from(this.memorySuppliers.values()).filter(
        (s) => s.businessId === businessId && (status === 'ALL' || s.status === status)
      );
    }

    if (query) {
      const qLower = query.toLowerCase();
      items = items.filter(
        (s) =>
          s.name.toLowerCase().includes(qLower) ||
          s.phone.includes(query) ||
          (s.email && s.email.toLowerCase().includes(qLower)) ||
          (s.category && s.category.toLowerCase().includes(qLower))
      );
    }

    items.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));

    const total = items.length;
    const startIndex = (page - 1) * limit;
    const paginatedItems = items.slice(startIndex, startIndex + limit);

    return {
      items: paginatedItems,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit) || 1,
    };
  }

  async create(data) {
    const supplier = new Supplier(data);
    const db = getFirestore();
    if (db) {
      try {
        await db.collection('suppliers').doc(supplier.supplierId).set(supplier.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }
    this.memorySuppliers.set(supplier.supplierId, supplier);
    return supplier;
  }

  async update(supplierId, updateData) {
    const supplier = await this.findById(supplierId);
    if (!supplier) return null;

    const allowed = ['name', 'phone', 'email', 'address', 'category', 'status'];
    for (const key of allowed) {
      if (updateData[key] !== undefined) {
        supplier[key] = updateData[key];
      }
    }
    supplier.updatedAt = new Date();

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('suppliers').doc(supplier.supplierId).set(supplier.toFirestore(), { merge: true });
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memorySuppliers.set(supplier.supplierId, supplier);
    return supplier;
  }

  async delete(supplierId) {
    return this.update(supplierId, { status: 'INACTIVE' });
  }
}

module.exports = new SupplierRepository();
