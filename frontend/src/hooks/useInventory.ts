import { useState, useEffect, useCallback } from 'react';
import { ProductModel } from '@/models/product';
import { InventorySummaryModel, InventoryMovementModel } from '@/models/inventoryMovement';
import { inventoryService, InventoryListParams, AdjustStockInput } from '@/services/inventoryService';

export function useInventory(initialParams: InventoryListParams = {}) {
  const [items, setItems] = useState<ProductModel[]>([]);
  const [summary, setSummary] = useState<InventorySummaryModel | null>(null);
  const [movements, setMovements] = useState<InventoryMovementModel[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState<number>(0);
  const [params, setParams] = useState<InventoryListParams>(initialParams);

  useEffect(() => {
    setParams(initialParams);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    initialParams.q,
    initialParams.category,
    initialParams.stockStatus,
    initialParams.page,
    initialParams.limit,
  ]);

  const fetchInventory = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [sumData, itemData] = await Promise.all([
        inventoryService.getSummary(),
        inventoryService.getInventoryItems(params),
      ]);
      setSummary(sumData);
      setItems(itemData.items);
      setTotal(itemData.total);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to load inventory');
    } finally {
      setLoading(false);
    }
  }, [params]);

  const fetchMovements = useCallback(async (productId?: string) => {
    try {
      const data = await inventoryService.getMovements({ productId });
      setMovements(data.items);
    } catch (err: unknown) {
      console.warn('Failed to fetch movements', err);
    }
  }, []);

  useEffect(() => {
    fetchInventory();
  }, [fetchInventory]);

  const adjustStock = async (input: AdjustStockInput) => {
    const res = await inventoryService.adjustStock(input);
    await fetchInventory();
    return res;
  };

  return {
    items,
    summary,
    movements,
    loading,
    error,
    total,
    params,
    setParams,
    refetch: fetchInventory,
    fetchMovements,
    adjustStock,
  };
}
