const InventoryMovement = require('../models/inventoryMovement');
const { getFirestore } = require('../config/firebaseAdmin');

class InventoryMovementRepository {
  constructor() {
    this.memoryMovements = new Map();
    this._seedDemoData();
  }

  _seedDemoData() {
    const demoMovements = [
      {
        movementId: 'mov_demo_001',
        businessId: 'biz_nirmaan_demo',
        productId: 'prod_demo_001',
        productName: 'Aashirvaad Shudh Chakki Atta 10kg',
        type: 'RESTOCK',
        quantity: 50,
        previousStock: 0,
        resultingStock: 50,
        reason: 'Initial supplier restock',
        createdBy: 'usr_business_owner',
      },
      {
        movementId: 'mov_demo_002',
        businessId: 'biz_nirmaan_demo',
        productId: 'prod_demo_001',
        productName: 'Aashirvaad Shudh Chakki Atta 10kg',
        type: 'SALE',
        quantity: 15,
        previousStock: 50,
        resultingStock: 35,
        reason: 'Order #ORD-10023 sales counter checkout',
        referenceId: 'ord_demo_001',
        createdBy: 'usr_sales_staff',
      },
    ];

    for (const m of demoMovements) {
      const mov = new InventoryMovement(m);
      this.memoryMovements.set(mov.movementId, mov);
    }
  }

  async create(data) {
    const movement = new InventoryMovement(data);
    const db = getFirestore();
    if (db) {
      try {
        await db.collection('inventoryMovements').doc(movement.movementId).set(movement.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }
    this.memoryMovements.set(movement.movementId, movement);
    return movement;
  }

  async findByBusinessId(businessId, options = {}) {
    const { productId, type, page = 1, limit = 50 } = options;

    let items = [];
    const db = getFirestore();
    if (db) {
      try {
        let q = db.collection('inventoryMovements').where('businessId', '==', businessId);
        if (productId) {
          q = q.where('productId', '==', productId);
        }
        if (type && type !== 'ALL') {
          q = q.where('type', '==', type.toUpperCase());
        }
        const snap = await q.get();
        items = snap.docs.map((doc) => new InventoryMovement({ movementId: doc.id, ...doc.data() }));
      } catch (err) {
        // Fallback to memory
      }
    }

    if (items.length === 0) {
      items = Array.from(this.memoryMovements.values()).filter(
        (m) =>
          m.businessId === businessId &&
          (!productId || m.productId === productId) &&
          (!type || type === 'ALL' || m.type === type.toUpperCase())
      );
    }

    // Sort descending by date
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

  async findByProductId(productId, limit = 20) {
    const items = Array.from(this.memoryMovements.values()).filter(
      (m) => m.productId === productId
    );
    items.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    return items.slice(0, limit);
  }
}

module.exports = new InventoryMovementRepository();
