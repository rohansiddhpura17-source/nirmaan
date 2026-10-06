import { apiClient } from './apiClient';
import { ProductModel } from '@/models/product';

export interface ProductListParams {
  q?: string;
  category?: string;
  stockStatus?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export interface CreateProductInput {
  name: string;
  category: string;
  sku?: string;
  barcode?: string;
  purchasePrice?: number;
  costPrice?: number;
  sellingPrice: number;
  currentStock?: number;
  stockQuantity?: number;
  minStockThreshold?: number;
  minThreshold?: number;
  unit?: string;
  description?: string;
}

export const productService = {
  async getProducts(params: ProductListParams = {}): Promise<{
    items: ProductModel[];
    total: number;
    page: number;
    limit: number;
  }> {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.category && params.category !== 'All') query.set('category', params.category);
    if (params.stockStatus && params.stockStatus !== 'ALL') query.set('stockStatus', params.stockStatus);
    if (params.status) query.set('status', params.status);
    if (params.page) query.set('page', params.page.toString());
    if (params.limit) query.set('limit', params.limit.toString());

    const queryString = query.toString() ? `?${query.toString()}` : '';
    const res = await apiClient.get<ProductModel[]>(`/products${queryString}`);
    if (!res.success) {
      throw new Error(res.message || 'Failed to fetch products');
    }
    return {
      items: res.data || [],
      total: res.meta?.total ?? (res.data || []).length,
      page: res.meta?.page ?? 1,
      limit: res.meta?.limit ?? 50,
    };
  },

  async getProductById(id: string): Promise<ProductModel> {
    const res = await apiClient.get<ProductModel>(`/products/${id}`);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to fetch product details');
    }
    return res.data;
  },

  async createProduct(data: CreateProductInput): Promise<ProductModel> {
    const res = await apiClient.post<ProductModel>('/products', data);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to create product');
    }
    return res.data;
  },

  async updateProduct(id: string, data: Partial<CreateProductInput>): Promise<ProductModel> {
    const res = await apiClient.put<ProductModel>(`/products/${id}`, data);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to update product');
    }
    return res.data;
  },

  async archiveProduct(id: string): Promise<ProductModel> {
    const res = await apiClient.delete<ProductModel>(`/products/${id}`);
    if (!res.success || !res.data) {
      throw new Error(res.message || 'Failed to archive product');
    }
    return res.data;
  },
};
