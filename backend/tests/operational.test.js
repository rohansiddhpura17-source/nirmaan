const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');
const userRepository = require('../src/repositories/userRepository');
const businessRepository = require('../src/repositories/businessRepository');
const productRepository = require('../src/repositories/productRepository');
const customerRepository = require('../src/repositories/customerRepository');
const supplierRepository = require('../src/repositories/supplierRepository');
const orderRepository = require('../src/repositories/orderRepository');
const inventoryMovementRepository = require('../src/repositories/inventoryMovementRepository');

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

test('Core Business Operations Suite (Phase 4)', async (t) => {
  const server = app.listen(0);
  const port = server.address().port;

  // Setup test users & businesses
  const ownerUser = await userRepository.findById('usr_business_owner');
  const staffUser = await userRepository.findById('usr_sales_staff');
  const ownerToken = makeToken(ownerUser);
  const staffToken = makeToken(staffUser);

  // Another business for tenant boundary tests
  const altBusiness = await businessRepository.create({
    businessId: 'biz_alt_test',
    businessName: 'Alternate Retail Enterprise',
    ownerId: 'usr_alt_owner',
    setupComplete: true,
  });

  const altUser = await userRepository.create({
    uid: 'usr_alt_owner',
    email: 'alt@nirmaan.com',
    displayName: 'Alternate Owner',
    role: 'BUSINESS_OWNER',
    businessId: 'biz_alt_test',
    setupComplete: true,
  });
  const altToken = makeToken(altUser);

  // User without business setup
  const unsetupUser = await userRepository.create({
    uid: 'usr_no_biz',
    email: 'nobiz@nirmaan.com',
    displayName: 'Unsetup User',
    role: 'BUSINESS_OWNER',
    businessId: null,
    setupComplete: false,
  });
  const unsetupToken = makeToken(unsetupUser);

  t.after(() => {
    server.close();
  });

  // 1. Authentication required
  await t.test('1. authentication required for operational routes returns 401', async () => {
    const res1 = await makeRequest({ port, method: 'GET', path: '/api/v1/products' });
    assert.strictEqual(res1.status, 401);
    assert.strictEqual(res1.data.success, false);

    const res2 = await makeRequest({ port, method: 'GET', path: '/api/v1/orders' });
    assert.strictEqual(res2.status, 401);

    const res3 = await makeRequest({ port, method: 'GET', path: '/api/v1/inventory/summary' });
    assert.strictEqual(res3.status, 401);
  });

  // 2. Tenant isolation - blocks users without business association
  await t.test('2. users without business association blocked from operations with 403', async () => {
    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/products',
      headers: { Authorization: `Bearer ${unsetupToken}` },
    });
    assert.strictEqual(res.status, 403);
    assert.match(res.data.message, /business setup required/i);
  });

  // 3. Unauthorized role (Sales Staff blocked from product creation, inventory adjustment, supplier management)
  await t.test('3. unauthorized roles blocked from privileged actions with 403', async () => {
    // Sales staff attempting product creation
    const resProd = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/products',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: { name: 'Unauthorized Item', category: 'Groceries', sellingPrice: 50 },
    });
    assert.strictEqual(resProd.status, 403);

    // Sales staff attempting manual inventory adjustment
    const resInv = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/inventory/adjust',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: { productId: 'prod_demo_001', type: 'ADJUSTMENT', quantity: 5, reason: 'Test' },
    });
    assert.strictEqual(resInv.status, 403);

    // Sales staff attempting supplier list / creation
    const resSup = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/suppliers',
      headers: { Authorization: `Bearer ${staffToken}` },
    });
    assert.strictEqual(resSup.status, 403);
  });

  // 4. Product CRUD authorization & Duplicate SKU policy
  let createdProductId = null;
  const testSku = `TEST-SKU-${Date.now()}`;
  await t.test('4. product CRUD with validation and duplicate SKU rejection', async () => {
    // Invalid product (empty name)
    const invalidRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/products',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: { name: '', category: 'Groceries', sellingPrice: 100 },
    });
    assert.strictEqual(invalidRes.status, 400);

    // Successful product creation
    const createRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/products',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: {
        name: 'Haldiram Bhujia 400g',
        category: 'FMCG',
        sku: testSku,
        barcode: `890111${Date.now().toString().slice(-6)}`,
        purchasePrice: 90,
        sellingPrice: 115,
        currentStock: 25,
        minStockThreshold: 5,
        unit: 'pack',
      },
    });
    assert.strictEqual(createRes.status, 201);
    assert.strictEqual(createRes.data.success, true);
    assert.strictEqual(createRes.data.data.name, 'Haldiram Bhujia 400g');
    createdProductId = createRes.data.data.productId;

    // Duplicate SKU in same business returns 409
    const dupRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/products',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: {
        name: 'Another Item With Same SKU',
        category: 'FMCG',
        sku: testSku,
        sellingPrice: 120,
      },
    });
    assert.strictEqual(dupRes.status, 409);
    assert.match(dupRes.data.message, /already exists/i);

    // Update product
    const updateRes = await makeRequest({
      port,
      method: 'PUT',
      path: `/api/v1/products/${createdProductId}`,
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: { sellingPrice: 125 },
    });
    assert.strictEqual(updateRes.status, 200);
    assert.strictEqual(updateRes.data.data.sellingPrice, 125);
  });

  // 5. Customer CRUD authorization & validation
  let createdCustId = null;
  const testPhone = `+91 98111 ${Date.now().toString().slice(-5)}`;
  await t.test('5. customer CRUD authorization and phone validation', async () => {
    const createRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/customers',
      headers: { Authorization: `Bearer ${staffToken}` }, // Sales Staff can create customers
      body: {
        name: 'Vikram Malhotra',
        phone: testPhone,
        email: 'vikram@example.com',
        address: 'Villa 12, Palm Residency',
      },
    });
    assert.strictEqual(createRes.status, 201);
    assert.strictEqual(createRes.data.data.name, 'Vikram Malhotra');
    createdCustId = createRes.data.data.customerId;

    // Duplicate phone in same business
    const dupRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/customers',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: {
        name: 'Another Person',
        phone: testPhone,
      },
    });
    assert.strictEqual(dupRes.status, 409);
  });

  // 6. Supplier CRUD authorization
  let createdSupplierId = null;
  await t.test('6. supplier CRUD authorization (Owner/Manager allowed)', async () => {
    const createRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/suppliers',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: {
        name: 'Nestle Regional Depot',
        phone: '+91 97000 88990',
        email: 'nestle.depot@example.com',
        category: 'Dairy & Confectionery',
      },
    });
    assert.strictEqual(createRes.status, 201);
    createdSupplierId = createRes.data.data.supplierId;

    // View supplier
    const getRes = await makeRequest({
      port,
      method: 'GET',
      path: `/api/v1/suppliers/${createdSupplierId}`,
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(getRes.status, 200);
    assert.strictEqual(getRes.data.data.name, 'Nestle Regional Depot');
  });

  // 7. Inventory movement recorded on stock adjustment
  await t.test('7. inventory adjustment records stock movement and prevents negative stock', async () => {
    // 1. Negative stock rejection
    const badAdjRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/inventory/adjust',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: {
        productId: createdProductId,
        type: 'ADJUSTMENT',
        quantity: -999,
        reason: 'Spoilage test',
      },
    });
    assert.strictEqual(badAdjRes.status, 400);

    // 2. Successful Restock
    const goodAdjRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/inventory/adjust',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: {
        productId: createdProductId,
        type: 'RESTOCK',
        quantity: 10,
        reason: 'Weekly shipment intake',
      },
    });
    assert.strictEqual(goodAdjRes.status, 200);
    assert.strictEqual(goodAdjRes.data.data.product.currentStock, 35); // 25 + 10
    assert.strictEqual(goodAdjRes.data.data.movement.type, 'RESTOCK');

    // 3. Movements list returns the movement
    const movRes = await makeRequest({
      port,
      method: 'GET',
      path: `/api/v1/inventory/movements?productId=${createdProductId}`,
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(movRes.status, 200);
    assert.ok(movRes.data.data.length >= 1);
  });

  // 8. Invalid order rejected
  await t.test('8. invalid order rejected with 400 (empty items, invalid product ID)', async () => {
    // Empty items
    const res1 = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: { items: [] },
    });
    assert.strictEqual(res1.status, 400);

    // Non-existent product
    const res2 = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: {
        items: [{ productId: 'prod_non_existent', quantity: 2 }],
      },
    });
    assert.strictEqual(res2.status, 400);
  });

  // 9. Insufficient stock rejected
  await t.test('9. order with quantity exceeding available stock rejected with 400', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: {
        items: [{ productId: createdProductId, quantity: 9999 }],
      },
    });
    assert.strictEqual(res.status, 400);
    assert.match(res.data.message, /insufficient stock/i);
  });

  // 10. Successful order & 11. Atomic order/inventory update
  const idempotencyTestKey = `IDEMP-${Date.now()}`;
  let completedOrder = null;

  await t.test('10 & 11. successful order processes atomically, decrements stock & updates customer', async () => {
    const custBefore = await customerRepository.findById(createdCustId);
    const prodBefore = await productRepository.findById(createdProductId);
    const initialStock = prodBefore.currentStock;
    const initialSpend = custBefore.totalSpend;
    const initialOrderCount = custBefore.orderCount || 0;

    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: {
        Authorization: `Bearer ${staffToken}`,
        'Idempotency-Key': idempotencyTestKey,
      },
      body: {
        customerId: createdCustId,
        customerName: custBefore.name,
        items: [
          {
            productId: createdProductId,
            quantity: 5,
            unitPrice: 125,
          },
        ],
        discount: 25,
        tax: 0,
        paymentMethod: 'UPI',
      },
    });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.data.success, true);
    completedOrder = res.data.data;
    assert.strictEqual(completedOrder.total, 600); // 5 * 125 = 625 - 25 = 600

    // Verify stock was decremented atomically
    const prodAfter = await productRepository.findById(createdProductId);
    assert.strictEqual(prodAfter.currentStock, initialStock - 5);

    // Verify customer spend was updated
    const custAfter = await customerRepository.findById(createdCustId);
    assert.strictEqual(custAfter.totalSpend, initialSpend + 600);
    assert.strictEqual(custAfter.orderCount, initialOrderCount + 1);

    // Verify SALE inventory movement was recorded
    const movements = await inventoryMovementRepository.findByBusinessId('biz_nirmaan_demo', {
      productId: createdProductId,
    });
    const saleMov = movements.items.find((m) => m.referenceId === completedOrder.orderId);
    assert.ok(saleMov, 'Inventory movement should link to order ID');
    assert.strictEqual(saleMov.type, 'SALE');
    assert.strictEqual(saleMov.quantity, 5);
  });

  // 12. Duplicate order protection (Idempotency)
  await t.test('12. repeated submission with same idempotency key returns existing order without re-deducting stock', async () => {
    const prodBefore = await productRepository.findById(createdProductId);
    const stockBefore = prodBefore.currentStock;

    const resDup = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: {
        Authorization: `Bearer ${staffToken}`,
        'Idempotency-Key': idempotencyTestKey,
      },
      body: {
        customerId: createdCustId,
        items: [{ productId: createdProductId, quantity: 5, unitPrice: 125 }],
      },
    });

    assert.strictEqual(resDup.status, 200);
    assert.strictEqual(resDup.data.data.orderId, completedOrder.orderId);
    assert.strictEqual(resDup.data.meta.isDuplicate, true);

    // Stock must NOT be decremented again
    const prodAfter = await productRepository.findById(createdProductId);
    assert.strictEqual(prodAfter.currentStock, stockBefore);
  });

  // 13. Cross-business access rejected (403)
  await t.test('13. cross-business access strictly rejected with 403 Forbidden', async () => {
    // User from alt business attempting to read products of main business
    const resProd = await makeRequest({
      port,
      method: 'GET',
      path: `/api/v1/products/${createdProductId}`,
      headers: { Authorization: `Bearer ${altToken}` },
    });
    assert.strictEqual(resProd.status, 403);
    assert.match(resProd.data.message, /cross-business/i);

    // User from alt business attempting to order product belonging to main business
    const resOrder = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: { Authorization: `Bearer ${altToken}` },
      body: {
        items: [{ productId: createdProductId, quantity: 1 }],
      },
    });
    assert.strictEqual(resOrder.status, 403);

    // User from alt business attempting to access customer of main business
    const resCust = await makeRequest({
      port,
      method: 'GET',
      path: `/api/v1/customers/${createdCustId}`,
      headers: { Authorization: `Bearer ${altToken}` },
    });
    assert.strictEqual(resCust.status, 403);
  });

  // 14. Pagination and filter behavior
  await t.test('14. search, category filter, and pagination return correct subsets and metadata', async () => {
    // Filter by category
    const catRes = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/products?category=FMCG',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(catRes.status, 200);
    for (const item of catRes.data.data) {
      assert.strictEqual(item.category, 'FMCG');
    }

    // Text search
    const searchRes = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/products?q=Bhujia',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(searchRes.status, 200);
    assert.ok(searchRes.data.data.length >= 1);
    assert.strictEqual(searchRes.data.data[0].productId, createdProductId);

    // Pagination metadata check
    const pageRes = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/products?page=1&limit=2',
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(pageRes.status, 200);
    assert.strictEqual(pageRes.data.data.length, 2);
    assert.strictEqual(pageRes.data.meta.page, 1);
    assert.strictEqual(pageRes.data.meta.limit, 2);
    assert.ok(pageRes.data.meta.total >= 2);
  });

  // 15. Order cancellation workflow restores stock
  await t.test('15. order cancellation workflow restores stock and sets status CANCELLED', async () => {
    const prodBefore = await productRepository.findById(createdProductId);
    const stockBefore = prodBefore.currentStock;

    // Create an order for 3 items
    const orderRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/orders',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: {
        items: [{ productId: createdProductId, quantity: 3, unitPrice: 125 }],
        paymentMethod: 'CASH',
      },
    });
    assert.strictEqual(orderRes.status, 201);
    const orderId = orderRes.data.data.orderId;

    // Verify stock decreased by 3
    const prodAfterOrder = await productRepository.findById(createdProductId);
    assert.strictEqual(prodAfterOrder.currentStock, stockBefore - 3);

    // Cancel order
    const cancelRes = await makeRequest({
      port,
      method: 'POST',
      path: `/api/v1/orders/${orderId}/cancel`,
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(cancelRes.status, 200);
    assert.strictEqual(cancelRes.data.data.orderStatus, 'CANCELLED');

    // Verify stock was restored
    const prodAfterCancel = await productRepository.findById(createdProductId);
    assert.strictEqual(prodAfterCancel.currentStock, stockBefore);
  });

  // 16. Customer deletion / archive
  await t.test('16. customer deletion removes customer and subsequent lookup returns 404', async () => {
    const createCustRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/customers',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: { name: 'Temporary Customer', phone: '+91 99999 11111' },
    });
    assert.strictEqual(createCustRes.status, 201);
    const tempCustId = createCustRes.data.data.customerId;

    const delRes = await makeRequest({
      port,
      method: 'DELETE',
      path: `/api/v1/customers/${tempCustId}`,
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(delRes.status, 200);

    const getRes = await makeRequest({
      port,
      method: 'GET',
      path: `/api/v1/customers/${tempCustId}`,
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    assert.strictEqual(getRes.status, 404);
  });
});
