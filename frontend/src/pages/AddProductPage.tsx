import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Barcode, Save, Sparkles, AlertCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { ProductCategory } from '@/models/product';
import { formatCurrency } from '@/lib/utils';
import { productService } from '@/services/productService';

export const AddProductPage: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    category: 'Groceries' as ProductCategory,
    sku: `SKU-${Math.floor(100000 + Math.random() * 900000)}`,
    barcode: '',
    costPrice: '',
    sellingPrice: '',
    stockQuantity: '',
    minThreshold: '5',
    unit: 'pack',
    description: '',
  });

  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const cost = parseFloat(formData.costPrice) || 0;
  const selling = parseFloat(formData.sellingPrice) || 0;
  const margin = selling > 0 ? (((selling - cost) / selling) * 100).toFixed(1) : '0';
  const profit = selling - cost;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      setFormError('Product name is required');
      return;
    }
    if (isNaN(selling) || selling < 0) {
      setFormError('Valid selling price is required');
      return;
    }

    setIsSubmitting(true);
    setFormError(null);
    try {
      await productService.createProduct({
        name: formData.name.trim(),
        category: formData.category,
        sku: formData.sku.trim().toUpperCase(),
        barcode: formData.barcode.trim() || undefined,
        costPrice: cost,
        purchasePrice: cost,
        sellingPrice: selling,
        stockQuantity: Number(formData.stockQuantity) || 0,
        currentStock: Number(formData.stockQuantity) || 0,
        minThreshold: Number(formData.minThreshold) || 5,
        minStockThreshold: Number(formData.minThreshold) || 5,
        unit: formData.unit,
        description: formData.description,
      });

      navigate('/products');
    } catch (err: unknown) {
      setFormError(err instanceof Error ? err.message : 'Failed to create product in catalog');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 rounded-xl text-slate-500 hover:text-slate-800 hover:bg-slate-100 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Add New Product</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Create a master catalog entry with automated stock threshold tracking.
          </p>
        </div>
      </div>

      {formError && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-sm flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
          <p className="font-semibold">{formError}</p>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Basic Details */}
        <Card className="space-y-4">
          <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
            General Information
          </h2>

          <Input
            label="Product Name"
            required
            placeholder="e.g. Tata Tea Gold 500g"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          />

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label htmlFor="product-category" className="block text-sm font-medium text-slate-700">Category</label>
              <select
                id="product-category"
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value as ProductCategory })}
                className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:border-[#0284C7]"
              >
                <option value="Groceries">Groceries</option>
                <option value="Beverages">Beverages</option>
                <option value="FMCG">FMCG</option>
                <option value="Personal Care">Personal Care</option>
                <option value="Electronics">Electronics</option>
                <option value="Clothing">Clothing</option>
                <option value="Hardware">Hardware</option>
                <option value="Other">Other</option>
              </select>
            </div>

            <div className="space-y-1.5">
              <label htmlFor="product-unit" className="block text-sm font-medium text-slate-700">Unit of Measure</label>
              <select
                id="product-unit"
                value={formData.unit}
                onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:border-[#0284C7]"
              >
                <option value="pack">Pack</option>
                <option value="bag">Bag</option>
                <option value="kg">Kilogram (kg)</option>
                <option value="pouch">Pouch</option>
                <option value="bottle">Bottle</option>
                <option value="piece">Piece (pc)</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Input
              label="SKU Code"
              required
              value={formData.sku}
              onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
            />

            <Input
              label="Barcode / EAN (Optional)"
              placeholder="Scan or enter 13-digit barcode"
              value={formData.barcode}
              onChange={(e) => setFormData({ ...formData, barcode: e.target.value })}
              rightIcon={<Barcode className="w-5 h-5 text-slate-400" />}
            />
          </div>
        </Card>

        {/* Pricing & Profit Margin */}
        <Card className="space-y-4">
          <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
            Pricing & Margin Analysis
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Input
              label="Cost Price (₹)"
              type="number"
              step="0.01"
              required
              placeholder="0.00"
              value={formData.costPrice}
              onChange={(e) => setFormData({ ...formData, costPrice: e.target.value })}
            />

            <Input
              label="Selling Price (MRP ₹)"
              type="number"
              step="0.01"
              required
              placeholder="0.00"
              value={formData.sellingPrice}
              onChange={(e) => setFormData({ ...formData, sellingPrice: e.target.value })}
            />
          </div>

          {/* Margin Live Calculation Card */}
          <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
            <div>
              <span className="text-slate-500">Gross Margin Estimate:</span>
              <span className="ml-2 font-bold text-emerald-600 text-sm">
                {margin}% ({formatCurrency(profit > 0 ? profit : 0)} profit/unit)
              </span>
            </div>
            <div className="flex items-center gap-1 text-indigo-600 font-semibold">
              <Sparkles className="w-3.5 h-3.5" /> AI Recommended: 15-20%
            </div>
          </div>
        </Card>

        {/* Stock & Reorder Thresholds */}
        <Card className="space-y-4">
          <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
            Initial Stock & Thresholds
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Input
              label="Initial Stock Quantity"
              type="number"
              required
              placeholder="0"
              value={formData.stockQuantity}
              onChange={(e) => setFormData({ ...formData, stockQuantity: e.target.value })}
            />

            <Input
              label="Low Stock Warning Alert Threshold"
              type="number"
              required
              placeholder="5"
              value={formData.minThreshold}
              onChange={(e) => setFormData({ ...formData, minThreshold: e.target.value })}
              helperText="You will be alerted when inventory reaches this level."
            />
          </div>
        </Card>

        {/* Actions */}
        <div className="flex items-center justify-end gap-3 pt-2">
          <Button type="button" variant="outline" onClick={() => navigate(-1)} disabled={isSubmitting}>
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            leftIcon={<Save className="w-4 h-4" />}
            isLoading={isSubmitting}
          >
            Save Product to Catalog
          </Button>
        </div>
      </form>
    </div>
  );
};
