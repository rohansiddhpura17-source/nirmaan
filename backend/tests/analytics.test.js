const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');
const userRepository = require('../src/repositories/userRepository');
const businessRepository = require('../src/repositories/businessRepository');
const productRepository = require('../src/repositories/productRepository');
const customerRepository = require('../src/repositories/customerRepository');
const orderRepository = require('../src/repositories/orderRepository');
const inventoryMovementRepository = require('../src/repositories/inventoryMovementRepository');
const { getDateRangeBoundaries, getISTDateString } = require('../src/utils/dateUtils');

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

test('Analytics & Reports Suite (Phase 6)', async (t) => {
  let server;
  let port;

  const testBusinessId = 'biz_analytics_test_01';
  const testBusinessIdB = 'biz_analytics_test_02';

  // Seed User Accounts
  const ownerUser = await userRepository.create({
    uid: 'usr_analytics_owner_01',
    email: 'owner@analytics.test',
    displayName: 'Analytics Owner',
    role: 'BUSINESS_OWNER',
    businessId: testBusinessId,
    setupComplete: true,
  });

  const managerUser = await userRepository.create({
    uid: 'usr_analytics_manager_01',
    email: 'manager@analytics.test',
    displayName: 'Analytics Manager',
    role: 'STORE_MANAGER',
    businessId: testBusinessId,
    setupComplete: true,
  });

  const staffUser = await userRepository.create({
    uid: 'usr_analytics_staff_01',
    email: 'staff@analytics.test',
    displayName: 'Sales Staff',
    role: 'SALES_STAFF',
    businessId: testBusinessId,
    setupComplete: true,
  });

  const noBusinessUser = await userRepository.create({
    uid: 'usr_analytics_nobiz_01',
    email: 'nobiz@analytics.test',
    displayName: 'No Biz User',
    role: 'BUSINESS_OWNER',
    businessId: null,
    setupComplete: false,
  });

  const ownerUserB = await userRepository.create({
    uid: 'usr_analytics_owner_b',
    email: 'ownerb@analytics.test',
    displayName: 'Owner B',
    role: 'BUSINESS_OWNER',
    businessId: testBusinessIdB,
    setupComplete: true,
  });

  // Seed Businesses
  await businessRepository.create({
    businessId: testBusinessId,
    businessName: 'Shree Krishna Mart',
    category: 'Grocery & FMCG',
    ownerId: ownerUser.uid,
    ownerName: ownerUser.displayName,
    phone: '+91 98765 43210',
    address: 'Indiranagar 100ft Road, Bengaluru',
    currency: '₹',
  });

  await businessRepository.create({
    businessId: testBusinessIdB,
    businessName: 'Competitor Kirana B',
    category: 'Retail',
    ownerId: ownerUserB.uid,
    ownerName: ownerUserB.displayName,
    phone: '+91 99999 88888',
    address: 'Koramangala, Bengaluru',
    currency: '₹',
  });

  // Seed Products for Business A
  const prodRice = await productRepository.create({
    businessId: testBusinessId,
    name: 'Basmati Rice 5kg',
    category: 'Grains & Staples',
    sku: 'RICE-5KG',
    currentStock: 25,
    minStockThreshold: 10,
    costPrice: 200,
    purchasePrice: 200,
    sellingPrice: 250,
    status: 'ACTIVE',
  });

  const prodOil = await productRepository.create({
    businessId: testBusinessId,
    name: 'Mustard Oil 1L',
    category: 'Edible Oils',
    sku: 'OIL-1L',
    currentStock: 5, // <= minStockThreshold (8) -> Low stock
    minStockThreshold: 8,
    costPrice: 120,
    purchasePrice: 120,
    sellingPrice: 150,
    status: 'ACTIVE',
  });

  const prodSalt = await productRepository.create({
    businessId: testBusinessId,
    name: 'Iodized Salt 1kg',
    category: 'Staples',
    sku: 'SALT-1KG',
    currentStock: 0, // Out of stock
    minStockThreshold: 5,
    costPrice: 15,
    purchasePrice: 15,
    sellingPrice: 25,
    status: 'ACTIVE',
  });

  const prodUnsold = await productRepository.create({
    businessId: testBusinessId,
    name: 'Almonds 500g',
    category: 'Dry Fruits',
    sku: 'ALM-500G',
    currentStock: 12,
    minStockThreshold: 4,
    costPrice: 350,
    purchasePrice: 350,
    sellingPrice: 450,
    status: 'ACTIVE',
  });

  // Seed Customers
  const custRamesh = await customerRepository.create({
    businessId: testBusinessId,
    name: 'Ramesh Patel',
    phone: '+91 98111 22233',
    email: 'ramesh@example.com',
    outstandingBalance: 1500,
  });

  const custSita = await customerRepository.create({
    businessId: testBusinessId,
    name: 'Sita Devi',
    phone: '+91 98222 33344',
    email: 'sita@example.com',
    outstandingBalance: 0,
  });

  // Dates in IST:
  const now = new Date();
  const todayStr = getISTDateString(now);
  const todayDate = new Date(`${todayStr}T10:00:00.000+05:30`);
  const yesterdayDate = new Date(`${todayStr}T10:00:00.000+05:30`);
  yesterdayDate.setDate(yesterdayDate.getDate() - 1);
  const tenDaysAgoDate = new Date(`${todayStr}T10:00:00.000+05:30`);
  tenDaysAgoDate.setDate(tenDaysAgoDate.getDate() - 10);
  const sixtyDaysAgoDate = new Date(`${todayStr}T10:00:00.000+05:30`);
  sixtyDaysAgoDate.setDate(sixtyDaysAgoDate.getDate() - 60);

  // Seed Orders:
  // Order 1: Today Completed (2 Rice @ 250 = 500, 1 Oil @ 150 = 150 -> Total 650)
  await orderRepository.create({
    orderId: 'ord_analytics_01',
    businessId: testBusinessId,
    orderNumber: 'ORD-A01',
    customerId: custRamesh.id,
    customerName: custRamesh.name,
    customerPhone: custRamesh.phone,
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, sku: prodRice.sku, quantity: 2, unitPrice: 250, lineTotal: 500 },
      { productId: prodOil.productId, productName: prodOil.name, sku: prodOil.sku, quantity: 1, unitPrice: 150, lineTotal: 150 },
    ],
    total: 650,
    createdAt: todayDate.toISOString(),
  });

  // Order 2: Today Cancelled (1 Rice @ 250 -> Total 250) - MUST BE EXCLUDED from revenue
  await orderRepository.create({
    orderId: 'ord_analytics_02',
    businessId: testBusinessId,
    orderNumber: 'ORD-A02',
    customerId: custRamesh.id,
    customerName: custRamesh.name,
    customerPhone: custRamesh.phone,
    orderStatus: 'CANCELLED',
    paymentMethod: 'CASH',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, sku: prodRice.sku, quantity: 1, unitPrice: 250, lineTotal: 250 },
    ],
    total: 250,
    createdAt: todayDate.toISOString(),
  });

  // Order 3: Yesterday Completed (3 Oil @ 150 = 450)
  await orderRepository.create({
    orderId: 'ord_analytics_03',
    businessId: testBusinessId,
    orderNumber: 'ORD-A03',
    customerId: custSita.id,
    customerName: custSita.name,
    customerPhone: custSita.phone,
    orderStatus: 'COMPLETED',
    paymentMethod: 'CASH',
    items: [
      { productId: prodOil.productId, productName: prodOil.name, sku: prodOil.sku, quantity: 3, unitPrice: 150, lineTotal: 450 },
    ],
    total: 450,
    createdAt: yesterdayDate.toISOString(),
  });

  // Order 4: 10 Days Ago Completed (4 Rice @ 250 = 1000)
  await orderRepository.create({
    orderId: 'ord_analytics_04',
    businessId: testBusinessId,
    orderNumber: 'ORD-A04',
    customerId: custRamesh.id,
    customerName: custRamesh.name,
    customerPhone: custRamesh.phone,
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, sku: prodRice.sku, quantity: 4, unitPrice: 250, lineTotal: 1000 },
    ],
    total: 1000,
    createdAt: tenDaysAgoDate.toISOString(),
  });

  // Order 5: 60 Days Ago Completed (Old order, should be excluded from 30d analytics)
  await orderRepository.create({
    orderId: 'ord_analytics_05',
    businessId: testBusinessId,
    orderNumber: 'ORD-A05',
    customerId: custSita.id,
    customerName: custSita.name,
    customerPhone: custSita.phone,
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, sku: prodRice.sku, quantity: 2, unitPrice: 250, lineTotal: 500 },
    ],
    total: 500,
    createdAt: sixtyDaysAgoDate.toISOString(),
  });

  // Seed an order for Business B (Tenant Isolation check)
  await orderRepository.create({
    orderId: 'ord_analytics_b01',
    businessId: testBusinessIdB,
    orderNumber: 'ORD-B01',
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    items: [
      { productId: 'p_b', productName: 'Product B', quantity: 10, unitPrice: 1000, lineTotal: 10000 },
    ],
    total: 10000,
    createdAt: todayDate.toISOString(),
  });

  // Seed inventory movement
  await inventoryMovementRepository.create({
    businessId: testBusinessId,
    productId: prodRice.productId,
    productName: prodRice.name,
    type: 'RESTOCK',
    quantity: 30,
    createdAt: todayDate.toISOString(),
  });

  // Start Server
  await new Promise((resolve) => {
    server = app.listen(0, () => {
      port = server.address().port;
      resolve();
    });
  });

  t.after(() => {
    if (server) server.close();
  });

  const ownerToken = makeToken(ownerUser);
  const managerToken = makeToken(managerUser);
  const staffToken = makeToken(staffUser);
  const noBizToken = makeToken(noBusinessUser);
  const ownerBToken = makeToken(ownerUserB);

  // ---------------------------------------------------------------------------
  // TEST 1: Authentication required
  // ---------------------------------------------------------------------------
  await t.test('1. authentication required: GET /api/v1/analytics returns 401 without token', async () => {
    const res = await makeRequest({ port, path: '/api/v1/analytics' });
    assert.strictEqual(res.status, 401);
  });

  // ---------------------------------------------------------------------------
  // TEST 2: Tenant required
  // ---------------------------------------------------------------------------
  await t.test('2. unauthorized access blocked: user without businessId returns 403', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics',
      headers: { Authorization: `Bearer ${noBizToken}` },
    });
    assert.strictEqual(res.status, 403);
  });

  // ---------------------------------------------------------------------------
  // TEST 3: RBAC Enforcement
  // ---------------------------------------------------------------------------
  await t.test('3. RBAC enforcement: Sales staff is rejected with 403', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics',
      headers: { Authorization: `Bearer ${staffToken}` },
    });
    assert.strictEqual(res.status, 403);
  });

  await t.test('4. RBAC authorization: Owner and Manager are allowed with 200', async () => {
    const ownerRes = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(ownerRes.status, 200);

    const mgrRes = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${managerToken}` },
    });
    assert.strictEqual(mgrRes.status, 200);
  });

  // ---------------------------------------------------------------------------
  // TEST 5: Date Range Boundaries ('today', 'yesterday', '7d', '30d')
  // ---------------------------------------------------------------------------
  await t.test("5. date boundary 'today': includes only today completed order (650)", async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=today',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const data = res.data.data;
    assert.strictEqual(data.sales.totalRevenue, 650);
    assert.strictEqual(data.sales.completedOrdersCount, 1);
    assert.strictEqual(data.sales.cancelledOrdersCount, 1);
    assert.strictEqual(data.sales.cancelledRevenue, 250);
  });

  await t.test("6. date boundary 'yesterday': includes only yesterday order (450)", async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=yesterday',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const data = res.data.data;
    assert.strictEqual(data.sales.totalRevenue, 450);
    assert.strictEqual(data.sales.completedOrdersCount, 1);
  });

  await t.test("7. date boundary '7d': includes today + yesterday orders (650 + 450 = 1100)", async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=7d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const data = res.data.data;
    assert.strictEqual(data.sales.totalRevenue, 1100);
    assert.strictEqual(data.sales.completedOrdersCount, 2);
  });

  await t.test("8. date boundary '30d': includes today, yesterday, 10d ago, excludes 60d ago (650 + 450 + 1000 = 2100)", async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const data = res.data.data;
    assert.strictEqual(data.sales.totalRevenue, 2100);
    assert.strictEqual(data.sales.completedOrdersCount, 3);
    assert.strictEqual(data.sales.averageOrderValue, 700); // 2100 / 3
  });

  // ---------------------------------------------------------------------------
  // TEST 9: Cancelled Orders Excluded from Revenue
  // ---------------------------------------------------------------------------
  await t.test('9. cancelled orders excluded: cancelled order of 250 is tracked separately and not in totalRevenue', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=today',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    const sales = res.data.data.sales;
    assert.strictEqual(sales.totalRevenue, 650);
    assert.strictEqual(sales.cancelledRevenue, 250);
    assert.strictEqual(sales.cancelledOrdersCount, 1);
  });

  // ---------------------------------------------------------------------------
  // TEST 10: Product Performance Rankings & Unsold Products
  // ---------------------------------------------------------------------------
  await t.test('10. product analytics: rankings, units sold, revenue, and weak/unsold products', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    const products = res.data.data.products;

    // Top products:
    // Rice: 2 (today) + 4 (10d ago) = 6 units, ₹1500 revenue
    // Oil: 1 (today) + 3 (yesterday) = 4 units, ₹600 revenue
    assert.ok(products.topProducts.length >= 2);
    assert.strictEqual(products.topProducts[0].name, 'Basmati Rice 5kg');
    assert.strictEqual(products.topProducts[0].quantitySold, 6);
    assert.strictEqual(products.topProducts[0].revenue, 1500);

    assert.strictEqual(products.topProducts[1].name, 'Mustard Oil 1L');
    assert.strictEqual(products.topProducts[1].quantitySold, 4);
    assert.strictEqual(products.topProducts[1].revenue, 600);

    // Unsold products in range should contain Almonds & Salt
    const unsoldNames = products.weakOrNoSalesProducts.map((p) => p.name);
    assert.ok(unsoldNames.includes('Almonds 500g'));
    assert.ok(unsoldNames.includes('Iodized Salt 1kg'));
  });

  // ---------------------------------------------------------------------------
  // TEST 11: Inventory Analytics Aggregation
  // ---------------------------------------------------------------------------
  await t.test('11. inventory analytics: valuation, units, stock status, movement summary', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    const inv = res.data.data.inventory;

    // Rice: 25 * 200 = 5000
    // Oil: 5 * 120 = 600
    // Salt: 0 * 15 = 0
    // Almonds: 12 * 350 = 4200
    // Total Valuation = 9800
    assert.strictEqual(inv.inventoryValuation, 9800);
    assert.strictEqual(inv.totalStockUnits, 42); // 25 + 5 + 0 + 12
    assert.strictEqual(inv.lowStockCount, 1); // Oil (5 <= 8)
    assert.strictEqual(inv.outOfStockCount, 1); // Salt (0)
    assert.strictEqual(inv.inStockCount, 2); // Rice & Almonds
    assert.ok(inv.stockMovementSummary.inwardUnits >= 30);
  });

  // ---------------------------------------------------------------------------
  // TEST 12: Customer Analytics
  // ---------------------------------------------------------------------------
  await t.test('12. customer analytics: active customers, spend ranking, frequency', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    const cust = res.data.data.customers;

    assert.strictEqual(cust.totalCustomers, 2); // Ramesh & Sita
    assert.strictEqual(cust.activeCustomersCount, 2); // both had orders in 30d
    assert.ok(cust.topCustomers.length >= 1);
    // Ramesh: Order 1 (650) + Order 4 (1000) = 1650
    assert.strictEqual(cust.topCustomers[0].customerName, 'Ramesh Patel');
    assert.strictEqual(cust.topCustomers[0].totalSpend, 1650);
  });

  // ---------------------------------------------------------------------------
  // TEST 13: Tenant Isolation
  // ---------------------------------------------------------------------------
  await t.test('13. tenant isolation: Business B sees 0 records from Business A', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/analytics?range=30d',
      headers: { Authorization: `Bearer ${ownerBToken}` },
    });
    const data = res.data.data;
    // Business B only has its 1 order of 10000
    assert.strictEqual(data.sales.totalRevenue, 10000);
    assert.strictEqual(data.sales.completedOrdersCount, 1);
    assert.strictEqual(data.inventory.totalStockUnits, 0); // No products in Business B
    assert.strictEqual(data.customers.totalCustomers, 0); // No customers in Business B
  });

  // ---------------------------------------------------------------------------
  // TEST 14: Reports Endpoint
  // ---------------------------------------------------------------------------
  await t.test('14. reports generation: SALES, PRODUCTS, INVENTORY, CUSTOMERS', async () => {
    // Sales Report
    const salesRep = await makeRequest({
      port,
      path: '/api/v1/analytics/reports?type=SALES&range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(salesRep.status, 200);
    assert.strictEqual(salesRep.data.data.reportType, 'SALES');
    assert.strictEqual(salesRep.data.data.summary.totalRevenue, 2100);
    assert.ok(Array.isArray(salesRep.data.data.records));

    // Products Report
    const prodRep = await makeRequest({
      port,
      path: '/api/v1/analytics/reports?type=PRODUCTS&range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(prodRep.status, 200);
    assert.strictEqual(prodRep.data.data.reportType, 'PRODUCTS');
    assert.ok(prodRep.data.data.records.length >= 2);

    // Inventory Report
    const invRep = await makeRequest({
      port,
      path: '/api/v1/analytics/reports?type=INVENTORY&range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(invRep.status, 200);
    assert.strictEqual(invRep.data.data.reportType, 'INVENTORY');
    assert.strictEqual(invRep.data.data.summary.inventoryValuation, 9800);

    // Customers Report
    const custRep = await makeRequest({
      port,
      path: '/api/v1/analytics/reports?type=CUSTOMERS&range=30d',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(custRep.status, 200);
    assert.strictEqual(custRep.data.data.reportType, 'CUSTOMERS');
    assert.strictEqual(custRep.data.data.summary.totalCustomers, 2);
  });
});
