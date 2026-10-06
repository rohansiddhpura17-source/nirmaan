const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');
const userRepository = require('../src/repositories/userRepository');
const businessRepository = require('../src/repositories/businessRepository');
const productRepository = require('../src/repositories/productRepository');
const customerRepository = require('../src/repositories/customerRepository');
const orderRepository = require('../src/repositories/orderRepository');
const { getTodayTimezoneRange } = require('../src/utils/dateUtils');

function makeRequest({ port, method = 'GET', path, headers = {}, body = null }) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const reqHeaders = { ...headers };
    if (payload) {
      reqHeaders['Content-Type'] = 'application/json';
      reqHeaders['Content-Length'] = Buffer.byteLength(payload);
    }

    const req = http.request(
      `http://localhost:${port}${path}`,
      { method, headers: reqHeaders },
      (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          let json = null;
          try {
            json = JSON.parse(data);
          } catch (_) {
            json = data;
          }
          resolve({ status: res.statusCode, data: json });
        });
      }
    );

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function makeToken(user) {
  const payload = {
    uid: user.uid,
    id: user.uid,
    email: user.email,
    name: user.displayName || user.name,
    role: user.role,
    businessId: user.businessId,
    setupComplete: user.setupComplete,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600,
  };
  return Buffer.from(JSON.stringify(payload)).toString('base64');
}

