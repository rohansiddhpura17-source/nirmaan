import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthLayout } from '@/layouts/AuthLayout';
import { DashboardLayout } from '@/layouts/DashboardLayout';

import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { RoleGuard } from '@/components/auth/RoleGuard';

import { SplashPage } from '@/pages/SplashPage';
import { LoginPage } from '@/pages/LoginPage';
import { RegisterPage } from '@/pages/RegisterPage';
import { ForgotPasswordPage } from '@/pages/ForgotPasswordPage';
import { BusinessSetupPage } from '@/pages/BusinessSetupPage';
import { UnauthorizedPage } from '@/pages/UnauthorizedPage';

import { DashboardPage } from '@/pages/DashboardPage';
import { OrdersPage } from '@/pages/OrdersPage';
import { InventoryPage } from '@/pages/InventoryPage';
import { CustomersPage } from '@/pages/CustomersPage';
import { MorePage } from '@/pages/MorePage';

import { ProductsPage } from '@/pages/ProductsPage';
import { AddProductPage } from '@/pages/AddProductPage';
import { SuppliersPage } from '@/pages/SuppliersPage';
import { AiCoachPage } from '@/pages/AiCoachPage';
import { TodaysBusinessPage } from '@/pages/TodaysBusinessPage';
import { AnalyticsPage } from '@/pages/AnalyticsPage';
import { BusinessHealthPage } from '@/pages/BusinessHealthPage';

import { ProfilePage } from '@/pages/ProfilePage';
import { SettingsPage } from '@/pages/SettingsPage';
import { NotificationsPage } from '@/pages/NotificationsPage';

export const AppRoutes: React.FC = () => {
  return (
    <Routes>
      {/* 1. Splash Screen & Session Check */}
      <Route path="/" element={<SplashPage />} />

      {/* 2. Public Auth Routes */}
      <Route element={<AuthLayout />}>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
      </Route>

      {/* 3. Onboarding & Business Setup Gated Route */}
      <Route
        element={
          <ProtectedRoute requireSetup={false}>
            <AuthLayout />
          </ProtectedRoute>
        }
      >
        <Route path="/business-setup" element={<BusinessSetupPage />} />
      </Route>

      {/* 4. Authenticated Application Routes (Guarded by ProtectedRoute & DashboardLayout) */}
      <Route
        element={
          <ProtectedRoute requireSetup={true}>
            <DashboardLayout />
          </ProtectedRoute>
        }
      >
        {/* Universal Core Views for All Roles */}
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/orders" element={<OrdersPage />} />
        <Route path="/inventory" element={<InventoryPage />} />
        <Route path="/customers" element={<CustomersPage />} />
        <Route path="/more" element={<MorePage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/notifications" element={<NotificationsPage />} />

        {/* Catalog & Operations (Owner, Manager, Admin) */}
        <Route
          path="/products"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR']}>
              <ProductsPage />
            </RoleGuard>
          }
        />
        <Route
          path="/products/add"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR']}>
              <AddProductPage />
            </RoleGuard>
          }
        />
        <Route
          path="/suppliers"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR']}>
              <SuppliersPage />
            </RoleGuard>
          }
        />
        <Route
          path="/todays-business"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR']}>
              <TodaysBusinessPage />
            </RoleGuard>
          }
        />

        {/* Intelligence, AI Coach & Governance (Owner, Manager, Admin) */}
        <Route
          path="/ai-coach"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'STORE_MANAGER', 'ADMINISTRATOR']}>
              <AiCoachPage />
            </RoleGuard>
          }
        />

        {/* Deep Financial Analytics & Business Health (Owner, Admin only) */}
        <Route
          path="/analytics"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'ADMINISTRATOR']}>
              <AnalyticsPage />
            </RoleGuard>
          }
        />
        <Route
          path="/business-health"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'ADMINISTRATOR']}>
              <BusinessHealthPage />
            </RoleGuard>
          }
        />

        {/* Settings & Configuration (Owner, Admin only) */}
        <Route
          path="/settings"
          element={
            <RoleGuard allowedRoles={['BUSINESS_OWNER', 'ADMINISTRATOR']}>
              <SettingsPage />
            </RoleGuard>
          }
        />

        {/* 403 Forbidden Access State */}
        <Route path="/unauthorized" element={<UnauthorizedPage />} />
      </Route>

      {/* Fallback route */}
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};
