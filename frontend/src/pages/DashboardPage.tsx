import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  IndianRupee,
  ShoppingCart,
  AlertTriangle,
  Users,
  Plus,
  ArrowRight,
  Package,
  TrendingUp,
  ShieldCheck,
  RotateCcw,
} from 'lucide-react';
import { StatsCard } from '@/components/ui/StatsCard';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { ErrorState } from '@/components/ui/ErrorState';
import { formatCurrency, formatDate } from '@/lib/utils';
import { useAuth } from '@/context/AuthContext';
import { useDashboard } from '@/hooks/useDashboard';

export const DashboardPage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { data, loading, error, refetch } = useDashboard();

  // Loading State
  if (loading && !data) {
    return (
      <div className="py-24 flex flex-col items-center justify-center space-y-4" data-testid="dashboard-loading">
        <LoadingSpinner size="lg" text="Aggregating live business metrics from store operations..." />
      </div>
    );
  }

  // Error State
  if (error && !data) {
    return (
      <div className="py-12" data-testid="dashboard-error">
        <ErrorState
          title="Unable to load store dashboard"
          message={error}
          onRetry={refetch}
        />
      </div>
    );
  }

  const metrics = data?.metrics || {
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
  };

  const recentOrders = data?.recentOrders || [];
  const stockAlerts = data?.stockAlerts || [];
  const topProducts = data?.topProducts || [];
  const businessHealth = data?.businessHealth;

  const isStoreEmpty = metrics.totalProducts === 0 && metrics.todayOrdersCount === 0 && recentOrders.length === 0;

  return (
    <div className="space-y-6" data-testid="dashboard-view">
      {/* Welcome Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">
            Namaste, {user?.displayName?.split(' ')[0] || user?.name?.split(' ')[0] || 'Partner'} 👋
          </h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Live business performance for today,{' '}
            {new Date().toLocaleDateString('en-IN', {
              weekday: 'short',
              month: 'short',
              day: 'numeric',
              year: 'numeric',
            })}{' '}
            ({data?.timezone || 'IST'}).
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => refetch()}
            leftIcon={<RotateCcw className="w-3.5 h-3.5" />}
            title="Refresh live metrics"
          >
            Refresh
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => navigate('/products/add')}
            leftIcon={<Plus className="w-4 h-4" />}
          >
            Add Product
          </Button>
          <Button
            variant="primary"
            size="sm"
            onClick={() => navigate('/orders')}
            leftIcon={<ShoppingCart className="w-4 h-4" />}
            data-testid="btn-new-sale-pos"
          >
            New Sale (POS)
          </Button>
        </div>
      </div>

      {/* Empty State Banner (If store has zero products and orders) */}
      {isStoreEmpty && (
        <Card className="p-6 border-dashed border-2 border-slate-300 bg-slate-50/50 text-center" data-testid="dashboard-empty-banner">
          <Package className="w-10 h-10 text-slate-400 mx-auto mb-2" />
          <h3 className="text-base font-bold text-slate-900">Your Store is Ready to Launch</h3>
          <p className="text-xs text-slate-500 max-w-md mx-auto mt-1 mb-4">
            Add catalog products and record customer sales to start seeing real-time revenue, stock alerts, and top-selling analytics.
          </p>
          <div className="flex items-center justify-center gap-3">
            <Button variant="primary" size="sm" onClick={() => navigate('/products/add')}>
              Add First Product
            </Button>
            <Button variant="outline" size="sm" onClick={() => navigate('/orders')}>
              Open POS Counter
            </Button>
          </div>
        </Card>
      )}

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div data-testid="card-today-revenue">
          <StatsCard
            title="Today's Revenue"
            value={formatCurrency(metrics.todayRevenue)}
            subtitle="Completed sales today"
            icon={<IndianRupee className="w-5 h-5" />}
            iconBgColor="bg-emerald-50 text-emerald-600"
          />
        </div>
        <div data-testid="card-today-orders">
          <StatsCard
            title="Orders Completed"
            value={metrics.todayOrdersCount.toString()}
            subtitle={`Avg ${formatCurrency(metrics.averageOrderValue)} / bill`}
            icon={<ShoppingCart className="w-5 h-5" />}
            iconBgColor="bg-sky-50 text-sky-600"
          />
        </div>
        <div data-testid="card-low-stock">
          <StatsCard
            title="Stock Alerts"
            value={metrics.totalStockAlerts.toString()}
            subtitle={`${metrics.lowStockCount} low, ${metrics.outOfStockCount} out`}
            icon={<AlertTriangle className="w-5 h-5" />}
            iconBgColor={metrics.totalStockAlerts > 0 ? 'bg-amber-50 text-amber-600' : 'bg-slate-100 text-slate-600'}
          />
        </div>
        <div data-testid="card-total-customers">
          <StatsCard
            title="Total Customers"
            value={metrics.totalCustomers.toString()}
            subtitle={`${metrics.activeKhataCustomers} with active khata`}
            icon={<Users className="w-5 h-5" />}
            iconBgColor="bg-indigo-50 text-indigo-600"
          />
        </div>
      </div>

      {/* Operational Health Status Card */}
      <Card variant="default" className="p-5 border-l-4 border-l-sky-500">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div className="flex items-start gap-3.5">
            <div className="w-10 h-10 rounded-xl bg-sky-600 text-white flex items-center justify-center shrink-0 shadow-md">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-sm font-bold text-slate-900">Operational Health Status</h3>
                <Badge
                  variant={metrics.totalStockAlerts > 0 ? 'warning' : 'success'}
                  size="sm"
                >
                  {metrics.totalStockAlerts > 0 ? 'Restock Recommended' : 'Optimal Inventory'}
                </Badge>
              </div>
              <p className="text-xs text-slate-600 mt-1 max-w-2xl leading-relaxed">
                {metrics.totalStockAlerts > 0
                  ? `${metrics.totalStockAlerts} product(s) have reached or dropped below reorder thresholds (${metrics.lowStockCount} low stock, ${metrics.outOfStockCount} out of stock). Immediate restock prevents lost retail sales.`
                  : 'All product inventory levels are currently healthy and within safe threshold levels. Register and POS operations are stable.'}
              </p>
              <div className="flex items-center gap-2 mt-2 text-[11px] text-slate-400 font-medium">
                <span>Business Health Scoring:</span>
                <span className="text-slate-600 font-semibold">
                  {businessHealth?.status === 'CONFIGURED' && businessHealth.score !== null
                    ? `${businessHealth.score} / 100`
                    : 'Evaluating (Unlocks as transactional history accumulates)'}
                </span>
              </div>
            </div>
          </div>
          <Button
            variant="outline"
            size="sm"
            className="shrink-0"
            onClick={() => navigate('/inventory')}
            rightIcon={<ArrowRight className="w-3.5 h-3.5" />}
          >
            Manage Inventory
          </Button>
        </div>
      </Card>

      {/* 2-Column Split: Recent Orders & Stock Alerts / Top Products */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Orders (2 Cols) */}
        <div className="lg:col-span-2 space-y-6">
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-base font-bold text-slate-900 tracking-tight">Recent Orders</h2>
                <p className="text-xs text-slate-500">Live feed of transactions recorded in this business</p>
              </div>
              <Button variant="ghost" size="sm" onClick={() => navigate('/orders')}>
                View All Orders
              </Button>
            </div>

            <Card padded={false} className="divide-y divide-slate-100 overflow-hidden" data-testid="section-recent-orders">
              {recentOrders.length === 0 ? (
                <div className="p-8 text-center text-xs text-slate-500">
                  <ShoppingCart className="w-6 h-6 text-slate-300 mx-auto mb-2" />
                  No sales recorded yet. Click <strong>New Sale (POS)</strong> above to create your first transaction.
                </div>
              ) : (
                recentOrders.map((order) => (
                  <div
                    key={order.id}
                    className="p-4 flex items-center justify-between hover:bg-slate-50/50 transition-colors"
                  >
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-semibold text-slate-900">{order.customerName}</span>
                        <Badge
                          variant={
                            order.status === 'COMPLETED'
                              ? 'success'
                              : order.status === 'PENDING'
                              ? 'warning'
                              : 'error'
                          }
                          size="sm"
                        >
                          {order.status}
                        </Badge>
                      </div>
                      <div className="flex items-center gap-2 text-xs text-slate-500">
                        <span className="font-mono text-[11px] font-semibold text-slate-600">{order.orderNumber}</span>
                        <span>•</span>
                        <span>{formatDate(order.createdAt)}</span>
                        <span>•</span>
                        <span className="font-medium text-slate-600">{order.paymentMethod}</span>
                      </div>
                    </div>

                    <div className="text-right">
                      <span className="text-sm font-bold text-slate-900 block">
                        {formatCurrency(order.totalAmount)}
                      </span>
                      <span className="text-xs text-slate-500">{order.itemCount} item(s)</span>
                    </div>
                  </div>
                ))
              )}
            </Card>
          </div>

          {/* Top-Selling Products */}
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-base font-bold text-slate-900 tracking-tight flex items-center gap-2">
                  <TrendingUp className="w-4 h-4 text-emerald-600" /> Top-Selling Products
                </h2>
                <p className="text-xs text-slate-500">Ranked by volume of completed customer orders</p>
              </div>
            </div>

            <Card padded={false} className="divide-y divide-slate-100 overflow-hidden" data-testid="section-top-products">
              {topProducts.length === 0 ? (
                <div className="p-8 text-center text-xs text-slate-500">
                  <TrendingUp className="w-6 h-6 text-slate-300 mx-auto mb-2" />
                  No item sales data yet. Once sales are finalized, best-sellers will rank here automatically.
                </div>
              ) : (
                topProducts.map((prod, idx) => (
                  <div
                    key={prod.productId}
                    className="p-3.5 px-4 flex items-center justify-between text-xs hover:bg-slate-50/50 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <span className="w-6 h-6 rounded-full bg-slate-100 font-bold text-slate-700 flex items-center justify-center text-[11px] shrink-0">
                        {idx + 1}
                      </span>
                      <div>
                        <span className="font-semibold text-slate-900 block">{prod.name}</span>
                        {prod.sku && <span className="text-[10px] text-slate-400 font-mono">SKU: {prod.sku}</span>}
                      </div>
                    </div>
                    <div className="text-right">
                      <span className="font-bold text-slate-900 block">{formatCurrency(prod.revenue)}</span>
                      <span className="text-slate-500 text-[11px] font-medium">{prod.quantitySold} units sold</span>
                    </div>
                  </div>
                ))
              )}
            </Card>
          </div>
        </div>

        {/* Right Column: Low Stock Alerts & Quick Links (1 Col) */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="text-base font-bold text-slate-900 tracking-tight">Stock Alerts</h2>
            <Button variant="ghost" size="sm" onClick={() => navigate('/inventory')}>
              Inventory
            </Button>
          </div>

          <div className="space-y-2.5" data-testid="section-stock-alerts">
            {stockAlerts.length === 0 ? (
              <Card className="p-4 text-center bg-slate-50 border-slate-200">
                <ShieldCheck className="w-6 h-6 text-emerald-500 mx-auto mb-1" />
                <p className="text-xs font-semibold text-slate-700">Healthy Stock Levels</p>
                <p className="text-[11px] text-slate-500">No items are below reorder threshold</p>
              </Card>
            ) : (
              stockAlerts.map((item) => (
                <Card
                  key={item.id}
                  className={`p-3.5 border-l-4 ${
                    item.stockStatus === 'OUT_OF_STOCK'
                      ? 'border-l-rose-500 bg-rose-50/30'
                      : 'border-l-amber-500'
                  }`}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="space-y-0.5 flex-1 min-w-0">
                      <div className="flex items-center gap-1.5 flex-wrap">
                        <h4 className="text-xs font-bold text-slate-900 truncate">{item.name}</h4>
                        <Badge
                          variant={item.stockStatus === 'OUT_OF_STOCK' ? 'error' : 'warning'}
                          size="sm"
                        >
                          {item.stockStatus === 'OUT_OF_STOCK' ? 'Out of Stock' : 'Low Stock'}
                        </Badge>
                      </div>
                      <p className="text-[11px] text-slate-500">
                        Current:{' '}
                        <strong
                          className={
                            item.stockStatus === 'OUT_OF_STOCK'
                              ? 'text-rose-600 font-bold'
                              : 'text-amber-600 font-semibold'
                          }
                        >
                          {item.stockQuantity} {item.unit || 'pcs'}
                        </strong>{' '}
                        (Min: {item.minStockThreshold})
                      </p>
                    </div>
                    <Button
                      variant="outline"
                      size="sm"
                      className="h-7 text-xs px-2.5 shrink-0"
                      onClick={() => navigate('/inventory')}
                    >
                      Restock
                    </Button>
                  </div>
                </Card>
              ))
            )}

            <Card
              className="p-4 bg-slate-50 border-slate-200 text-center cursor-pointer hover:bg-slate-100 transition-colors"
              onClick={() => navigate('/products')}
            >
              <Package className="w-5 h-5 text-slate-400 mx-auto mb-1" />
              <p className="text-xs font-semibold text-slate-700">Manage Full Catalog</p>
              <p className="text-[10px] text-slate-500">Check pricing & stock thresholds</p>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};
