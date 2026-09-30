/**
 * Nirmaan Audit Logger
 * Records security, authentication, and administrative actions
 */
const fs = require('fs');
const path = require('path');

const logDir = path.resolve(__dirname, '../../logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

const auditLogFile = path.join(logDir, 'audit.log');

function recordAuditEvent({ userId, action, resource, details, ip, status = 'SUCCESS' }) {
  const event = {
    timestamp: new Date().toISOString(),
    userId: userId || 'ANONYMOUS',
    action,
    resource,
    details: details || {},
    ip: ip || 'unknown',
    status,
  };

  const line = JSON.stringify(event) + '\n';
  try {
    fs.appendFileSync(auditLogFile, line, 'utf8');
  } catch (err) {
    console.error('Failed to write audit log:', err.message);
  }

  return event;
}

module.exports = {
  recordAuditEvent,
};
