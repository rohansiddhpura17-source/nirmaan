import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  TrendingUp,
  ShoppingCart,
  Package,
  Users,
  Sparkles,
  HeartPulse,
  BarChart3,
  Boxes,
  PlusCircle,
  Truck,
  Bell,
  Settings,
  User,
  Store,
  LogOut,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuth } from '@/context/AuthContext';
import { UserRole } from '@/models/user';

interface NavItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: string;
  allowedRoles?: UserRole[];
}

const navSections: { title: string; items: NavItem[] }[] = [
  {
    title: 'Core Business',
    items: [
      { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
      {
        name: "Today's Pulse",
        href: '/todays-business',
        icon: TrendingUp,
        allowedRoles: ['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR'],
      },
      { name: 'Sales & Orders', href: '/orders', icon: ShoppingCart },
      { name: 'Inventory', href: '/inventory', icon: Package },
      { name: 'Customers', href: '/customers', icon: Users },
    ],
  },
  {
    title: 'AI Intelligence',
    items: [
      {
        name: 'AI Business Coach',
        href: '/ai-coach',
        icon: Sparkles,
        badge: 'AI',
        allowedRoles: ['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR'],
      },
      {
        name: 'Business Health',
        href: '/business-health',
        icon: HeartPulse,
        allowedRoles: ['BUSINESS_OWNER', 'ADMINISTRATOR'],
      },
      {
        name: 'Analytics',
        href: '/analytics',
        icon: BarChart3,
        allowedRoles: ['BUSINESS_OWNER', 'ADMINISTRATOR'],
      },
    ],
  },
  {
    title: 'Catalog',
    items: [
      {
        name: 'Products Catalog',
        href: '/products',
        icon: Boxes,
        allowedRoles: ['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR'],
      },
      {
        name: 'Add Product',
        href: '/products/add',
        icon: PlusCircle,
        allowedRoles: ['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR'],
      },
      {
        name: 'Suppliers',
        href: '/suppliers',
        icon: Truck,
        allowedRoles: ['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR'],
      },
    ],
  },
  {
    title: 'System & Admin',
    items: [
      { name: 'Notifications', href: '/notifications', icon: Bell, badge: '3' },
      {
        name: 'Store Settings',
        href: '/settings',
        icon: Settings,
        allowedRoles: ['BUSINESS_OWNER', 'ADMINISTRATOR'],
      },
      { name: 'User Profile', href: '/profile', icon: User },
    ],
  },
];

export interface SidebarProps {
  className?: string;
  isMobile?: boolean;
  onItemClick?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  className,
  isMobile = false,
  onItemClick,
}) => {
  const navigate = useNavigate();
  const { user, business, role, logout } = useAuth();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <aside
      className={cn(
        isMobile
          ? 'flex flex-col w-full bg-[#0F172A] text-slate-300 h-full'
          : 'hidden md:flex flex-col w-64 bg-[#0F172A] text-slate-300 min-h-screen border-r border-slate-800 shrink-0',
        className
      )}
    >
      {/* Brand Header */}
      <div className="h-16 px-6 flex items-center gap-3 border-b border-slate-800">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 flex items-center justify-center text-white shadow-md font-black tracking-wider text-base">
          N
        </div>
        <div>
          <span className="text-white font-bold tracking-tight text-lg leading-tight block">
            NIRMAAN
          </span>
          <span className="text-[10px] text-sky-400 font-semibold uppercase tracking-wider block">
            Business OS
          </span>
        </div>
      </div>

      {/* Role Pill */}
      <div className="px-4 py-3 border-b border-slate-800/80 bg-slate-900/50">
        <div className="flex items-center justify-between text-xs mb-1">
          <span className="text-slate-400">Authenticated Role</span>
          <span className="text-[10px] text-emerald-400 font-medium bg-emerald-950/60 border border-emerald-800/50 px-1.5 py-0.5 rounded">
            Verified
          </span>
        </div>
        <div className="text-xs font-semibold text-sky-300 bg-slate-800 border border-slate-700 rounded-lg px-2.5 py-1.5">
          {role.replace('_', ' ')}
        </div>
      </div>

      {/* Navigation Links */}
      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6">
        {navSections.map((section) => {
          // Filter items allowed for active role
          const visibleItems = section.items.filter(
            (item) => !item.allowedRoles || item.allowedRoles.includes(role)
          );

          if (visibleItems.length === 0) return null;

          return (
            <div key={section.title} className="space-y-1">
              <h4 className="px-3 text-[11px] font-bold uppercase tracking-wider text-slate-500">
                {section.title}
              </h4>
              <nav className="space-y-0.5">
                {visibleItems.map((item) => (
                  <NavLink
                    key={item.href}
                    to={item.href}
                    onClick={onItemClick}
                    className={({ isActive }) =>
                      cn(
                        'flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-xl transition-all duration-150 group',
                        isActive
                          ? 'bg-sky-600/15 text-white border border-sky-500/30'
                          : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
                      )
                    }
                  >
                    {({ isActive }) => {
                      const Icon = item.icon;
                      return (
                        <>
                          <Icon
                            className={cn(
                              'w-4 h-4 transition-colors',
                              isActive ? 'text-sky-400' : 'text-slate-500 group-hover:text-slate-300'
                            )}
                          />
                          <span className="flex-1 truncate">{item.name}</span>
                          {item.badge && (
                            <span
                              className={cn(
                                'text-[10px] px-1.5 py-0.5 rounded-full font-bold',
                                item.badge === 'AI'
                                  ? 'bg-indigo-600/30 text-indigo-300 border border-indigo-500/40'
                                  : 'bg-slate-800 text-slate-300 border border-slate-700'
                              )}
                            >
                              {item.badge}
                            </span>
                          )}
                        </>
                      );
                    }}
                  </NavLink>
                ))}
              </nav>
            </div>
          );
        })}
      </div>

      {/* Store Footer & Logout */}
      <div className="p-4 border-t border-slate-800 bg-slate-900/60 flex flex-col gap-2">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center text-slate-300">
            <Store className="w-4 h-4 text-sky-400" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-white truncate">
              {business?.businessName || 'Nirmaan Enterprise'}
            </p>
            <p className="text-[10px] text-slate-400 truncate">{user?.displayName || user?.email}</p>
          </div>
        </div>

        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 mt-1 px-3 py-1.5 rounded-lg text-xs font-medium text-slate-400 hover:text-rose-400 hover:bg-rose-950/20 border border-slate-800 hover:border-rose-900/40 transition-colors"
        >
          <LogOut className="w-3.5 h-3.5" />
          <span>Sign Out</span>
        </button>
      </div>
    </aside>
  );
};
