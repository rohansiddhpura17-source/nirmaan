import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, User, Store, Phone, ArrowRight, AlertCircle } from 'lucide-react';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { useAuth } from '@/context/AuthContext';
import { UserRole } from '@/models/user';

export const RegisterPage: React.FC = () => {
  const navigate = useNavigate();
  const { register, error, clearError } = useAuth();

  const [name, setName] = useState('');
  const [businessName, setBusinessName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [selectedRole, setSelectedRole] = useState<UserRole>('BUSINESS_OWNER');
  const [localError, setLocalError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLocalError(null);
    clearError();

    if (!name.trim()) {
      setLocalError('Please enter your full name');
      return;
    }
    if (!email.trim()) {
      setLocalError('Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      setLocalError('Password must be at least 6 characters long');
      return;
    }

    setIsLoading(true);
    try {
      const user = await register({
        name,
        businessName,
        email,
        phone,
        password,
        role: selectedRole,
      });

      // Flow: If business setup is complete, go to dashboard; otherwise go to /business-setup
      if (user.setupComplete) {
        navigate('/dashboard');
      } else {
        navigate('/business-setup');
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Registration failed. Please try again.';
      setLocalError(msg);
    } finally {
      setIsLoading(false);
    }
  };

  const displayError = localError || error;

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <h2 className="text-xl font-bold text-slate-900 tracking-tight">Create your account</h2>
        <p className="text-xs text-slate-500 mt-1">
          Register your retail store and initialize your smart business operating system.
        </p>
      </div>

      {displayError && (
        <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2">
          <AlertCircle className="w-4 h-4 text-rose-500 shrink-0 mt-0.5" />
          <span>{displayError}</span>
        </div>
      )}

      <div className="space-y-3.5">
        <Input
          label="Full Name"
          type="text"
          required
          value={name}
          onChange={(e) => setName(e.target.value)}
          leftIcon={<User className="w-4 h-4" />}
          placeholder="e.g. Rajesh Sharma"
        />

        <Input
          label="Store / Business Name"
          type="text"
          value={businessName}
          onChange={(e) => setBusinessName(e.target.value)}
          leftIcon={<Store className="w-4 h-4" />}
          placeholder="e.g. Kirana King Store"
        />

        <Input
          label="Email address"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          leftIcon={<Mail className="w-4 h-4" />}
          placeholder="owner@store.com"
        />

        <Input
          label="Phone Number"
          type="tel"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          leftIcon={<Phone className="w-4 h-4" />}
          placeholder="+91 98765 43210"
        />

        <Input
          label="Password (min 6 characters)"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          leftIcon={<Lock className="w-4 h-4" />}
          placeholder="••••••••"
        />

        <div className="space-y-1.5">
          <label htmlFor="reg-role" className="block text-sm font-medium text-slate-700">
            Account Role
          </label>
          <select
            id="reg-role"
            value={selectedRole}
            onChange={(e) => setSelectedRole(e.target.value as UserRole)}
            className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:border-[#0284C7]"
          >
            <option value="BUSINESS_OWNER">Business Owner (Full BI & Administration)</option>
            <option value="STORE_MANAGER">Store Manager (Operations & Inventory)</option>
            <option value="SALES_STAFF">Sales Staff (POS Billing & Orders)</option>
          </select>
          <p className="text-[11px] text-slate-400">
            * Administrator role cannot be self-registered and requires system governance authorization.
          </p>
        </div>
      </div>

      <Button
        type="submit"
        variant="primary"
        size="lg"
        className="w-full mt-2"
        isLoading={isLoading}
        rightIcon={<ArrowRight className="w-4 h-4" />}
      >
        Continue to Business Setup
      </Button>

      <div className="pt-2 text-center text-xs text-slate-500">
        Already have an account?{' '}
        <Link to="/login" className="text-sky-600 font-semibold hover:underline">
          Sign In
        </Link>
      </div>
    </form>
  );
};
