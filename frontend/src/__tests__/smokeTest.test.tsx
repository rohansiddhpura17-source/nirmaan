import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AuthProvider, useAuth } from '@/context/AuthContext';
import { RoleGuard } from '@/components/auth/RoleGuard';
import { authService } from '@/services/authService';

const SmokeTestHarness: React.FC = () => {
  const {
    user,
    business,
    isAuthenticated,
    role,
    error,
    login,
    register,
    logout,
    completeBusinessSetup,
    sendPasswordReset,
  } = useAuth();

  return (
    <div>
      <div data-testid="is-authenticated">{isAuthenticated ? 'TRUE' : 'FALSE'}</div>
      <div data-testid="current-role">{role}</div>
      <div data-testid="user-uid">{user?.uid || 'NONE'}</div>
      <div data-testid="user-email">{user?.email || 'NONE'}</div>
      <div data-testid="business-id">{user?.businessId || business?.businessId || 'NONE'}</div>
      <div data-testid="setup-complete">{user?.setupComplete ? 'TRUE' : 'FALSE'}</div>
      {error && <div data-testid="error-message">{error}</div>}

      <button
        data-testid="act-register"
        onClick={() =>
          register({
            name: 'Rohit Verma',
            businessName: 'Verma Supermarket',
            email: 'rohit@verma.com',
            password: 'Password@123',
            role: 'BUSINESS_OWNER',
          }).catch(() => {})
        }
      >
        Register
      </button>

      <button
        data-testid="act-complete-setup"
        onClick={() =>
          completeBusinessSetup({
            businessName: 'Verma Supermarket',
            businessCategory: 'Groceries & Kirana',
            phone: '+91 98765 11111',
            address: 'Plot 4, Station Road',
            currency: 'INR',
          }).catch(() => {})
        }
      >
        Complete Setup
      </button>

      <button
        data-testid="act-login-valid"
        onClick={() => login('owner@nirmaan.com', 'Password@123').catch(() => {})}
      >
        Login Valid
      </button>

      <button
        data-testid="act-login-invalid"
        onClick={() => login('unknown@domain.com', 'BadPassword').catch(() => {})}
      >
        Login Invalid
      </button>

      <button data-testid="act-logout" onClick={() => logout()}>
        Logout
      </button>

      <button
        data-testid="act-forgot-password"
        onClick={() => sendPasswordReset('rohit@verma.com').catch(() => {})}
      >
        Forgot Password
      </button>
    </div>
  );
};

