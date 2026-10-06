import React, { useState } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { Mail, Lock, LogIn, AlertCircle } from 'lucide-react';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { useAuth } from '@/context/AuthContext';
import { UserRole } from '@/models/user';

export const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { login, error, clearError } = useAuth();

  const [email, setEmail] = useState('owner@nirmaan.com');
  const [password, setPassword] = useState('Password@123');
  const [selectedRole, setSelectedRole] = useState<UserRole>('BUSINESS_OWNER');
  const [localError, setLocalError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  // Quick-fill helper for demo accounts
  const handleRolePreset = (role: UserRole) => {
    setSelectedRole(role);
    clearError();
    setLocalError(null);
    switch (role) {
      case 'BUSINESS_OWNER':
        setEmail('owner@nirmaan.com');
        setPassword('Password@123');
        break;
      case 'STORE_MANAGER':
        setEmail('manager@nirmaan.com');
        setPassword('Password@123');
        break;
      case 'SALES_STAFF':
        setEmail('staff@nirmaan.com');
        setPassword('Password@123');
        break;
      case 'ADMINISTRATOR':
        setEmail('admin@nirmaan.com');
        setPassword('Password@123');
        break;
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLocalError(null);
    clearError();

    if (!email.trim()) {
      setLocalError('Please enter your email address');
      return;
    }
    if (!password) {
      setLocalError('Please enter your password');
      return;
    }

    setIsLoading(true);
    try {
      const user = await login(email, password);

      // Routing destination check:
      // If user hasn't completed business setup, gate to /business-setup
      if (!user.setupComplete) {
        navigate('/business-setup', { replace: true });
      } else {
        const from = (location.state as { from?: { pathname?: string } })?.from?.pathname || '/dashboard';
        navigate(from, { replace: true });
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Invalid credentials. Please try again.';
      setLocalError(msg);
    } finally {
      setIsLoading(false);
    }
  };

  const displayError = localError || error;

  return (
    <form onSubmit={handleSubmit} className="space-y-5">
      <div>
        <h2 className="text-xl font-bold text-slate-900 tracking-tight">Sign in to your account</h2>
        <p className="text-xs text-slate-500 mt-1">
          Access your inventory, POS billing, and business dashboard.
        </p>
      </div>

      {displayError && (
        <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2">
          <AlertCircle className="w-4 h-4 text-rose-500 shrink-0 mt-0.5" />
          <span>{displayError}</span>
        </div>
      )}

      <div className="space-y-4">
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
          label="Password"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          leftIcon={<Lock className="w-4 h-4" />}
          placeholder="••••••••"
        />

        <div className="space-y-1.5">
          <label htmlFor="role-select" className="block text-sm font-medium text-slate-700">
            Account Role Preset
          </label>
          <select
            id="role-select"
            value={selectedRole}
            onChange={(e) => handleRolePreset(e.target.value as UserRole)}
            className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:border-[#0284C7]"
          >
            <option value="BUSINESS_OWNER">Business Owner (Full Access)</option>
            <option value="STORE_MANAGER">Store Manager (Inventory & Sales)</option>
            <option value="SALES_STAFF">Sales Staff (POS Billing Only)</option>
            <option value="ADMINISTRATOR">Administrator (System Config)</option>
          </select>
        </div>
      </div>

      <div className="flex items-center justify-between text-xs">
        <label className="flex items-center gap-2 cursor-pointer text-slate-600">
          <input
            type="checkbox"
            defaultChecked
            className="w-4 h-4 rounded text-sky-600 focus:ring-sky-500 border-slate-300"
          />
          <span>Remember me</span>
        </label>
        <Link to="/forgot-password" className="text-sky-600 hover:text-sky-700 font-medium">
          Forgot password?
        </Link>
      </div>

      <Button
        type="submit"
        variant="primary"
        size="lg"
        className="w-full"
        isLoading={isLoading}
        rightIcon={<LogIn className="w-4 h-4" />}
      >
        Sign In to Nirmaan
      </Button>

      <div className="pt-2 text-center text-xs text-slate-500">
        Don&apos;t have an account?{' '}
        <Link to="/register" className="text-sky-600 font-semibold hover:underline">
          Register Store
        </Link>
      </div>
    </form>
  );
};
