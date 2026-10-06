import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Boxes,
  Truck,
  Sparkles,
  TrendingUp,
  HeartPulse,
  BarChart3,
  Bell,
  Settings,
  User,
  LogOut,
  ChevronRight,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { useAuth } from '@/context/AuthContext';

export const MorePage: React.FC = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const menuSections = [
    {
      title: 'Store Intelligence',
      items: [
        { label: 'AI Business Coach', icon: Sparkles, color: 'text-indigo-600 bg-indigo-50', path: '/ai-coach' },
        { label: "Today's Live Pulse", icon: TrendingUp, color: 'text-sky-600 bg-sky-50', path: '/todays-business' },
        { label: 'Business Health Score', icon: HeartPulse, color: 'text-rose-600 bg-rose-50', path: '/business-health' },
        { label: 'Analytics & Insights', icon: BarChart3, color: 'text-emerald-600 bg-emerald-50', path: '/analytics' },
      ],
    },
    {
      title: 'Inventory & Catalog',
      items: [
        { label: 'Full Product Catalog', icon: Boxes, color: 'text-amber-600 bg-amber-50', path: '/products' },
        { label: 'Add New Product', icon: Boxes, color: 'text-blue-600 bg-blue-50', path: '/products/add' },
        { label: 'Suppliers & Vendors', icon: Truck, color: 'text-emerald-600 bg-emerald-50', path: '/suppliers' },
      ],
    },
    {
      title: 'Account & Settings',
      items: [
        { label: 'Store & POS Settings', icon: Settings, color: 'text-slate-600 bg-slate-100', path: '/settings' },
        { label: 'My Profile & Roles', icon: User, color: 'text-slate-600 bg-slate-100', path: '/profile' },
        { label: 'Notification Center', icon: Bell, color: 'text-slate-600 bg-slate-100', path: '/notifications' },
      ],
    },
  ];

  return (
    <div className="space-y-6 max-w-2xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">More Features</h1>
        <p className="text-xs sm:text-sm text-slate-500">
          Access specialized intelligence tools, store settings, and operational reports.
        </p>
      </div>

      {/* User profile card */}
      <Card className="p-4 bg-gradient-to-r from-slate-900 to-slate-800 text-white border-none shadow-md">
        <div className="flex items-center gap-4">
          <img
            src={user?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120'}
            alt={user?.displayName || 'User Profile'}
            className="w-12 h-12 rounded-full object-cover ring-2 ring-sky-400"
          />
          <div className="flex-1 min-w-0">
            <h3 className="font-bold text-base truncate">{user?.displayName}</h3>
            <p className="text-xs text-sky-300 truncate">{user?.businessName}</p>
            <p className="text-[11px] text-slate-400 mt-0.5 capitalize">{user?.role.toLowerCase().replace('_', ' ')}</p>
          </div>
        </div>
      </Card>

      {/* Navigation sections */}
      <div className="space-y-4">
        {menuSections.map((section) => (
          <div key={section.title} className="space-y-2">
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider px-1">
              {section.title}
            </h3>
            <Card padded={false} className="divide-y divide-slate-100">
              {section.items.map((item) => {
                const Icon = item.icon;
                return (
                  <button
                    key={item.label}
                    onClick={() => navigate(item.path)}
                    className="w-full p-4 flex items-center justify-between hover:bg-slate-50 transition-colors text-left group"
                  >
                    <div className="flex items-center gap-3">
                      <div className={`p-2 rounded-xl ${item.color}`}>
                        <Icon className="w-5 h-5" />
                      </div>
                      <span className="text-sm font-semibold text-slate-800 group-hover:text-sky-600 transition-colors">
                        {item.label}
                      </span>
                    </div>
                    <ChevronRight className="w-4 h-4 text-slate-400 group-hover:text-slate-600 transition-transform group-hover:translate-x-0.5" />
                  </button>
                );
              })}
            </Card>
          </div>
        ))}
      </div>

      {/* Logout button */}
      <div className="pt-2">
        <button
          onClick={() => {
            logout();
            navigate('/login');
          }}
          className="w-full p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-sm font-semibold flex items-center justify-center gap-2 hover:bg-rose-100 transition-colors"
        >
          <LogOut className="w-4 h-4" />
          <span>Sign Out of Nirmaan</span>
        </button>
      </div>
    </div>
  );
};