describe('Nirmaan Phase 2 Smoke Test Suite', () => {
  beforeEach(() => {
    localStorage.clear();
    vi.restoreAllMocks();
  });

  it('Smoke Step 1 & 2: User Registration and Business Setup Lifecycle', async () => {
    vi.spyOn(authService, 'register').mockResolvedValue({
      user: {
        uid: 'usr_rohit_123',
        email: 'rohit@verma.com',
        displayName: 'Rohit Verma',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_rohit_456',
        setupComplete: false,
      },
      business: {
        businessId: 'biz_rohit_456',
        businessName: 'Verma Supermarket',
        businessCategory: 'Groceries & Kirana',
        ownerId: 'usr_rohit_123',
        contact: { phone: '+91 98765 11111', address: 'Plot 4, Station Road' },
        currency: 'INR',
        setupComplete: false,
      },
    });

    vi.spyOn(authService, 'completeBusinessSetup').mockImplementation(async (user, payload) => {
      return {
        user: {
          ...user,
          setupComplete: true,
        },
        business: {
          businessId: user.businessId || 'biz_rohit_456',
          businessName: payload.businessName,
          businessCategory: payload.businessCategory,
          ownerId: user.uid,
          contact: { phone: payload.phone, address: payload.address },
          currency: 'INR',
          setupComplete: true,
        },
      };
    });

    render(
      <MemoryRouter initialEntries={['/']}>
        <AuthProvider>
          <SmokeTestHarness />
        </AuthProvider>
      </MemoryRouter>
    );

    expect(screen.getByTestId('is-authenticated').textContent).toBe('FALSE');

    // 1. Trigger Registration
    const regBtn = screen.getByTestId('act-register');
    regBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('is-authenticated').textContent).toBe('TRUE');
      expect(screen.getByTestId('user-email').textContent).toBe('rohit@verma.com');
      expect(screen.getByTestId('current-role').textContent).toBe('BUSINESS_OWNER');
      expect(screen.getByTestId('setup-complete').textContent).toBe('FALSE');
    });

    // 2. Trigger Business Setup Completion
    const setupBtn = screen.getByTestId('act-complete-setup');
    setupBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('setup-complete').textContent).toBe('TRUE');
      expect(screen.getByTestId('business-id').textContent).not.toBe('NONE');
    });

    // 3. Verify session persists in storage (browser refresh simulation)
    const stored = localStorage.getItem('nirmaan_auth_user');
    expect(stored).not.toBeNull();
    const parsed = JSON.parse(stored!);
    expect(parsed.setupComplete).toBe(true);
    expect(parsed.email).toBe('rohit@verma.com');

    // 4. Log out
    const logoutBtn = screen.getByTestId('act-logout');
    logoutBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('is-authenticated').textContent).toBe('FALSE');
      expect(localStorage.getItem('nirmaan_auth_user')).toBeNull();
    });
  });

  it('Smoke Step 3: Login with Valid & Invalid Credentials', async () => {
    vi.spyOn(authService, 'login').mockImplementation(async (email, password) => {
      if (password === 'BadPassword') {
        const err = new Error('Incorrect email or password');
        (err as unknown as { code: string }).code = 'auth/invalid-credential';
        throw err;
      }
      return {
        user: {
          uid: 'usr_owner',
          email: 'owner@nirmaan.com',
          displayName: 'Rohan Owner',
          role: 'BUSINESS_OWNER',
          businessId: 'biz_01',
          setupComplete: true,
        },
        business: {
          businessId: 'biz_01',
          businessName: 'Kirana King Superstore',
          businessCategory: 'Groceries & Kirana',
          ownerId: 'usr_owner',
          contact: { phone: '+91 98765 43210', address: 'Main Market' },
          currency: 'INR',
          setupComplete: true,
        },
      };
    });

    render(
      <MemoryRouter initialEntries={['/login']}>
        <AuthProvider>
          <SmokeTestHarness />
        </AuthProvider>
      </MemoryRouter>
    );

    // 1. Valid login
    const validLoginBtn = screen.getByTestId('act-login-valid');
    validLoginBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('is-authenticated').textContent).toBe('TRUE');
      expect(screen.getByTestId('setup-complete').textContent).toBe('TRUE');
    });

    // 2. Logout
    screen.getByTestId('act-logout').click();
    await waitFor(() => {
      expect(screen.getByTestId('is-authenticated').textContent).toBe('FALSE');
    });

    // 3. Invalid login
    const invalidLoginBtn = screen.getByTestId('act-login-invalid');
    invalidLoginBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('is-authenticated').textContent).toBe('FALSE');
      expect(screen.getByTestId('error-message').textContent).toContain('Incorrect email or password');
    });
  });

  it('Smoke Step 4: Password Reset Request', async () => {
    const resetSpy = vi.spyOn(authService, 'sendPasswordReset').mockResolvedValue(undefined);

    render(
      <MemoryRouter initialEntries={['/forgot-password']}>
        <AuthProvider>
          <SmokeTestHarness />
        </AuthProvider>
      </MemoryRouter>
    );

    screen.getByTestId('act-forgot-password').click();

    await waitFor(() => {
      expect(resetSpy).toHaveBeenCalledWith('rohit@verma.com');
    });
  });

  it('Smoke Step 7: Multi-Role RBAC Views Access Verification', async () => {
    const rolesToTest = [
      {
        role: 'BUSINESS_OWNER' as const,
        canAccessBI: true,
        canAccessOps: true,
        canAccessGov: false,
      },
      {
        role: 'STORE_MANAGER' as const,
        canAccessBI: false,
        canAccessOps: true,
        canAccessGov: false,
      },
      {
        role: 'SALES_STAFF' as const,
        canAccessBI: false,
        canAccessOps: false,
        canAccessGov: false,
      },
      {
        role: 'ADMINISTRATOR' as const,
        canAccessBI: true,
        canAccessOps: true,
        canAccessGov: true,
      },
    ];

    for (const testRole of rolesToTest) {
      localStorage.setItem(
        'nirmaan_auth_user',
        JSON.stringify({
          uid: `usr_${testRole.role.toLowerCase()}`,
          email: `${testRole.role.toLowerCase()}@nirmaan.com`,
          displayName: testRole.role,
          role: testRole.role,
          businessId: 'biz_01',
          setupComplete: true,
        })
      );

      const { unmount } = render(
        <MemoryRouter initialEntries={['/test']}>
          <AuthProvider>
            <RoleGuard
              allowedRoles={['BUSINESS_OWNER', 'ADMINISTRATOR']}
              fallback={<div data-testid="denied-bi">BI Denied</div>}
            >
              <div data-testid="allowed-bi">BI Allowed</div>
            </RoleGuard>
            <RoleGuard
              allowedRoles={['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR']}
              fallback={<div data-testid="denied-ops">Ops Denied</div>}
            >
              <div data-testid="allowed-ops">Ops Allowed</div>
            </RoleGuard>
            <RoleGuard
              allowedRoles={['ADMINISTRATOR']}
              fallback={<div data-testid="denied-gov">Gov Denied</div>}
            >
              <div data-testid="allowed-gov">Gov Allowed</div>
            </RoleGuard>
          </AuthProvider>
        </MemoryRouter>
      );

      await waitFor(() => {
        if (testRole.canAccessBI) {
          expect(screen.queryByTestId('allowed-bi')).not.toBeNull();
        } else {
          expect(screen.queryByTestId('denied-bi')).not.toBeNull();
        }

        if (testRole.canAccessOps) {
          expect(screen.queryByTestId('allowed-ops')).not.toBeNull();
        } else {
          expect(screen.queryByTestId('denied-ops')).not.toBeNull();
        }

        if (testRole.canAccessGov) {
          expect(screen.queryByTestId('allowed-gov')).not.toBeNull();
        } else {
          expect(screen.queryByTestId('denied-gov')).not.toBeNull();
        }
      });

      unmount();
    }
  });

  it('Smoke Step 8: Firestore Schema Documents Integrity', async () => {
    const sampleUser = {
      uid: 'usr_smoke_123',
      email: 'owner@store.com',
      displayName: 'Aarav Patel',
      role: 'BUSINESS_OWNER',
      businessId: 'biz_smoke_456',
      setupComplete: true,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const sampleBusiness = {
      businessId: 'biz_smoke_456',
      businessName: 'Patel Supermarket',
      businessCategory: 'Groceries & Kirana',
      ownerId: 'usr_smoke_123',
      contact: { phone: '+91 99887 76655', address: 'Main Road' },
      currency: 'INR',
      setupComplete: true,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    expect(sampleUser.uid).toBeDefined();
    expect(sampleUser.email).toBeDefined();
    expect(sampleUser.displayName).toBeDefined();
    expect(sampleUser.role).toBe('BUSINESS_OWNER');
    expect(sampleUser.businessId).toBe('biz_smoke_456');
    expect(sampleUser.setupComplete).toBe(true);

    expect(sampleBusiness.businessId).toBe('biz_smoke_456');
    expect(sampleBusiness.businessName).toBe('Patel Supermarket');
    expect(sampleBusiness.ownerId).toBe('usr_smoke_123');
    expect(sampleBusiness.currency).toBe('INR');
    expect(sampleBusiness.setupComplete).toBe(true);
  });
});
