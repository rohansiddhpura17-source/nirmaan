import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider, useAuth } from '@/context/AuthContext';
import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { RoleGuard } from '@/components/auth/RoleGuard';
import { getFriendlyAuthErrorMessage, authService } from '@/services/authService';
import { apiClient } from '@/services/apiClient';

// Helper component that exposes auth context for testing
const AuthTestConsumer: React.FC = () => {
  const {
    user,
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
      <div data-testid="auth-status">{isAuthenticated ? 'AUTHENTICATED' : 'ANONYMOUS'}</div>
      <div data-testid="user-email">{user?.email || 'NONE'}</div>
      <div data-testid="user-role">{role}</div>
      <div data-testid="setup-status">{user?.setupComplete ? 'COMPLETE' : 'INCOMPLETE'}</div>
      {error && <div data-testid="auth-error">{error}</div>}

      <button data-testid="btn-login" onClick={() => login('owner@nirmaan.com', 'Password@123')}>
        Login
      </button>
      <button
        data-testid="btn-login-incomplete"
        onClick={() => {
          // Simulate login for new user with incomplete setup
          localStorage.setItem(
            'nirmaan_auth_user',
            JSON.stringify({
              uid: 'usr_new',
              email: 'newowner@store.com',
              displayName: 'New Owner',
              role: 'BUSINESS_OWNER',
              businessId: null,
              setupComplete: false,
            })
          );
          window.location.reload();
        }}
      >
        Login Incomplete
      </button>
      <button data-testid="btn-logout" onClick={() => logout()}>
        Logout
      </button>
      <button
        data-testid="btn-register"
        onClick={() =>
          register({
            name: 'Pooja Shah',
            email: 'pooja@store.com',
            password: 'Password@123',
            role: 'BUSINESS_OWNER',
          })
        }
      >
        Register
      </button>
      <button
        data-testid="btn-register-admin"
        onClick={() =>
          register({
            name: 'Hacker Admin',
            email: 'hacker@store.com',
            password: 'Password@123',
            role: 'ADMINISTRATOR',
          }).catch(() => {})
        }
      >
        Register Admin
      </button>
      <button
        data-testid="btn-setup"
        onClick={() =>
          completeBusinessSetup({
            businessName: 'Shah Provisions',
            businessCategory: 'Groceries & Kirana',
            phone: '+91 98765 00000',
            address: 'Market Yard, Shop 5',
          })
        }
      >
        Complete Setup
      </button>
      <button data-testid="btn-reset" onClick={() => sendPasswordReset('test@nirmaan.com')}>
        Reset Password
      </button>
    </div>
  );
};

