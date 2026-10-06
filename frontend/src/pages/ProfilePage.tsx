import React from 'react';
import { Shield, Key } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useAuth } from '@/context/AuthContext';

export const ProfilePage: React.FC = () => {
  const { user, business, role } = useAuth();

  return (
    <div className="space-y-6 max-w-2xl mx-auto">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">User Profile</h1>
        <p className="text-xs sm:text-sm text-slate-500">
          Manage your personal account credentials and security preferences.
        </p>
      </div>

      {/* Main Profile Info Card */}
      <Card className="p-6">
        <div className="flex flex-col sm:flex-row items-center gap-6">
          <img
            src={user?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120'}
            alt={user?.displayName || 'User Profile'}
            className="w-20 h-20 rounded-full object-cover ring-4 ring-sky-50 shadow-md"
          />

          <div className="text-center sm:text-left space-y-1">
            <div className="flex items-center justify-center sm:justify-start gap-2">
              <h2 className="text-lg font-bold text-slate-900">{user?.displayName}</h2>
              <Badge variant="info">{role.replace('_', ' ')}</Badge>
            </div>
            <p className="text-xs text-slate-500">{user?.email}</p>
            <p className="text-xs text-slate-500">{user?.phone || '+91 98765 43210'}</p>
          </div>
        </div>

        <div className="mt-6 pt-6 border-t border-slate-100 grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
          <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
            <span className="text-slate-400 block font-medium">Assigned Business</span>
            <span className="font-bold text-slate-800 text-sm mt-0.5 block">
              {business?.businessName || 'Nirmaan Enterprise'}
            </span>
          </div>
          <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
            <span className="text-slate-400 block font-medium">Business / Store ID</span>
            <span className="font-mono font-bold text-slate-800 text-sm mt-0.5 block">
              {user?.businessId || business?.businessId || 'biz_main'}
            </span>
          </div>
        </div>
      </Card>

      {/* Security & Access Rights */}
      <Card className="p-5 space-y-4">
        <div className="flex items-center gap-2 text-slate-900 font-bold text-sm">
          <Shield className="w-4 h-4 text-sky-600" />
          <span>RBAC Security & Role Privileges</span>
        </div>

        <div className="space-y-2 text-xs text-slate-600">
          <div className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
            <span>Inventory Master Write</span>
            <Badge variant="success" size="sm">Authorized</Badge>
          </div>
          <div className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
            <span>POS Cash Register Access</span>
            <Badge variant="success" size="sm">Authorized</Badge>
          </div>
          <div className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
            <span>AI Business Coach Queries</span>
            <Badge variant="success" size="sm">Authorized</Badge>
          </div>
          <div className="flex items-center justify-between p-2.5 bg-slate-50 rounded-lg">
            <span>Store Configuration & Taxes</span>
            <Badge variant={role === 'BUSINESS_OWNER' || role === 'ADMINISTRATOR' ? 'success' : 'neutral'} size="sm">
              {role === 'BUSINESS_OWNER' || role === 'ADMINISTRATOR' ? 'Authorized' : 'Restricted'}
            </Badge>
          </div>
        </div>

        <div className="pt-2">
          <Button variant="outline" size="sm" leftIcon={<Key className="w-4 h-4" />}>
            Change Account Password
          </Button>
        </div>
      </Card>
    </div>
  );
};
