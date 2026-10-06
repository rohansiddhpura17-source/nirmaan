export type InventoryMovementType = 'SALE' | 'RESTOCK' | 'ADJUSTMENT' | 'RETURN';

export interface InventoryMovementModel {
  id: string;
  movementId?: string;
  businessId?: string;
  productId: string;
  productName: string;
  type: InventoryMovementType;
  quantity: number;
  previousStock: number;
  resultingStock: number;
  reason: string;
  referenceId?: string | null;
  createdBy?: string;
  createdAt: string;
}

export interface InventorySummaryModel {
  totalProducts: number;
  totalStockUnits: number;
  lowStockCount: number;
  outOfStockCount: number;
  inStockCount: number;
  totalCostValue: number;
  totalRetailValue: number;
  potentialProfit: number;
}
