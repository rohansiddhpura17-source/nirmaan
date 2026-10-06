import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  sendPasswordResetEmail,
  updateProfile,
  onAuthStateChanged as firebaseOnAuthStateChanged,
  User as FirebaseUser,
} from 'firebase/auth';
import {
  doc,
  getDoc,
  setDoc,
} from 'firebase/firestore';
import { auth, db, isFirebaseConfigured } from '@/config/firebase';
import { UserModel, BusinessModel, UserRole } from '@/models/user';
import { apiClient } from './apiClient';

export interface RegisterPayload {
  name: string;
  email: string;
  password: string;
  role?: UserRole;
  phone?: string;
  businessName?: string;
}

export interface BusinessSetupPayload {
  businessName: string;
  businessCategory: string;
  ownerName?: string;
  phone: string;
  address: string;
  gstNumber?: string;
  currency?: string;
}

/**
 * Transforms Firebase error codes into user-friendly messages
 */
export function getFriendlyAuthErrorMessage(error: unknown): string {
  if (!error || typeof error !== 'object') {
    return 'An unexpected error occurred during authentication.';
  }

  const err = error as { code?: string; message?: string };
  switch (err.code) {
    case 'auth/user-not-found':
      return 'No account found with this email address.';
    case 'auth/wrong-password':
    case 'auth/invalid-credential':
      return 'Incorrect email or password. Please verify your credentials.';
    case 'auth/email-already-in-use':
      return 'An account with this email address already exists. Please sign in.';
    case 'auth/weak-password':
      return 'Password should be at least 6 characters.';
    case 'auth/invalid-email':
      return 'Please enter a valid email address.';
    case 'auth/network-request-failed':
      return 'Network connection failure. Please verify your connection.';
    case 'auth/too-many-requests':
      return 'Access temporarily disabled due to multiple failed login attempts. Try again later.';
    default:
      return err.message || 'Authentication request failed.';
  }
}

class AuthService {
  /**
   * Listen to Firebase Auth state changes
   */
  onAuthStateChanged(callback: (user: FirebaseUser | null) => void) {
    return firebaseOnAuthStateChanged(auth, callback);
  }

  /**
   * Retrieves current Firebase auth user
   */
  getCurrentFirebaseUser(): FirebaseUser | null {
    return auth.currentUser;
  }

  /**
   * Retrieves current Firebase ID token for backend Authorization header
   */
  async getIdToken(): Promise<string | null> {
    if (!auth.currentUser) return null;
    return auth.currentUser.getIdToken(true);
  }

  /**
   * Sign In with Email and Password
   */
  async login(email: string, password: string): Promise<{ user: UserModel; business: BusinessModel | null }> {
    const credential = await signInWithEmailAndPassword(auth, email.trim(), password);
    const fbUser = credential.user;

    const profile = await this.getUserProfile(fbUser.uid);
    if (!profile) {
      // Fallback: create default profile if not found in Firestore
      const defaultUser: UserModel = {
        uid: fbUser.uid,
        email: fbUser.email || email,
        displayName: fbUser.displayName || email.split('@')[0],
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      };
      await this.saveUserProfile(defaultUser);
      return { user: defaultUser, business: null };
    }

    let business: BusinessModel | null = null;
    if (profile.businessId) {
      business = await this.getBusinessProfile(profile.businessId);
    }

    return { user: profile, business };
  }

