import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '@/context/AuthContext';
import { SessionLoadingState } from './SessionLoadingState';

interface ProtectedRouteProps {
  children?: React.ReactNode;
  requireSetup?: boolean;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  requireSetup = true,
}) => {
  const { isAuthenticated, isLoading, user } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return <SessionLoadingState />;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Business setup gating:
  // If business setup is incomplete, redirect to /business-setup
  if (requireSetup && user && !user.setupComplete) {
    return <Navigate to="/business-setup" replace />;
  }

  // If business setup is already complete and user visits /business-setup, send to dashboard
  if (!requireSetup && user && user.setupComplete && location.pathname === '/business-setup') {
    return <Navigate to="/dashboard" replace />;
  }

  return children ? <>{children}</> : <Outlet />;
};
