const Product = require('../models/product');
const { getFirestore } = require('../config/firebaseAdmin');

class ProductRepository {
  constructor() {
    this.memoryProducts = new Map();
    this._seedDemoData();
  }

  _seedDemoData() {
    const demoItems = [
      {
        productId: 'prod_demo_001',
        businessId: 'biz_nirmaan_demo',
        name: 'Aashirvaad Shudh Chakki Atta 10kg',
        category: 'Groceries',
        sku: 'AASH-ATTA-10KG',
        barcode: '8901030012345',
        purchasePrice: 380,
        sellingPrice: 440,
        currentStock: 35,
        minStockThreshold: 10,
        unit: 'pack',
        status: 'ACTIVE',
      },
      {
        productId: 'prod_demo_002',
        businessId: 'biz_nirmaan_demo',
        name: 'Fortune Sunlite Refined Sunflower Oil 1L',
        category: 'Groceries',
        sku: 'FORT-OIL-1L',
        barcode: '8901030012346',
        purchasePrice: 120,
        sellingPrice: 145,
        currentStock: 4,
        minStockThreshold: 8,
        unit: 'pouch',
        status: 'ACTIVE',
      },
      {
        productId: 'prod_demo_003',
        businessId: 'biz_nirmaan_demo',
        name: 'Tata Tea Gold Leaf 500g',
        category: 'Beverages',
        sku: 'TATA-TEA-500G',
        barcode: '8901030012347',
        purchasePrice: 220,
        sellingPrice: 260,
        currentStock: 0,
        minStockThreshold: 5,
        unit: 'pack',
        status: 'ACTIVE',
      },
      {
        productId: 'prod_demo_004',
        businessId: 'biz_nirmaan_demo',
        name: 'Dettol Original Germ Protection Soap 125g',
        category: 'Personal Care',
        sku: 'DETT-SOAP-125G',
        barcode: '8901030012348',
        purchasePrice: 45,
        sellingPrice: 58,
        currentStock: 60,
        minStockThreshold: 15,
        unit: 'bar',
        status: 'ACTIVE',
      },
      {
        productId: 'prod_demo_005',
        businessId: 'biz_nirmaan_demo',
        name: 'Surf Excel Easy Wash Detergent Powder 1kg',
        category: 'FMCG',
        sku: 'SURF-DET-1KG',
        barcode: '8901030012349',
        purchasePrice: 115,
        sellingPrice: 140,
        currentStock: 22,
        minStockThreshold: 10,
        unit: 'pack',
        status: 'ACTIVE',
      },
    ];

    for (const item of demoItems) {
      const prod = new Product(item);
      this.memoryProducts.set(prod.productId, prod);
    }
  }

  async findById(productId) {
    if (!productId) return null;
    const db = getFirestore();
    if (db) {
      try {
        const doc = await db.collection('products').doc(productId).get();
        if (doc.exists) {
          return new Product({ productId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }
    return this.memoryProducts.get(productId) || null;
  }

  async findBySku(businessId, sku) {
    if (!businessId || !sku) return null;
    const normalizedSku = sku.trim().toUpperCase();

    const db = getFirestore();
    if (db) {
      try {
        const snap = await db
          .collection('products')
          .where('businessId', '==', businessId)
          .where('sku', '==', normalizedSku)
          .limit(1)
          .get();
        if (!snap.empty) {
          const doc = snap.docs[0];
          return new Product({ productId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    for (const p of this.memoryProducts.values()) {
      if (p.businessId === businessId && p.sku === normalizedSku) {
        return p;
      }
    }
    return null;
  }

  async findByBarcode(businessId, barcode) {
    if (!businessId || !barcode) return null;
    const normalizedBarcode = barcode.trim();

    const db = getFirestore();
    if (db) {
      try {
        const snap = await db
          .collection('products')
          .where('businessId', '==', businessId)
          .where('barcode', '==', normalizedBarcode)
          .limit(1)
          .get();
        if (!snap.empty) {
          const doc = snap.docs[0];
          return new Product({ productId: doc.id, ...doc.data() });
        }
      } catch (err) {
        // Fallback to memory
      }
    }

    for (const p of this.memoryProducts.values()) {
      if (p.businessId === businessId && p.barcode === normalizedBarcode) {
        return p;
      }
    }
    return null;
  }

  async findByBusinessId(businessId, options = {}) {
    const {
      query = '',
      category = 'All',
      stockStatus = 'ALL',
      status = 'ACTIVE',
      page = 1,
      limit = 50,
    } = options;

    let items = [];
    const db = getFirestore();
    if (db) {
      try {
        let q = db.collection('products').where('businessId', '==', businessId);
        if (status && status !== 'ALL') {
          q = q.where('status', '==', status);
        }
        const snap = await q.get();
        items = snap.docs.map((doc) => new Product({ productId: doc.id, ...doc.data() }));
      } catch (err) {
        // Fallback to memory
      }
    }

    if (items.length === 0) {
      items = Array.from(this.memoryProducts.values()).filter(
        (p) => p.businessId === businessId && (status === 'ALL' || p.status === status)
      );
    }

    // Apply filtering
    if (category && category !== 'All') {
      items = items.filter((p) => p.category.toLowerCase() === category.toLowerCase());
    }

    if (query) {
      const qLower = query.toLowerCase();
      items = items.filter(
        (p) =>
          p.name.toLowerCase().includes(qLower) ||
          p.sku.toLowerCase().includes(qLower) ||
          (p.barcode && p.barcode.toLowerCase().includes(qLower)) ||
          (p.description && p.description.toLowerCase().includes(qLower))
      );
    }

    if (stockStatus && stockStatus !== 'ALL') {
      items = items.filter((p) => p.stockStatus === stockStatus);
    }

    // Sort by name or updatedAt
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
    const product = new Product(data);
    const db = getFirestore();
    if (db) {
      try {
        await db.collection('products').doc(product.productId).set(product.toFirestore());
      } catch (err) {
        // Fallback to memory
      }
    }
    this.memoryProducts.set(product.productId, product);
    return product;
  }

  async update(productId, updateData) {
    const product = await this.findById(productId);
    if (!product) return null;

    const allowedFields = [
      'name',
      'description',
      'category',
      'sku',
      'barcode',
      'purchasePrice',
      'costPrice',
      'sellingPrice',
      'currentStock',
      'stockQuantity',
      'minStockThreshold',
      'minThreshold',
      'unit',
      'status',
      'imageUrl',
    ];

    for (const key of allowedFields) {
      if (updateData[key] !== undefined) {
        if (key === 'costPrice') product.purchasePrice = Number(updateData[key]);
        else if (key === 'stockQuantity') product.currentStock = Number(updateData[key]);
        else if (key === 'minThreshold') product.minStockThreshold = Number(updateData[key]);
        else if (key === 'sku') product.sku = updateData[key].trim().toUpperCase();
        else product[key] = updateData[key];
      }
    }
    product.updatedAt = new Date();

    const db = getFirestore();
    if (db) {
      try {
        await db.collection('products').doc(product.productId).set(product.toFirestore(), { merge: true });
      } catch (err) {
        // Fallback to memory
      }
    }

    this.memoryProducts.set(product.productId, product);
    return product;
  }

  async delete(productId) {
    return this.update(productId, { status: 'ARCHIVED' });
  }

  async clearBusiness(businessId) {
    for (const [id, p] of this.memoryProducts.entries()) {
      if (p.businessId === businessId) {
        this.memoryProducts.delete(id);
      }
    }
  }
}

module.exports = new ProductRepository();
