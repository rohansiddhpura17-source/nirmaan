const express = require('express');
const router = express.Router();
const { sendSuccess, sendError } = require('../utils/responseFormatter');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRoles, ROLES } = require('../middleware/rbacMiddleware');
const { recordAuditEvent } = require('../utils/auditLogger');

// Public login (mock / dev supported)
router.post('/login', (req, res) => {
  const { email, password, role = 'BUSINESS_OWNER' } = req.body;

  if (!email || !password) {
    return sendError(res, 'Email and password are required', 400);
  }

  // Supported demo credentials
  const demoUsers = {
    'owner@nirmaan.com': { role: ROLES.BUSINESS_OWNER, name: 'Rohan (Owner)' },
    'manager@nirmaan.com': { role: ROLES.STORE_MANAGER, name: 'Store Manager' },
    'staff@nirmaan.com': { role: ROLES.SALES_STAFF, name: 'Sales Associate' },
    'admin@nirmaan.com': { role: ROLES.ADMINISTRATOR, name: 'System Admin' },
  };

  const userRole = demoUsers[email]?.role || role.toUpperCase();
  const userName = demoUsers[email]?.name || 'Demo User';
  const token = `mock-token-${userRole.toLowerCase()}`;

  recordAuditEvent({
    userId: email,
    action: 'USER_LOGIN',
    resource: '/api/v1/auth/login',
    details: { email, role: userRole },
    ip: req.ip,
    status: 'SUCCESS',
  });

  return sendSuccess(
    res,
    {
      user: {
        id: 'usr_' + Date.now(),
        email,
        name: userName,
        role: userRole,
      },
      token,
      tokenType: 'Bearer',
      expiresIn: '7d',
    },
    'Login successful'
  );
});

// Profile endpoint (Authenticated)
router.get('/me', authenticate, (req, res) => {
  return sendSuccess(res, { user: req.user }, 'Current user profile');
});

// Owner-only test endpoint (Owner BI access)
router.get('/owner-dashboard', authenticate, requireRoles([ROLES.BUSINESS_OWNER, ROLES.ADMINISTRATOR]), (req, res) => {
  return sendSuccess(res, { access: 'GRANTED', message: 'Owner Business Intelligence Access' });
});

// Admin-only test endpoint (Governance access)
router.get('/admin-governance', authenticate, requireRoles([ROLES.ADMINISTRATOR]), (req, res) => {
  return sendSuccess(res, { access: 'GRANTED', message: 'System Administration & Governance Access' });
});

module.exports = router;