test('Business Dashboard Suite (Phase 5)', async (t) => {
  let server;
  let port;

  const testBizA = 'biz_dash_test_a';
  const testBizB = 'biz_dash_test_b';

  const userOwnerA = {
    uid: 'uid_dash_owner_a',
    email: 'owner.a@nirmaan.test',
    name: 'Owner Business A',
    role: 'BUSINESS_OWNER',
    businessId: testBizA,
    setupComplete: true,
  };

  const userStaffA = {
    uid: 'uid_dash_staff_a',
    email: 'staff.a@nirmaan.test',
    name: 'Staff Business A',
    role: 'SALES_STAFF',
    businessId: testBizA,
    setupComplete: true,
  };

  const userNoBiz = {
    uid: 'uid_dash_nobiz',
    email: 'nobiz@nirmaan.test',
    name: 'No Business User',
    role: 'BUSINESS_OWNER',
    businessId: null,
    setupComplete: false,
  };

  const userOwnerB = {
    uid: 'uid_dash_owner_b',
    email: 'owner.b@nirmaan.test',
    name: 'Owner Business B',
    role: 'BUSINESS_OWNER',
    businessId: testBizB,
    setupComplete: true,
  };

  await userRepository.create(userOwnerA);
  await userRepository.create(userStaffA);
  await userRepository.create(userNoBiz);
  await userRepository.create(userOwnerB);

  await businessRepository.create({
    businessId: testBizA,
    name: 'Apex Supermart A',
    ownerId: userOwnerA.uid,
    setupComplete: true,
  });

  await businessRepository.create({
    businessId: testBizB,
    name: 'Zenith Retail B',
    ownerId: userOwnerB.uid,
    setupComplete: true,
  });

  // Today dates in IST
  const { startOfDayISO } = getTodayTimezoneRange('Asia/Kolkata');
  const nowISO = new Date().toISOString();
  // Yesterday's ISO string (24 hours prior to start of today)
  const yesterdayISO = new Date(new Date(startOfDayISO).getTime() - 3600000 * 12).toISOString();

  // Seed Products for Business A
  // Product 1: In stock
  const prodA1 = await productRepository.create({
    productId: 'prod_a1',
    businessId: testBizA,
    name: 'Fortune Sunflower Oil 1L',
    sku: 'FORT-OIL-A1',
    category: 'Groceries',
    sellingPrice: 150,
    costPrice: 120,
    stockQuantity: 25,
    currentStock: 25,
    minStockThreshold: 5,
    unit: 'pouch',
    status: 'ACTIVE',
  });

  // Product 2: Low Stock (stock: 3 <= threshold: 5)
  const prodA2 = await productRepository.create({
    productId: 'prod_a2',
    businessId: testBizA,
    name: 'Tata Tea Premium 250g',
    sku: 'TATA-TEA-A2',
    category: 'Beverages',
    sellingPrice: 140,
    costPrice: 110,
    stockQuantity: 3,
    currentStock: 3,
    minStockThreshold: 5,
    unit: 'pack',
    status: 'ACTIVE',
  });

  // Product 3: Out of Stock (stock: 0)
  const prodA3 = await productRepository.create({
    productId: 'prod_a3',
    businessId: testBizA,
    name: 'Aashirvaad Atta 5kg',
    sku: 'AASH-ATTA-A3',
    category: 'Groceries',
    sellingPrice: 220,
    costPrice: 180,
    stockQuantity: 0,
    currentStock: 0,
    minStockThreshold: 10,
    unit: 'bag',
    status: 'ACTIVE',
  });

  // Seed Product for Business B (Tenant Isolation check)
  const prodB1 = await productRepository.create({
    productId: 'prod_b1',
    businessId: testBizB,
    name: 'Secret Product B',
    sku: 'SECRET-B1',
    category: 'Other',
    sellingPrice: 999,
    costPrice: 500,
    stockQuantity: 1,
    currentStock: 1,
    minStockThreshold: 10,
    unit: 'pcs',
    status: 'ACTIVE',
  });

  // Seed Customers for Business A
  await customerRepository.create({
    customerId: 'cust_a1',
    businessId: testBizA,
    name: 'Ramesh Patel',
    phone: '+91 98980 11111',
    outstandingKhataBalance: 500,
  });

  await customerRepository.create({
    customerId: 'cust_a2',
    businessId: testBizA,
    name: 'Suresh Shah',
    phone: '+91 98980 22222',
    outstandingKhataBalance: 0,
  });

  // Seed Customer for Business B
  await customerRepository.create({
    customerId: 'cust_b1',
    businessId: testBizB,
    name: 'Private Client B',
    phone: '+91 98980 99999',
  });

  // Seed Orders for Business A:
  // 1. Valid completed order TODAY: 2x ProdA1 (300) + 1x ProdA2 (140) = 440
  await orderRepository.create({
    orderId: 'ord_today_1',
    businessId: testBizA,
    orderNumber: 'ORD-A-1001',
    customerName: 'Ramesh Patel',
    totalAmount: 440,
    total: 440,
    status: 'COMPLETED',
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    createdAt: nowISO,
    items: [
      { productId: prodA1.productId, productName: prodA1.name, sku: prodA1.sku, quantity: 2, unitPrice: 150, lineTotal: 300 },
      { productId: prodA2.productId, productName: prodA2.name, sku: prodA2.sku, quantity: 1, unitPrice: 140, lineTotal: 140 },
    ],
  });

  // 2. Valid completed order TODAY: 3x ProdA1 (450) = 450
  await orderRepository.create({
    orderId: 'ord_today_2',
    businessId: testBizA,
    orderNumber: 'ORD-A-1002',
    customerName: 'Walk-in Customer',
    totalAmount: 450,
    total: 450,
    status: 'COMPLETED',
    orderStatus: 'COMPLETED',
    paymentMethod: 'CASH',
    createdAt: nowISO,
    items: [
      { productId: prodA1.productId, productName: prodA1.name, sku: prodA1.sku, quantity: 3, unitPrice: 150, lineTotal: 450 },
    ],
  });

  // 3. CANCELLED order TODAY: should be EXCLUDED from revenue (500)
  await orderRepository.create({
    orderId: 'ord_today_cancelled',
    businessId: testBizA,
    orderNumber: 'ORD-A-CANCELLED',
    customerName: 'Cancelled Order Customer',
    totalAmount: 500,
    total: 500,
    status: 'CANCELLED',
    orderStatus: 'CANCELLED',
    paymentMethod: 'CASH',
    createdAt: nowISO,
    items: [
      { productId: prodA3.productId, productName: prodA3.name, sku: prodA3.sku, quantity: 2, unitPrice: 250, lineTotal: 500 },
    ],
  });

  // 4. Completed order from YESTERDAY: should be EXCLUDED from TODAY'S revenue (800)
  await orderRepository.create({
    orderId: 'ord_yesterday_1',
    businessId: testBizA,
    orderNumber: 'ORD-A-YESTERDAY',
    customerName: 'Yesterday Shopper',
    totalAmount: 800,
    total: 800,
    status: 'COMPLETED',
    orderStatus: 'COMPLETED',
    paymentMethod: 'CARD',
    createdAt: yesterdayISO,
    items: [
      { productId: prodA1.productId, productName: prodA1.name, sku: prodA1.sku, quantity: 4, unitPrice: 200, lineTotal: 800 },
    ],
  });

  // 5. Order from Business B (5000): strictly separated
  await orderRepository.create({
    orderId: 'ord_b_1',
    businessId: testBizB,
    orderNumber: 'ORD-B-9999',
    customerName: 'Business B Buyer',
    totalAmount: 5000,
    total: 5000,
    status: 'COMPLETED',
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    createdAt: nowISO,
    items: [
      { productId: prodB1.productId, productName: prodB1.name, sku: prodB1.sku, quantity: 5, unitPrice: 1000, lineTotal: 5000 },
    ],
  });

  t.before(async () => {
    await new Promise((resolve) => {
      server = http.createServer(app);
      server.listen(0, () => {
        port = server.address().port;
        resolve();
      });
    });
  });

  t.after(async () => {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
  });

  // -------------------------------------------------------------------------
  // 1. Authentication Required
  // -------------------------------------------------------------------------
  await t.test('1. authentication required: GET /api/v1/dashboard returns 401 without token', async () => {
    const res = await makeRequest({ port, path: '/api/v1/dashboard' });
    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
  });

  // -------------------------------------------------------------------------
  // 2. Unauthorized Access Blocked
  // -------------------------------------------------------------------------
  await t.test('2. unauthorized access blocked: user without businessId returns 403', async () => {
    const token = makeToken(userNoBiz);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });
    assert.strictEqual(res.status, 403);
    assert.strictEqual(res.data.success, false);
  });

  // -------------------------------------------------------------------------
  // 3. Dashboard Aggregation Returns Structured Payload
  // -------------------------------------------------------------------------
  await t.test('3. dashboard aggregation returns complete structured response', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.ok(res.data.data);

    const d = res.data.data;
    assert.strictEqual(d.businessId, testBizA);
    assert.strictEqual(d.timezone, 'Asia/Kolkata');
    assert.ok(d.today);
    assert.ok(d.metrics);
    assert.ok(Array.isArray(d.recentOrders));
    assert.ok(Array.isArray(d.stockAlerts));
    assert.ok(Array.isArray(d.topProducts));
    assert.ok(d.businessHealth);
    assert.strictEqual(d.businessHealth.status, 'UNAVAILABLE');
    assert.strictEqual(d.businessHealth.score, null);
  });

  // -------------------------------------------------------------------------
  // 4. Tenant Isolation
  // -------------------------------------------------------------------------
  await t.test('4. tenant isolation: business A dashboard never contains business B records', async () => {
    const tokenA = makeToken(userOwnerA);
    const resA = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${tokenA}` },
    });

    const dataA = resA.data.data;
    // Must NOT contain Business B revenue (5000) or products or orders
    assert.strictEqual(dataA.businessId, testBizA);
    assert.strictEqual(dataA.metrics.todayRevenue, 890); // 440 + 450
    assert.ok(!dataA.recentOrders.some((o) => o.orderNumber === 'ORD-B-9999'));
    assert.ok(!dataA.stockAlerts.some((p) => p.sku === 'SECRET-B1'));
    assert.ok(!dataA.topProducts.some((p) => p.name === 'Secret Product B'));
  });

  // -------------------------------------------------------------------------
  // 5. Cancelled Orders Excluded from Revenue
  // -------------------------------------------------------------------------
  await t.test('5. cancelled orders excluded: cancelled order of 500 is not counted', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    // 440 (ORD-A-1001) + 450 (ORD-A-1002) = 890. If cancelled (500) were included it would be 1390.
    assert.strictEqual(res.data.data.metrics.todayRevenue, 890);
    assert.strictEqual(res.data.data.metrics.todayOrdersCount, 2);
  });

  // -------------------------------------------------------------------------
  // 6. Today Date Boundary
  // -------------------------------------------------------------------------
  await t.test('6. today date boundary: yesterday order of 800 is excluded from today revenue', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    // Today revenue is strictly 890, excluding 800 from yesterday
    assert.strictEqual(res.data.data.metrics.todayRevenue, 890);
    assert.strictEqual(res.data.data.metrics.todayOrdersCount, 2);
    assert.strictEqual(res.data.data.metrics.averageOrderValue, 445); // 890 / 2
  });

  // -------------------------------------------------------------------------
  // 7. Low-Stock Calculation
  // -------------------------------------------------------------------------
  await t.test('7. low-stock calculation: products with stock <= threshold & > 0 counted as low stock', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    // ProdA2 has stock 3 <= threshold 5
    assert.strictEqual(res.data.data.metrics.lowStockCount, 1);
    const lowStockAlert = res.data.data.stockAlerts.find((a) => a.sku === 'TATA-TEA-A2');
    assert.ok(lowStockAlert);
    assert.strictEqual(lowStockAlert.stockStatus, 'LOW_STOCK');
    assert.strictEqual(lowStockAlert.stockQuantity, 3);
  });

  // -------------------------------------------------------------------------
  // 8. Out-of-Stock Calculation
  // -------------------------------------------------------------------------
  await t.test('8. out-of-stock calculation: products with stock <= 0 counted as out of stock', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    // ProdA3 has stock 0
    assert.strictEqual(res.data.data.metrics.outOfStockCount, 1);
    const outOfStockAlert = res.data.data.stockAlerts.find((a) => a.sku === 'AASH-ATTA-A3');
    assert.ok(outOfStockAlert);
    assert.strictEqual(outOfStockAlert.stockStatus, 'OUT_OF_STOCK');
    assert.strictEqual(outOfStockAlert.stockQuantity, 0);
  });

  // -------------------------------------------------------------------------
  // 9. Top-Product Calculation from Order Line Items
  // -------------------------------------------------------------------------
  await t.test('9. top-product calculation: aggregates quantity & revenue from completed order items', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    const top = res.data.data.topProducts;
    assert.ok(top.length > 0);

    // ProdA1 was sold in ord_today_1 (qty 2), ord_today_2 (qty 3), and ord_yesterday_1 (qty 4) = 9 units total
    const topItem = top[0];
    assert.strictEqual(topItem.productId, prodA1.productId);
    assert.strictEqual(topItem.quantitySold, 9);
    assert.strictEqual(topItem.revenue, 1550); // 300 + 450 + 800
  });

  // -------------------------------------------------------------------------
  // 10. Recent Orders Restricted to Tenant
  // -------------------------------------------------------------------------
  await t.test('10. recent orders: latest orders sorted descending, restricted to tenant', async () => {
    const token = makeToken(userStaffA); // Sales staff allowed to read dashboard
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    const recent = res.data.data.recentOrders;
    assert.ok(recent.length > 0);
    assert.ok(recent.length <= 5);

    // Verify sorted by createdAt descending
    for (let i = 0; i < recent.length - 1; i++) {
      assert.ok(new Date(recent[i].createdAt) >= new Date(recent[i + 1].createdAt));
    }

    // Verify fields
    const first = recent[0];
    assert.ok(first.orderNumber);
    assert.ok(first.customerName);
    assert.ok(typeof first.totalAmount === 'number');
    assert.ok(first.status);
    assert.ok(first.paymentMethod);
    assert.ok(first.createdAt);

    // Verify none belong to Business B
    assert.ok(!recent.some((o) => o.orderNumber === 'ORD-B-9999'));
  });

  // -------------------------------------------------------------------------
  // 11. Total Revenue, Inventory Valuation & Units Aggregation
  // -------------------------------------------------------------------------
  await t.test('11. total revenue, inventory valuation & units aggregation', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    const m = res.data.data.metrics;
    // Total Revenue across all completed orders: ord_today_1 (440) + ord_today_2 (450) + ord_yesterday_1 (800) = 1690
    assert.strictEqual(m.totalRevenue, 1690);
    assert.strictEqual(m.completedOrdersCount, 3);
    assert.strictEqual(m.cancelledOrdersCount, 1);
    // Stock Units: 25 (prodA1) + 3 (prodA2) + 0 (prodA3) = 28
    assert.strictEqual(m.totalStockUnits, 28);
    // Valuation: 25*120 + 3*110 + 0*180 = 3000 + 330 = 3330
    assert.strictEqual(m.inventoryValuation, 3330);
    // In-stock products: prodA1 has 25 > threshold 5 = 1 in-stock
    assert.strictEqual(m.inStockCount, 1);
  });

  // -------------------------------------------------------------------------
  // 12. Empty Business Data Handling
  // -------------------------------------------------------------------------
  await t.test('12. empty business returns zeroed metrics without failure', async () => {
    const emptyBizId = 'biz_dash_empty';
    const userEmpty = {
      uid: 'uid_dash_empty',
      email: 'empty@nirmaan.test',
      name: 'Empty Business Owner',
      role: 'BUSINESS_OWNER',
      businessId: emptyBizId,
      setupComplete: true,
    };
    await userRepository.create(userEmpty);
    await businessRepository.create({
      businessId: emptyBizId,
      name: 'Fresh Empty Store',
      ownerId: userEmpty.uid,
      setupComplete: true,
    });

    const token = makeToken(userEmpty);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    assert.strictEqual(res.status, 200);
    const d = res.data.data;
    assert.strictEqual(d.metrics.todayRevenue, 0);
    assert.strictEqual(d.metrics.todayOrdersCount, 0);
    assert.strictEqual(d.metrics.totalRevenue, 0);
    assert.strictEqual(d.metrics.totalProducts, 0);
    assert.strictEqual(d.metrics.totalCustomers, 0);
    assert.strictEqual(d.metrics.inventoryValuation, 0);
    assert.strictEqual(d.recentOrders.length, 0);
    assert.strictEqual(d.topProducts.length, 0);
    assert.ok(d.insights.length > 0);
  });

  // -------------------------------------------------------------------------
  // 13. Operational Insights and Business Profile
  // -------------------------------------------------------------------------
  await t.test('13. operational insights and business profile populated correctly', async () => {
    const token = makeToken(userOwnerA);
    const res = await makeRequest({
      port,
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${token}` },
    });

    const d = res.data.data;
    assert.ok(Array.isArray(d.insights));
    assert.ok(d.insights.length > 0);
    assert.ok(d.businessProfile);
    assert.strictEqual(d.businessProfile.name, 'Apex Supermart A');
  });
});
