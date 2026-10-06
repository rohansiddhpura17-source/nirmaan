import React from 'react';
import { UserRole } from '@/models/user';
import { useAuth } from '@/context/AuthContext';
import { UnauthorizedPage } from '@/pages/UnauthorizedPage';

interface RoleGuardProps {
  allowedRoles: UserRole[];
  children?: React.ReactNode;
  fallback?: React.ReactNode;
}

export const RoleGuard: React.FC<RoleGuardProps> = ({
  allowedRoles,
  children,
  fallback,
}) => {
  const { role } = useAuth();

  if (!allowedRoles.includes(role)) {
    return fallback ? <>{fallback}</> : <UnauthorizedPage requiredRoles={allowedRoles} />;
  }

  return children ? <>{children}</> : null;
};
