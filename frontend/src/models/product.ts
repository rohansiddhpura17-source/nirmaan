export type ProductCategory =
  | 'Groceries'
  | 'Electronics'
  | 'Clothing'
  | 'Hardware'
  | 'FMCG'
  | 'Beverages'
  | 'Personal Care'
  | 'Other';

export type StockStatus = 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK';

export interface ProductModel {
  id: string;
  productId?: string;
  businessId?: string;
  name: string;
  sku: string;
  barcode?: string | null;
  category: ProductCategory;
  costPrice: number;
  purchasePrice?: number;
  sellingPrice: number;
  stockQuantity: number;
  currentStock?: number;
  minStockThreshold: number;
  unit: string;
  description?: string;
  status?: 'ACTIVE' | 'ARCHIVED' | 'INACTIVE';
  stockStatus?: StockStatus;
  imageUrl?: string | null;
  createdAt?: string;
  updatedAt: string;
}

export function getStockStatus(quantity: number, threshold: number): StockStatus {
  if (quantity <= 0) return 'OUT_OF_STOCK';
  if (quantity <= threshold) return 'LOW_STOCK';
  return 'IN_STOCK';
}
