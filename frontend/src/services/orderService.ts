import { apiClient } from './apiClient';
import { OrderModel, PaymentMethod } from '@/models/order';

export interface OrderListParams {
  q?: string;
  status?: string;
  paymentStatus?: string;
  page?: number;
  limit?: number;
}

export interface CreateOrderInput {
  customerId?: string | null;
  customerName?: string;
  customerPhone?: string | null;
  items: {
    productId: string;
    productName?: string;
    quantity: number;
    unitPrice?: number;
  }[];
  discount?: number;
  tax?: number;
  paymentMethod?: PaymentMethod;
  idempotencyKey?: string;
}

export const orderService = {
  async getOrders(params: OrderListParams = {}): Promise<{
    items: OrderModel[];
    total: number;
    page: number;
    limit: number;
  }> {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.status && params.status !== 'ALL') query.set('status', params.status);
    if (params.paymentStatus && params.paymentStatus !== 'ALL') query.set('paymentStatus', params.paymentStatus);
    if (params.page) query.set('page', params.page.toString());
    if (params.limit) query.set('limit', params.limit.toString());

    const queryString = query.toString() ? `?${query.toString()}` : '';
    const res = await apiClient.get<OrderModel[]>(`/orders${queryString}`);
    if (!res.success) {
      throw new Error(res.message || 'Failed to fetch sales orders');
    }
    return {
      items: res.data || [],
      total: res.meta?.total ?? (res.data || []).length,
      page: res.meta?.page ?? 1,
      limit: res.meta?.limit ?? 50,
    };
  },

  async getOrderById(id: string): Promise<OrderModel> {
    const res = await apiClient.get<OrderModel>(`/orders/${id}`);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to fetch order details');
    }
    return res.data;
  },

  async createOrder(data: CreateOrderInput): Promise<OrderModel> {
    const idempotencyKey = data.idempotencyKey || `idemp_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const headers = { 'Idempotency-Key': idempotencyKey };

    const res = await apiClient.post<OrderModel>('/orders', { ...data, idempotencyKey }, { headers });
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to complete sales transaction');
    }
    return res.data;
  },
};
