import { useState, useEffect, useCallback } from 'react';
import { SupplierModel } from '@/models/supplier';
import { supplierService, SupplierListParams, CreateSupplierInput } from '@/services/supplierService';

export function useSuppliers(initialParams: SupplierListParams = {}) {
  const [suppliers, setSuppliers] = useState<SupplierModel[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState<number>(0);
  const [params, setParams] = useState<SupplierListParams>(initialParams);

  useEffect(() => {
    setParams(initialParams);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    initialParams.q,
    initialParams.status,
    initialParams.page,
    initialParams.limit,
  ]);

  const fetchSuppliers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await supplierService.getSuppliers(params);
      setSuppliers(data.items);
      setTotal(data.total);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to load suppliers');
    } finally {
      setLoading(false);
    }
  }, [params]);

  useEffect(() => {
    fetchSuppliers();
  }, [fetchSuppliers]);

  const createSupplier = async (input: CreateSupplierInput) => {
    const created = await supplierService.createSupplier(input);
    await fetchSuppliers();
    return created;
  };

  const updateSupplier = async (id: string, input: Partial<CreateSupplierInput>) => {
    const updated = await supplierService.updateSupplier(id, input);
    await fetchSuppliers();
    return updated;
  };

  const deactivateSupplier = async (id: string) => {
    const res = await supplierService.deactivateSupplier(id);
    await fetchSuppliers();
    return res;
  };

  return {
    suppliers,
    loading,
    error,
    total,
    params,
    setParams,
    refetch: fetchSuppliers,
    createSupplier,
    updateSupplier,
    deactivateSupplier,
  };
}
