const authService = require('../services/authService');
const seedService = require('../services/seedService');
const { sendSuccess, sendError } = require('../utils/responseFormatter');
const { recordAuditEvent } = require('../utils/auditLogger');
const config = require('../config/environment');

class AuthController {
  async register(req, res, next) {
    if (config.env === 'production') {
      return sendError(
        res,
        'Direct registration on the backend is disabled in production. Authenticate via Firebase Authentication.',
        403
      );
    }

    try {
      const { name, email, password, role, phone, businessName } = req.body;

      const result = await authService.register({
        name,
        email,
        password,
        role,
        phone,
        businessName,
      });

      recordAuditEvent({
        userId: result.user.uid || result.user.id,
        action: 'USER_REGISTER',
        resource: '/api/v1/auth/register',
        details: { email: result.user.email, role: result.user.role },
        ip: req.ip,
        status: 'SUCCESS',
      });

      return sendSuccess(res, result, 'User registered successfully', 201);
    } catch (error) {
      if (error.statusCode) {
        recordAuditEvent({
          userId: req.body.email || 'anonymous',
          action: 'USER_REGISTER_FAILED',
          resource: '/api/v1/auth/register',
          details: { error: error.message },
          ip: req.ip,
          status: 'FAILED',
        });
        return sendError(res, error.message, error.statusCode);
      }
      next(error);
    }
  }

  async login(req, res, next) {
    if (config.env === 'production') {
      return sendError(
        res,
        'Direct login on the backend is disabled in production. Authenticate via Firebase Authentication.',
        403
      );
    }

    try {
      const { email, password, role } = req.body;

      const result = await authService.login({
        email,
        password,
        role,
      });

      recordAuditEvent({
        userId: result.user.uid || result.user.id,
        action: 'USER_LOGIN',
        resource: '/api/v1/auth/login',
        details: { email: result.user.email, role: result.user.role },
        ip: req.ip,
        status: 'SUCCESS',
      });

      return sendSuccess(res, result, 'Login successful');
    } catch (error) {
      if (error.statusCode) {
        recordAuditEvent({
          userId: req.body.email || 'anonymous',
          action: 'USER_LOGIN_FAILED',
          resource: '/api/v1/auth/login',
          details: { error: error.message },
          ip: req.ip,
          status: 'FAILED',
        });
        return sendError(res, error.message, error.statusCode);
      }
      next(error);
    }
  }

  async forgotPassword(req, res, next) {
    if (config.env === 'production') {
      return sendError(
        res,
        'Password reset is managed via Firebase Authentication on the client.',
        403
      );
    }

    try {
      const { email } = req.body;
      const result = await authService.requestPasswordReset(email);

      recordAuditEvent({
        userId: email,
        action: 'PASSWORD_RESET_REQUESTED',
        resource: '/api/v1/auth/forgot-password',
        details: { email },
        ip: req.ip,
        status: 'SUCCESS',
      });

      return sendSuccess(res, result, result.message);
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode);
      }
      next(error);
    }
  }

  async logout(req, res, next) {
    try {
      const user = req.user;

      recordAuditEvent({
        userId: user ? user.uid || user.id : 'anonymous',
        action: 'USER_LOGOUT',
        resource: '/api/v1/auth/logout',
        details: { email: user?.email },
        ip: req.ip,
        status: 'SUCCESS',
      });

      return sendSuccess(res, { loggedOut: true }, 'Successfully logged out');
    } catch (error) {
      next(error);
    }
  }

  async getProfile(req, res, next) {
    try {
      const userId = req.user.uid || req.user.id;
      const data = await authService.getUserProfile(userId);
      return sendSuccess(res, data, 'Current user profile');
    } catch (error) {
      if (req.user) {
        return sendSuccess(res, { user: req.user, business: null }, 'Current user profile');
      }
      next(error);
    }
  }

  async completeBusinessSetup(req, res, next) {
    try {
      const userId = req.user.uid || req.user.id;
      // Security Rule: Strip any client-supplied identity, role, or owner fields
      const {
        userId: _spoofedUid,
        role: _spoofedRole,
        ownerId: _spoofedOwnerId,
        uid: _spoofedUid2,
        id: _spoofedId,
        ...sanitizedSetupData
      } = req.body;

      const result = await authService.completeBusinessSetup(userId, sanitizedSetupData);

      // Seed initial realistic products and customers for the business
      try {
        await seedService.seedTenant(result.business.businessId, userId, sanitizedSetupData);
      } catch (seedErr) {
        // Non-blocking in production
      }

      recordAuditEvent({
        userId,
        action: 'BUSINESS_SETUP_COMPLETED',
        resource: '/api/v1/auth/business-setup',
        details: { businessId: result.business.businessId },
        ip: req.ip,
        status: 'SUCCESS',
      });

      return sendSuccess(res, result, 'Business setup completed successfully');
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode);
      }
      next(error);
    }
  }

  async seedDemo(req, res, next) {
    if (config.env === 'production') {
      return sendError(
        res,
        'Demo data seeding is disabled in production environments for operational integrity.',
        403
      );
    }
    try {
      const businessId = req.businessId || req.user?.businessId || 'biz_nirmaan_demo';
      const userId = req.user?.uid || req.user?.id || 'usr_business_owner';
      const result = await seedService.seedTenant(businessId, userId);
      return sendSuccess(res, result, 'Demo business data seeded successfully');
    } catch (error) {
      next(error);
    }
  }

  async getBusiness(req, res, next) {
    try {
      const userId = req.user.uid || req.user.id;
      const business = await authService.getBusinessProfile(userId);
      return sendSuccess(res, { business }, 'Business details retrieved');
    } catch (error) {
      if (error.statusCode) {
        return sendError(res, error.message, error.statusCode);
      }
      next(error);
    }
  }
}

module.exports = new AuthController();
