const Customer = require('../models/customer');
const { getFirestore } = require('../config/firebaseAdmin');

class CustomerRepository {
  constructor() {
    this.memoryCustomers = new Map();
    this._seedDemoData();
  }

  _seedDemoData() {
    const demoCustomers = [
      {
        customerId: 'cust_demo_001',
        businessId: 'biz_nirmaan_demo',
        name: 'Sharma Ji Kirana Account',
        phone: '+91 98200 12345',
        email: 'sharma@example.com',
        address: 'B-102 Gokuldham Society',
        totalSpend: 14250,
        orderCount: 18,
        loyaltyPoints: 142,
        outstandingCredit: 1200,
      },
      {
        customerId: 'cust_demo_002',
        businessId: 'biz_nirmaan_demo',
        name: 'Pooja Verma',
        phone: '+91 98200 54321',
        email: 'pooja.verma@example.com',
        address: 'Flat 4A, Green Meadows',
        totalSpend: 8400,
        orderCount: 11,
        loyaltyPoints: 84,
        outstandingCredit: 0,
      },
      {
        customerId: 'cust_demo_003',
        businessId: 'biz_nirmaan_demo',
        name: 'Amit Patel',
        phone: '+91 98200 99887',
        email: 'amit.patel@example.com',
        address: 'Plot 55, Shivam Enclave',
        totalSpend: 3100,
        orderCount: 4,
        loyaltyPoints: 31,
        outstandingCredit: 450,
      },
    ];

    for (const c of demoCustomers) {
      const cust = new Customer(c);
      this.memoryCustomers.set(cust.customerId, cust);
    }
  }

  async findById(customerId) {
    if (!customerId) return null;
    const db = getFirestore();
    if (db) {
      try {
        const doc = await db.collection('customers').doc(customerId).get();
        if (doc.exists) {
          return new Customer({ customerId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }
    return this.memoryCustomers.get(customerId) || null;
  }

  async findByPhone(businessId, phone) {
    if (!businessId || !phone) return null;
    const normalized = phone.replace(/[\s-]/g, '');

    const db = getFirestore();
    if (db) {
      try {
        const snap = await db
          .collection('customers')
          .where('businessId', '==', businessId)
          .where('phone', '==', phone)
          .limit(1)
          .get();
        if (!snap.empty) {
          const doc = snap.docs[0];
          return new Customer({ customerId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    for (const c of this.memoryCustomers.values()) {
      if (c.businessId === businessId && c.phone.replace(/[\s-]/g, '') === normalized) {
        return c;
      }
    }
    return null;
  }

  async findByBusinessId(businessId, options = {}) {
    const { query = '', page = 1, limit = 50 } = options;

    let items = [];
    const db = getFirestore();
    if (db) {
      try {
        const snap = await db.collection('customers').where('businessId', '==', businessId).get();
        items = snap.docs.map((doc) => new Customer({ customerId: doc.id, ...doc.data() }));
      } catch (err) {
        // Fallback to memory
      }
    }

    if (items.length === 0) {
      items = Array.from(this.memoryCustomers.values()).filter(
        (c) => c.businessId === businessId
      );
    }

    if (query) {
      const qLower = query.toLowerCase();
      items = items.filter(
        (c) =>
          c.name.toLowerCase().includes(qLower) ||
          c.phone.includes(query) ||
          (c.email && c.email.toLowerCase().includes(qLower))
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
    const customer = new Customer(data);
    const db = getFirestore();
    if (db) {
      try {
        await db.collection('customers').doc(customer.customerId).set(customer.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }
    this.memoryCustomers.set(customer.customerId, customer);
    return customer;
  }

  async update(customerId, updateData) {
    const customer = await this.findById(customerId);
    if (!customer) return null;

    const allowed = [
      'name',
      'phone',
      'email',
      'address',
      'totalSpend',
      'orderCount',
      'loyaltyPoints',
      'outstandingCredit',
      'lastVisitDate',
    ];

    for (const key of allowed) {
      if (updateData[key] !== undefined) {
        customer[key] = updateData[key];
      }
    }
    customer.updatedAt = new Date();

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('customers').doc(customer.customerId).set(customer.toFirestore(), { merge: true });
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryCustomers.set(customer.customerId, customer);
    return customer;
  }

  async remove(customerId) {
    const customer = await this.findById(customerId);
    if (!customer) return false;
    const db = getFirestore();
    if (db) {
      try {
        await db.collection('customers').doc(customerId).delete();
      } catch (err) {
        // Fallback to memory
      }
    }
    this.memoryCustomers.delete(customerId);
    return true;
  }
}

module.exports = new CustomerRepository();
