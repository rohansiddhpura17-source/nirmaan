const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');

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

test('Authentication & Authorization Suite (Phase 2)', async (t) => {
  const server = app.listen(0);
  const port = server.address().port;

  await t.test('POST /api/v1/auth/register blocks ADMINISTRATOR escalation with 403', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/register',
      body: {
        name: 'Malicious Admin',
        email: 'malicious@example.com',
        password: 'Password123!',
        role: 'ADMINISTRATOR',
      },
    });

    assert.strictEqual(res.status, 403);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /Administrator accounts cannot be created/i);
  });

  await t.test('POST /api/v1/auth/register creates a new user & business with setupComplete: false', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/register',
      body: {
        name: 'Aarav Patel',
        email: 'aarav.patel@example.com',
        password: 'SecurePassword123!',
        role: 'BUSINESS_OWNER',
        phone: '+91 99887 76655',
        businessName: 'Patel Electronics',
      },
    });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.user.email, 'aarav.patel@example.com');
    assert.strictEqual(res.data.data.user.role, 'BUSINESS_OWNER');
    assert.strictEqual(res.data.data.user.setupComplete, false);
    assert.strictEqual(res.data.data.business.setupComplete, false);
    assert.ok(res.data.data.token, 'Token must be returned');
  });

  await t.test('POST /api/v1/auth/register rejects duplicate email with 409', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/register',
      body: {
        name: 'Duplicate Aarav',
        email: 'aarav.patel@example.com',
        password: 'AnotherPassword123!',
        role: 'BUSINESS_OWNER',
      },
    });

    assert.strictEqual(res.status, 409);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /already exists/i);
  });

  await t.test('POST /api/v1/auth/register validates inputs with 400', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/register',
      body: {
        name: '',
        email: 'not-an-email',
        password: '123',
      },
    });

    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.data.success, false);
    assert.ok(res.data.errors.length >= 3);
  });

  await t.test('POST /api/v1/auth/login logs in registered user', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/login',
      body: {
        email: 'aarav.patel@example.com',
        password: 'SecurePassword123!',
      },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.user.name, 'Aarav Patel');
    assert.ok(res.data.data.token);
  });

  await t.test('POST /api/v1/auth/login rejects unregistered user with 401', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/login',
      body: {
        email: 'nobody@nirmaan.com',
        password: 'Password123!',
      },
    });

    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
  });

  await t.test('Protected endpoint rejects missing token with 401', async () => {
    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/me',
    });

    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /token missing/i);
  });

  await t.test('Protected endpoint rejects invalid/malformed token with 401', async () => {
    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/me',
      headers: { Authorization: 'Bearer totally-invalid-token-12345' },
    });

    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
  });

  await t.test('Protected endpoint rejects expired token with 401', async () => {
    const expiredPayload = {
      uid: 'usr_expired',
      email: 'expired@nirmaan.com',
      role: 'BUSINESS_OWNER',
      exp: Math.floor(Date.now() / 1000) - 3600, // Expired 1 hour ago
    };
    const expiredToken = Buffer.from(JSON.stringify(expiredPayload)).toString('base64');

    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/me',
      headers: { Authorization: `Bearer ${expiredToken}` },
    });

    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.data.success, false);
    assert.match(res.data.message, /expired/i);
  });

  await t.test('Production security fails closed if Firebase Admin is unconfigured', async () => {
    const config = require('../src/config/environment');
    const originalEnv = config.env;
    config.env = 'production';

    try {
      const res = await makeRequest({
        port,
        method: 'GET',
        path: '/api/v1/auth/me',
        headers: { Authorization: 'Bearer any-token-value' },
      });

      // Must fail closed with 503 Service Unavailable or 401
      assert.ok([401, 503].includes(res.status));
      assert.strictEqual(res.data.success, false);

      // Verify direct backend login is blocked in production (403)
      const loginRes = await makeRequest({
        port,
        method: 'POST',
        path: '/api/v1/auth/login',
        body: { email: 'aarav.patel@example.com', password: 'Password123' },
      });
      assert.strictEqual(loginRes.status, 403);
      assert.match(loginRes.data.message, /disabled in production/i);

      // Verify direct backend registration is blocked in production (403)
      const regRes = await makeRequest({
        port,
        method: 'POST',
        path: '/api/v1/auth/register',
        body: { name: 'Test', email: 'test_prod@example.com', password: 'Password123' },
      });
      assert.strictEqual(regRes.status, 403);
      assert.match(regRes.data.message, /disabled in production/i);
    } finally {
      config.env = originalEnv;
    }
  });

  await t.test('Backend and Firestore never store passwords in User entities', async () => {
    const userRepository = require('../src/repositories/userRepository');
    const user = await userRepository.findByEmail('aarav.patel@example.com');
    assert.ok(user);
    assert.strictEqual(user.password, undefined);
    assert.strictEqual(user._devPassword, undefined);
    const firestoreData = user.toFirestore();
    assert.strictEqual(firestoreData.password, undefined);
    assert.strictEqual(firestoreData._devPassword, undefined);
    const safeJson = user.toSafeJSON();
    assert.strictEqual(safeJson.password, undefined);
    assert.strictEqual(safeJson._devPassword, undefined);
  });

  let userToken = null;
  await t.test('GET /api/v1/auth/me returns authenticated profile with token', async () => {
    const loginRes = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/login',
      body: {
        email: 'aarav.patel@example.com',
        password: 'SecurePassword123!',
      },
    });

    userToken = loginRes.data.data.token;

    const meRes = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/me',
      headers: { Authorization: `Bearer ${userToken}` },
    });

    assert.strictEqual(meRes.status, 200);
    assert.strictEqual(meRes.data.success, true);
    assert.strictEqual(meRes.data.data.user.email, 'aarav.patel@example.com');
    assert.strictEqual(meRes.data.data.user.setupComplete, false);
  });

  await t.test('POST /api/v1/auth/business-setup updates business and marks setupComplete: true', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/business-setup',
      headers: { Authorization: `Bearer ${userToken}` },
      body: {
        businessName: 'Patel Electronics & Gadgets',
        businessCategory: 'Electronics & Mobiles',
        phone: '+91 99887 76655',
        address: 'Shop 10, MG Road, Ahmedabad, Gujarat',
        gstNumber: '24ABCDE1234F1Z5',
        currency: 'INR',
      },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.business.setupComplete, true);
    assert.strictEqual(res.data.data.user.setupComplete, true);
    assert.strictEqual(res.data.data.business.businessName, 'Patel Electronics & Gadgets');
  });

  await t.test('GET /api/v1/auth/business returns updated business profile', async () => {
    const res = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/business',
      headers: { Authorization: `Bearer ${userToken}` },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.business.setupComplete, true);
  });

  await t.test('RBAC Access Enforcement for 4 SRS Roles', async () => {
    // 1. Sales staff blocked from owner dashboard (403)
    const staffDenied = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/owner-dashboard',
      headers: { Authorization: 'Bearer test-token-sales_staff' },
    });
    assert.strictEqual(staffDenied.status, 403);
    assert.strictEqual(staffDenied.data.success, false);

    // 2. Business owner allowed on owner dashboard (200)
    const ownerAllowed = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/owner-dashboard',
      headers: { Authorization: 'Bearer test-token-business_owner' },
    });
    assert.strictEqual(ownerAllowed.status, 200);
    assert.strictEqual(ownerAllowed.data.success, true);

    // 3. Store manager allowed on manager operations (200)
    const mgrAllowed = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/manager-operations',
      headers: { Authorization: 'Bearer test-token-store_manager' },
    });
    assert.strictEqual(mgrAllowed.status, 200);
    assert.strictEqual(mgrAllowed.data.success, true);

    // 4. Non-admin blocked from admin governance (403)
    const adminDenied = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/admin-governance',
      headers: { Authorization: 'Bearer test-token-business_owner' },
    });
    assert.strictEqual(adminDenied.status, 403);

    // 5. Administrator allowed on admin governance (200)
    const adminAllowed = await makeRequest({
      port,
      method: 'GET',
      path: '/api/v1/auth/admin-governance',
      headers: { Authorization: 'Bearer test-token-administrator' },
    });
    assert.strictEqual(adminAllowed.status, 200);
  });

  await t.test('POST /api/v1/auth/logout succeeds with valid token', async () => {
    const res = await makeRequest({
      port,
      method: 'POST',
      path: '/api/v1/auth/logout',
      headers: { Authorization: `Bearer ${userToken}` },
    });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.data.success, true);
    assert.strictEqual(res.data.data.loggedOut, true);
  });

  server.close();
});
