const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');
const userRepository = require('../src/repositories/userRepository');
const businessRepository = require('../src/repositories/businessRepository');

function makeRequest({ port, method = 'POST', path, headers = {}, body = null }) {
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

test('Business Setup Suite (Phase 3)', async (t) => {
  const server = app.listen(0);
  const port = server.address().port;

  // 1. Unauthenticated setup request → 401
  await t.test('1. unauthenticated setup request returns 401', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      body: {
        businessName: 'Laxmi Traders',
        businessCategory: 'Groceries & Kirana',
        phone: '+91 98765 43210',
        address: 'Shop 1, Main Market',
      },
    });

    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /token missing/i);
  });

  // 2. Invalid token → 401
  await t.test('2. invalid or malformed token returns 401', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: 'Bearer this-is-not-a-valid-token' },
      body: {
        businessName: 'Laxmi Traders',
        businessCategory: 'Groceries & Kirana',
        phone: '+91 98765 43210',
        address: 'Shop 1, Main Market',
      },
    });

    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /invalid or expired/i);
  });

  // 3. Invalid input → 400
  await t.test('3. invalid input (empty name, bad phone, short address, bad GSTIN) returns 400 with field errors', async () => {
    // Create a new owner with incomplete setup
    const ownerUser = await userRepository.create({
      uid: 'usr_phase3_test_owner',
      email: 'p3_owner@store.com',
      displayName: 'Phase3 Owner',
      role: 'BUSINESS_OWNER',
      businessId: null,
      setupComplete: false,
    });
    const token = makeToken(ownerUser);

    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${token}` },
      body: {
        businessName: '',
        businessCategory: '',
        phone: '123',
        address: 'ab',
        gstNumber: 'invalid-gst-123',
      },
    });

    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.data.success, false);
    assert.ok(Array.isArray(res.data.errors));
    assert.ok(res.data.errors.some((e) => e.field === 'businessName'));
    assert.ok(res.data.errors.some((e) => e.field === 'businessCategory'));
    assert.ok(res.data.errors.some((e) => e.field === 'phone'));
    assert.ok(res.data.errors.some((e) => e.field === 'address'));
    assert.ok(res.data.errors.some((e) => e.field === 'gstNumber'));
  });

  // 4. Unauthorized business modification → 403
  await t.test('4. unauthorized business modification (role check & tenant boundary) returns 403', async () => {
    // 4a. Staff role blocked from setup (only owner or admin)
    const staffUser = await userRepository.create({
      uid: 'usr_phase3_staff_user',
      email: 'p3_staff@store.com',
      displayName: 'Phase3 Staff',
      role: 'SALES_STAFF',
      businessId: null,
      setupComplete: false,
    });
    const staffToken = makeToken(staffUser);

    const staffRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${staffToken}` },
      body: {
        businessName: 'Staff Store Attempt',
        businessCategory: 'General Retail',
        phone: '+91 98765 00000',
        address: 'Some Address, City',
      },
    });
    assert.strictEqual(staffRes.status, 403);
    assert.strictEqual(staffRes.data.success, false);
    assert.match(staffRes.data.message, /only business owners/i);

    // 4b. Owner attempting to modify another business (businessId manipulation)
    const ownerA = await userRepository.create({
      uid: 'usr_phase3_owner_a',
      email: 'owner_a@store.com',
      displayName: 'Owner A',
      role: 'BUSINESS_OWNER',
      businessId: 'biz_owner_a',
      setupComplete: false,
    });
    const ownerB = await userRepository.create({
      uid: 'usr_phase3_owner_b',
      email: 'owner_b@store.com',
      displayName: 'Owner B',
      role: 'BUSINESS_OWNER',
      businessId: 'biz_owner_b',
      setupComplete: true,
    });
    await businessRepository.create({
      businessId: 'biz_owner_b',
      businessName: "Owner B's Business",
      businessCategory: 'General Retail',
      ownerId: ownerB.uid,
      contact: { phone: '+91 98765 11111', address: 'Market Road' },
      setupComplete: true,
    });

    const tokenA = makeToken(ownerA);
    const tamperedRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${tokenA}` },
      body: {
        businessId: 'biz_owner_b', // Attempting to modify User B's business!
        businessName: 'Hijacked Store',
        businessCategory: 'General Retail',
        phone: '+91 98765 22222',
        address: 'Hacked Address, City',
      },
    });
    assert.strictEqual(tamperedRes.status, 403);
    assert.strictEqual(tamperedRes.data.success, false);
    assert.match(tamperedRes.data.message, /forbidden/i);
  });

  // 5. Successful business creation
  let createdBusinessId = null;
  let newOwnerUid = null;
  await t.test('5. successful business creation returns 200 with structured data', async () => {
    newOwnerUid = `usr_new_biz_owner_${Date.now()}`;
    const newOwner = await userRepository.create({
      uid: newOwnerUid,
      email: `owner_${Date.now()}@nirmaan.local`,
      displayName: 'Naveen Kumar',
      role: 'BUSINESS_OWNER',
      businessId: null,
      setupComplete: false,
    });
    const token = makeToken(newOwner);

    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${token}` },
      body: {
        businessName: 'Naveen Supermarket',
        businessCategory: 'Grocery & FMCG',
        ownerName: 'Naveen Kumar',
        phone: '+91 98765 99999',
        address: 'Plot 10, Ring Road, Surat',
        gstNumber: '24ABCDE1234F1Z5',
        currency: 'INR',
      },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.business.businessName, 'Naveen Supermarket');
    assert.strictEqual(res.data.data.business.businessCategory, 'Grocery & FMCG');
    assert.strictEqual(res.data.data.business.gstNumber, '24ABCDE1234F1Z5');
    assert.strictEqual(res.data.data.business.currency, 'INR');
    assert.strictEqual(res.data.data.business.setupComplete, true);
    assert.strictEqual(res.data.data.user.setupComplete, true);

    createdBusinessId = res.data.data.business.businessId;
    assert.ok(createdBusinessId);
  });

  // 6. User-business relationship created correctly
  await t.test('6. user-business relationship created correctly (users/{uid}.businessId == businesses/{businessId}.businessId and ownerId == uid)', async () => {
    const userDoc = await userRepository.findById(newOwnerUid);
    const bizDoc = await businessRepository.findById(createdBusinessId);

    assert.ok(userDoc);
    assert.ok(bizDoc);
    assert.strictEqual(userDoc.businessId, createdBusinessId);
    assert.strictEqual(bizDoc.ownerId, newOwnerUid);
    assert.strictEqual(bizDoc.businessId, createdBusinessId);
  });

  // 7. setupComplete updated correctly
  await t.test('7. setupComplete updated correctly to true on both user and business', async () => {
    const userDoc = await userRepository.findById(newOwnerUid);
    const bizDoc = await businessRepository.findById(createdBusinessId);

    assert.strictEqual(userDoc.setupComplete, true);
    assert.strictEqual(bizDoc.setupComplete, true);
  });

  // 8. Duplicate/invalid business setup handled safely and idempotently
  await t.test('8. duplicate setup calls update existing business idempotently without creating duplicate businesses', async () => {
    const userDoc = await userRepository.findById(newOwnerUid);
    const token = makeToken(userDoc);

    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${token}` },
      body: {
        businessName: 'Naveen Supermarket Updated',
        businessCategory: 'Groceries & Kirana',
        phone: '+91 98765 88888',
        address: 'Plot 10, New Ring Road, Surat',
      },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    // Business ID remains the same, not a duplicate
    assert.strictEqual(res.data.data.business.businessId, createdBusinessId);
    assert.strictEqual(res.data.data.business.businessName, 'Naveen Supermarket Updated');
    assert.strictEqual(res.data.data.user.businessId, createdBusinessId);
    assert.strictEqual(res.data.data.user.setupComplete, true);
  });

  // 9. GET /api/v1/auth/business returns 404 if user has no business configured yet
  await t.test('9. GET /api/v1/auth/business returns 404 when no business profile exists', async () => {
    const unconfiguredOwner = await userRepository.create({
      uid: `usr_unconfigured_${Date.now()}`,
      email: `unconf_${Date.now()}@nirmaan.local`,
      displayName: 'Unconfigured Owner',
      role: 'BUSINESS_OWNER',
      businessId: null,
      setupComplete: false,
    });
    const token = makeToken(unconfiguredOwner);

    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/business',
      headers: { Authorization: `Bearer ${token}` },
    });

    assert.strictEqual(res.status, 404);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /business profile not found/i);
  });

  // 10. GET /api/v1/auth/business returns 200 with business details after business setup
  await t.test('10. GET /api/v1/auth/business returns 200 with profile after setup', async () => {
    const userDoc = await userRepository.findById(newOwnerUid);
    const token = makeToken(userDoc);

    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/business',
      headers: { Authorization: `Bearer ${token}` },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.business.businessId, createdBusinessId);
    assert.strictEqual(res.data.data.business.businessName, 'Naveen Supermarket Updated');
  });

  // 11. tenantMiddleware verification: operational route blocked before setup, permitted after setup
  await t.test('11. tenantMiddleware blocks operational route access until business setup is complete', async () => {
    // Fresh owner without business
    const freshOwner = await userRepository.create({
      uid: `usr_fresh_${Date.now()}`,
      email: `fresh_${Date.now()}@nirmaan.local`,
      displayName: 'Fresh Owner',
      role: 'BUSINESS_OWNER',
      businessId: null,
      setupComplete: false,
    });
    const freshToken = makeToken(freshOwner);

    // Step A: Attempt to access operational dashboard -> 403 Access Denied
    const blockedRes = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${freshToken}` },
    });
    assert.strictEqual(blockedRes.status, 403);
    assert.match(blockedRes.data.message, /business setup required/i);

    // Step B: Complete business setup
    const setupRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${freshToken}` },
      body: {
        businessName: 'Fresh Mart',
        businessCategory: 'Retail',
        phone: '+91 98765 33333',
        address: 'Station Road, Vadodara',
      },
    });
    assert.strictEqual(setupRes.status, 200);
    const configuredUser = setupRes.data.data.user;
    const configuredToken = makeToken(configuredUser);

    // Step C: Access operational dashboard -> 200 OK permitted
    const permittedRes = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/dashboard',
      headers: { Authorization: `Bearer ${configuredToken}` },
    });
    assert.strictEqual(permittedRes.status, 200);
    assert.strictEqual(permittedRes.data.success, true);
  });

  server.close();
});
