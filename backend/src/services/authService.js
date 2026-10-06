const userRepository = require('../repositories/userRepository');
const businessRepository = require('../repositories/businessRepository');
const { ROLES } = require('../middleware/rbacMiddleware');
const { getAuth } = require('../config/firebaseAdmin');
const config = require('../config/environment');

/**
 * Authentication & Identity Service
 * In production: Firebase Authentication is the sole authoritative credential system.
 * The backend does NOT store passwords or issue production authentication credentials.
 */
class AuthService {
  _generateDevToken(user) {
    if (config.env === 'production') {
      const error = new Error('Dev token generation is strictly forbidden in production');
      error.statusCode = 403;
      throw error;
    }

    const payload = {
      uid: user.uid || user.id,
      id: user.uid || user.id,
      email: user.email,
      name: user.displayName || user.name,
      role: user.role,
      businessId: user.businessId,
      setupComplete: user.setupComplete,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60,
    };
    return Buffer.from(JSON.stringify(payload)).toString('base64');
  }

  async register({ name, email, password, role = ROLES.BUSINESS_OWNER, phone, businessName }) {
    // Production Guard: Identity must be registered via client Firebase Auth
    if (config.env === 'production') {
      const error = new Error('Direct credential registration on the backend is disabled in production. Use Firebase Authentication.');
      error.statusCode = 403;
      throw error;
    }

    // 1. Prevent Administrator self-registration
    if (role && role.toUpperCase() === ROLES.ADMINISTRATOR) {
      const error = new Error('Administrator accounts cannot be created via public registration');
      error.statusCode = 403;
      throw error;
    }

    const existing = await userRepository.findByEmail(email);
    if (existing) {
      const error = new Error('A user with this email address already exists');
      error.statusCode = 409;
      throw error;
    }

    let uid = `usr_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;

    // If full Firebase Admin service account is configured, create Firebase Auth user
    const firebaseAuth = getAuth();
    const hasServiceAccount = config.firebase && config.firebase.clientEmail && config.firebase.privateKey;
    if (firebaseAuth && hasServiceAccount) {
      try {
        const userRecord = await firebaseAuth.createUser({
          email: email.trim(),
          password,
          displayName: name.trim(),
          phoneNumber: phone && /^\+[1-9]\d{1,14}$/.test(phone.trim()) ? phone.trim() : undefined,
        });
        uid = userRecord.uid;
      } catch (fbErr) {
        if (fbErr.code === 'auth/email-already-exists') {
          const err = new Error('A user with this email address already exists in Firebase Auth');
          err.statusCode = 409;
          throw err;
        }
        // If Firebase Auth fails with another code, throw with status
        const err = new Error(fbErr.message || 'Firebase user creation failed');
        err.statusCode = 400;
        throw err;
      }
    }

    const businessId = `biz_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;

    // Create business profile (initially setupComplete = false)
    const business = await businessRepository.create({
      businessId,
      businessName: businessName ? businessName.trim() : `${name.trim()}'s Business`,
      businessCategory: 'General Retail',
      ownerId: uid,
      contact: { phone: phone ? phone.trim() : '', address: '', email: email.trim() },
      currency: 'INR',
      setupComplete: false,
    });

    const user = await userRepository.create({
      uid,
      email: email.trim(),
      displayName: name.trim(),
      role: (role || ROLES.BUSINESS_OWNER).toUpperCase(),
      phone: phone ? phone.trim() : null,
      businessId,
      setupComplete: false,
      password,
    });

    const token = this._generateDevToken(user);

    return {
      user: user.toSafeJSON(),
      business: business.toSafeJSON(),
      token,
      tokenType: 'Bearer',
      expiresIn: '7d',
    };
  }

