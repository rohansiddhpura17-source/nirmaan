/**
 * Tenant Isolation Middleware
 * Resolves the authenticated user's businessId from the verified identity
 * Strictly prevents cross-tenant access and ensures businessId is never spoofed by clients
 */
const { sendError } = require('../utils/responseFormatter');
const { recordAuditEvent } = require('../utils/auditLogger');

function enforceTenant(req, res, next) {
  if (!req.user) {
    return sendError(res, 'Authentication required', 401);
  }

  // Administrators can have a system business or be explicitly authorized
  const businessId = req.user.businessId;

  if (!businessId) {
    recordAuditEvent({
      userId: req.user.id || req.user.uid,
      action: 'TENANT_ACCESS_BLOCKED_NO_BUSINESS',
      resource: req.originalUrl,
      status: 'DENIED',
    });
    return sendError(
      res,
      'Access Denied: Business setup required before accessing operational records',
      403
    );
  }

  // Never trust client-supplied businessId in headers, query, or body
  req.businessId = businessId;

  next();
}

/**
 * Validates that an existing entity belongs to the requesting user's tenant
 */
function assertTenantOwnership(entity, req, res) {
  if (!entity) return true;

  if (entity.businessId !== req.businessId) {
    recordAuditEvent({
      userId: req.user.id || req.user.uid,
      action: 'CROSS_TENANT_ACCESS_ATTEMPT',
      resource: req.originalUrl,
      details: {
        entityBusinessId: entity.businessId,
        userBusinessId: req.businessId,
      },
      status: 'BLOCKED',
    });
    sendError(res, 'Forbidden: Cross-business access denied', 403);
    return false;
  }
  return true;
}

module.exports = {
  enforceTenant,
  assertTenantOwnership,
};
