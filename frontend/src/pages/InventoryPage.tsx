import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Plus, Package, History, ArrowUpDown } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { ErrorState } from '@/components/ui/ErrorState';
import { EmptyState } from '@/components/ui/EmptyState';
import { formatCurrency, formatDate } from '@/lib/utils';
import { getStockStatus, ProductModel } from '@/models/product';
import { useInventory } from '@/hooks/useInventory';

export const InventoryPage: React.FC = () => {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [selectedStockFilter, setSelectedStockFilter] = useState<string>('ALL');

  // Adjustment Modal State
  const [adjustingProduct, setAdjustingProduct] = useState<ProductModel | null>(null);
  const [adjustmentType, setAdjustmentType] = useState<'RESTOCK' | 'ADJUSTMENT' | 'RETURN'>('RESTOCK');
  const [adjustQuantity, setAdjustQuantity] = useState('10');
  const [adjustReason, setAdjustReason] = useState('Weekly supplier restock shipment');
  const [adjustError, setAdjustError] = useState<string | null>(null);
  const [isAdjusting, setIsAdjusting] = useState(false);

  // Movements Modal State
  const [viewingHistoryProduct, setViewingHistoryProduct] = useState<ProductModel | null>(null);

  const categories = ['All', 'Groceries', 'Beverages', 'FMCG', 'Personal Care', 'Electronics', 'Clothing', 'Hardware', 'Other'];

  const {
    items,
    summary,
    movements,
    loading,
    error,
    refetch,
    fetchMovements,
    adjustStock,
  } = useInventory({
    q: search,
    category: selectedCategory,
    stockStatus: selectedStockFilter,
  });

  const handleQuickAdjust = async (product: ProductModel, delta: number) => {
    const type = delta > 0 ? 'RESTOCK' : 'ADJUSTMENT';
    const reason = delta > 0 ? 'Quick stock increment' : 'Quick stock decrement';
    try {
      await adjustStock({
        productId: product.id,
        type,
        quantity: delta,
        reason,
        adjustmentMode: 'DELTA',
      });
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Failed to adjust stock');
    }
  };

  const handleOpenDetailedAdjust = (product: ProductModel) => {
    setAdjustingProduct(product);
    setAdjustmentType('RESTOCK');
    setAdjustQuantity('10');
    setAdjustReason('Weekly supplier restock shipment');
    setAdjustError(null);
  };

  const handleSubmitAdjustment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!adjustingProduct) return;
    const qty = Number(adjustQuantity);
    if (isNaN(qty) || qty <= 0) {
      setAdjustError('Please specify a positive quantity');
      return;
    }

    setIsAdjusting(true);
    setAdjustError(null);
    try {
      await adjustStock({
        productId: adjustingProduct.id,
        type: adjustmentType,
        quantity: qty,
        reason: adjustReason.trim(),
        adjustmentMode: 'DELTA',
      });
      setAdjustingProduct(null);
    } catch (err: unknown) {
      setAdjustError(err instanceof Error ? err.message : 'Failed to adjust stock');
    } finally {
      setIsAdjusting(false);
    }
  };

  const handleOpenHistory = async (product: ProductModel) => {
    setViewingHistoryProduct(product);
    await fetchMovements(product.id);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Inventory Management</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Monitor real-time warehouse stock, SKU counts, and reorder levels.
          </p>
        </div>

        <Button
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
          onClick={() => navigate('/products/add')}
        >
          Add New Product
        </Button>
      </div>

      {/* Summary KPI Cards */}
      {summary && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
          <Card className="p-4">
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">Total SKUs</p>
            <p className="text-xl sm:text-2xl font-bold text-slate-900 mt-1">{summary.totalProducts}</p>
            <p className="text-[11px] text-slate-400 mt-0.5">{summary.totalStockUnits} units in stock</p>
          </Card>

          <Card className="p-4 border-l-4 border-l-amber-500">
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">Low Stock Warnings</p>
            <p className="text-xl sm:text-2xl font-bold text-amber-600 mt-1">{summary.lowStockCount}</p>
            <p className="text-[11px] text-slate-400 mt-0.5">Needs reorder soon</p>
          </Card>

          <Card className="p-4 border-l-4 border-l-rose-500">
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">Out of Stock</p>
            <p className="text-xl sm:text-2xl font-bold text-rose-600 mt-1">{summary.outOfStockCount}</p>
            <p className="text-[11px] text-slate-400 mt-0.5">Critical deficit</p>
          </Card>

          <Card className="p-4 border-l-4 border-l-sky-500">
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">Inventory Value</p>
            <p className="text-xl sm:text-2xl font-bold text-sky-600 mt-1">{formatCurrency(summary.totalCostValue)}</p>
            <p className="text-[11px] text-emerald-600 font-medium mt-0.5">Retail: {formatCurrency(summary.totalRetailValue)}</p>
          </Card>
        </div>
      )}

      {/* Search & Filter */}
      <Card className="p-4 space-y-3">
        <div className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              type="text"
              placeholder="Search by product name or SKU..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full h-10 pl-10 pr-4 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:bg-white transition-all text-slate-800 placeholder:text-slate-400"
            />
          </div>

          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`px-3 py-1.5 text-xs font-semibold rounded-xl transition-colors shrink-0 ${
                  selectedCategory === cat
                    ? 'bg-slate-900 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Stock Status Filter Chips */}
        <div className="flex items-center gap-2 pt-1 border-t border-slate-100 text-xs">
          <span className="text-slate-400 font-medium">Filter Status:</span>
          {['ALL', 'IN_STOCK', 'LOW_STOCK', 'OUT_OF_STOCK'].map((st) => (
            <button
              key={st}
              onClick={() => setSelectedStockFilter(st)}
              className={`px-2.5 py-1 rounded-lg font-semibold text-[11px] transition-colors ${
                selectedStockFilter === st
                  ? 'bg-sky-100 text-sky-800 border border-sky-300'
                  : 'text-slate-600 hover:bg-slate-100'
              }`}
            >
              {st.replace(/_/g, ' ')}
            </button>
          ))}
        </div>
      </Card>

      {/* Content State */}
      {loading ? (
        <div className="py-16 flex flex-col items-center justify-center">
          <LoadingSpinner size="lg" />
          <p className="text-xs text-slate-500 mt-3 font-medium">Loading inventory records from database...</p>
        </div>
      ) : error ? (
        <ErrorState
          title="Unable to load inventory data"
          message={error}
          onRetry={refetch}
        />
      ) : items.length === 0 ? (
        <EmptyState
          icon={Package}
          title="No inventory records found"
          description={
            search || selectedCategory !== 'All' || selectedStockFilter !== 'ALL'
              ? 'No items matched your search and filter criteria.'
              : 'You have not added any inventory items to your catalog yet.'
          }
          actionLabel="Add Inventory Item"
          onAction={() => navigate('/products/add')}
        />
      ) : (
        /* Inventory Items List */
        <div className="space-y-3">
          {items.map((product) => {
            const stockQty = product.stockQuantity ?? product.currentStock ?? 0;
            const threshold = product.minStockThreshold ?? 5;
            const status = getStockStatus(stockQty, threshold);

            return (
              <Card key={product.id} className="p-4 hover:shadow-md transition-shadow">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div className="space-y-1 flex-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-bold text-slate-900 text-sm md:text-base">
                        {product.name}
                      </span>
                      <Badge
                        variant={
                          status === 'IN_STOCK'
                            ? 'success'
                            : status === 'LOW_STOCK'
                            ? 'warning'
                            : 'error'
                        }
                      >
                        {status === 'IN_STOCK'
                          ? 'In Stock'
                          : status === 'LOW_STOCK'
                          ? 'Low Stock'
                          : 'Out of Stock'}
                      </Badge>
                      <span className="text-xs text-slate-400 font-mono">SKU: {product.sku}</span>
                    </div>

                    <div className="flex items-center gap-4 text-xs text-slate-500 pt-1 flex-wrap">
                      <span>Category: <strong className="text-slate-700">{product.category}</strong></span>
                      <span>Cost: <strong className="text-slate-700">{formatCurrency(product.costPrice ?? product.purchasePrice ?? 0)}</strong></span>
                      <span>Selling: <strong className="text-slate-700">{formatCurrency(product.sellingPrice)}</strong></span>
                      <span>Valuation: <strong className="text-sky-700">{formatCurrency(stockQty * (product.costPrice ?? product.purchasePrice ?? 0))}</strong></span>
                    </div>
                  </div>

                  {/* Stock Counts & Quick Adjustment Buttons */}
                  <div className="flex items-center justify-between md:justify-end gap-6 pt-3 md:pt-0 border-t md:border-t-0 border-slate-100">
                    <div className="text-left md:text-right">
                      <p className="text-xs text-slate-400 font-medium">Available Units</p>
                      <p className="text-lg font-bold text-slate-900">
                        {stockQty} <span className="text-xs font-normal text-slate-500">{product.unit || 'pcs'}</span>
                      </p>
                      <p className="text-[10px] text-slate-400">Min threshold: {threshold}</p>
                    </div>

                    <div className="flex items-center gap-2">
                      <div className="flex items-center gap-1.5 bg-slate-100 p-1 rounded-xl">
                        <button
                          onClick={() => handleQuickAdjust(product, -1)}
                          disabled={stockQty <= 0}
                          className="w-7 h-7 rounded-lg bg-white text-slate-700 font-bold hover:bg-slate-200 disabled:opacity-40 transition-colors shadow-xs flex items-center justify-center text-sm"
                          title="Decrease stock by 1"
                        >
                          -
                        </button>
                        <span className="w-8 text-center text-xs font-bold text-slate-800">
                          {stockQty}
                        </span>
                        <button
                          onClick={() => handleQuickAdjust(product, 1)}
                          className="w-7 h-7 rounded-lg bg-white text-slate-700 font-bold hover:bg-slate-200 transition-colors shadow-xs flex items-center justify-center text-sm"
                          title="Increase stock by 1"
                        >
                          +
                        </button>
                      </div>

                      <Button
                        variant="outline"
                        size="sm"
                        className="h-8 text-xs px-2"
                        onClick={() => handleOpenDetailedAdjust(product)}
                        title="Adjust Stock"
                      >
                        <ArrowUpDown className="w-3.5 h-3.5" />
                      </Button>

                      <button
                        onClick={() => handleOpenHistory(product)}
                        className="p-2 text-slate-400 hover:text-sky-600 rounded-lg hover:bg-sky-50 transition-colors"
                        title="View stock movement history"
                      >
                        <History className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* Detailed Stock Adjustment Modal */}
      {adjustingProduct && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-xl border border-slate-200 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <div>
                <h3 className="font-bold text-slate-900 text-lg">Adjust Stock</h3>
                <p className="text-xs text-slate-500">{adjustingProduct.name}</p>
              </div>
              <button
                onClick={() => setAdjustingProduct(null)}
                className="text-slate-400 hover:text-slate-600 text-sm font-semibold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmitAdjustment} className="p-6 space-y-4">
              {adjustError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold">
                  {adjustError}
                </div>
              )}

              <div className="space-y-1.5">
                <label htmlFor="adjust-type" className="block text-sm font-medium text-slate-700">Movement Type</label>
                <select
                  id="adjust-type"
                  value={adjustmentType}
                  onChange={(e) => setAdjustmentType(e.target.value as 'RESTOCK' | 'ADJUSTMENT' | 'RETURN')}
                  className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7]"
                >
                  <option value="RESTOCK">RESTOCK (Shipment Intake)</option>
                  <option value="ADJUSTMENT">ADJUSTMENT (Audit / Correction)</option>
                  <option value="RETURN">RETURN (Customer Return)</option>
                </select>
              </div>

              <Input
                label="Quantity to Add / Adjust"
                type="number"
                required
                min="1"
                value={adjustQuantity}
                onChange={(e) => setAdjustQuantity(e.target.value)}
              />

              <Input
                label="Reason / Notes"
                required
                placeholder="e.g. Weekly vendor shipment batch"
                value={adjustReason}
                onChange={(e) => setAdjustReason(e.target.value)}
              />

              <div className="flex items-center justify-end gap-3 pt-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setAdjustingProduct(null)}
                  disabled={isAdjusting}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  isLoading={isAdjusting}
                >
                  Apply & Record Movement
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Movement History Modal */}
      {viewingHistoryProduct && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-lg w-full shadow-xl border border-slate-200 overflow-hidden max-h-[85vh] flex flex-col">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <div>
                <h3 className="font-bold text-slate-900 text-lg">Stock Movement History</h3>
                <p className="text-xs text-slate-500">{viewingHistoryProduct.name}</p>
              </div>
              <button
                onClick={() => setViewingHistoryProduct(null)}
                className="text-slate-400 hover:text-slate-600 text-sm font-semibold"
              >
                ✕
              </button>
            </div>

            <div className="p-6 overflow-y-auto space-y-3 flex-1">
              {movements.length === 0 ? (
                <div className="py-8 text-center text-slate-400 text-xs">
                  No stock movements recorded yet for this item.
                </div>
              ) : (
                movements.map((mov) => (
                  <div
                    key={mov.id}
                    className="p-3 rounded-xl border border-slate-100 bg-slate-50/70 space-y-1 text-xs"
                  >
                    <div className="flex items-center justify-between">
                      <span
                        className={`font-bold px-2 py-0.5 rounded text-[11px] ${
                          mov.type === 'SALE'
                            ? 'bg-rose-100 text-rose-800'
                            : mov.type === 'RESTOCK'
                            ? 'bg-emerald-100 text-emerald-800'
                            : 'bg-sky-100 text-sky-800'
                        }`}
                      >
                        {mov.type}
                      </span>
                      <span className="text-slate-400 text-[11px]">{formatDate(mov.createdAt)}</span>
                    </div>
                    <div className="flex items-center justify-between font-medium text-slate-700 pt-1">
                      <span>Stock: {mov.previousStock} → {mov.resultingStock}</span>
                      <span className="font-bold text-slate-900">
                        {mov.type === 'SALE' ? `-${mov.quantity}` : `+${mov.quantity}`}
                      </span>
                    </div>
                    <p className="text-slate-500 italic text-[11px]">{mov.reason}</p>
                  </div>
                ))
              )}
            </div>

            <div className="p-4 border-t border-slate-100 flex justify-end">
              <Button variant="outline" size="sm" onClick={() => setViewingHistoryProduct(null)}>
                Close
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
