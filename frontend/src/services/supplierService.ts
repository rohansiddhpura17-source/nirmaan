import { apiClient } from './apiClient';
import { SupplierModel } from '@/models/supplier';

export interface SupplierListParams {
  q?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export interface CreateSupplierInput {
  name: string;
  phone: string;
  email?: string;
  address?: string;
  category?: string;
  status?: 'ACTIVE' | 'INACTIVE';
}

export const supplierService = {
  async getSuppliers(params: SupplierListParams = {}): Promise<{
    items: SupplierModel[];
    total: number;
    page: number;
    limit: number;
  }> {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.status && params.status !== 'ALL') query.set('status', params.status);
    if (params.page) query.set('page', params.page.toString());
    if (params.limit) query.set('limit', params.limit.toString());

    const queryString = query.toString() ? `?${query.toString()}` : '';
    const res = await apiClient.get<SupplierModel[]>(`/suppliers${queryString}`);
    if (!res.success) {
      throw new Error(res.message || 'Failed to fetch suppliers');
    }
    return {
      items: res.data || [],
      total: res.meta?.total ?? (res.data || []).length,
      page: res.meta?.page ?? 1,
      limit: res.meta?.limit ?? 50,
    };
  },

  async getSupplierById(id: string): Promise<SupplierModel> {
    const res = await apiClient.get<SupplierModel>(`/suppliers/${id}`);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to fetch supplier details');
    }
    return res.data;
  },

  async createSupplier(data: CreateSupplierInput): Promise<SupplierModel> {
    const res = await apiClient.post<SupplierModel>('/suppliers', data);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to add supplier');
    }
    return res.data;
  },

  async updateSupplier(id: string, data: Partial<CreateSupplierInput>): Promise<SupplierModel> {
    const res = await apiClient.put<SupplierModel>(`/suppliers/${id}`, data);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to update supplier');
    }
    return res.data;
  },

  async deactivateSupplier(id: string): Promise<SupplierModel> {
    const res = await apiClient.delete<SupplierModel>(`/suppliers/${id}`);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to deactivate supplier');
    }
    return res.data;
  },
};
