import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ShieldAlert, ArrowLeft, Home } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { useAuth } from '@/context/AuthContext';
import { UserRole } from '@/models/user';

interface UnauthorizedPageProps {
  requiredRoles?: UserRole[];
}

export const UnauthorizedPage: React.FC<UnauthorizedPageProps> = ({ requiredRoles }) => {
  const navigate = useNavigate();
  const { role } = useAuth();

  const roleLabels: Record<UserRole, string> = {
    BUSINESS_OWNER: 'Business Owner',
    STORE_MANAGER: 'Store Manager',
    SALES_STAFF: 'Sales Staff',
    ADMINISTRATOR: 'Administrator',
  };

  return (
    <div className="min-h-[70vh] flex flex-col items-center justify-center p-6 text-center">
      <div className="w-16 h-16 rounded-2xl bg-amber-50 border border-amber-200 text-amber-600 flex items-center justify-center mb-5 shadow-sm">
        <ShieldAlert className="w-8 h-8" />
      </div>

      <span className="text-xs font-semibold uppercase tracking-widest text-amber-600 mb-2">
        403 Access Denied
      </span>

      <h1 className="text-2xl font-bold text-slate-900 tracking-tight mb-2">
        Unauthorized Role Access
      </h1>

      <p className="text-sm text-slate-600 max-w-md mb-4">
        Your current role is <strong className="text-slate-900 font-semibold">{roleLabels[role] || role}</strong>.
        {requiredRoles && requiredRoles.length > 0 && (
          <span>
            {' '}This section requires:{' '}
            <strong className="text-slate-900 font-semibold">
              {requiredRoles.map((r) => roleLabels[r] || r).join(', ')}
            </strong>.
          </span>
        )}
      </p>

      <div className="flex items-center gap-3">
        <Button
          variant="outline"
          size="sm"
          onClick={() => navigate(-1)}
          leftIcon={<ArrowLeft className="w-4 h-4" />}
        >
          Go Back
        </Button>
        <Button
          variant="primary"
          size="sm"
          onClick={() => navigate('/dashboard')}
          leftIcon={<Home className="w-4 h-4" />}
        >
          Return to Dashboard
        </Button>
      </div>
    </div>
  );
};
