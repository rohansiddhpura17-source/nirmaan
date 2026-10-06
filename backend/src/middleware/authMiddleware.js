/**
 * Authentication Middleware for Nirmaan API
 * Verifies Firebase ID Tokens server-side using Firebase Admin SDK
 * Enforces server-side authorization and RBAC role resolution
 * SECURITY: Enforces Fail-Closed behavior in Production
 */
const { sendError } = require('../utils/responseFormatter');
const config = require('../config/environment');
const { getAuth } = require('../config/firebaseAdmin');
const userRepository = require('../repositories/userRepository');

async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return sendError(res, 'Authentication required: Bearer token missing or malformed', 401);
  }

  const token = authHeader.split(' ')[1];
  if (!token || token.trim() === '') {
    return sendError(res, 'Authentication required: Token cannot be empty', 401);
  }

  let decoded = null;

  // FAIL-CLOSED RULE FOR PRODUCTION:
  // In production, Firebase Admin verification is strictly mandatory.
  // No mock tokens, no base64 fallback, no silent local bypass.
  if (config.env === 'production') {
    const firebaseAuth = getAuth();
    if (!firebaseAuth) {
      return sendError(
        res,
        'Security Error: Firebase Admin service unavailable. Authentication failed-closed.',
        503
      );
    }

    try {
      decoded = await firebaseAuth.verifyIdToken(token);
    } catch (err) {
      return sendError(res, 'Invalid, malformed or expired Firebase ID token', 401);
    }
  } else {
    // Development and Test environments:
    if (token.startsWith('test-token-')) {
      const rolePart = token.replace('test-token-', '').toUpperCase();
      decoded = {
        uid: `usr_${rolePart.toLowerCase()}`,
        email: `${rolePart.toLowerCase()}@nirmaan.com`,
        role: rolePart,
      };
    } else {
      const firebaseAuth = getAuth();
      const isJwt = token.split('.').length === 3;
      if (firebaseAuth && isJwt) {
        try {
          decoded = await firebaseAuth.verifyIdToken(token);
        } catch (err) {
          return sendError(res, 'Invalid or expired authentication token', 401);
        }
      } else {
        // Safe development emulation fallback when cloud keys are not configured locally
        try {
          const payload = Buffer.from(token, 'base64').toString('utf8');
          const parsed = JSON.parse(payload);
          if (parsed.uid || parsed.id) {
            if (parsed.exp && parsed.exp < Math.floor(Date.now() / 1000)) {
              return sendError(res, 'Authentication token has expired', 401);
            }
            decoded = parsed;
          }
        } catch (_) {
          // Malformed token
        }

        if (!decoded) {
          return sendError(res, 'Invalid or expired authentication token', 401);
        }
      }
    }
  }

  if (!decoded || (!decoded.uid && !decoded.id)) {
    return sendError(res, 'Invalid authentication token payload', 401);
  }

  const uid = decoded.uid || decoded.id;

  // Resolve user profile and authorized role from database (never trust client-supplied role)
  try {
    let user = await userRepository.findById(uid);
    if (!user && decoded.email) {
      user = await userRepository.findByEmail(decoded.email);
    }

    if (!user) {
      // First-time Firebase user sync into user store
      // Default to BUSINESS_OWNER, strictly block ADMINISTRATOR from auto-assignment
      const initialRole = decoded.role === 'ADMINISTRATOR' ? 'BUSINESS_OWNER' : (decoded.role || 'BUSINESS_OWNER');
      user = await userRepository.create({
        uid,
        email: decoded.email || `${uid}@nirmaan.local`,
        displayName: decoded.name || decoded.displayName || 'Nirmaan User',
        role: initialRole,
        businessId: null,
        setupComplete: false,
      });
    }

    if (!user.isActive) {
      return sendError(res, 'User account is deactivated. Contact system governance.', 403);
    }

    req.user = {
      id: user.uid || user.id,
      uid: user.uid || user.id,
      email: user.email,
      name: user.displayName || user.name,
      displayName: user.displayName || user.name,
      role: user.role,
      businessId: user.businessId || null,
      setupComplete: Boolean(user.setupComplete),
    };

    return next();
  } catch (error) {
    return sendError(res, 'Failed to resolve user authorization', 500);
  }
}

module.exports = {
  authenticate,
};
