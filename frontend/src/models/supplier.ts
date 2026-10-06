export interface SupplierModel {
  id: string;
  supplierId?: string;
  businessId?: string;
  name: string;
  phone: string;
  email?: string | null;
  address?: string;
  category?: string;
  status: 'ACTIVE' | 'INACTIVE';
  createdAt?: string;
  updatedAt?: string;
}
