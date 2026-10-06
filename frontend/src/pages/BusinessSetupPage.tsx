import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  Store,
  Phone,
  MapPin,
  Building,
  ArrowRight,
  AlertCircle,
  CheckCircle2,
  User,
  Mail,
  IndianRupee,
  RotateCcw,
} from 'lucide-react';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { useAuth } from '@/context/AuthContext';

const DRAFT_STORAGE_KEY = 'nirmaan_setup_draft';
const GSTIN_REGEX = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
const PHONE_REGEX = /^[+]?[\d\s-]{10,15}$/;

export const BusinessSetupPage: React.FC = () => {
  const navigate = useNavigate();
  const { user, completeBusinessSetup, error: authError, clearError } = useAuth();

  // If user setup is already complete, redirect to dashboard immediately
  useEffect(() => {
    if (user?.setupComplete) {
      navigate('/dashboard', { replace: true });
    }
  }, [user?.setupComplete, navigate]);

  // Initialize form from sessionStorage draft or authenticated user profile
  const [formData, setFormData] = useState(() => {
    try {
      const saved = sessionStorage.getItem(DRAFT_STORAGE_KEY);
      if (saved) {
        const parsed = JSON.parse(saved);
        return {
          businessName: parsed.businessName || '',
          category: parsed.category || 'Groceries & Kirana',
          ownerName: parsed.ownerName || user?.displayName || '',
          phone: parsed.phone || user?.phone || '',
          address: parsed.address || '',
          gstNumber: parsed.gstNumber || '',
          currency: parsed.currency || 'INR',
        };
      }
    } catch {
      // Ignore storage read error
    }

    return {
      businessName: '',
      category: 'Groceries & Kirana',
      ownerName: user?.displayName || '',
      phone: user?.phone || '',
      address: '',
      gstNumber: '',
      currency: 'INR',
    };
  });

  // Keep ownerName and phone in sync if user profile loads after mount
  useEffect(() => {
    if (user) {
      setFormData((prev) => ({
        ...prev,
        ownerName: prev.ownerName || user.displayName || '',
        phone: prev.phone || user.phone || '',
      }));
    }
  }, [user]);

  // Persist form draft on changes so reload doesn't lose user input
  useEffect(() => {
    try {
      sessionStorage.setItem(DRAFT_STORAGE_KEY, JSON.stringify(formData));
    } catch {
      // Ignore storage write error
    }
  }, [formData]);

  const [fieldErrors, setFieldErrors] = useState<{
    businessName?: string;
    category?: string;
    ownerName?: string;
    phone?: string;
    address?: string;
    gstNumber?: string;
  }>({});

  const [localError, setLocalError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const validateForm = useCallback((): boolean => {
    const errors: typeof fieldErrors = {};

    if (!formData.businessName.trim()) {
      errors.businessName = 'Business or store name is required';
    } else if (formData.businessName.trim().length < 2) {
      errors.businessName = 'Business name must be at least 2 characters';
    }

    if (!formData.ownerName.trim()) {
      errors.ownerName = 'Owner / manager name is required';
    } else if (formData.ownerName.trim().length < 2) {
      errors.ownerName = 'Owner name must be at least 2 characters';
    }

    const cleanPhone = formData.phone.trim();
    if (!cleanPhone) {
      errors.phone = 'Store contact number is required';
    } else if (!PHONE_REGEX.test(cleanPhone)) {
      errors.phone = 'Please enter a valid 10-15 digit phone number';
    }

    if (!formData.address.trim()) {
      errors.address = 'Store address and city are required';
    } else if (formData.address.trim().length < 5) {
      errors.address = 'Store address must be at least 5 characters';
    }

    if (formData.gstNumber.trim()) {
      const upperGst = formData.gstNumber.trim().toUpperCase();
      if (!GSTIN_REGEX.test(upperGst)) {
        errors.gstNumber = 'Invalid 15-character GSTIN format (e.g. 24ABCDE1234F1Z5)';
      }
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  }, [formData]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Prevent duplicate submission while saving
    if (isSubmitting || isSuccess) return;

    setLocalError(null);
    clearError();

    if (!validateForm()) {
      setLocalError('Please fix the validation errors below before proceeding.');
      return;
    }

    setIsSubmitting(true);
    try {
      await completeBusinessSetup({
        businessName: formData.businessName.trim(),
        businessCategory: formData.category,
        ownerName: formData.ownerName.trim(),
        phone: formData.phone.trim(),
        address: formData.address.trim(),
        gstNumber: formData.gstNumber.trim() ? formData.gstNumber.trim().toUpperCase() : undefined,
        currency: formData.currency,
      });

      // Clear draft on successful completion
      try {
        sessionStorage.removeItem(DRAFT_STORAGE_KEY);
      } catch {
        // Ignore
      }

      setIsSuccess(true);

      // Smooth transition to dashboard
      setTimeout(() => {
        navigate('/dashboard', { replace: true });
      }, 500);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to complete business setup. Please try again.';
      setLocalError(msg);
      setIsSubmitting(false);
    }
  };

  const handleRetry = () => {
    setLocalError(null);
    clearError();
    const fakeEvent = { preventDefault: () => {} } as React.FormEvent;
    handleSubmit(fakeEvent);
  };

  const displayError = localError || authError;

  return (
    <form onSubmit={handleSubmit} className="space-y-5" noValidate>
      <div>
        <h2 className="text-xl font-bold text-slate-900 tracking-tight">Business Setup</h2>
        <p className="text-xs text-slate-500 mt-1">
          Configure your store profile to initialize inventory, analytics, and POS settings.
        </p>
      </div>

      {/* Success Banner */}
      {isSuccess && (
        <div
          data-testid="setup-success-banner"
          className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 flex items-center gap-2.5 animate-fadeIn"
        >
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span className="font-medium">Store profile configured successfully! Launching your dashboard...</span>
        </div>
      )}

      {/* Error Alert Banner */}
      {displayError && !isSuccess && (
        <div
          data-testid="setup-error-banner"
          className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start justify-between gap-2 animate-fadeIn"
        >
          <div className="flex items-start gap-2">
            <AlertCircle className="w-4 h-4 text-rose-500 shrink-0 mt-0.5" />
            <span data-testid="setup-error-message">{displayError}</span>
          </div>
          <button
            type="button"
            id="btn-retry-setup"
            data-testid="btn-retry-setup"
            onClick={handleRetry}
            className="shrink-0 text-xs font-semibold text-rose-700 hover:text-rose-900 underline flex items-center gap-1"
          >
            <RotateCcw className="w-3 h-3" />
            Retry
          </button>
        </div>
      )}

      <div className="space-y-4">
        {/* Business Name */}
        <Input
          id="business-name"
          data-testid="input-business-name"
          label="Business / Store Name *"
          required
          value={formData.businessName}
          onChange={(e) => {
            setFormData({ ...formData, businessName: e.target.value });
            if (fieldErrors.businessName) setFieldErrors({ ...fieldErrors, businessName: undefined });
          }}
          error={fieldErrors.businessName}
          leftIcon={<Store className="w-4 h-4" />}
          placeholder="e.g. Sharma Kirana Store"
          disabled={isSubmitting || isSuccess}
        />

        {/* Business Category */}
        <div className="space-y-1.5">
          <label htmlFor="business-category" className="block text-sm font-medium text-slate-700">
            Business Category *
          </label>
          <select
            id="business-category"
            data-testid="select-business-category"
            value={formData.category}
            onChange={(e) => setFormData({ ...formData, category: e.target.value })}
            disabled={isSubmitting || isSuccess}
            className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:border-[#0284C7] transition-all"
          >
            <option value="Groceries & Kirana">Groceries & Kirana</option>
            <option value="Grocery & FMCG">Grocery & FMCG</option>
            <option value="Retail & Apparel">Retail & Apparel</option>
            <option value="Electronics & Hardware">Electronics & Hardware</option>
            <option value="Pharmacy & Health">Pharmacy & Health</option>
            <option value="Food & Beverage">Food & Beverage</option>
            <option value="Wholesale & Trade">Wholesale & Trade</option>
            <option value="General Retail">General Retail</option>
          </select>
        </div>

        {/* Owner Information */}
        <Input
          id="owner-name"
          data-testid="input-owner-name"
          label="Owner / Manager Name *"
          required
          value={formData.ownerName}
          onChange={(e) => {
            setFormData({ ...formData, ownerName: e.target.value });
            if (fieldErrors.ownerName) setFieldErrors({ ...fieldErrors, ownerName: undefined });
          }}
          error={fieldErrors.ownerName}
          leftIcon={<User className="w-4 h-4" />}
          placeholder="e.g. Ramesh Patel"
          disabled={isSubmitting || isSuccess}
        />

        {/* Account Email (Read-only reference) */}
        <Input
          id="owner-email"
          data-testid="input-owner-email"
          label="Store Account Email"
          value={user?.email || 'owner@store.com'}
          readOnly
          disabled
          leftIcon={<Mail className="w-4 h-4" />}
          helperText="Authenticated account email for administrative access"
        />

        {/* Phone / WhatsApp */}
        <Input
          id="store-phone"
          data-testid="input-store-phone"
          label="Store Phone Number / WhatsApp *"
          type="tel"
          required
          value={formData.phone}
          onChange={(e) => {
            setFormData({ ...formData, phone: e.target.value });
            if (fieldErrors.phone) setFieldErrors({ ...fieldErrors, phone: undefined });
          }}
          error={fieldErrors.phone}
          leftIcon={<Phone className="w-4 h-4" />}
          placeholder="+91 98765 43210"
          disabled={isSubmitting || isSuccess}
        />

        {/* Address */}
        <Input
          id="store-address"
          data-testid="input-store-address"
          label="Store Address & City *"
          required
          value={formData.address}
          onChange={(e) => {
            setFormData({ ...formData, address: e.target.value });
            if (fieldErrors.address) setFieldErrors({ ...fieldErrors, address: undefined });
          }}
          error={fieldErrors.address}
          leftIcon={<MapPin className="w-4 h-4" />}
          placeholder="Shop No., Street, Area, City"
          disabled={isSubmitting || isSuccess}
        />

        {/* GSTIN (Optional) */}
        <Input
          id="gst-number"
          data-testid="input-gst-number"
          label="GSTIN / Business Registration (Optional)"
          value={formData.gstNumber}
          onChange={(e) => {
            setFormData({ ...formData, gstNumber: e.target.value });
            if (fieldErrors.gstNumber) setFieldErrors({ ...fieldErrors, gstNumber: undefined });
          }}
          error={fieldErrors.gstNumber}
          leftIcon={<Building className="w-4 h-4" />}
          placeholder="24ABCDE1234F1Z5"
          helperText="15-character GST identification number if registered"
          disabled={isSubmitting || isSuccess}
        />

        {/* Currency Display */}
        <div className="space-y-1.5">
          <label className="block text-sm font-medium text-slate-700">Store Currency</label>
          <div className="flex items-center gap-2 px-3.5 h-11 rounded-xl border border-slate-300 bg-slate-50 text-sm text-slate-700 font-medium">
            <IndianRupee className="w-4 h-4 text-slate-500" />
            <span>INR (₹) — Indian Rupee (Default)</span>
          </div>
        </div>
      </div>

      {/* Submit Button */}
      <Button
        id="btn-complete-setup"
        data-testid="btn-complete-setup"
        type="submit"
        variant="primary"
        size="lg"
        className="w-full mt-2"
        isLoading={isSubmitting}
        disabled={isSubmitting || isSuccess}
        rightIcon={isSuccess ? <CheckCircle2 className="w-4 h-4" /> : <ArrowRight className="w-4 h-4" />}
      >
        {isSuccess ? 'Store Ready! Opening...' : isSubmitting ? 'Saving Store Profile...' : 'Complete Setup & Open Store'}
      </Button>

      <div className="pt-2 text-center text-xs text-slate-500">
        Already configured?{' '}
        <Link to="/login" className="text-sky-600 font-semibold hover:underline">
          Return to Login
        </Link>
      </div>
    </form>
  );
};

export default BusinessSetupPage;
