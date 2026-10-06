import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { DashboardPage } from '@/pages/DashboardPage';
import { dashboardService } from '@/services/dashboardService';
import { DashboardData } from '@/models/dashboard';

const mockUser = {
  uid: 'user_owner_1',
  id: 'user_owner_1',
  email: 'owner@kirana.test',
  displayName: 'Rajesh Sharma',
  role: 'BUSINESS_OWNER' as const,
  businessId: 'biz_123',
  setupComplete: true,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
};

const sampleDashboardData: DashboardData = {
  businessId: 'biz_123',
  timezone: 'Asia/Kolkata',
  today: '2026-10-01',
  metrics: {
    todayRevenue: 15400,
    todayOrdersCount: 12,
    averageOrderValue: 1283.33,
    lowStockCount: 2,
    outOfStockCount: 1,
    totalStockAlerts: 3,
    totalCustomers: 45,
    totalProducts: 28,
    activeKhataCustomers: 4,
    totalOutstandingKhata: 3200,
  },
  recentOrders: [
    {
      id: 'ord_1',
      orderNumber: 'ORD-1001',
      customerName: 'Ramesh Kumar',
      customerPhone: '+91 98200 12345',
      totalAmount: 1250,
      status: 'COMPLETED',
      paymentMethod: 'UPI',
      itemCount: 3,
      createdAt: '2026-10-01T10:30:00.000Z',
    },
    {
      id: 'ord_2',
      orderNumber: 'ORD-1002',
      customerName: 'Priya Sharma',
      customerPhone: '+91 98200 67890',
      totalAmount: 850,
      status: 'COMPLETED',
      paymentMethod: 'CASH',
      itemCount: 2,
      createdAt: '2026-10-01T09:15:00.000Z',
    },
  ],
  stockAlerts: [
    {
      id: 'prod_1',
      name: 'Tata Tea Gold 500g',
      sku: 'TATA-TEA-500G',
      category: 'Beverages',
      stockQuantity: 2,
      minStockThreshold: 5,
      unit: 'pack',
      stockStatus: 'LOW_STOCK',
    },
    {
      id: 'prod_2',
      name: 'Aashirvaad Atta 10kg',
      sku: 'AASH-ATTA-10KG',
      category: 'Groceries',
      stockQuantity: 0,
      minStockThreshold: 8,
      unit: 'bag',
      stockStatus: 'OUT_OF_STOCK',
    },
  ],
  topProducts: [
    {
      productId: 'prod_1',
      name: 'Tata Tea Gold 500g',
      sku: 'TATA-TEA-500G',
      quantitySold: 24,
      revenue: 6000,
    },
    {
      productId: 'prod_3',
      name: 'Fortune Sunflower Oil 1L',
      sku: 'FORT-OIL-1L',
      quantitySold: 18,
      revenue: 2700,
    },
  ],
  businessHealth: {
    status: 'UNAVAILABLE',
    score: null,
    message: 'Business Health scoring requires accumulated transaction history and will be evaluated in subsequent intelligence updates.',
    isConfigured: false,
  },
};

vi.mock('@/context/AuthContext', () => ({
  useAuth: () => ({
    user: mockUser,
    business: null,
    isAuthenticated: true,
    isLoading: false,
    role: 'BUSINESS_OWNER',
    error: null,
    login: vi.fn(),
    register: vi.fn(),
    logout: vi.fn(),
    completeBusinessSetup: vi.fn(),
    sendPasswordReset: vi.fn(),
    clearError: vi.fn(),
    setRole: vi.fn(),
  }),
}));

function renderDashboard() {
  return render(
    <MemoryRouter>
      <DashboardPage />
    </MemoryRouter>
  );
}