  /**
   * Register a new user
   * SECURITY RULE: Administrator role cannot be assigned via public registration
   */
  async register(payload: RegisterPayload): Promise<{ user: UserModel; business: BusinessModel | null }> {
    if (payload.role === 'ADMINISTRATOR') {
      throw new Error('Administrator accounts cannot be created via public registration.');
    }

    const assignedRole: UserRole = payload.role || 'BUSINESS_OWNER';

    const credential = await createUserWithEmailAndPassword(auth, payload.email.trim(), payload.password);
    const fbUser = credential.user;

    // Update Firebase display name
    await updateProfile(fbUser, {
      displayName: payload.name.trim(),
    });

    const businessId = `biz_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;

    // Initial business model (setupComplete: false until BusinessSetup is submitted)
    const initialBusiness: BusinessModel = {
      businessId,
      businessName: payload.businessName ? payload.businessName.trim() : `${payload.name.trim()}'s Business`,
      businessCategory: 'General Retail',
      ownerId: fbUser.uid,
      contact: {
        phone: payload.phone ? payload.phone.trim() : '',
        address: '',
        email: payload.email.trim(),
      },
      currency: 'INR',
      setupComplete: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const newUser: UserModel = {
      uid: fbUser.uid,
      id: fbUser.uid,
      email: payload.email.trim(),
      displayName: payload.name.trim(),
      role: assignedRole,
      phone: payload.phone ? payload.phone.trim() : undefined,
      businessId,
      setupComplete: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    // Save user & initial business to Firestore
    try {
      await this.saveUserProfile(newUser);
      await this.saveBusinessProfile(initialBusiness);
    } catch (dbErr) {
      console.warn('[AuthService] Firestore document persistence notice:', dbErr);
    }

    return { user: newUser, business: initialBusiness };
  }

  /**
   * Send Password Reset instructions
   */
  async sendPasswordReset(email: string): Promise<void> {
    await sendPasswordResetEmail(auth, email.trim());
  }

  /**
   * Sign out current user
   */
  async logout(): Promise<void> {
    await signOut(auth);
  }

  /**
   * Fetch User Profile from Firestore
   */
  async getUserProfile(uid: string): Promise<UserModel | null> {
    try {
      const userDocRef = doc(db, 'users', uid);
      const snap = await getDoc(userDocRef);
      if (snap.exists()) {
        const data = snap.data();
        return {
          uid: snap.id,
          id: snap.id,
          email: data.email || '',
          displayName: data.displayName || 'Nirmaan User',
          role: (data.role || 'BUSINESS_OWNER') as UserRole,
          businessId: data.businessId || null,
          phone: data.phone,
          setupComplete: Boolean(data.setupComplete),
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      }
    } catch (err) {
      console.warn('[AuthService] Could not fetch user doc from Firestore:', err);
    }
    return null;
  }

  /**
   * Save or Update User Profile in Firestore
   */
  async saveUserProfile(user: UserModel): Promise<void> {
    const userDocRef = doc(db, 'users', user.uid);
    await setDoc(
      userDocRef,
      {
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        businessId: user.businessId,
        phone: user.phone || null,
        setupComplete: user.setupComplete,
        updatedAt: new Date().toISOString(),
      },
      { merge: true }
    );
  }

  /**
   * Fetch Business Profile from Firestore
   */
  async getBusinessProfile(businessId: string): Promise<BusinessModel | null> {
    try {
      const bizDocRef = doc(db, 'businesses', businessId);
      const snap = await getDoc(bizDocRef);
      if (snap.exists()) {
        const data = snap.data();
        return {
          businessId: snap.id,
          businessName: data.businessName || '',
          businessCategory: data.businessCategory || 'General Retail',
          ownerId: data.ownerId || '',
          contact: data.contact || { phone: '', address: '', email: '' },
          gstNumber: data.gstNumber || null,
          currency: data.currency || 'INR',
          setupComplete: Boolean(data.setupComplete),
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      }
    } catch (err) {
      console.warn('[AuthService] Could not fetch business doc from Firestore:', err);
    }
    return null;
  }

  /**
   * Save or Update Business Profile in Firestore
   */
  async saveBusinessProfile(business: BusinessModel): Promise<void> {
    const bizDocRef = doc(db, 'businesses', business.businessId);
    await setDoc(bizDocRef, { ...business, updatedAt: new Date().toISOString() }, { merge: true });
  }

  /**
   * Complete Business Setup:
   * Architecture: All Business Setup mutations strictly pass through the protected backend API.
   * Direct Firestore client mutations and offline mutation fallbacks are strictly prohibited.
   */
  async completeBusinessSetup(
    user: UserModel,
    payload: BusinessSetupPayload
  ): Promise<{ user: UserModel; business: BusinessModel }> {
    const response = await apiClient.post<{ user: UserModel; business: BusinessModel }>(
      '/auth/business-setup',
      {
        businessName: payload.businessName.trim(),
        businessCategory: payload.businessCategory,
        ownerName: payload.ownerName?.trim(),
        phone: payload.phone.trim(),
        address: payload.address.trim(),
        gstNumber: payload.gstNumber?.trim() || undefined,
        currency: payload.currency || 'INR',
      }
    );

    if (!response.success || !response.data) {
      throw new Error(response.error || 'Unable to save business setup. Backend service is currently unavailable.');
    }

    return response.data;
  }
}

export const authService = new AuthService();
export { isFirebaseConfigured };
