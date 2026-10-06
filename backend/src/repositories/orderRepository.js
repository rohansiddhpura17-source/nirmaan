const Order = require('../models/order');
const { getFirestore } = require('../config/firebaseAdmin');

class OrderRepository {
  constructor() {
    this.memoryOrders = new Map();
    this._seedDemoData();
  }

  _seedDemoData() {
    const demoOrders = [
      {
        orderId: 'ord_demo_001',
        businessId: 'biz_nirmaan_demo',
        orderNumber: 'ORD-10023',
        customerId: 'cust_demo_001',
        customerName: 'Sharma Ji Kirana Account',
        customerPhone: '+91 98200 12345',
        items: [
          {
            productId: 'prod_demo_001',
            productName: 'Aashirvaad Shudh Chakki Atta 10kg',
            sku: 'AASH-ATTA-10KG',
            quantity: 2,
            unitPrice: 440,
            lineTotal: 880,
          },
          {
            productId: 'prod_demo_002',
            productName: 'Fortune Sunlite Refined Sunflower Oil 1L',
            sku: 'FORT-OIL-1L',
            quantity: 3,
            unitPrice: 145,
            lineTotal: 435,
          },
        ],
        subtotal: 1315,
        discount: 15,
        tax: 0,
        total: 1300,
        paymentMethod: 'UPI',
        paymentStatus: 'PAID',
        orderStatus: 'COMPLETED',
        createdBy: 'usr_sales_staff',
      },
      {
        orderId: 'ord_demo_002',
        businessId: 'biz_nirmaan_demo',
        orderNumber: 'ORD-10024',
        customerId: 'cust_demo_002',
        customerName: 'Pooja Verma',
        customerPhone: '+91 98200 54321',
        items: [
          {
            productId: 'prod_demo_004',
            productName: 'Dettol Original Germ Protection Soap 125g',
            sku: 'DETT-SOAP-125G',
            quantity: 4,
            unitPrice: 58,
            lineTotal: 232,
          },
        ],
        subtotal: 232,
        discount: 0,
        tax: 0,
        total: 232,
        paymentMethod: 'CASH',
        paymentStatus: 'PAID',
        orderStatus: 'COMPLETED',
        createdBy: 'usr_sales_staff',
      },
    ];

    for (const o of demoOrders) {
      const order = new Order(o);
      this.memoryOrders.set(order.orderId, order);
    }
  }

  async findById(orderId) {
    if (!orderId) return null;
    const db = getFirestore();
    if (db) {
      try {
        const doc = await db.collection('orders').doc(orderId).get();
        if (doc.exists) {
          return new Order({ orderId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }
    return this.memoryOrders.get(orderId) || null;
  }

  async findByIdempotencyKey(businessId, idempotencyKey) {
    if (!businessId || !idempotencyKey) return null;

    const db = getFirestore();
    if (db) {
      try {
        const snap = await db
          .collection('orders')
          .where('businessId', '==', businessId)
          .where('idempotencyKey', '==', idempotencyKey)
          .limit(1)
          .get();
        if (!snap.empty) {
          const doc = snap.docs[0];
          return new Order({ orderId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    for (const o of this.memoryOrders.values()) {
      if (o.businessId === businessId && o.idempotencyKey === idempotencyKey) {
        return o;
      }
    }
    return null;
  }

  async findByBusinessId(businessId, options = {}) {
    const {
      query = '',
      status = 'ALL',
      paymentStatus = 'ALL',
      page = 1,
      limit = 50,
    } = options;

    let items = [];
    const db = getFirestore();
    if (db) {
      try {
        let q = db.collection('orders').where('businessId', '==', businessId);
        if (status && status !== 'ALL') {
          q = q.where('orderStatus', '==', status);
        }
        const snap = await q.get();
        items = snap.docs.map((doc) => new Order({ orderId: doc.id, ...doc.data() }));
      } catch (err) {
        // Fallback to memory
      }
    }

    if (items.length === 0) {
      items = Array.from(this.memoryOrders.values()).filter(
        (o) =>
          o.businessId === businessId &&
          (status === 'ALL' || o.orderStatus === status) &&
          (paymentStatus === 'ALL' || o.paymentStatus === paymentStatus)
      );
    }

    if (query) {
      const qLower = query.toLowerCase();
      items = items.filter(
        (o) =>
          o.orderNumber.toLowerCase().includes(qLower) ||
          o.customerName.toLowerCase().includes(qLower) ||
          (o.customerPhone && o.customerPhone.includes(query))
      );
    }

    items.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

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
    const order = new Order(data);
    const db = getFirestore();
    if (db) {
      try {
        await db.collection('orders').doc(order.orderId).set(order.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }
    this.memoryOrders.set(order.orderId, order);
    return order;
  }

  async update(orderId, updateData) {
    const order = await this.findById(orderId);
    if (!order) return null;

    if (updateData.orderStatus) order.orderStatus = updateData.orderStatus;
    if (updateData.paymentStatus) order.paymentStatus = updateData.paymentStatus;
    order.updatedAt = new Date();

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('orders').doc(order.orderId).set(order.toFirestore(), { merge: true });
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryOrders.set(order.orderId, order);
    return order;
  }
}

module.exports = new OrderRepository();
