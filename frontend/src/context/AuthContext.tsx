import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { UserModel, BusinessModel, UserRole } from '@/models/user';
import {
  authService,
  RegisterPayload,
  BusinessSetupPayload,
  getFriendlyAuthErrorMessage,
} from '@/services/authService';

interface AuthContextType {
  user: UserModel | null;
  business: BusinessModel | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  role: UserRole;
  error: string | null;
  login: (email: string, password: string) => Promise<UserModel>;
  register: (payload: RegisterPayload) => Promise<UserModel>;
  logout: () => Promise<void>;
  completeBusinessSetup: (payload: BusinessSetupPayload) => Promise<BusinessModel>;
  sendPasswordReset: (email: string) => Promise<void>;
  clearError: () => void;
  setRole: (role: UserRole) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserModel | null>(null);
  const [business, setBusiness] = useState<BusinessModel | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Initialize and maintain persistent authenticated session
  useEffect(() => {
    const unsubscribe = authService.onAuthStateChanged(async (fbUser) => {
      try {
        if (fbUser) {
          // User is authenticated in Firebase
          const profile = await authService.getUserProfile(fbUser.uid);
          if (profile) {
            setUser(profile);
            localStorage.setItem('nirmaan_auth_user', JSON.stringify(profile));
            if (profile.businessId) {
              const biz = await authService.getBusinessProfile(profile.businessId);
              setBusiness(biz);
              if (biz) {
                localStorage.setItem('nirmaan_auth_business', JSON.stringify(biz));
              }
            }
          } else {
            // First time login profile fallback
            const fallbackProfile: UserModel = {
              uid: fbUser.uid,
              id: fbUser.uid,
              email: fbUser.email || '',
              displayName: fbUser.displayName || fbUser.email?.split('@')[0] || 'Nirmaan User',
              role: 'BUSINESS_OWNER',
              businessId: null,
              setupComplete: false,
            };
            setUser(fallbackProfile);
            localStorage.setItem('nirmaan_auth_user', JSON.stringify(fallbackProfile));
          }
          setIsAuthenticated(true);
        } else {
          // Firebase reports no authenticated user.
          // In test environment only (Vitest), allow seeded local storage for isolated component tests.
          const isTestEnv = import.meta.env.MODE === 'test';
          const savedSession = localStorage.getItem('nirmaan_auth_user');
          const savedBiz = localStorage.getItem('nirmaan_auth_business');

          if (isTestEnv && savedSession) {
            try {
              const parsedUser = JSON.parse(savedSession) as UserModel;
              setUser(parsedUser);
              setIsAuthenticated(true);
              if (savedBiz) {
                setBusiness(JSON.parse(savedBiz) as BusinessModel);
              }
            } catch {
              localStorage.removeItem('nirmaan_auth_user');
              localStorage.removeItem('nirmaan_auth_business');
              setUser(null);
              setBusiness(null);
              setIsAuthenticated(false);
            }
          } else {
            // In browser runtime, strictly clear local cache and enforce unauthenticated state
            localStorage.removeItem('nirmaan_auth_user');
            localStorage.removeItem('nirmaan_auth_business');
            setUser(null);
            setBusiness(null);
            setIsAuthenticated(false);
          }
        }
      } catch (err) {
        console.error('[AuthContext] Session restoration error:', err);
        setUser(null);
        setIsAuthenticated(false);
      } finally {
        setIsLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const login = useCallback(async (email: string, password: string): Promise<UserModel> => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await authService.login(email, password);
      setUser(result.user);
      setBusiness(result.business);
      setIsAuthenticated(true);
      localStorage.setItem('nirmaan_auth_user', JSON.stringify(result.user));
      if (result.business) {
        localStorage.setItem('nirmaan_auth_business', JSON.stringify(result.business));
      }
      return result.user;
    } catch (err: unknown) {
      const friendlyMsg = getFriendlyAuthErrorMessage(err);
      setError(friendlyMsg);
      throw new Error(friendlyMsg);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const register = useCallback(async (payload: RegisterPayload): Promise<UserModel> => {
    setIsLoading(true);
    setError(null);

    // Client-side guard against admin escalation
    if (payload.role === 'ADMINISTRATOR') {
      const msg = 'Administrator accounts cannot be created via public registration.';
      setError(msg);
      setIsLoading(false);
      throw new Error(msg);
    }

    try {
      const result = await authService.register(payload);
      setUser(result.user);
      setBusiness(result.business);
      setIsAuthenticated(true);
      localStorage.setItem('nirmaan_auth_user', JSON.stringify(result.user));
      if (result.business) {
        localStorage.setItem('nirmaan_auth_business', JSON.stringify(result.business));
      }
      return result.user;
    } catch (err: unknown) {
      const friendlyMsg = getFriendlyAuthErrorMessage(err);
      setError(friendlyMsg);
      throw new Error(friendlyMsg);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const logout = useCallback(async (): Promise<void> => {
    setIsLoading(true);
    try {
      await authService.logout();
    } catch (err) {
      console.warn('[AuthContext] Firebase signOut warning:', err);
    } finally {
      setUser(null);
      setBusiness(null);
      setIsAuthenticated(false);
      setError(null);
      localStorage.removeItem('nirmaan_auth_user');
      localStorage.removeItem('nirmaan_auth_business');
      setIsLoading(false);
    }
  }, []);

  const completeBusinessSetup = useCallback(
    async (payload: BusinessSetupPayload): Promise<BusinessModel> => {
      if (!user) {
        throw new Error('Authentication required to complete business setup.');
      }
      setIsLoading(true);
      setError(null);
      try {
        const result = await authService.completeBusinessSetup(user, payload);
        setUser(result.user);
        setBusiness(result.business);
        localStorage.setItem('nirmaan_auth_user', JSON.stringify(result.user));
        localStorage.setItem('nirmaan_auth_business', JSON.stringify(result.business));
        return result.business;
      } catch (err: unknown) {
        const friendlyMsg = getFriendlyAuthErrorMessage(err);
        setError(friendlyMsg);
        throw new Error(friendlyMsg);
      } finally {
        setIsLoading(false);
      }
    },
    [user]
  );

  const sendPasswordReset = useCallback(async (email: string): Promise<void> => {
    setIsLoading(true);
    setError(null);
    try {
      await authService.sendPasswordReset(email);
    } catch (err: unknown) {
      const friendlyMsg = getFriendlyAuthErrorMessage(err);
      setError(friendlyMsg);
      throw new Error(friendlyMsg);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const setRole = useCallback(
    (newRole: UserRole) => {
      if (user) {
        const updated = { ...user, role: newRole };
        setUser(updated);
        localStorage.setItem('nirmaan_auth_user', JSON.stringify(updated));
      }
    },
    [user]
  );

  return (
    <AuthContext.Provider
      value={{
        user,
        business,
        isAuthenticated,
        isLoading,
        role: user?.role || 'BUSINESS_OWNER',
        error,
        login,
        register,
        logout,
        completeBusinessSetup,
        sendPasswordReset,
        clearError,
        setRole,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
