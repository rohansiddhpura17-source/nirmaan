import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from '@/context/AuthContext';
import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { BusinessSetupPage } from '@/pages/BusinessSetupPage';
import { authService } from '@/services/authService';
import { apiClient } from '@/services/apiClient';
import { UserModel, BusinessModel } from '@/models/user';

type SetupResult = { user: UserModel; business: BusinessModel };

describe('Nirmaan Web — Phase 3: Business Setup Suite', () => {
  beforeEach(() => {
    localStorage.clear();
    sessionStorage.clear();
    vi.restoreAllMocks();
  });

  // 1. setupComplete=false routes to Business Setup
  it('1. setupComplete=false routes to Business Setup when trying to access dashboard', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
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

  // 2. setupComplete=true routes to Dashboard
  it('2. setupComplete=true routes to Dashboard and allows full access', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_existing_owner',
        email: 'owner@store.com',
        displayName: 'Existing Owner',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_existing_123',
        setupComplete: true,
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
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
      expect(screen.queryByTestId('setup-view')).toBeNull();
    });
  });

  // 3. Required fields validate correctly
  it('3. required fields validate correctly and show inline validation messages', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'New Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/business-setup" element={<BusinessSetupPage />} />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('input-business-name')).toBeDefined();
    });

    // Clear required fields to trigger validation
    fireEvent.change(screen.getByTestId('input-business-name'), { target: { value: '' } });
    fireEvent.change(screen.getByTestId('input-owner-name'), { target: { value: '' } });
    fireEvent.change(screen.getByTestId('input-store-phone'), { target: { value: '' } });
    fireEvent.change(screen.getByTestId('input-store-address'), { target: { value: '' } });

    // Click submit
    fireEvent.click(screen.getByTestId('btn-complete-setup'));

    await waitFor(() => {
      expect(screen.getByText('Business or store name is required')).toBeDefined();
      expect(screen.getByText('Owner / manager name is required')).toBeDefined();
      expect(screen.getByText('Store contact number is required')).toBeDefined();
      expect(screen.getByText('Store address and city are required')).toBeDefined();
    });
  });

  // 4. Submit shows loading state
  it('4. submit shows loading state while saving store profile', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'New Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    let resolveSetupPromise: (val: SetupResult) => void;
    const delayedPromise = new Promise<SetupResult>((resolve) => {
      resolveSetupPromise = resolve;
    });

    vi.spyOn(authService, 'completeBusinessSetup').mockReturnValue(delayedPromise);

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/business-setup" element={<BusinessSetupPage />} />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('input-business-name')).toBeDefined();
    });

    // Fill valid data
    fireEvent.change(screen.getByTestId('input-business-name'), { target: { value: 'Laxmi Supermarket' } });
    fireEvent.change(screen.getByTestId('input-owner-name'), { target: { value: 'Ramesh Patel' } });
    fireEvent.change(screen.getByTestId('input-store-phone'), { target: { value: '+91 98765 43210' } });
    fireEvent.change(screen.getByTestId('input-store-address'), { target: { value: 'Shop 12, Station Road' } });

    // Submit
    const submitBtn = screen.getByTestId('btn-complete-setup');
    fireEvent.click(submitBtn);

    // Verify loading state
    await waitFor(() => {
      expect(submitBtn.hasAttribute('disabled')).toBe(true);
      expect(submitBtn.textContent).toContain('Saving Store Profile');
    });

    // Cleanup promise
    resolveSetupPromise!({
      user: {
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'Ramesh Patel',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_laxmi_1',
        setupComplete: true,
      },
      business: {
        businessId: 'biz_laxmi_1',
        businessName: 'Laxmi Supermarket',
        businessCategory: 'Groceries & Kirana',
        ownerId: 'usr_new_owner',
        contact: { phone: '+91 98765 43210', address: 'Shop 12, Station Road' },
        currency: 'INR',
        setupComplete: true,
      },
    });
  });

  // 5. Successful setup updates auth/business state
  it('5. successful setup updates auth/business state and triggers transition', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'New Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    const setupSpy = vi.spyOn(authService, 'completeBusinessSetup').mockResolvedValue({
      user: {
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'Aarav Patel',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_aarav_999',
        setupComplete: true,
      },
      business: {
        businessId: 'biz_aarav_999',
        businessName: 'Aarav Provisions',
        businessCategory: 'Groceries & Kirana',
        ownerId: 'usr_new_owner',
        contact: { phone: '+91 98765 12345', address: 'Sector 5, Market Yard' },
        gstNumber: '24ABCDE1234F1Z5',
        currency: 'INR',
        setupComplete: true,
      },
    });

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/business-setup" element={<BusinessSetupPage />} />
            <Route path="/dashboard" element={<div data-testid="dashboard-view">Dashboard View</div>} />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('input-business-name')).toBeDefined();
    });

    fireEvent.change(screen.getByTestId('input-business-name'), { target: { value: 'Aarav Provisions' } });
    fireEvent.change(screen.getByTestId('input-owner-name'), { target: { value: 'Aarav Patel' } });
    fireEvent.change(screen.getByTestId('input-store-phone'), { target: { value: '+91 98765 12345' } });
    fireEvent.change(screen.getByTestId('input-store-address'), { target: { value: 'Sector 5, Market Yard' } });
    fireEvent.change(screen.getByTestId('input-gst-number'), { target: { value: '24ABCDE1234F1Z5' } });

    fireEvent.click(screen.getByTestId('btn-complete-setup'));

    await waitFor(() => {
      expect(setupSpy).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          businessName: 'Aarav Provisions',
          ownerName: 'Aarav Patel',
          phone: '+91 98765 12345',
          address: 'Sector 5, Market Yard',
          gstNumber: '24ABCDE1234F1Z5',
          currency: 'INR',
        })
      );
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
    });
  });

  // 6. Setup error is displayed
  it('6. setup error is displayed with retry button and form values preserved', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'New Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    vi.spyOn(authService, 'completeBusinessSetup').mockRejectedValue(
      new Error('Firestore cluster write timeout. Please try again.')
    );

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/business-setup" element={<BusinessSetupPage />} />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('input-business-name')).toBeDefined();
    });

    fireEvent.change(screen.getByTestId('input-business-name'), { target: { value: 'Error Test Store' } });
    fireEvent.change(screen.getByTestId('input-owner-name'), { target: { value: 'Error Owner' } });
    fireEvent.change(screen.getByTestId('input-store-phone'), { target: { value: '+91 98765 00000' } });
    fireEvent.change(screen.getByTestId('input-store-address'), { target: { value: 'Shop 1, Test Road' } });

    fireEvent.click(screen.getByTestId('btn-complete-setup'));

    await waitFor(() => {
      expect(screen.getByTestId('setup-error-banner')).toBeDefined();
      expect(screen.getByTestId('setup-error-message').textContent).toContain(
        'Firestore cluster write timeout'
      );
      // Verify inputs remain preserved
      expect((screen.getByTestId('input-business-name') as HTMLInputElement).value).toBe('Error Test Store');
      expect((screen.getByTestId('input-store-address') as HTMLInputElement).value).toBe('Shop 1, Test Road');
    });
  });

  // 7. Repeated submit is prevented
  it('7. repeated submit is prevented while submission is already in progress', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'New Store Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    let resolvePromise: (val: SetupResult) => void;
    const delayed = new Promise<SetupResult>((res) => {
      resolvePromise = res;
    });

    const setupSpy = vi.spyOn(authService, 'completeBusinessSetup').mockReturnValue(delayed);

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/business-setup" element={<BusinessSetupPage />} />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('input-business-name')).toBeDefined();
    });

    fireEvent.change(screen.getByTestId('input-business-name'), { target: { value: 'Single Click Store' } });
    fireEvent.change(screen.getByTestId('input-owner-name'), { target: { value: 'Single Owner' } });
    fireEvent.change(screen.getByTestId('input-store-phone'), { target: { value: '+91 98765 55555' } });
    fireEvent.change(screen.getByTestId('input-store-address'), { target: { value: 'Market Road, Sector 1' } });

    const btn = screen.getByTestId('btn-complete-setup');
    fireEvent.click(btn);
    // Attempt second and third clicks immediately
    fireEvent.click(btn);
    fireEvent.click(btn);

    // Spy should only have been called once
    expect(setupSpy).toHaveBeenCalledTimes(1);

    resolvePromise!({
      user: {
        uid: 'usr_new_owner',
        email: 'newowner@store.com',
        displayName: 'Single Owner',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_single',
        setupComplete: true,
      },
      business: {
        businessId: 'biz_single',
        businessName: 'Single Click Store',
        businessCategory: 'Groceries & Kirana',
        ownerId: 'usr_new_owner',
        contact: { phone: '+91 98765 55555', address: 'Market Road' },
        currency: 'INR',
        setupComplete: true,
      },
    });
  });

  // 8. Completed setup cannot be unnecessarily repeated
  it('8. completed setup cannot be unnecessarily repeated (redirects to dashboard)', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_done_owner',
        email: 'done@store.com',
        displayName: 'Done Owner',
        role: 'BUSINESS_OWNER',
        businessId: 'biz_done_123',
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
                  <BusinessSetupPage />
                </ProtectedRoute>
              }
            />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
      expect(screen.queryByTestId('btn-complete-setup')).toBeNull();
    });
  });

  // 9. Backend unavailable → no Firestore write → form data remains available → error/retry state shown
  it('9. backend unavailable: blocks direct Firestore fallback, preserves form data, displays error with retry', async () => {
    localStorage.setItem(
      'nirmaan_auth_user',
      JSON.stringify({
        uid: 'usr_offline_owner',
        email: 'offline@store.com',
        displayName: 'Offline Owner',
        role: 'BUSINESS_OWNER',
        businessId: null,
        setupComplete: false,
      })
    );

    // 1. Mock apiClient.post to simulate backend unavailable (network failure)
    const apiSpy = vi.spyOn(apiClient, 'post').mockResolvedValue({
      success: false,
      error: 'Unable to connect to Nirmaan backend API (Service Unavailable 503)',
    });

    // 2. Spy on direct Firestore mutations to verify none are called
    const firestoreBizSpy = vi.spyOn(authService, 'saveBusinessProfile');
    const firestoreUserSpy = vi.spyOn(authService, 'saveUserProfile');

    render(
      <MemoryRouter initialEntries={['/business-setup']}>
        <AuthProvider>
          <Routes>
            <Route path="/dashboard" element={<div data-testid="dashboard-view">Dashboard Screen</div>} />
            <Route path="/business-setup" element={<BusinessSetupPage />} />
          </Routes>
        </AuthProvider>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByTestId('input-business-name')).toBeDefined();
    });

    // Fill form data
    fireEvent.change(screen.getByTestId('input-business-name'), { target: { value: 'Offline Kirana Superstore' } });
    fireEvent.change(screen.getByTestId('input-owner-name'), { target: { value: 'Offline Owner' } });
    fireEvent.change(screen.getByTestId('input-store-phone'), { target: { value: '+91 98765 77777' } });
    fireEvent.change(screen.getByTestId('input-store-address'), { target: { value: 'Shop 5, Station Road, Rajkot' } });
    fireEvent.change(screen.getByTestId('input-gst-number'), { target: { value: '24ABCDE1234F1Z5' } });

    // Submit form while backend is unavailable
    fireEvent.click(screen.getByTestId('btn-complete-setup'));

    // Assert:
    // a. Error banner is shown with the backend unavailable message
    await waitFor(() => {
      expect(screen.getByTestId('setup-error-banner')).toBeDefined();
      expect(screen.getByTestId('setup-error-message').textContent).toContain('Service Unavailable 503');
    });

    // b. Form data remains completely available in inputs (not lost)
    expect((screen.getByTestId('input-business-name') as HTMLInputElement).value).toBe('Offline Kirana Superstore');
    expect((screen.getByTestId('input-store-phone') as HTMLInputElement).value).toBe('+91 98765 77777');
    expect((screen.getByTestId('input-store-address') as HTMLInputElement).value).toBe('Shop 5, Station Road, Rajkot');
    expect((screen.getByTestId('input-gst-number') as HTMLInputElement).value).toBe('24ABCDE1234F1Z5');

    // c. Crucial Security Verification: No direct Firestore write occurred as fallback!
    expect(firestoreBizSpy).not.toHaveBeenCalled();
    expect(firestoreUserSpy).not.toHaveBeenCalled();

    // d. User remains on /business-setup (dashboard is NOT reached)
    expect(screen.queryByTestId('dashboard-view')).toBeNull();

    // e. Retry action is provided
    const retryBtn = screen.getByTestId('btn-retry-setup');
    expect(retryBtn).toBeDefined();

    // 3. Simulate backend recovering and succeeding on retry
    apiSpy.mockResolvedValueOnce({
      success: true,
      data: {
        user: {
          uid: 'usr_offline_owner',
          email: 'offline@store.com',
          displayName: 'Offline Owner',
          role: 'BUSINESS_OWNER',
          businessId: 'biz_recovered_123',
          setupComplete: true,
        },
        business: {
          businessId: 'biz_recovered_123',
          businessName: 'Offline Kirana Superstore',
          businessCategory: 'Groceries & Kirana',
          ownerId: 'usr_offline_owner',
          contact: { phone: '+91 98765 77777', address: 'Shop 5, Station Road, Rajkot' },
          currency: 'INR',
          setupComplete: true,
        },
      },
    });

    fireEvent.click(retryBtn);

    // Verify retry succeeds and now routes to dashboard
    await waitFor(() => {
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
    });
  });
});