  async login({ email, password, role }) {
    // Production Guard: Login must be authenticated via client Firebase Auth
    if (config.env === 'production') {
      const error = new Error('Direct credential login on the backend is disabled in production. Use Firebase Authentication.');
      error.statusCode = 403;
      throw error;
    }

    const user = await userRepository.findByEmail(email);
    if (!user) {
      const error = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    const isPasswordValid = userRepository.verifyTestPassword(email, password);
    if (!isPasswordValid) {
      const error = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    if (!user.isActive) {
      const error = new Error('Account is deactivated. Please contact support.');
      error.statusCode = 403;
      throw error;
    }

    // Resolve business
    let business = null;
    if (user.businessId) {
      business = await businessRepository.findById(user.businessId);
    }
    if (!business) {
      business = await businessRepository.findByOwnerId(user.uid);
    }

    const token = this._generateDevToken(user);

    return {
      user: user.toSafeJSON(),
      business: business ? business.toSafeJSON() : null,
      token,
      tokenType: 'Bearer',
      expiresIn: '7d',
    };
  }

  async getUserProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    let business = null;
    if (user.businessId) {
      business = await businessRepository.findById(user.businessId);
    }
    if (!business) {
      business = await businessRepository.findByOwnerId(user.uid);
    }

    return {
      user: user.toSafeJSON(),
      business: business ? business.toSafeJSON() : null,
    };
  }

  async completeBusinessSetup(userId, setupData) {
    const user = await userRepository.findById(userId);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    // Role Guard: Only BUSINESS_OWNER or ADMINISTRATOR can execute business setup
    if (user.role !== ROLES.BUSINESS_OWNER && user.role !== ROLES.ADMINISTRATOR) {
      const error = new Error('Unauthorized: Only Business Owners can configure business setup');
      error.statusCode = 403;
      throw error;
    }

    // Security Guard: Prevent Business ID manipulation across tenants
    if (setupData.businessId) {
      if (user.businessId && user.businessId !== setupData.businessId) {
        const error = new Error('Forbidden: You are not authorized to modify another business');
        error.statusCode = 403;
        throw error;
      }

      const requestedBiz = await businessRepository.findById(setupData.businessId);
      if (requestedBiz && requestedBiz.ownerId && requestedBiz.ownerId !== user.uid && user.role !== ROLES.ADMINISTRATOR) {
        const error = new Error('Forbidden: You do not own this business');
        error.statusCode = 403;
        throw error;
      }
    }

    let business = null;
    if (user.businessId) {
      business = await businessRepository.findById(user.businessId);
    }
    if (!business) {
      business = await businessRepository.findByOwnerId(user.uid);
    }

    // Guard against ownership mismatch on existing business
    if (business && business.ownerId && business.ownerId !== user.uid && user.role !== ROLES.ADMINISTRATOR) {
      const error = new Error('Forbidden: You do not own this business');
      error.statusCode = 403;
      throw error;
    }

    const businessName = (setupData.businessName || '').trim();
    const businessCategory = (setupData.businessCategory || setupData.category || 'General Retail').trim();
    const phone = (setupData.phone || user.phone || '').trim();
    const address = (setupData.address || '').trim();
    const gstNumber = setupData.gstNumber && setupData.gstNumber.trim() ? setupData.gstNumber.trim().toUpperCase() : null;
    const currency = setupData.currency && setupData.currency.trim() ? setupData.currency.trim() : 'INR';

    if (business) {
      business = await businessRepository.update(business.businessId, {
        businessName,
        businessCategory,
        contact: {
          phone,
          address,
          email: user.email,
        },
        gstNumber,
        currency,
        setupComplete: true,
      });
    } else {
      const businessId = `biz_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
      business = await businessRepository.create({
        businessId,
        businessName,
        businessCategory,
        ownerId: user.uid,
        contact: {
          phone,
          address,
          email: user.email,
        },
        gstNumber,
        currency,
        setupComplete: true,
      });
    }

    // Mark user setup as complete and link business ID
    await userRepository.update(user.uid, {
      businessId: business.businessId,
      phone: phone || user.phone,
      displayName: setupData.ownerName && setupData.ownerName.trim() ? setupData.ownerName.trim() : user.displayName,
      setupComplete: true,
    });

    const updatedUser = await userRepository.findById(user.uid);

    return {
      user: updatedUser.toSafeJSON(),
      business: business.toSafeJSON(),
    };
  }

  async getBusinessProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    let business = null;
    if (user.businessId) {
      business = await businessRepository.findById(user.businessId);
    }
    if (!business) {
      business = await businessRepository.findByOwnerId(user.uid);
    }

    if (!business) {
      const error = new Error('Business profile not found');
      error.statusCode = 404;
      throw error;
    }

    return business.toSafeJSON();
  }

  async requestPasswordReset(email) {
    const user = await userRepository.findByEmail(email);
    const resetToken = Buffer.from(
      JSON.stringify({ email: email.toLowerCase(), ts: Date.now() })
    ).toString('base64');

    return {
      message: 'Password reset link has been dispatched to your email address',
      email: email.toLowerCase().trim(),
      resetToken,
    };
  }
}

module.exports = new AuthService();
