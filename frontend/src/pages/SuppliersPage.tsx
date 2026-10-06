import React, { useState } from 'react';
import { Truck, Search, Plus, Phone, Mail, MapPin, CheckCircle2, XCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { ErrorState } from '@/components/ui/ErrorState';
import { EmptyState } from '@/components/ui/EmptyState';
import { useSuppliers } from '@/hooks/useSuppliers';
import { SupplierModel } from '@/models/supplier';

export const SuppliersPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSupplier, setEditingSupplier] = useState<SupplierModel | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: '',
    address: '',
    category: 'General Goods',
  });
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    suppliers,
    loading,
    error,
    refetch,
    createSupplier,
    updateSupplier,
    deactivateSupplier,
  } = useSuppliers({ q: search, status: statusFilter });

  const activeCount = suppliers.filter((s) => s.status === 'ACTIVE').length;

  const handleOpenAdd = () => {
    setEditingSupplier(null);
    setFormData({
      name: '',
      phone: '',
      email: '',
      address: '',
      category: 'General Goods',
    });
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (sup: SupplierModel) => {
    setEditingSupplier(sup);
    setFormData({
      name: sup.name,
      phone: sup.phone,
      email: sup.email || '',
      address: sup.address || '',
      category: sup.category || 'General Goods',
    });
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleSaveSupplier = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      setFormError('Supplier name is required');
      return;
    }
    if (!formData.phone.trim()) {
      setFormError('Phone number is required');
      return;
    }

    setIsSubmitting(true);
    setFormError(null);
    try {
      if (editingSupplier) {
        await updateSupplier(editingSupplier.id, formData);
      } else {
        await createSupplier(formData);
      }
      setIsModalOpen(false);
    } catch (err: unknown) {
      setFormError(err instanceof Error ? err.message : 'Failed to save supplier');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleToggleStatus = async (sup: SupplierModel) => {
    try {
      if (sup.status === 'ACTIVE') {
        await deactivateSupplier(sup.id);
      } else {
        await updateSupplier(sup.id, { status: 'ACTIVE' });
      }
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Failed to update status');
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Suppliers & Vendors</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Manage procurement contacts, distributor directories, and supply contracts.
          </p>
        </div>

        <Button
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
          onClick={handleOpenAdd}
        >
          Add Supplier
        </Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <Card className="p-4">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Suppliers</p>
          <p className="text-2xl font-bold text-slate-900 mt-1">{suppliers.length}</p>
        </Card>
        <Card className="p-4 border-l-4 border-l-emerald-500">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Active Supply Partners</p>
          <p className="text-2xl font-bold text-emerald-600 mt-1">{activeCount}</p>
        </Card>
      </div>

      {/* Search and Filter */}
      <Card className="p-4">
        <div className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              type="text"
              placeholder="Search by supplier name, phone, or category..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full h-10 pl-10 pr-4 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:bg-white transition-all text-slate-800 placeholder:text-slate-400"
            />
          </div>

          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
            {['ALL', 'ACTIVE', 'INACTIVE'].map((status) => (
              <button
                key={status}
                onClick={() => setStatusFilter(status)}
                className={`px-3 py-1.5 text-xs font-semibold rounded-xl transition-colors shrink-0 ${
                  statusFilter === status
                    ? 'bg-slate-900 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {status === 'ALL' ? 'All Vendors' : status}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {/* Body Content */}
      {loading ? (
        <div className="py-16 flex flex-col items-center justify-center">
          <LoadingSpinner size="lg" />
          <p className="text-xs text-slate-500 mt-3 font-medium">Loading verified supplier directory...</p>
        </div>
      ) : error ? (
        <ErrorState
          title="Unable to load suppliers"
          message={error}
          onRetry={refetch}
        />
      ) : suppliers.length === 0 ? (
        <EmptyState
          icon={Truck}
          title="No suppliers found"
          description={
            search || statusFilter !== 'ALL'
              ? 'No suppliers match your current filter query.'
              : 'Add your distributor and wholesale suppliers to keep purchasing organized.'
          }
          actionLabel="Add First Supplier"
          onAction={handleOpenAdd}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {suppliers.map((sup) => (
            <Card key={sup.id} className="p-5 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-bold text-slate-900 text-base">{sup.name}</h3>
                    <Badge variant={sup.status === 'ACTIVE' ? 'success' : 'neutral'} size="sm">
                      {sup.status}
                    </Badge>
                  </div>
                  <p className="text-xs text-slate-500 font-medium">Category: {sup.category || 'General'}</p>
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  className="h-8 text-xs px-2.5"
                  onClick={() => handleOpenEdit(sup)}
                >
                  Edit
                </Button>
              </div>

              <div className="mt-3 pt-3 border-t border-slate-100 space-y-1 text-xs text-slate-600">
                <p className="flex items-center gap-2">
                  <Phone className="w-3.5 h-3.5 text-slate-400" />
                  <span>{sup.phone}</span>
                </p>
                {sup.email && (
                  <p className="flex items-center gap-2">
                    <Mail className="w-3.5 h-3.5 text-slate-400" />
                    <span>{sup.email}</span>
                  </p>
                )}
                {sup.address && (
                  <p className="flex items-center gap-2">
                    <MapPin className="w-3.5 h-3.5 text-slate-400" />
                    <span className="truncate">{sup.address}</span>
                  </p>
                )}
              </div>

              <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between">
                <span className="text-[11px] text-slate-400 font-mono">ID: {sup.id}</span>
                <button
                  onClick={() => handleToggleStatus(sup)}
                  className={`text-xs font-medium flex items-center gap-1 ${
                    sup.status === 'ACTIVE'
                      ? 'text-rose-600 hover:text-rose-700'
                      : 'text-emerald-600 hover:text-emerald-700'
                  }`}
                >
                  {sup.status === 'ACTIVE' ? (
                    <>
                      <XCircle className="w-3.5 h-3.5" /> Deactivate
                    </>
                  ) : (
                    <>
                      <CheckCircle2 className="w-3.5 h-3.5" /> Re-activate
                    </>
                  )}
                </button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Add / Edit Supplier Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-xl border border-slate-200 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <h3 className="font-bold text-slate-900 text-lg">
                {editingSupplier ? 'Edit Supplier' : 'Add New Supplier'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 text-sm font-semibold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveSupplier} className="p-6 space-y-4">
              {formError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold">
                  {formError}
                </div>
              )}

              <Input
                label="Supplier / Company Name"
                required
                placeholder="e.g. Metro Cash & Carry Wholesale"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              />

              <Input
                label="Phone Contact"
                required
                placeholder="+91 99000 11223"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              />

              <Input
                label="Email (Optional)"
                type="email"
                placeholder="vendor@example.com"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              />

              <Input
                label="Address / Depot Location"
                placeholder="e.g. APMC Market, Yard 4"
                value={formData.address}
                onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              />

              <Input
                label="Category / Specialization"
                placeholder="e.g. FMCG & Staples"
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
              />

              <div className="flex items-center justify-end gap-3 pt-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsModalOpen(false)}
                  disabled={isSubmitting}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  isLoading={isSubmitting}
                >
                  {editingSupplier ? 'Save Changes' : 'Create Supplier'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
