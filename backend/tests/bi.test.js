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
const { getISTDateString } = require('../src/utils/dateUtils');

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

test('Business Intelligence Suite (Phase 7)', async (t) => {
  let server;
  let port;

  const testBusinessId = `biz_bi_test_${Date.now()}`;
  const isolatedBusinessId = `biz_bi_iso_${Date.now()}`;

  // Users
  const ownerUser = await userRepository.create({
    uid: `usr_bi_owner_${Date.now()}`,
    email: 'bi.owner@nirmaan.store',
    displayName: 'BI Store Owner',
    role: 'BUSINESS_OWNER',
    businessId: testBusinessId,
    setupComplete: true,
  });
  const ownerToken = makeToken(ownerUser);

  const managerUser = await userRepository.create({
    uid: `usr_bi_manager_${Date.now()}`,
    email: 'bi.manager@nirmaan.store',
    displayName: 'BI Store Manager',
    role: 'STORE_MANAGER',
    businessId: testBusinessId,
    setupComplete: true,
  });
  const managerToken = makeToken(managerUser);

  const staffUser = await userRepository.create({
    uid: `usr_bi_staff_${Date.now()}`,
    email: 'bi.staff@nirmaan.store',
    displayName: 'Sales Staff',
    role: 'SALES_STAFF',
    businessId: testBusinessId,
    setupComplete: true,
  });
  const staffToken = makeToken(staffUser);

  const noBusinessUser = await userRepository.create({
    uid: `usr_bi_nobiz_${Date.now()}`,
    email: 'bi.nobiz@nirmaan.store',
    displayName: 'No Business User',
    role: 'BUSINESS_OWNER',
    businessId: null,
    setupComplete: false,
  });
  const noBizToken = makeToken(noBusinessUser);

  const ownerBUser = await userRepository.create({
    uid: `usr_bi_owner_b_${Date.now()}`,
    email: 'bi.ownerb@nirmaan.store',
    displayName: 'Business B Owner',
    role: 'BUSINESS_OWNER',
    businessId: isolatedBusinessId,
    setupComplete: true,
  });
  const ownerBToken = makeToken(ownerBUser);

  // Business profiles
  await businessRepository.create({
    businessId: testBusinessId,
    businessName: 'Nirmaan Intelligence Mart',
    category: 'Grocery & FMCG',
    ownerId: ownerUser.uid,
    phone: '+91 98123 45678',
    address: 'Commercial Street, Bangalore',
    setupComplete: true,
  });

  await businessRepository.create({
    businessId: isolatedBusinessId,
    businessName: 'Isolated Business Store',
    category: 'Retail',
    ownerId: ownerBUser.uid,
    setupComplete: true,
  });

  // Seed Products for testBusinessId
  const prodRice = await productRepository.create({
    businessId: testBusinessId,
    name: 'Basmati Rice 5kg',
    category: 'Grains',
    sku: 'RICE-5KG',
    currentStock: 40,
    minStockThreshold: 10,
    costPrice: 200,
    purchasePrice: 200,
    sellingPrice: 300,
    status: 'ACTIVE',
  });

  const prodOil = await productRepository.create({
    businessId: testBusinessId,
    name: 'Mustard Oil 1L',
    category: 'Oils',
    sku: 'OIL-1L',
    currentStock: 4, // LOW STOCK (4 <= 10)
    minStockThreshold: 10,
    costPrice: 120,
    purchasePrice: 120,
    sellingPrice: 180,
    status: 'ACTIVE',
  });

  const prodSalt = await productRepository.create({
    businessId: testBusinessId,
    name: 'Crystal Salt 1kg',
    category: 'Staples',
    sku: 'SALT-1KG',
    currentStock: 0, // OUT OF STOCK
    minStockThreshold: 5,
    costPrice: 15,
    purchasePrice: 15,
    sellingPrice: 25,
    status: 'ACTIVE',
  });

  const prodCashew = await productRepository.create({
    businessId: testBusinessId,
    name: 'Kaju Cashews 500g',
    category: 'Dry Fruits',
    sku: 'KAJU-500G',
    currentStock: 25, // Unsold in period
    minStockThreshold: 5,
    costPrice: 350,
    purchasePrice: 350,
    sellingPrice: 450,
    status: 'ACTIVE',
  });

  // Seed Customers
  const custActive = await customerRepository.create({
    businessId: testBusinessId,
    name: 'Active Buyer',
    phone: '+91 98000 11111',
  });

  const custInactive = await customerRepository.create({
    businessId: testBusinessId,
    name: 'Dormant Patron',
    phone: '+91 98000 22222',
  });

  // Seed Orders
  const now = new Date();
  const todayStr = getISTDateString(now);
  const todayDate = new Date(`${todayStr}T11:00:00.000+05:30`);
  const twoDaysAgo = new Date(`${todayStr}T11:00:00.000+05:30`);
  twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
  const fiftyDaysAgo = new Date(`${todayStr}T11:00:00.000+05:30`);
  fiftyDaysAgo.setDate(fiftyDaysAgo.getDate() - 50);

  // Order 1: Completed today by Active Buyer (2 Rice @ 300 = 600, 1 Oil @ 180 = 180 -> Total 780)
  await orderRepository.create({
    orderId: 'ord_bi_01',
    businessId: testBusinessId,
    orderNumber: 'ORD-BI-01',
    customerId: custActive.id,
    customerName: custActive.name,
    orderStatus: 'COMPLETED',
    paymentMethod: 'UPI',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, quantity: 2, unitPrice: 300, lineTotal: 600 },
      { productId: prodOil.productId, productName: prodOil.name, quantity: 1, unitPrice: 180, lineTotal: 180 },
    ],
    total: 780,
    createdAt: todayDate.toISOString(),
  });

  // Order 2: Completed 2 days ago by Active Buyer (3 Rice @ 300 = 900)
  await orderRepository.create({
    orderId: 'ord_bi_02',
    businessId: testBusinessId,
    orderNumber: 'ORD-BI-02',
    customerId: custActive.id,
    customerName: custActive.name,
    orderStatus: 'COMPLETED',
    paymentMethod: 'CASH',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, quantity: 3, unitPrice: 300, lineTotal: 900 },
    ],
    total: 900,
    createdAt: twoDaysAgo.toISOString(),
  });

  // Order 3: Completed 50 days ago by Dormant Patron (1 Oil @ 180 = 180) -> high churn risk!
  await orderRepository.create({
    orderId: 'ord_bi_03',
    businessId: testBusinessId,
    orderNumber: 'ORD-BI-03',
    customerId: custInactive.id,
    customerName: custInactive.name,
    orderStatus: 'COMPLETED',
    paymentMethod: 'CASH',
    items: [
      { productId: prodOil.productId, productName: prodOil.name, quantity: 1, unitPrice: 180, lineTotal: 180 },
    ],
    total: 180,
    createdAt: fiftyDaysAgo.toISOString(),
  });

  // Order 4: Cancelled order (Must be excluded from sales vitality & forecasts)
  await orderRepository.create({
    orderId: 'ord_bi_04',
    businessId: testBusinessId,
    orderNumber: 'ORD-BI-04',
    customerId: custActive.id,
    orderStatus: 'CANCELLED',
    paymentMethod: 'CASH',
    items: [
      { productId: prodRice.productId, productName: prodRice.name, quantity: 1, unitPrice: 300, lineTotal: 300 },
    ],
    total: 300,
    createdAt: todayDate.toISOString(),
  });

  // Seed inventory movement
  await inventoryMovementRepository.create({
    businessId: testBusinessId,
    productId: prodRice.productId,
    quantity: 20,
    type: 'RESTOCK',
    reason: 'Initial stock intake',
  });

  // Start HTTP Server
  await new Promise((resolve) => {
    server = app.listen(0, () => {
      port = server.address().port;
      resolve();
    });
  });

  t.after(() => {
    if (server) server.close();
  });

  // ---------------------------------------------------------------------------
  // TEST 1: Authentication Requirement
  // ---------------------------------------------------------------------------
  await t.test('1. unauthenticated BI access returns 401', async () => {
    const res = await makeRequest({ port, path: '/api/v1/bi/overview' });
    assert.strictEqual(res.status, 401);
  });

  // ---------------------------------------------------------------------------
  // TEST 2: Tenant Enforcement
  // ---------------------------------------------------------------------------
  await t.test('2. user without businessId returns 403', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/overview',
      headers: { Authorization: `Bearer ${noBizToken}` },
    });
    assert.strictEqual(res.status, 403);
  });

  // ---------------------------------------------------------------------------
  // TEST 3: RBAC Role Guard
  // ---------------------------------------------------------------------------
  await t.test('3. unauthorized roles (SALES_STAFF) blocked from BI with 403', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/overview',
      headers: { Authorization: `Bearer ${staffToken}` },
    });
    assert.strictEqual(res.status, 403);

    // STORE_MANAGER is allowed
    const mgrRes = await makeRequest({
      port,
      path: '/api/v1/bi/overview',
      headers: { Authorization: `Bearer ${managerToken}` },
    });
    assert.strictEqual(mgrRes.status, 200);
  });

  // ---------------------------------------------------------------------------
  // TEST 4: Business Health Score Engine
  // ---------------------------------------------------------------------------
  await t.test('4. health score is deterministic, bounded 0-100, with 5 dimensions', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/health-score',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const hs = res.data.data.healthScore;

    assert.ok(typeof hs.overallScore === 'number');
    assert.ok(hs.overallScore >= 0 && hs.overallScore <= 100);
    assert.ok(['EXCELLENT', 'GOOD', 'AVERAGE', 'CRITICAL'].includes(hs.healthLevel));
    assert.ok(hs.explanation.includes(`${hs.overallScore}/100`));

    // Verify 5 dimensions are present
    const d = hs.dimensions;
    assert.ok(d.salesVitality && d.salesVitality.score >= 0);
    assert.ok(d.inventoryHealth && d.inventoryHealth.score >= 0);
    assert.ok(d.customerActivity && d.customerActivity.score >= 0);
    assert.ok(d.productEfficiency && d.productEfficiency.score >= 0);
    assert.ok(d.operationalStability && d.operationalStability.score >= 0);

    // Negative signals should reflect Salt out-of-stock and Oil low-stock
    assert.ok(hs.negativeSignals.some((s) => s.includes('out of stock')));
    assert.ok(hs.negativeSignals.some((s) => s.includes('minimum inventory threshold')));
  });

  // ---------------------------------------------------------------------------
  // TEST 5: Sales & Demand Forecasting
  // ---------------------------------------------------------------------------
  await t.test('5. sales forecast derives from real history and marks decision-support', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/forecast',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const fc = res.data.data.forecast;

    assert.strictEqual(fc.isGuaranteed, false);
    assert.ok(fc.disclaimer.includes('decision-support'));
    assert.ok(fc.dailyForecasts.length === 7);
    assert.ok(fc.projectedTotalRevenue >= 0);
    assert.ok(fc.projectedTotalOrders >= 0);

    // Product demand forecasts
    assert.ok(fc.productForecasts.length >= 1);
    const riceFc = fc.productForecasts.find((p) => p.name.includes('Basmati Rice'));
    assert.ok(riceFc);
    assert.ok(riceFc.dailyVelocity >= 0);
  });

  // ---------------------------------------------------------------------------
  // TEST 6: Inventory Intelligence Engine
  // ---------------------------------------------------------------------------
  await t.test('6. inventory intelligence identifies out-of-stock, low-stock & replenishment', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/inventory-intelligence',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const inv = res.data.data.inventoryIntelligence;

    assert.strictEqual(inv.outOfStockCount, 1); // Salt
    assert.strictEqual(inv.lowStockCount, 1); // Oil
    assert.ok(inv.outOfStockAlerts.some((a) => a.name.includes('Salt') && a.urgency === 'IMMEDIATE'));
    assert.ok(inv.lowStockAlerts.some((a) => a.name.includes('Oil') && a.urgency === 'HIGH'));

    // Replenishment suggestions
    assert.ok(inv.replenishmentRecommendations.length >= 2);
    const saltReorder = inv.replenishmentRecommendations.find((r) => r.name.includes('Salt'));
    assert.ok(saltReorder && saltReorder.suggestedReorderQuantity > 0);

    // Fast moving should include Rice (5 sold)
    assert.ok(inv.fastMovingProducts.some((p) => p.name.includes('Rice')));
    // Slow moving should include Cashews (0 sold)
    assert.ok(inv.slowMovingProducts.some((p) => p.name.includes('Cashews')));
  });

  // ---------------------------------------------------------------------------
  // TEST 7: Customer Churn & Risk Engine
  // ---------------------------------------------------------------------------
  await t.test('7. customer risk classifies dormant patron as HIGH_RISK (>45 days)', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/customer-risk',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const cr = res.data.data.customerRisk;

    assert.strictEqual(cr.totalTrackedCustomers, 2);
    const inactiveSignal = cr.customerRiskSignals.find((s) => s.customerName.includes('Dormant'));
    assert.ok(inactiveSignal);
    assert.strictEqual(inactiveSignal.riskLevel, 'HIGH_RISK');
    assert.ok(inactiveSignal.daysSinceLastOrder >= 45);

    const activeSignal = cr.customerRiskSignals.find((s) => s.customerName.includes('Active'));
    assert.ok(activeSignal);
    assert.strictEqual(activeSignal.riskLevel, 'LOW_RISK');
  });

  // ---------------------------------------------------------------------------
  // TEST 8: Product Intelligence Engine
  // ---------------------------------------------------------------------------
  await t.test('8. product intelligence identifies top performers and dormant items', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/product-intelligence',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const pi = res.data.data.productIntelligence;

    assert.ok(pi.topPerformers.length >= 2);
    assert.strictEqual(pi.topPerformers[0].name, 'Basmati Rice 5kg');
    assert.strictEqual(pi.topPerformers[0].quantitySold, 5);

    assert.ok(pi.dormantProducts.length >= 1);
    assert.ok(pi.dormantProducts.some((p) => p.name.includes('Cashews')));
  });

  // ---------------------------------------------------------------------------
  // TEST 9: Comprehensive BI Overview Payload
  // ---------------------------------------------------------------------------
  await t.test('9. GET /api/v1/bi/overview returns all intelligence modules in single payload', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/overview',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(res.status, 200);
    const data = res.data.data;

    assert.ok(data.healthScore);
    assert.ok(data.forecast);
    assert.ok(data.inventoryIntelligence);
    assert.ok(data.customerRisk);
    assert.ok(data.productIntelligence);
    assert.ok(data.recommendations && data.recommendations.length > 0);
  });

  // ---------------------------------------------------------------------------
  // TEST 10: Tenant Isolation
  // ---------------------------------------------------------------------------
  await t.test('10. tenant isolation: Business B BI does not leak Business A metrics', async () => {
    const res = await makeRequest({
      port,
      path: '/api/v1/bi/overview',
      headers: { Authorization: `Bearer ${ownerBToken}` },
    });
    assert.strictEqual(res.status, 200);
    const data = res.data.data;

    assert.strictEqual(data.inventoryIntelligence.catalogSize, 0);
    assert.strictEqual(data.customerRisk.totalTrackedCustomers, 0);
    assert.strictEqual(data.productIntelligence.topPerformers.length, 0);
    assert.strictEqual(data.forecast.projectedTotalRevenue, 0);
  });
});
