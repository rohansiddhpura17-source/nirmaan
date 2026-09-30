const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/app');

test('Health Route returns 200 and UP status', (t, done) => {
  const server = app.listen(0, () => {
    const port = server.address().port;
    http.get(`http://localhost:${port}/api/v1/health`, (res) => {
      assert.strictEqual(res.statusCode, 200);
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        const json = JSON.parse(data);
        assert.strictEqual(json.success, true);
        assert.strictEqual(json.data.status, 'UP');
        server.close(done);
      });
    });
  });
});

test('RBAC Access Enforcement', (t, done) => {
  const server = app.listen(0, () => {
    const port = server.address().port;

    // 1. Test unauthenticated access to /api/v1/auth/me -> 401
    http.get(`http://localhost:${port}/api/v1/auth/me`, (res) => {
      assert.strictEqual(res.statusCode, 401);

      // 2. Test Sales Staff trying to access Owner-only BI endpoint -> 403
      const req = http.request(
        `http://localhost:${port}/api/v1/auth/owner-dashboard`,
        {
          headers: {
            Authorization: 'Bearer mock-token-sales_staff',
          },
        },
        (resStaff) => {
          assert.strictEqual(resStaff.statusCode, 403);

          // 3. Test Business Owner accessing Owner-only BI endpoint -> 200
          const reqOwner = http.request(
            `http://localhost:${port}/api/v1/auth/owner-dashboard`,
            {
              headers: {
                Authorization: 'Bearer mock-token-business_owner',
              },
            },
            (resOwner) => {
              assert.strictEqual(resOwner.statusCode, 200);
              server.close(done);
            }
          );
          reqOwner.end();
        }
      );
      req.end();
    });
  });
});
