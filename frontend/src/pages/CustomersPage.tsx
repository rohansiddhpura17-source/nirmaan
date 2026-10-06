import React, { useState } from 'react';
import { Search, Plus, Phone, MessageSquare, Users, Edit2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { ErrorState } from '@/components/ui/ErrorState';
import { EmptyState } from '@/components/ui/EmptyState';
import { formatCurrency } from '@/lib/utils';
import { useCustomers } from '@/hooks/useCustomers';
import { CustomerModel } from '@/models/customer';

export const CustomersPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCustomer, setEditingCustomer] = useState<CustomerModel | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: '',
    address: '',
    outstandingCredit: '0',
  });
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    customers,
    loading,
    error,
    refetch,
    createCustomer,
    updateCustomer,
  } = useCustomers({ q: search });

  const totalOutstanding = customers.reduce((sum, c) => sum + (c.outstandingCredit || 0), 0);
  const totalLifetimePurchases = customers.reduce((sum, c) => sum + (c.totalPurchases || c.totalSpend || 0), 0);

  const handleOpenAdd = () => {
    setEditingCustomer(null);
    setFormData({
      name: '',
      phone: '',
      email: '',
      address: '',
      outstandingCredit: '0',
    });
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (cust: CustomerModel) => {
    setEditingCustomer(cust);
    setFormData({
      name: cust.name,
      phone: cust.phone,
      email: cust.email || '',
      address: cust.address || '',
      outstandingCredit: (cust.outstandingCredit || 0).toString(),
    });
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleSaveCustomer = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      setFormError('Customer name is required');
      return;
    }
    if (!formData.phone.trim()) {
      setFormError('Valid phone number is required');
      return;
    }

    setIsSubmitting(true);
    setFormError(null);
    try {
      if (editingCustomer) {
        await updateCustomer(editingCustomer.id, {
          name: formData.name.trim(),
          phone: formData.phone.trim(),
          email: formData.email.trim() || undefined,
          address: formData.address.trim() || undefined,
          outstandingCredit: Number(formData.outstandingCredit) || 0,
        });
      } else {
        await createCustomer({
          name: formData.name.trim(),
          phone: formData.phone.trim(),
          email: formData.email.trim() || undefined,
          address: formData.address.trim() || undefined,
          outstandingCredit: Number(formData.outstandingCredit) || 0,
        });
      }
      setIsModalOpen(false);
    } catch (err: unknown) {
      setFormError(err instanceof Error ? err.message : 'Failed to save customer');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">
            Customers & Khata Ledger
          </h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Manage your store directory, track store credit, and foster loyal shoppers.
          </p>
        </div>

        <Button
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
          onClick={handleOpenAdd}
        >
          Add Customer
        </Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="p-4">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Customer Accounts</p>
          <p className="text-2xl font-bold text-slate-900 mt-1">{customers.length}</p>
        </Card>
        <Card className="p-4 border-l-4 border-l-rose-500">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Outstanding Khata</p>
          <p className="text-2xl font-bold text-rose-600 mt-1">{formatCurrency(totalOutstanding)}</p>
        </Card>
        <Card className="p-4 border-l-4 border-l-emerald-500">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Customer Lifetime Value</p>
          <p className="text-2xl font-bold text-emerald-600 mt-1">{formatCurrency(totalLifetimePurchases)}</p>
        </Card>
      </div>

      {/* Search Input */}
      <Card className="p-4">
        <div className="relative">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          <input
            type="text"
            placeholder="Search customers by name or phone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full h-10 pl-10 pr-4 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:bg-white transition-all text-slate-800 placeholder:text-slate-400"
          />
        </div>
      </Card>

      {/* Content State */}
      {loading ? (
        <div className="py-16 flex flex-col items-center justify-center">
          <LoadingSpinner size="lg" />
          <p className="text-xs text-slate-500 mt-3 font-medium">Loading customer accounts from database...</p>
        </div>
      ) : error ? (
        <ErrorState
          title="Unable to load customer directory"
          message={error}
          onRetry={refetch}
        />
      ) : customers.length === 0 ? (
        <EmptyState
          icon={Users}
          title="No customer accounts found"
          description={
            search
              ? 'No customer accounts matched your search keyword.'
              : 'You do not have any registered customer profiles yet. Add your regular shoppers to maintain a khata ledger.'
          }
          actionLabel="Add First Customer"
          onAction={handleOpenAdd}
        />
      ) : (
        /* Customer Directory */
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {customers.map((cust) => {
            const credit = cust.outstandingCredit || 0;
            const purchases = cust.totalPurchases || cust.totalSpend || 0;

            return (
              <Card key={cust.id} className="p-5 hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <h3 className="font-bold text-slate-900 text-base">{cust.name}</h3>
                      {credit > 0 && (
                        <Badge variant="error" size="sm">
                          Credit Due
                        </Badge>
                      )}
                    </div>
                    <p className="text-xs text-slate-500 flex items-center gap-1.5">
                      <Phone className="w-3.5 h-3.5 text-slate-400" />
                      {cust.phone}
                    </p>
                    {cust.address && (
                      <p className="text-xs text-slate-400 truncate max-w-xs">{cust.address}</p>
                    )}
                  </div>

                  <div className="text-right">
                    <p className="text-[11px] text-slate-400 font-medium">Khata Balance</p>
                    <p
                      className={`text-base font-bold ${
                        credit > 0 ? 'text-rose-600' : 'text-emerald-600'
                      }`}
                    >
                      {formatCurrency(credit)}
                    </p>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t border-slate-100 flex items-center justify-between text-xs">
                  <div className="text-slate-500">
                    Lifetime: <strong className="text-slate-700">{formatCurrency(purchases)}</strong> • {cust.orderCount || 0} orders
                  </div>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      className="h-8 px-2 text-xs gap-1"
                      onClick={() => handleOpenEdit(cust)}
                    >
                      <Edit2 className="w-3 h-3" /> Edit
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      className="h-8 px-2.5 text-xs gap-1 text-slate-600"
                      onClick={() => alert(`Calling ${cust.phone}`)}
                    >
                      <Phone className="w-3 h-3" /> Call
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      className="h-8 px-2.5 text-xs gap-1 text-emerald-700 border-emerald-300 bg-emerald-50 hover:bg-emerald-100"
                      onClick={() => alert(`Opening WhatsApp for ${cust.name}`)}
                    >
                      <MessageSquare className="w-3 h-3" /> WhatsApp
                    </Button>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* Add / Edit Customer Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-xl border border-slate-200 overflow-hidden">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
              <h3 className="font-bold text-slate-900 text-lg">
                {editingCustomer ? 'Edit Customer Details' : 'Add New Customer Profile'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 text-sm font-semibold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveCustomer} className="p-6 space-y-4">
              {formError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold">
                  {formError}
                </div>
              )}

              <Input
                label="Customer Full Name"
                required
                placeholder="e.g. Ramesh Patel"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              />

              <Input
                label="Phone Contact"
                required
                placeholder="+91 98200 12345"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              />

              <Input
                label="Email (Optional)"
                type="email"
                placeholder="customer@example.com"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              />

              <Input
                label="Home / Shop Address"
                placeholder="e.g. Flat 402, Green Avenue"
                value={formData.address}
                onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              />

              <Input
                label="Initial Khata Credit Balance (₹)"
                type="number"
                placeholder="0"
                value={formData.outstandingCredit}
                onChange={(e) => setFormData({ ...formData, outstandingCredit: e.target.value })}
                helperText="Enter current unpaid credit balance if migrating existing ledger."
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
                  {editingCustomer ? 'Save Changes' : 'Save Customer'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