describe('Nirmaan Web — Phase 5: Real Business Dashboard Suite', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  // 1. Dashboard renders real API data
  it('1. dashboard renders real API data: renders layout and welcome greeting', async () => {
    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
      expect(screen.getByText(/Namaste, Rajesh/i)).toBeDefined();
    });
  });

  // 2. Revenue displayed from API response
  it('2. revenue displayed from API response: shows formatted todayRevenue', async () => {
    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      const revenueCard = screen.getByTestId('card-today-revenue');
      expect(revenueCard).toBeDefined();
      // ₹15,400 from sample data
      expect(revenueCard.textContent).toContain('15,400');
    });
  });

  // 3. Order count displayed from API response
  it('3. order count displayed from API response: shows todayOrdersCount and averageOrderValue', async () => {
    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      const ordersCard = screen.getByTestId('card-today-orders');
      expect(ordersCard).toBeDefined();
      expect(ordersCard.textContent).toContain('12');
      expect(ordersCard.textContent).toContain('1,283');
    });
  });

  // 4. Low-stock data displayed
  it('4. low-stock data displayed: displays alert card with count, badge, and restock actions', async () => {
    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      const stockCard = screen.getByTestId('card-low-stock');
      expect(stockCard.textContent).toContain('3'); // 2 low + 1 out

      const stockSection = screen.getByTestId('section-stock-alerts');
      expect(stockSection.textContent).toContain('Tata Tea Gold 500g');
      expect(stockSection.textContent).toContain('Low Stock');
      expect(stockSection.textContent).toContain('Aashirvaad Atta 10kg');
      expect(stockSection.textContent).toContain('Out of Stock');
    });
  });

  // 5. Recent orders displayed
  it('5. recent orders displayed: shows latest orders with customer name, amount, and status', async () => {
    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      const ordersSection = screen.getByTestId('section-recent-orders');
      expect(ordersSection.textContent).toContain('ORD-1001');
      expect(ordersSection.textContent).toContain('Ramesh Kumar');
      expect(ordersSection.textContent).toContain('1,250');
      expect(ordersSection.textContent).toContain('ORD-1002');
      expect(ordersSection.textContent).toContain('Priya Sharma');
    });
  });

  // 6. Top products displayed
  it('6. top products displayed: ranks products by quantity sold and revenue', async () => {
    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      const topSection = screen.getByTestId('section-top-products');
      expect(topSection.textContent).toContain('Tata Tea Gold 500g');
      expect(topSection.textContent).toContain('24 units sold');
      expect(topSection.textContent).toContain('6,000');
      expect(topSection.textContent).toContain('Fortune Sunflower Oil 1L');
      expect(topSection.textContent).toContain('18 units sold');
    });
  });

  // 7. Loading state
  it('7. loading state: renders loading indicator while API request is pending', () => {
    // Return promise that never resolves during this check
    vi.spyOn(dashboardService, 'getDashboard').mockImplementation(() => new Promise(() => {}));

    renderDashboard();

    expect(screen.getByTestId('dashboard-loading')).toBeDefined();
    expect(screen.getByText(/aggregating live business metrics/i)).toBeDefined();
  });

  // 8. Empty state
  it('8. empty state: renders store launch guidance when business has zero records', async () => {
    const emptyDashboard: DashboardData = {
      ...sampleDashboardData,
      metrics: {
        todayRevenue: 0,
        todayOrdersCount: 0,
        averageOrderValue: 0,
        lowStockCount: 0,
        outOfStockCount: 0,
        totalStockAlerts: 0,
        totalCustomers: 0,
        totalProducts: 0,
        activeKhataCustomers: 0,
        totalOutstandingKhata: 0,
      },
      recentOrders: [],
      stockAlerts: [],
      topProducts: [],
    };

    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(emptyDashboard);

    renderDashboard();

    await waitFor(() => {
      expect(screen.getByTestId('dashboard-empty-banner')).toBeDefined();
      expect(screen.getByText(/your store is ready to launch/i)).toBeDefined();
      expect(screen.getByText(/no sales recorded yet/i)).toBeDefined();
      expect(screen.getByText(/healthy stock levels/i)).toBeDefined();
    });
  });

  // 9. API error + retry
  it('9. API error + retry: displays actionable error state and retries on user click', async () => {
    const getSpy = vi
      .spyOn(dashboardService, 'getDashboard')
      .mockRejectedValueOnce(new Error('Connection timed out to store database'))
      .mockResolvedValueOnce(sampleDashboardData);

    renderDashboard();

    await waitFor(() => {
      expect(screen.getByTestId('dashboard-error')).toBeDefined();
      expect(screen.getByText(/connection timed out to store database/i)).toBeDefined();
    });

    const retryBtn = screen.getByRole('button', { name: /try again/i });
    fireEvent.click(retryBtn);

    await waitFor(() => {
      expect(getSpy).toHaveBeenCalledTimes(2);
      expect(screen.getByTestId('dashboard-view')).toBeDefined();
    });
  });

  // 10. Dashboard does not use presentation seed data
  it('10. dashboard does not use presentation seed data: renders dynamic API values without hardcoded defaults', async () => {
    // Custom test payload with distinctive numbers unlike mockDailyMetrics (which had 28450)
    const customDynamicData: DashboardData = {
      ...sampleDashboardData,
      metrics: {
        ...sampleDashboardData.metrics,
        todayRevenue: 99420,
        todayOrdersCount: 77,
      },
    };

    vi.spyOn(dashboardService, 'getDashboard').mockResolvedValue(customDynamicData);

    renderDashboard();

    await waitFor(() => {
      const revenueCard = screen.getByTestId('card-today-revenue');
      expect(revenueCard.textContent).toContain('99,420');
      // Must NOT contain hardcoded mockDailyMetrics value 28,450
      expect(revenueCard.textContent).not.toContain('28,450');

      const ordersCard = screen.getByTestId('card-today-orders');
      expect(ordersCard.textContent).toContain('77');
      expect(ordersCard.textContent).not.toContain('42'); // mockDailyMetrics had 42
    });
  });
});
