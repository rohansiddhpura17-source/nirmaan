import React from 'react';
import { Link } from 'react-router-dom';
import { Search, Bell, Sparkles, Store, Menu } from 'lucide-react';
import { useAuth } from '@/context/AuthContext';
import { Badge } from '@/components/ui/Badge';

export interface TopNavbarProps {
  onToggleMobileSidebar?: () => void;
}

export const TopNavbar: React.FC<TopNavbarProps> = ({ onToggleMobileSidebar }) => {
  const { user, business, role } = useAuth();

  const roleLabel = {
    BUSINESS_OWNER: 'Owner',
    STORE_MANAGER: 'Manager',
    SALES_STAFF: 'Sales Staff',
    ADMINISTRATOR: 'Admin',
  }[role];

  return (
    <header className="h-16 bg-white border-b border-slate-200 px-4 md:px-8 flex items-center justify-between sticky top-0 z-20">
      {/* Left: Mobile trigger & Store Name */}
      <div className="flex items-center gap-3">
        <button
          onClick={onToggleMobileSidebar}
          aria-label="Toggle Navigation Menu"
          className="md:hidden p-2 rounded-xl text-slate-600 hover:bg-slate-100 focus:outline-none"
        >
          <Menu className="w-5 h-5" />
        </button>

        <div className="flex items-center gap-2">
          <div className="hidden sm:flex w-7 h-7 rounded-lg bg-sky-50 items-center justify-center text-sky-600 border border-sky-100">
            <Store className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-sm font-bold text-slate-800 tracking-tight leading-tight">
              {business?.businessName || 'Nirmaan Store'}
            </h2>
            <p className="text-[11px] text-slate-500 font-medium">Main Branch • Active</p>
          </div>
        </div>
      </div>

      {/* Middle: Search Bar (Desktop) */}
      <div className="hidden md:flex items-center flex-1 max-w-md mx-8">
        <div className="relative w-full">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            placeholder="Search products, orders, customers..."
            className="w-full h-10 pl-10 pr-4 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:bg-white transition-all text-slate-800 placeholder:text-slate-400"
          />
        </div>
      </div>

      {/* Right: Actions, AI Badge, Notifications & Profile */}
      <div className="flex items-center gap-2 sm:gap-3">
        {/* Quick AI Coach Link */}
        <Link
          to="/ai-coach"
          className="hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-indigo-50 border border-indigo-200 text-indigo-700 text-xs font-semibold hover:bg-indigo-100 transition-colors"
        >
          <Sparkles className="w-3.5 h-3.5 text-indigo-600" />
          <span>Ask AI</span>
        </Link>

        {/* Notifications Bell */}
        <Link
          to="/notifications"
          aria-label="View notifications"
          className="relative p-2 rounded-xl text-slate-600 hover:bg-slate-100 transition-colors"
        >
          <Bell className="w-5 h-5" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-rose-500 ring-2 ring-white" />
        </Link>

        {/* Profile chip */}
        <Link
          to="/profile"
          className="flex items-center gap-2 pl-2 border-l border-slate-200 group"
        >
          <img
            src={user?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120'}
            alt={user?.displayName || 'User Profile'}
            className="w-8 h-8 rounded-full object-cover ring-1 ring-slate-200"
          />
          <div className="hidden lg:block text-left">
            <p className="text-xs font-semibold text-slate-800 leading-tight group-hover:text-sky-600 transition-colors">
              {user?.displayName}
            </p>
            <Badge variant="neutral" size="sm" className="mt-0.5 text-[9px] px-1.5 py-0">
              {roleLabel}
            </Badge>
          </div>
        </Link>
      </div>
    </header>
  );
};