describe('Nirmaan Authentication & RBAC Suite (Phase 2)', () => {
  beforeEach(() => {
    localStorage.clear();
    vi.restoreAllMocks();
  });

  // 1. Unauthenticated user redirected to login
  it('1. unauthenticated user redirected to login when accessing protected route', async () => {
    render(
      <MemoryRouter initialEntries={['/dashboard']}>
        <AuthProvider>
          <Routes>
            <Route path="/login" element={<div data-testid="login-view">Login Screen</div>} />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <div data-testid="dashboard-view">Dashboard Screen</div>
                </ProtectedRoute>
              }
            />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('login-view')).toBeDefined();
      expect(screen.queryByTestId('dashboard-view')).toBeNull();
    });
  });

  // 2. Authenticated user reaches dashboard
  it('2. authenticated user reaches dashboard successfully', async () => {
    // Seed authenticated session in localStorage
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_owner',
        email: 'owner@nirmaan.com',
        displayName: 'Rohan Owner',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_01',
        setupComplete: true,
      })
    );

    render(
      <MemoryRouter initialEntries={['/dashboard']}>
        <AuthProvider>
          <Routes>
            <Route path="/login" element={<div data-testid="login-view">Login Screen</div>} />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <div data-testid="dashboard-view">Dashboard Screen</div>
                </ProtectedRoute>
              }
            />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
      expect(screen.queryByTestId('login-view')).toBeNull();
    });
  });

  // 3. Incomplete setup redirected to business setup
  it('3. incomplete setup redirected to business setup page', async () => {
    // User is authenticated, but setupComplete is false
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'new@store.com',
        displayName: 'New Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    render(
      <MemoryRouter initialEntries={['/dashboard']}>
        <AuthProvider>
          <Routes>
            <Route
              path="/business-setup"
              element={<div data-testid="setup-view">Business Setup Screen</div>}
            />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute requireSetup={true}>
                  <div data-testid="dashboard-view">Dashboard Screen</div>
                </ProtectedRoute>
              }
            />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('setup-view')).toBeDefined();
      expect(screen.queryByTestId('dashboard-view')).toBeNull();
    });
  });

  // 4. Completed setup reaches dashboard
  it('4. completed setup reaches dashboard and unlocks full access', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_owner',
        email: 'owner@nirmaan.com',
        displayName: 'Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_123',
        setupComplete: true,
      })
    );

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/dashboard" element={<div data-testid="dashboard-view">Dashboard Screen</div>} />
            <Route
              path="/business-setup"
              element={
                <ProtectedRoute requireSetup={false}>
                  <div data-testid="setup-view">Setup Screen</div>
                </ProtectedRoute>
              }
            />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    // Because setupComplete is true, visiting /business-setup redirects to /dashboard
    await waitFor(() => {
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
      expect(screen.queryByTestId('setup-view')).toBeNull();
    });
  });

  // 5. Logout clears authenticated state
  it('5. logout clears authenticated state and storage', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_owner',
        email: 'owner@nirmaan.com',
        displayName: 'Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_123',
        setupComplete: true,
      })
    );

    render(
      <MemoryRouter initialEntries={['/']}>
        <AuthProvider>
          <AuthTestConsumer />
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('auth-status').textContent).toBe('AUTHENTICATED');
    });

    const logoutBtn = screen.getByTestId('btn-logout');
    logoutBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('auth-status').textContent).toBe('ANONYMOUS');
      expect(localStorage.getItem('nirmaan_auth_user')).toBeNull();
    });
  });

  // 6. Login error handling
  it('6. login error handling maps Firebase errors correctly', () => {
    expect(getFriendlyAuthErrorMessage({ code: 'auth/wrong-password' })).toContain(
      'Incorrect email or password'
    );
    expect(getFriendlyAuthErrorMessage({ code: 'auth/user-not-found' })).toContain(
      'No account found with this email'
    );
    expect(getFriendlyAuthErrorMessage({ code: 'auth/invalid-credential' })).toContain(
      'Incorrect email or password'
    );
    expect(getFriendlyAuthErrorMessage({ code: 'auth/too-many-requests' })).toContain(
      'temporarily disabled'
    );
    expect(getFriendlyAuthErrorMessage({ code: 'auth/email-already-in-use' })).toContain(
      'already exists'
    );
  });

  // 7. Registration validation prevents Administrator creation
  it('7. registration validation blocks Administrator privilege escalation', async () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <AuthProvider>
          <AuthTestConsumer />
        </AuthProvider>
      </MemoryRouter>
    );

    const regAdminBtn = screen.getByTestId('btn-register-admin');
    regAdminBtn.click();

    await waitFor(() => {
      expect(screen.getByTestId('auth-error').textContent).toContain(
        'Administrator accounts cannot be created via public registration'
      );
    });
  });

  // 8. Forgot password flow
  it('8. forgot-password flow invokes reset service properly', async () => {
    const resetSpy = vi.spyOn(authService, 'sendPasswordReset').mockResolvedValue(undefined);

    render(
      <MemoryRouter initialEntries={['/']}>
        <AuthProvider>
          <AuthTestConsumer />
        </AuthProvider>
      </MemoryRouter>
    );

    const resetBtn = screen.getByTestId('btn-reset');
    resetBtn.click();

    await waitFor(() => {
      expect(resetSpy).toHaveBeenCalledWith('test@nirmaan.com');
    });
  });

  // 9. Unauthorized role blocked
  it('9. unauthorized role is blocked by RoleGuard', async () => {
    // Current user role is SALES_STAFF
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_staff',
        email: 'staff@nirmaan.com',
        displayName: 'Sales Staff Member',
        role: 'SALES_STAFF',
        businessId: 'biz_123',
        setupComplete: true,
      })
    );

    render(
      <MemoryRouter initialEntries={['/analytics']}>
        <AuthProvider>
          <Routes>
            <Route
              path="/analytics"
              element={
                <RoleGuard
                  allowedRoles={['BUSINESS_OWNER', 'ADMINISTRATOR']}
                  fallback={<div data-testid="access-denied">403 Forbidden</div>}
                >
                  <div data-testid="analytics-view">Owner Analytics</div>
                </RoleGuard>
              }
            />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('access-denied')).toBeDefined();
      expect(screen.queryByTestId('analytics-view')).toBeNull();
    });
  });

  // 10. Protected backend endpoint token handling
  it('10. apiClient attaches Bearer token to protected requests', async () => {
    const fetchSpy = vi.spyOn(global, 'fetch').mockResolvedValue(
      new Response(JSON.stringify({ success: true, data: { status: 'OK' } }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      })
    );

    apiClient.setToken('test-id-token-abc-123');
    const res = await apiClient.get('/auth/me');

    expect(res.success).toBe(true);
    expect(fetchSpy).toHaveBeenCalledWith(
      expect.stringContaining('/auth/me'),
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: 'Bearer test-id-token-abc-123',
        }),
      })
    );
  });
});
