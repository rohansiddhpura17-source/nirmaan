import { apiClient } from './apiClient';
import { ProductModel } from '@/models/product';
import { InventoryMovementModel, InventorySummaryModel } from '@/models/inventoryMovement';

export interface InventoryListParams {
  q?: string;
  category?: string;
  stockStatus?: string;
  page?: number;
  limit?: number;
}

export interface AdjustStockInput {
  productId: string;
  type: 'RESTOCK' | 'ADJUSTMENT' | 'RETURN';
  quantity: number;
  reason: string;
  adjustmentMode?: 'DELTA' | 'SET';
}

export const inventoryService = {
  async getSummary(): Promise<InventorySummaryModel> {
    const res = await apiClient.get<InventorySummaryModel>('/inventory/summary');
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to fetch inventory metrics');
    }
    return res.data;
  },

  async getInventoryItems(params: InventoryListParams = {}): Promise<{
    items: ProductModel[];
    total: number;
    page: number;
    limit: number;
  }> {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.category && params.category !== 'All') query.set('category', params.category);
    if (params.stockStatus && params.stockStatus !== 'ALL') query.set('stockStatus', params.stockStatus);
    if (params.page) query.set('page', params.page.toString());
    if (params.limit) query.set('limit', params.limit.toString());

    const queryString = query.toString() ? `?${query.toString()}` : '';
    const res = await apiClient.get<ProductModel[]>(`/inventory/items${queryString}`);
    if (!res.success) {
      throw new Error(res.message || 'Failed to fetch inventory items');
    }
    return {
      items: res.data || [],
      total: res.meta?.total ?? (res.data || []).length,
      page: res.meta?.page ?? 1,
      limit: res.meta?.limit ?? 50,
    };
  },

  async adjustStock(input: AdjustStockInput): Promise<{
    product: ProductModel;
    movement: InventoryMovementModel;
  }> {
    const res = await apiClient.post<{
      product: ProductModel;
      movement: InventoryMovementModel;
    }>('/inventory/adjust', input);

    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to adjust stock');
    }
    return res.data;
  },

  async getMovements(params: { productId?: string; type?: string; page?: number; limit?: number } = {}): Promise<{
    items: InventoryMovementModel[];
    total: number;
  }> {
    const query = new URLSearchParams();
    if (params.productId) query.set('productId', params.productId);
    if (params.type && params.type !== 'ALL') query.set('type', params.type);
    if (params.page) query.set('page', params.page.toString());
    if (params.limit) query.set('limit', params.limit.toString());

    const queryString = query.toString() ? `?${query.toString()}` : '';
    const res = await apiClient.get<InventoryMovementModel[]>(`/inventory/movements${queryString}`);
    if (!res.success) {
      throw new Error(res.message || 'Failed to fetch inventory movements');
    }
    return {
      items: res.data || [],
      total: res.meta?.total ?? (res.data || []).length,
    };
  },
};
