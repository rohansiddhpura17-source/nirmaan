/**
 * Dedicated Business Data Seeding Service for Nirmaan (Phase 6 Data Fix).
 *
 * Generates realistic, internally consistent business data for a small retail/general store:
 * - 1 Business profile with realistic location and contact details
 * - 20 Products across Grocery, Beverages, Personal Care, Household (mix of healthy, low, and out-of-stock)
 * - 15 Synthetic Customers with realistic purchase history and khata balances
 * - 32 Historical Orders distributed across today, yesterday, last 7 days, and last 30 days
 * - Consistent Inventory Movements corresponding to sales and stock levels
 */

const businessRepository = require('../repositories/businessRepository');
const productRepository = require('../repositories/productRepository');
const customerRepository = require('../repositories/customerRepository');
const orderRepository = require('../repositories/orderRepository');
const inventoryMovementRepository = require('../repositories/inventoryMovementRepository');
const Business = require('../models/business');
const Product = require('../models/product');
const Customer = require('../models/customer');
const Order = require('../models/order');

class SeedService {
  /**
   * Seeds realistic business data for a specified businessId and ownerId.
   *
   * @param {string} [targetBusinessId='biz_nirmaan_demo']
   * @param {string} [targetOwnerId='usr_business_owner']
   * @param {Object} [overrides={}]
   * @returns {Promise<Object>} Summary of seeded records
   */
  async seedTenant(targetBusinessId = 'biz_nirmaan_demo', targetOwnerId = 'usr_business_owner', overrides = {}) {
    const businessId = targetBusinessId;
    const ownerId = targetOwnerId;

    // 1. Seed Business Profile
    const businessData = {
      businessId,
      businessName: overrides.businessName || 'Shreeji General & Provision Store',
      businessCategory: overrides.businessCategory || 'Grocery & FMCG',
      ownerId,
      contact: {
        phone: overrides.phone || '+91 98258 82648',
        address: overrides.address || 'Shop 14, Galaxy Commercial Complex, Kalawad Road, Rajkot, Gujarat 360005',
        email: overrides.email || 'shreeji.rajkot@nirmaan.local',
      },
      gstNumber: overrides.gstNumber || '24AAACS1428Q1ZP',
      currency: 'INR',
      setupComplete: true,
    };

    const business = new Business(businessData);
    await businessRepository.create(business);

    // 2. Seed 20 Products (Categorized & Stock Variance)
    const productDefinitions = [
      // Grocery
      {
        id: `prod_${businessId}_01`,
        name: 'Aashirvaad Shudh Chakki Atta 10kg',
        category: 'Grocery & FMCG',
        sku: 'AASH-ATTA-10KG',
        barcode: '8901030012341',
        purchasePrice: 380,
        sellingPrice: 440,
        currentStock: 35,
        minStockThreshold: 10,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_02`,
        name: 'Fortune Sunlite Sunflower Oil 1L',
        category: 'Grocery & FMCG',
        sku: 'FORT-OIL-1L',
        barcode: '8901030012342',
        purchasePrice: 120,
        sellingPrice: 145,
        currentStock: 4, // LOW STOCK
        minStockThreshold: 8,
        unit: 'pouch',
      },
      {
        id: `prod_${businessId}_03`,
        name: 'Tata Salt Vacuum Evaporated 1kg',
        category: 'Grocery & FMCG',
        sku: 'TATA-SALT-1KG',
        barcode: '8901030012343',
        purchasePrice: 22,
        sellingPrice: 28,
        currentStock: 60,
        minStockThreshold: 15,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_04`,
        name: 'Daawat Rozana Super Basmati Rice 5kg',
        category: 'Grocery & FMCG',
        sku: 'DAWT-RICE-5KG',
        barcode: '8901030012344',
        purchasePrice: 350,
        sellingPrice: 420,
        currentStock: 22,
        minStockThreshold: 8,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_05`,
        name: 'Maggi 2-Minute Masala Noodles 420g',
        category: 'Grocery & FMCG',
        sku: 'NEST-MAGG-420G',
        barcode: '8901030012345',
        purchasePrice: 80,
        sellingPrice: 96,
        currentStock: 45,
        minStockThreshold: 12,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_06`,
        name: 'Tata Sampann Unpolished Toor Dal 1kg',
        category: 'Grocery & FMCG',
        sku: 'TATA-TOOR-1KG',
        barcode: '8901030012346',
        purchasePrice: 148,
        sellingPrice: 175,
        currentStock: 18,
        minStockThreshold: 6,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_07`,
        name: 'Amul Pure Ghee 1L Tin',
        category: 'Grocery & FMCG',
        sku: 'AMUL-GHEE-1L',
        barcode: '8901030012347',
        purchasePrice: 540,
        sellingPrice: 610,
        currentStock: 12,
        minStockThreshold: 5,
        unit: 'tin',
      },
      // Beverages
      {
        id: `prod_${businessId}_08`,
        name: 'Tata Tea Gold Leaf 500g',
        category: 'Beverages',
        sku: 'TATA-TEA-500G',
        barcode: '8901030012348',
        purchasePrice: 220,
        sellingPrice: 260,
        currentStock: 0, // OUT OF STOCK
        minStockThreshold: 5,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_09`,
        name: 'Nescafe Classic Instant Coffee Jar 100g',
        category: 'Beverages',
        sku: 'NESC-COFF-100G',
        barcode: '8901030012349',
        purchasePrice: 270,
        sellingPrice: 320,
        currentStock: 15,
        minStockThreshold: 5,
        unit: 'jar',
      },
      {
        id: `prod_${businessId}_10`,
        name: 'Cadbury Bournvita Chocolate Drink 500g',
        category: 'Beverages',
        sku: 'CADB-BOURN-500G',
        barcode: '8901030012350',
        purchasePrice: 195,
        sellingPrice: 235,
        currentStock: 3, // LOW STOCK
        minStockThreshold: 6,
        unit: 'jar',
      },
      {
        id: `prod_${businessId}_11`,
        name: 'Real Fruit Power Mixed Fruit Juice 1L',
        category: 'Beverages',
        sku: 'DABR-REAL-1L',
        barcode: '8901030012351',
        purchasePrice: 102,
        sellingPrice: 125,
        currentStock: 20,
        minStockThreshold: 8,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_12`,
        name: 'Coca-Cola 750ml PET Bottle',
        category: 'Beverages',
        sku: 'COKE-PET-750ML',
        barcode: '8901030012352',
        purchasePrice: 32,
        sellingPrice: 40,
        currentStock: 36,
        minStockThreshold: 12,
        unit: 'bottle',
      },
      // Personal Care
      {
        id: `prod_${businessId}_13`,
        name: 'Dettol Original Germ Protection Soap 125g',
        category: 'Personal Care',
        sku: 'DETT-SOAP-125G',
        barcode: '8901030012353',
        purchasePrice: 46,
        sellingPrice: 58,
        currentStock: 50,
        minStockThreshold: 15,
        unit: 'bar',
      },
      {
        id: `prod_${businessId}_14`,
        name: 'Colgate MaxFresh Spicy Fresh Toothpaste 150g',
        category: 'Personal Care',
        sku: 'COLG-MAXF-150G',
        barcode: '8901030012354',
        purchasePrice: 88,
        sellingPrice: 110,
        currentStock: 28,
        minStockThreshold: 10,
        unit: 'tube',
      },
      {
        id: `prod_${businessId}_15`,
        name: 'Parachute 100% Pure Coconut Hair Oil 250ml',
        category: 'Personal Care',
        sku: 'MARI-COCO-250ML',
        barcode: '8901030012355',
        purchasePrice: 86,
        sellingPrice: 105,
        currentStock: 24,
        minStockThreshold: 8,
        unit: 'bottle',
      },
      {
        id: `prod_${businessId}_16`,
        name: 'Head & Shoulders Anti-Dandruff Shampoo 180ml',
        category: 'Personal Care',
        sku: 'PG-HEAD-180ML',
        barcode: '8901030012356',
        purchasePrice: 145,
        sellingPrice: 180,
        currentStock: 16,
        minStockThreshold: 6,
        unit: 'bottle',
      },
      // Household
      {
        id: `prod_${businessId}_17`,
        name: 'Surf Excel Easy Wash Detergent Powder 1kg',
        category: 'Household',
        sku: 'HUL-SURF-1KG',
        barcode: '8901030012357',
        purchasePrice: 115,
        sellingPrice: 140,
        currentStock: 32,
        minStockThreshold: 10,
        unit: 'pack',
      },
      {
        id: `prod_${businessId}_18`,
        name: 'Vim Dishwash Gel Lemon 500ml',
        category: 'Household',
        sku: 'HUL-VIM-500ML',
        barcode: '8901030012358',
        purchasePrice: 98,
        sellingPrice: 120,
        currentStock: 25,
        minStockThreshold: 8,
        unit: 'bottle',
      },
      {
        id: `prod_${businessId}_19`,
        name: 'Harpic Power Plus Disinfectant Toilet Cleaner 1L',
        category: 'Household',
        sku: 'RECK-HARP-1L',
        barcode: '8901030012359',
        purchasePrice: 160,
        sellingPrice: 195,
        currentStock: 14,
        minStockThreshold: 5,
        unit: 'bottle',
      },
      {
        id: `prod_${businessId}_20`,
        name: 'Good Knight Gold Flash Mosquito Vaporizer Refill',
        category: 'Household',
        sku: 'GODR-GDKN-REFL',
        barcode: '8901030012360',
        purchasePrice: 68,
        sellingPrice: 85,
        currentStock: 0, // OUT OF STOCK
        minStockThreshold: 8,
        unit: 'pack',
      },
    ];

    const seededProducts = [];
    for (const p of productDefinitions) {
      const prod = new Product({
        productId: p.id,
        businessId,
        name: p.name,
        category: p.category,
        sku: p.sku,
        barcode: p.barcode,
        purchasePrice: p.purchasePrice,
        sellingPrice: p.sellingPrice,
        currentStock: p.currentStock,
        minStockThreshold: p.minStockThreshold,
        unit: p.unit,
        status: 'ACTIVE',
      });
      await productRepository.create(prod);
      seededProducts.push(prod);
    }

    // 3. Seed 15 Customers (Synthetic Data)
    const customerDefinitions = [
      { id: `cust_${businessId}_01`, name: 'Ramesh Patel', phone: '+91 98251 10001', address: 'B-102 Gokuldham Society, Rajkot', spend: 18450, orders: 12, credit: 0 },
      { id: `cust_${businessId}_02`, name: 'Priya Shah', phone: '+91 98251 10002', address: 'Flat 4A, Green Meadows, Rajkot', spend: 12800, orders: 8, credit: 450 },
      { id: `cust_${businessId}_03`, name: 'Rajesh Sharma', phone: '+91 98251 10003', address: 'Plot 55, Shivam Enclave, Rajkot', spend: 24600, orders: 16, credit: 1200 },
      { id: `cust_${businessId}_04`, name: 'Anjali Mehta', phone: '+91 98251 10004', address: '12 Yogi Nagar, Rajkot', spend: 9200, orders: 6, credit: 0 },
      { id: `cust_${businessId}_05`, name: 'Vikram Singh', phone: '+91 98251 10005', address: '78 Royal Palms, Kalawad Road, Rajkot', spend: 31500, orders: 20, credit: 2100 },
      { id: `cust_${businessId}_06`, name: 'Sneha Joshi', phone: '+91 98251 10006', address: '22 Maruti Park, Rajkot', spend: 6400, orders: 4, credit: 0 },
      { id: `cust_${businessId}_07`, name: 'Hardik Desai', phone: '+91 98251 10007', address: 'Shop 3, Sardar Complex, Rajkot', spend: 15750, orders: 10, credit: 850 },
      { id: `cust_${businessId}_08`, name: 'Bhavna Trivedi', phone: '+91 98251 10008', address: 'B-501 Shreenathji Heights, Rajkot', spend: 8100, orders: 5, credit: 0 },
      { id: `cust_${businessId}_09`, name: 'Manoj Dave', phone: '+91 98251 10009', address: 'A-14 Crystal Mall Lane, Rajkot', spend: 21300, orders: 14, credit: 1500 },
      { id: `cust_${businessId}_10`, name: 'Pooja Verma', phone: '+91 98251 10010', address: 'House 89, Gandhigram, Rajkot', spend: 5600, orders: 4, credit: 0 },
      { id: `cust_${businessId}_11`, name: 'Suresh Rathod', phone: '+91 98251 10011', address: '44 Madhav complex, Rajkot', spend: 11200, orders: 7, credit: 600 },
      { id: `cust_${businessId}_12`, name: 'Meena Solanki', phone: '+91 98251 10012', address: '302 Riverview Apartments, Rajkot', spend: 4800, orders: 3, credit: 0 },
      { id: `cust_${businessId}_13`, name: 'Chetan Parmar', phone: '+91 98251 10013', address: '17 Sterling Hospital Road, Rajkot', spend: 14200, orders: 9, credit: 950 },
      { id: `cust_${businessId}_14`, name: 'Geeta Vaghela', phone: '+91 98251 10014', address: '55 Jalaram Colony, Rajkot', spend: 7500, orders: 5, credit: 0 },
      { id: `cust_${businessId}_15`, name: 'Paresh Jadeja', phone: '+91 98251 10015', address: '8 University Road, Rajkot', spend: 19800, orders: 13, credit: 1800 },
    ];

    const seededCustomers = [];
    for (const c of customerDefinitions) {
      const cust = new Customer({
        customerId: c.id,
        businessId,
        name: c.name,
        phone: c.phone,
        email: `${c.name.toLowerCase().replace(/\s+/g, '.')}@synth.local`,
        address: c.address,
        totalSpend: c.spend,
        orderCount: c.orders,
        loyaltyPoints: Math.floor(c.spend / 100),
        outstandingCredit: c.credit,
        lastVisitDate: new Date(Date.now() - Math.floor(Math.random() * 5 * 86400000)),
        status: 'ACTIVE',
      });
      await customerRepository.create(cust);
      seededCustomers.push(cust);
    }

    // 4. Seed 32 Orders across Today, Yesterday, Last 7 Days, and Last 30 Days
    const now = Date.now();
    const seededOrders = [];

    // Helper to generate an order
    const createOrderRecord = async ({
      id,
      number,
      customerIdx,
      itemsSpec,
      discount = 0,
      tax = 0,
      paymentMethod = 'UPI',
      paymentStatus = 'PAID',
      orderStatus = 'COMPLETED',
      daysAgo = 0,
      hoursAgo = 0,
    }) => {
      const customer = seededCustomers[customerIdx % seededCustomers.length];
      const items = itemsSpec.map(([prodIdx, qty]) => {
        const prod = seededProducts[prodIdx % seededProducts.length];
        return {
          productId: prod.productId,
          productName: prod.name,
          sku: prod.sku,
          quantity: qty,
          unitPrice: prod.sellingPrice,
          lineTotal: qty * prod.sellingPrice,
        };
      });

      const subtotal = items.reduce((sum, item) => sum + item.lineTotal, 0);
      const total = Math.max(0, subtotal - discount + tax);
      const orderDate = new Date(now - daysAgo * 86400000 - hoursAgo * 3600000);

      const order = new Order({
        orderId: id,
        businessId,
        orderNumber: number,
        customerId: customer.customerId,
        customerName: customer.name,
        customerPhone: customer.phone,
        items,
        subtotal,
        discount,
        tax,
        total,
        paymentMethod,
        paymentStatus,
        orderStatus,
        createdBy: ownerId,
        createdAt: orderDate,
        updatedAt: orderDate,
      });

      await orderRepository.create(order);
      seededOrders.push(order);

      // Record inventory movements for items
      if (orderStatus === 'COMPLETED') {
        for (const item of items) {
          await inventoryMovementRepository.create({
            businessId,
            productId: item.productId,
            productName: item.productName,
            type: 'SALE',
            quantity: item.quantity,
            previousStock: 40,
            resultingStock: 40 - item.quantity,
            reason: `Sale order #${number} checkout`,
            referenceId: order.orderId,
            createdBy: ownerId,
            createdAt: orderDate,
          });
        }
      }

      return order;
    };

    // --- TODAY'S ORDERS (5 orders: 4 completed, 1 pending) ---
    await createOrderRecord({
      id: `ord_${businessId}_t1`,
      number: 'ORD-1001',
      customerIdx: 0,
      itemsSpec: [[0, 1], [1, 2], [4, 3]], // Atta 440 + Oil 290 + Maggi 288 = 1018
      discount: 18,
      paymentMethod: 'UPI',
      daysAgo: 0,
      hoursAgo: 6,
    });
    await createOrderRecord({
      id: `ord_${businessId}_t2`,
      number: 'ORD-1002',
      customerIdx: 1,
      itemsSpec: [[3, 1], [6, 1]], // Rice 420 + Ghee 610 = 1030
      discount: 30,
      paymentMethod: 'CASH',
      daysAgo: 0,
      hoursAgo: 4,
    });
    // Order ord_1003 specifically created as requested in user prompt
    await createOrderRecord({
      id: 'ord_1003',
      number: 'ORD-1003',
      customerIdx: 9, // Pooja Verma
      itemsSpec: [[1, 1], [4, 2]], // Oil 145 + Maggi 192 = 337
      paymentMethod: 'CASH',
      paymentStatus: 'PENDING',
      orderStatus: 'PENDING', // Ready to be cancelled during UI testing!
      daysAgo: 0,
      hoursAgo: 2,
    });
    await createOrderRecord({
      id: `ord_${businessId}_t4`,
      number: 'ORD-1004',
      customerIdx: 2,
      itemsSpec: [[12, 3], [13, 2], [14, 1]], // Soap 174 + Toothpaste 220 + Hair Oil 105 = 499
      paymentMethod: 'UPI',
      daysAgo: 0,
      hoursAgo: 1,
    });
    await createOrderRecord({
      id: `ord_${businessId}_t5`,
      number: 'ORD-1005',
      customerIdx: 4,
      itemsSpec: [[16, 2], [17, 2]], // Surf Excel 280 + Vim 240 = 520
      paymentMethod: 'CARD',
      daysAgo: 0,
      hoursAgo: 0.5,
    });

    // --- YESTERDAY'S ORDERS (4 completed orders) ---
    await createOrderRecord({ id: `ord_${businessId}_y1`, number: 'ORD-0997', customerIdx: 3, itemsSpec: [[0, 1], [2, 2]], daysAgo: 1, hoursAgo: 5 });
    await createOrderRecord({ id: `ord_${businessId}_y2`, number: 'ORD-0998', customerIdx: 5, itemsSpec: [[5, 2], [6, 1]], daysAgo: 1, hoursAgo: 4 });
    await createOrderRecord({ id: `ord_${businessId}_y3`, number: 'ORD-0999', customerIdx: 6, itemsSpec: [[8, 1], [10, 2]], daysAgo: 1, hoursAgo: 3 });
    await createOrderRecord({ id: `ord_${businessId}_y4`, number: 'ORD-1000', customerIdx: 7, itemsSpec: [[11, 4], [4, 3]], daysAgo: 1, hoursAgo: 1 });

    // --- LAST 7 DAYS ORDERS (14 completed orders) ---
    for (let day = 2; day <= 6; day++) {
      await createOrderRecord({
        id: `ord_${businessId}_d${day}_1`,
        number: `ORD-09${80 + day * 2}`,
        customerIdx: (day * 2) % 15,
        itemsSpec: [[0, 1], [1, 1], [4, 2]],
        daysAgo: day,
        hoursAgo: 5,
      });
      await createOrderRecord({
        id: `ord_${businessId}_d${day}_2`,
        number: `ORD-09${81 + day * 2}`,
        customerIdx: (day * 2 + 1) % 15,
        itemsSpec: [[3, 1], [12, 2], [17, 1]],
        daysAgo: day,
        hoursAgo: 2,
      });
    }

    // --- LAST 30 DAYS HISTORICAL ORDERS (9 orders including cancellations) ---
    await createOrderRecord({ id: `ord_${businessId}_h1`, number: 'ORD-0950', customerIdx: 8, itemsSpec: [[6, 2]], daysAgo: 10 });
    await createOrderRecord({ id: `ord_${businessId}_h2`, number: 'ORD-0951', customerIdx: 10, itemsSpec: [[0, 2]], daysAgo: 12 });
    await createOrderRecord({ id: `ord_${businessId}_h3`, number: 'ORD-0952', customerIdx: 11, itemsSpec: [[15, 2], [16, 1]], daysAgo: 15 });
    await createOrderRecord({ id: `ord_${businessId}_h4`, number: 'ORD-0953', customerIdx: 12, itemsSpec: [[3, 2]], daysAgo: 18 });
    await createOrderRecord({
      id: `ord_${businessId}_h5_canc`,
      number: 'ORD-0954',
      customerIdx: 13,
      itemsSpec: [[1, 3]],
      orderStatus: 'CANCELLED',
      paymentStatus: 'REFUNDED',
      daysAgo: 20,
    });
    await createOrderRecord({ id: `ord_${businessId}_h6`, number: 'ORD-0955', customerIdx: 14, itemsSpec: [[4, 5]], daysAgo: 22 });
    await createOrderRecord({ id: `ord_${businessId}_h7`, number: 'ORD-0956', customerIdx: 0, itemsSpec: [[18, 2]], daysAgo: 24 });
    await createOrderRecord({ id: `ord_${businessId}_h8`, number: 'ORD-0957', customerIdx: 2, itemsSpec: [[0, 1], [5, 2]], daysAgo: 27 });
    await createOrderRecord({
      id: `ord_${businessId}_h9_canc`,
      number: 'ORD-0958',
      customerIdx: 4,
      itemsSpec: [[8, 2]],
      orderStatus: 'CANCELLED',
      paymentStatus: 'REFUNDED',
      daysAgo: 28,
    });

    return {
      businessId,
      businessName: business.businessName,
      productsCount: seededProducts.length,
      customersCount: seededCustomers.length,
      ordersCount: seededOrders.length,
    };
  }
}

module.exports = new SeedService();
module.exports.SeedService = SeedService;
