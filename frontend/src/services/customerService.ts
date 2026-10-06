import { apiClient } from './apiClient';
import { CustomerModel } from '@/models/customer';

export interface CustomerListParams {
  q?: string;
  page?: number;
  limit?: number;
}

export interface CreateCustomerInput {
  name: string;
  phone: string;
  email?: string;
  address?: string;
  outstandingCredit?: number;
}

export const customerService = {
  async getCustomers(params: CustomerListParams = {}): Promise<{
    items: CustomerModel[];
    total: number;
    page: number;
    limit: number;
  }> {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.page) query.set('page', params.page.toString());
    if (params.limit) query.set('limit', params.limit.toString());

    const queryString = query.toString() ? `?${query.toString()}` : '';
    const res = await apiClient.get<CustomerModel[]>(`/customers${queryString}`);
    if (!res.success) {
      throw new Error(res.message || 'Failed to fetch customers');
    }
    return {
      items: res.data || [],
      total: res.meta?.total ?? (res.data || []).length,
      page: res.meta?.page ?? 1,
      limit: res.meta?.limit ?? 50,
    };
  },

  async getCustomerById(id: string): Promise<CustomerModel> {
    const res = await apiClient.get<CustomerModel>(`/customers/${id}`);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to fetch customer details');
    }
    return res.data;
  },

  async createCustomer(data: CreateCustomerInput): Promise<CustomerModel> {
    const res = await apiClient.post<CustomerModel>('/customers', data);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to create customer');
    }
    return res.data;
  },

  async updateCustomer(id: string, data: Partial<CreateCustomerInput>): Promise<CustomerModel> {
    const res = await apiClient.put<CustomerModel>(`/customers/${id}`, data);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to update customer');
    }
    return res.data;
  },
};
