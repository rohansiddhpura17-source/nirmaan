export type UserRole = 'BUSINESS_OWNER' | 'STORE_MANAGER' | 'SALES_STAFF' | 'ADMINISTRATOR';

export type UserStatus = 'ACTIVE' | 'INACTIVE' | 'PENDING';

export interface UserModel {
  uid: string;
  id?: string;
  email: string;
  displayName: string;
  role: UserRole;
  businessId: string | null;
  phone?: string;
  setupComplete: boolean;
  avatarUrl?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface BusinessModel {
  businessId: string;
  businessName: string;
  businessCategory: string;
  ownerId: string;
  contact: {
    phone: string;
    address: string;
    email?: string;
  };
  gstNumber?: string | null;
  currency: string;
  setupComplete: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface AuthState {
  user: UserModel | null;
  business: BusinessModel | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}
