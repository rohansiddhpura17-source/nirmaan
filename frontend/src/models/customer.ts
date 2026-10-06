export interface CustomerModel {
  id: string;
  customerId?: string;
  businessId?: string;
  name: string;
  phone: string;
  email?: string | null;
  address?: string;
  totalPurchases: number;
  totalSpend?: number;
  orderCount?: number;
  outstandingCredit: number;
  lastVisitDate: string;
  loyaltyPoints: number;
  createdAt?: string;
  updatedAt?: string;
}
