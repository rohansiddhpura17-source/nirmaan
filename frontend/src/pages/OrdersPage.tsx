import React, { useState } from 'react';
import { ShoppingCart, Search, Plus, ArrowUpRight, Trash2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { ErrorState } from '@/components/ui/ErrorState';
import { EmptyState } from '@/components/ui/EmptyState';
import { formatCurrency, formatDate } from '@/lib/utils';
import { OrderStatus, PaymentMethod, OrderModel } from '@/models/order';
import { useOrders } from '@/hooks/useOrders';
import { useProducts } from '@/hooks/useProducts';
import { useCustomers } from '@/hooks/useCustomers';

interface CartLineItem {
  productId: string;
  productName: string;
  sku: string;
  unitPrice: number;
  availableStock: number;
  quantity: number;
}

export const OrdersPage: React.FC = () => {
  const [selectedFilter, setSelectedFilter] = useState<'ALL' | OrderStatus>('ALL');
  const [searchQuery, setSearchQuery] = useState('');

  // POS Modal State
  const [isPosOpen, setIsPosOpen] = useState(false);
  const [selectedCustomerId, setSelectedCustomerId] = useState<string>('');
  const [walkinName, setWalkinName] = useState('Walk-in Customer');
  const [walkinPhone, setWalkinPhone] = useState('');
  const [cartItems, setCartItems] = useState<CartLineItem[]>([]);
  const [selectedProductId, setSelectedProductId] = useState<string>('');
  const [addItemQty, setAddItemQty] = useState('1');
  const [discountAmount, setDiscountAmount] = useState('0');
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>('CASH');
  const [posError, setPosError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Invoice / Details Modal
  const [viewingOrder, setViewingOrder] = useState<OrderModel | null>(null);

  const {
    orders,
    loading,
    error,
    refetch,
    createOrder,
  } = useOrders({
    q: searchQuery,
    status: selectedFilter,
  });

  const { products, refetch: refetchProducts } = useProducts({ limit: 100 });
  const { customers } = useCustomers({ limit: 100 });

  const totalSalesRevenue = orders
    .filter((o) => o.status === 'COMPLETED' || o.orderStatus === 'COMPLETED')
    .reduce((sum, o) => sum + (o.totalAmount || o.total || 0), 0);

  const completedCount = orders.filter((o) => o.status === 'COMPLETED' || o.orderStatus === 'COMPLETED').length;

  const handleOpenPos = () => {
    setCartItems([]);
    setSelectedCustomerId('');
    setWalkinName('Walk-in Customer');
    setWalkinPhone('');
    setSelectedProductId(products[0]?.id || '');
    setAddItemQty('1');
    setDiscountAmount('0');
    setPaymentMethod('CASH');
    setPosError(null);
    setIsPosOpen(true);
    refetchProducts().catch(() => {});
  };

  const handleAddToCart = () => {
    const targetProdId = selectedProductId || products[0]?.id;
    if (!targetProdId) return;
    const prod = products.find((p) => p.id === targetProdId);
    if (!prod) return;

    const qty = Number(addItemQty);
    if (isNaN(qty) || qty <= 0) {
      setPosError('Quantity must be greater than 0');
      return;
    }

    const available = prod.stockQuantity ?? prod.currentStock ?? 0;
    const existing = cartItems.find((i) => i.productId === targetProdId);
    const currentCartQty = existing ? existing.quantity : 0;
    const totalDesired = currentCartQty + qty;

    if (totalDesired > available) {
      setPosError(`Cannot add ${qty} units. Only ${available} units available in stock for "${prod.name}"`);
      return;
    }

    setPosError(null);
    if (existing) {
      setCartItems((prev) =>
        prev.map((i) =>
          i.productId === targetProdId
            ? { ...i, quantity: totalDesired }
            : i
        )
      );
    } else {
      setCartItems((prev) => [
        ...prev,
        {
          productId: prod.id,
          productName: prod.name,
          sku: prod.sku,
          unitPrice: prod.sellingPrice,
          availableStock: available,
          quantity: qty,
        },
      ]);
    }
    setAddItemQty('1');
  };

  const handleRemoveFromCart = (productId: string) => {
    setCartItems((prev) => prev.filter((i) => i.productId !== productId));
  };

  const handleUpdateCartQty = (productId: string, newQty: number) => {
    const item = cartItems.find((i) => i.productId === productId);
    if (!item) return;
    if (newQty <= 0) {
      handleRemoveFromCart(productId);
      return;
    }
    if (newQty > item.availableStock) {
      setPosError(`Maximum available stock for ${item.productName} is ${item.availableStock}`);
      return;
    }
    setPosError(null);
    setCartItems((prev) =>
      prev.map((i) => (i.productId === productId ? { ...i, quantity: newQty } : i))
    );
  };

  const subtotal = cartItems.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);
  const discount = Number(discountAmount) || 0;
  const grandTotal = Math.max(0, subtotal - discount);

  const handleCompleteSale = async (e: React.FormEvent) => {
    e.preventDefault();
    if (cartItems.length === 0) {
      setPosError('Please add at least one product item to the order');
      return;
    }

    setIsSubmitting(true);
    setPosError(null);

    // Client Idempotency Key prevents double-click duplicate orders
    const idempotencyKey = `ord_pos_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    try {
      const selectedCust = customers.find((c) => c.id === selectedCustomerId);
      const custName = selectedCust ? selectedCust.name : walkinName.trim() || 'Walk-in Customer';
      const custPhone = selectedCust ? selectedCust.phone : walkinPhone.trim() || undefined;

      await createOrder({
        customerId: selectedCustomerId || undefined,
        customerName: custName,
        customerPhone: custPhone,
        items: cartItems.map((item) => ({
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        })),
        discount,
        tax: 0,
        paymentMethod,
        idempotencyKey,
      });

      setIsPosOpen(false);
    } catch (err: unknown) {
      setPosError(err instanceof Error ? err.message : 'Failed to complete sales transaction');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Sales & Orders</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Track recent sales, pending customer orders, and POS transactions.
          </p>
        </div>

        <Button
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
          onClick={handleOpenPos}
          data-testid="btn-create-sale"
        >
          Create New Sale
        </Button>
      </div>

      {/* Summary Metrics */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="p-4">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Sales Invoices</p>
          <p className="text-2xl font-bold text-slate-900 mt-1">{orders.length}</p>
        </Card>
        <Card className="p-4 border-l-4 border-l-emerald-500">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Sales Revenue</p>
          <p className="text-2xl font-bold text-emerald-600 mt-1">{formatCurrency(totalSalesRevenue)}</p>
        </Card>
        <Card className="p-4 border-l-4 border-l-sky-500">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Completed Transactions</p>
          <p className="text-2xl font-bold text-sky-600 mt-1">{completedCount}</p>
        </Card>
      </div>

      {/* Filter and Search Bar */}
      <Card className="p-4">
        <div className="flex flex-col sm:flex-row gap-3 items-stretch sm:items-center justify-between">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              type="text"
              placeholder="Search by order number or customer name..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full h-10 pl-10 pr-4 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:bg-white transition-all text-slate-800 placeholder:text-slate-400"
            />
          </div>

          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
            {(['ALL', 'COMPLETED', 'PENDING', 'CANCELLED'] as const).map((filter) => (
              <button
                key={filter}
                onClick={() => setSelectedFilter(filter)}
                className={`px-3 py-1.5 text-xs font-semibold rounded-xl transition-colors shrink-0 ${
                  selectedFilter === filter
                    ? 'bg-slate-900 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {filter === 'ALL' ? 'All Orders' : filter}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {/* Orders List / State */}
      {loading ? (
        <div className="py-16 flex flex-col items-center justify-center">
          <LoadingSpinner size="lg" />
          <p className="text-xs text-slate-500 mt-3 font-medium">Loading sales transactions from database...</p>
        </div>
      ) : error ? (
        <ErrorState
          title="Unable to load orders"
          message={error}
          onRetry={refetch}
        />
      ) : orders.length === 0 ? (
        <EmptyState
          icon={ShoppingCart}
          title="No sales orders found"
          description={
            searchQuery || selectedFilter !== 'ALL'
              ? 'No orders matched your current search and status filters.'
              : 'You have not processed any sales orders yet. Use "Create New Sale" to execute checkout.'
          }
          actionLabel="Create First Sale"
          onAction={handleOpenPos}
        />
      ) : (
        <div className="space-y-3">
          {orders.map((order) => {
            const st = order.orderStatus || order.status || 'COMPLETED';
            const total = order.totalAmount ?? order.total ?? 0;

            return (
              <Card key={order.id} className="p-4 md:p-5 hover:shadow-md transition-shadow">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div className="space-y-1.5">
                    <div className="flex items-center gap-2.5 flex-wrap">
                      <span className="font-bold text-slate-900 text-sm md:text-base">
                        {order.orderNumber}
                      </span>
                      <Badge
                        variant={
                          st === 'COMPLETED'
                            ? 'success'
                            : st === 'PENDING'
                            ? 'warning'
                            : 'error'
                        }
                      >
                        {st}
                      </Badge>
                      <span className="text-xs px-2 py-0.5 rounded-md bg-slate-100 font-semibold text-slate-700">
                        {order.paymentMethod}
                      </span>
                    </div>

                    <p className="text-xs text-slate-500">
                      Customer: <span className="font-semibold text-slate-700">{order.customerName}</span> •{' '}
                      {formatDate(order.createdAt)}
                    </p>

                    <div className="text-xs text-slate-600 pt-1">
                      {order.items.map((i) => `${i.productName} (x${i.quantity})`).join(', ')}
                    </div>
                  </div>

                  <div className="flex md:flex-col items-center md:items-end justify-between border-t md:border-t-0 pt-3 md:pt-0 border-slate-100">
                    <div className="text-left md:text-right">
                      <p className="text-xs text-slate-400 font-medium">Grand Total</p>
                      <p className="text-lg md:text-xl font-bold text-slate-900">
                        {formatCurrency(total)}
                      </p>
                    </div>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="text-sky-600 hover:text-sky-700 p-0 h-auto md:mt-2 text-xs font-semibold gap-1"
                      onClick={() => setViewingOrder(order)}
                    >
                      View Invoice <ArrowUpRight className="w-3.5 h-3.5" />
                    </Button>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* POS Checkout Counter Modal */}
      {isPosOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-2xl w-full shadow-2xl border border-slate-200 overflow-hidden max-h-[90vh] flex flex-col">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50">
              <div>
                <h3 className="font-bold text-slate-900 text-lg flex items-center gap-2">
                  <ShoppingCart className="w-5 h-5 text-sky-600" /> New Sale / POS Counter
                </h3>
                <p className="text-xs text-slate-500">Select items, verify live stock, and complete invoice</p>
              </div>
              <button
                onClick={() => setIsPosOpen(false)}
                className="text-slate-400 hover:text-slate-600 font-bold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCompleteSale} className="p-6 overflow-y-auto space-y-5 flex-1">
              {posError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs font-semibold">
                  {posError}
                </div>
              )}

              {/* Customer Selector */}
              <div className="space-y-3 bg-slate-50/80 p-3.5 rounded-xl border border-slate-100">
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
                  Customer Information
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label htmlFor="customer-select" className="text-xs text-slate-500 mb-1 block">Registered Customer (Optional)</label>
                    <select
                      id="customer-select"
                      value={selectedCustomerId}
                      onChange={(e) => {
                        setSelectedCustomerId(e.target.value);
                        const c = customers.find((cust) => cust.id === e.target.value);
                        if (c) {
                          setWalkinName(c.name);
                          setWalkinPhone(c.phone);
                        } else {
                          setWalkinName('Walk-in Customer');
                          setWalkinPhone('');
                        }
                      }}
                      className="w-full h-10 rounded-xl border border-slate-300 bg-white px-3 text-xs focus:ring-2 focus:ring-[#0284C7]"
                    >
                      <option value="">-- Walk-in Shopper --</option>
                      {customers.map((c) => (
                        <option key={c.id} value={c.id}>
                          {c.name} ({c.phone})
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label htmlFor="walkin-name" className="text-xs text-slate-500 mb-1 block">Customer Name</label>
                    <Input
                      id="walkin-name"
                      value={walkinName}
                      onChange={(e) => setWalkinName(e.target.value)}
                      placeholder="Walk-in Customer"
                    />
                  </div>
                </div>
              </div>

              {/* Product Picker */}
              <div className="space-y-3 border border-slate-200 p-4 rounded-xl">
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
                  Add Product to Cart
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-12 gap-2">
                  <div className="sm:col-span-8">
                    <label htmlFor="select-catalog-product" className="sr-only">Select Catalog Product</label>
                    <select
                      id="select-catalog-product"
                      value={selectedProductId}
                      onChange={(e) => setSelectedProductId(e.target.value)}
                      className="w-full h-10 rounded-xl border border-slate-300 bg-white px-3 text-xs focus:ring-2 focus:ring-[#0284C7]"
                    >
                      {products.length === 0 && <option value="">No products in catalog</option>}
                      {products.map((p) => {
                        const stock = p.stockQuantity ?? p.currentStock ?? 0;
                        return (
                          <option key={p.id} value={p.id} disabled={stock <= 0}>
                            {p.name} — {formatCurrency(p.sellingPrice)} (Stock: {stock} {p.unit || 'pcs'})
                          </option>
                        );
                      })}
                    </select>
                  </div>

                  <div className="sm:col-span-2">
                    <label htmlFor="add-item-qty" className="sr-only">Item Quantity</label>
                    <input
                      id="add-item-qty"
                      type="number"
                      min="1"
                      value={addItemQty}
                      onChange={(e) => setAddItemQty(e.target.value)}
                      className="w-full h-10 rounded-xl border border-slate-300 bg-white px-3 text-xs text-center font-bold"
                      placeholder="Qty"
                    />
                  </div>

                  <div className="sm:col-span-2">
                    <Button
                      type="button"
                      variant="primary"
                      className="w-full h-10 text-xs font-bold"
                      onClick={handleAddToCart}
                      disabled={products.length === 0}
                    >
                      Add
                    </Button>
                  </div>
                </div>
              </div>

              {/* Line Items Table */}
              <div className="space-y-2">
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
                  Order Items ({cartItems.length})
                </label>

                {cartItems.length === 0 ? (
                  <div className="py-6 border-2 border-dashed border-slate-200 rounded-xl text-center text-xs text-slate-400">
                    Your cart is currently empty. Select products above to add to invoice.
                  </div>
                ) : (
                  <div className="divide-y divide-slate-100 border border-slate-200 rounded-xl overflow-hidden text-xs">
                    {cartItems.map((item) => (
                      <div key={item.productId} className="p-3 flex items-center justify-between gap-3 bg-white">
                        <div className="flex-1 min-w-0">
                          <p className="font-bold text-slate-900 truncate">{item.productName}</p>
                          <p className="text-[11px] text-slate-400 font-mono">
                            {formatCurrency(item.unitPrice)} each • Stock: {item.availableStock}
                          </p>
                        </div>

                        <div className="flex items-center gap-2">
                          <input
                            type="number"
                            min="1"
                            max={item.availableStock}
                            value={item.quantity}
                            onChange={(e) => handleUpdateCartQty(item.productId, parseInt(e.target.value, 10) || 1)}
                            className="w-14 h-8 rounded-lg border border-slate-200 text-center font-bold text-xs"
                          />
                          <span className="font-bold text-slate-900 w-16 text-right">
                            {formatCurrency(item.unitPrice * item.quantity)}
                          </span>
                          <button
                            type="button"
                            onClick={() => handleRemoveFromCart(item.productId)}
                            className="text-slate-400 hover:text-rose-600 p-1"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Payment and Totals */}
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label htmlFor="pos-payment-method" className="text-xs font-semibold text-slate-700 mb-1 block">Payment Mode</label>
                    <select
                      id="pos-payment-method"
                      value={paymentMethod}
                      onChange={(e) => setPaymentMethod(e.target.value as PaymentMethod)}
                      className="w-full h-10 rounded-xl border border-slate-300 bg-white px-3 text-xs font-medium"
                    >
                      <option value="CASH">CASH</option>
                      <option value="UPI">UPI / QR Code</option>
                      <option value="CARD">DEBIT / CREDIT CARD</option>
                      <option value="CREDIT">KHATA STORE CREDIT</option>
                    </select>
                  </div>

                  <div>
                    <label htmlFor="pos-discount" className="text-xs font-semibold text-slate-700 mb-1 block">Discount (₹)</label>
                    <Input
                      id="pos-discount"
                      type="number"
                      min="0"
                      value={discountAmount}
                      onChange={(e) => setDiscountAmount(e.target.value)}
                    />
                  </div>
                </div>

                <div className="pt-2 border-t border-slate-200 flex items-center justify-between text-sm">
                  <span className="font-bold text-slate-700">Subtotal:</span>
                  <span className="font-bold text-slate-900">{formatCurrency(subtotal)}</span>
                </div>
                <div className="flex items-center justify-between text-base border-t border-slate-200 pt-2">
                  <span className="font-black text-slate-900 uppercase">Grand Total:</span>
                  <span className="text-xl font-black text-emerald-600">{formatCurrency(grandTotal)}</span>
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 pt-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsPosOpen(false)}
                  disabled={isSubmitting}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  isLoading={isSubmitting}
                  disabled={cartItems.length === 0}
                  data-testid="btn-complete-order"
                >
                  Complete Order & Print Invoice
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Invoice Details Modal */}
      {viewingOrder && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl border border-slate-200 overflow-hidden">
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <div>
                <span className="text-xs font-bold text-sky-600 tracking-wider uppercase">Tax Invoice</span>
                <h3 className="font-bold text-slate-900 text-lg">{viewingOrder.orderNumber}</h3>
              </div>
              <Badge variant="success">PAID</Badge>
            </div>

            <div className="p-6 space-y-4 text-xs">
              <div className="flex justify-between text-slate-500">
                <span>Customer: <strong className="text-slate-800">{viewingOrder.customerName}</strong></span>
                <span>{formatDate(viewingOrder.createdAt)}</span>
              </div>

              <div className="divide-y divide-slate-100 border-y border-slate-100 py-2">
                {viewingOrder.items.map((i, idx) => (
                  <div key={idx} className="py-1.5 flex justify-between">
                    <span>{i.productName} × {i.quantity}</span>
                    <span className="font-bold text-slate-800">
                      {formatCurrency((i.unitPrice || 0) * (i.quantity || 1))}
                    </span>
                  </div>
                ))}
              </div>

              <div className="space-y-1 pt-1 text-right">
                <p className="text-slate-500">Payment: <strong className="text-slate-800">{viewingOrder.paymentMethod}</strong></p>
                <p className="text-base font-black text-slate-900">
                  Total Paid: {formatCurrency(viewingOrder.totalAmount ?? viewingOrder.total ?? 0)}
                </p>
              </div>
            </div>

            <div className="p-4 bg-slate-50 border-t border-slate-100 flex justify-end">
              <Button variant="outline" size="sm" onClick={() => setViewingOrder(null)}>
                Close
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
