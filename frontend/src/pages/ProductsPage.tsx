import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Search, Boxes, Edit2, Archive } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { ErrorState } from '@/components/ui/ErrorState';
import { EmptyState } from '@/components/ui/EmptyState';
import { formatCurrency } from '@/lib/utils';
import { useProducts } from '@/hooks/useProducts';
import { ProductModel, ProductCategory } from '@/models/product';

export const ProductsPage: React.FC = () => {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [selectedCat, setSelectedCat] = useState('All');
  const [editingProduct, setEditingProduct] = useState<ProductModel | null>(null);
  const [editFormData, setEditFormData] = useState({
    name: '',
    category: 'Groceries' as ProductCategory,
    sellingPrice: '',
    costPrice: '',
    minStockThreshold: '',
  });
  const [editError, setEditError] = useState<string | null>(null);
  const [isUpdating, setIsUpdating] = useState(false);

  const categories = ['All', 'Groceries', 'Beverages', 'FMCG', 'Personal Care', 'Electronics', 'Clothing', 'Hardware', 'Other'];

  const {
    products,
    loading,
    error,
    refetch,
    updateProduct,
    archiveProduct,
  } = useProducts({
    q: search,
    category: selectedCat,
  });

  const handleOpenEdit = (p: ProductModel) => {
    setEditingProduct(p);
    setEditFormData({
      name: p.name,
      category: p.category,
      sellingPrice: p.sellingPrice.toString(),
      costPrice: (p.costPrice ?? p.purchasePrice ?? 0).toString(),
      minStockThreshold: (p.minStockThreshold ?? 5).toString(),
    });
    setEditError(null);
  };

  const handleSaveEdit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingProduct) return;
    if (!editFormData.name.trim()) {
      setEditError('Product name is required');
      return;
    }

    setIsUpdating(true);
    setEditError(null);
    try {
      await updateProduct(editingProduct.id, {
        name: editFormData.name.trim(),
        category: editFormData.category,
        sellingPrice: Number(editFormData.sellingPrice) || 0,
        costPrice: Number(editFormData.costPrice) || 0,
        minStockThreshold: Number(editFormData.minStockThreshold) || 5,
      });
      setEditingProduct(null);
    } catch (err: unknown) {
      setEditError(err instanceof Error ? err.message : 'Failed to update product');
    } finally {
      setIsUpdating(false);
    }
  };

  const handleArchive = async (id: string, name: string) => {
    if (window.confirm(`Are you sure you want to archive "${name}"?`)) {
      try {
        await archiveProduct(id);
      } catch (err: unknown) {
        alert(err instanceof Error ? err.message : 'Failed to archive product');
      }
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Product Catalog</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Define pricing, profit margins, bar codes, and master catalog details.
          </p>
        </div>

        <Button
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
          onClick={() => navigate('/products/add')}
        >
          Add Product
        </Button>
      </div>

      {/* Search and Filters */}
      <Card className="p-4 space-y-3">
        <div className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              type="text"
              placeholder="Search catalog by name or SKU..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full h-10 pl-10 pr-4 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:bg-white transition-all text-slate-800 placeholder:text-slate-400"
            />
          </div>

          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setSelectedCat(cat)}
                className={`px-3 py-1.5 text-xs font-semibold rounded-xl transition-colors shrink-0 ${
                  selectedCat === cat
                    ? 'bg-slate-900 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {/* Content State */}
      {loading ? (
        <div className="py-16 flex flex-col items-center justify-center">
          <LoadingSpinner size="lg" />
          <p className="text-xs text-slate-500 mt-3 font-medium">Loading catalog records from database...</p>
        </div>
      ) : error ? (
        <ErrorState
          title="Unable to load product catalog"
          message={error}
          onRetry={refetch}
        />
      ) : products.length === 0 ? (
        <EmptyState
          icon={Boxes}
          title="No products in catalog"
          description={
            search || selectedCat !== 'All'
              ? 'No products matched your search or category filter.'
              : 'Your store catalog is currently empty. Add your first product to begin tracking sales and inventory.'
          }
          actionLabel="Add First Product"
          onAction={() => navigate('/products/add')}
        />
      ) : (
        /* Catalog Table */
        <Card padded={false} className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs md:text-sm">
            <thead>
              <tr className="border-b border-slate-200 bg-slate-50/75 text-slate-600 font-semibold uppercase tracking-wider text-[11px]">
                <th className="py-3.5 px-4 md:px-6">Product & SKU</th>
                <th className="py-3.5 px-4">Category</th>
                <th className="py-3.5 px-4">Cost Price</th>
                <th className="py-3.5 px-4">Selling Price</th>
                <th className="py-3.5 px-4">Profit Margin</th>
                <th className="py-3.5 px-4">In Stock</th>
                <th className="py-3.5 px-4 md:px-6 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {products.map((product) => {
                const cost = product.costPrice ?? product.purchasePrice ?? 0;
                const selling = product.sellingPrice || 0;
                const profit = selling - cost;
                const marginPercent = selling > 0 ? ((profit / selling) * 100).toFixed(1) : '0.0';
                const stock = product.stockQuantity ?? product.currentStock ?? 0;

                return (
                  <tr key={product.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-4 md:px-6">
                      <p className="font-bold text-slate-900">{product.name}</p>
                      <p className="text-[11px] font-mono text-slate-400 mt-0.5">{product.sku}</p>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center px-2 py-0.5 rounded-md bg-slate-100 text-slate-700 text-xs font-medium">
                        {product.category}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-medium text-slate-600">
                      {formatCurrency(cost)}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      {formatCurrency(selling)}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className={`font-semibold ${profit >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {profit >= 0 ? `+${marginPercent}%` : `${marginPercent}%`} ({formatCurrency(profit)})
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="font-semibold text-slate-800">
                        {stock} {product.unit || 'pcs'}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 md:px-6 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Button
                          variant="outline"
                          size="sm"
                          className="h-8 text-xs px-2.5 gap-1"
                          onClick={() => handleOpenEdit(product)}
                        >
                          <Edit2 className="w-3 h-3" /> Edit
                        </Button>
                        <button
                          onClick={() => handleArchive(product.id, product.name)}
                          className="p-1.5 text-slate-400 hover:text-rose-600 rounded-lg hover:bg-rose-50 transition-colors"
                          title="Archive Product"
                        >
                          <Archive className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </Card>
      )}

      {/* Edit Product Modal */}
      {editingProduct && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-xl border border-slate-200 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <h3 className="font-bold text-slate-900 text-lg">Edit Product Details</h3>
              <button
                onClick={() => setEditingProduct(null)}
                className="text-slate-400 hover:text-slate-600 text-sm font-semibold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveEdit} className="p-6 space-y-4">
              {editError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold">
                  {editError}
                </div>
              )}

              <Input
                label="Product Name"
                required
                value={editFormData.name}
                onChange={(e) => setEditFormData({ ...editFormData, name: e.target.value })}
              />

              <div className="space-y-1.5">
                <label htmlFor="edit-category" className="block text-sm font-medium text-slate-700">Category</label>
                <select
                  id="edit-category"
                  value={editFormData.category}
                  onChange={(e) => setEditFormData({ ...editFormData, category: e.target.value as ProductCategory })}
                  className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7]"
                >
                  {categories.filter((c) => c !== 'All').map((cat) => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <Input
                  label="Cost Price (₹)"
                  type="number"
                  step="0.01"
                  required
                  value={editFormData.costPrice}
                  onChange={(e) => setEditFormData({ ...editFormData, costPrice: e.target.value })}
                />
                <Input
                  label="Selling Price (₹)"
                  type="number"
                  step="0.01"
                  required
                  value={editFormData.sellingPrice}
                  onChange={(e) => setEditFormData({ ...editFormData, sellingPrice: e.target.value })}
                />
              </div>

              <Input
                label="Low Stock Alert Threshold"
                type="number"
                value={editFormData.minStockThreshold}
                onChange={(e) => setEditFormData({ ...editFormData, minStockThreshold: e.target.value })}
              />

              <div className="flex items-center justify-end gap-3 pt-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setEditingProduct(null)}
                  disabled={isUpdating}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  isLoading={isUpdating}
                >
                  Save Changes
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
