/**
 * Role-Based Access Control (RBAC) Middleware for Nirmaan
 * Roles defined in SRS:
 * - Business Owner (Full BI, Health, Forecasts, Reports, Employee/Settings)
 * - Store Manager (Operations: Products, Inventory, Orders, Customers, Reports)
 * - Sales Staff (Fast Execution: Orders, Stock updates, Customer information)
 * - Administrator (Governance: Users, Security, Backups, Monitoring)
 */
const { sendError } = require('../utils/responseFormatter');
const { recordAuditEvent } = require('../utils/auditLogger');

const ROLES = {
  BUSINESS_OWNER: 'BUSINESS_OWNER',
  STORE_MANAGER: 'STORE_MANAGER',
  SALES_STAFF: 'SALES_STAFF',
  ADMINISTRATOR: 'ADMINISTRATOR',
};

function requireRoles(allowedRoles = []) {
  return (req, res, next) => {
    const user = req.user;

    if (!user) {
      return sendError(res, 'Authentication required', 401);
    }

    const userRole = (user.role || '').toUpperCase();
    const normalizedAllowed = allowedRoles.map((r) => r.toUpperCase());

    if (!normalizedAllowed.includes(userRole)) {
      recordAuditEvent({
        userId: user.id || user.uid,
        action: 'RBAC_ACCESS_DENIED',
        resource: req.originalUrl,
        details: { userRole, requiredRoles: allowedRoles },
        ip: req.ip,
        status: 'DENIED',
      });
      return sendError(res, `Forbidden: role '${userRole}' is not authorized for this resource`, 403);
    }

    next();
  };
}

module.exports = {
  ROLES,
  requireRoles,
};
