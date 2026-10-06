import { useState, useEffect, useCallback } from 'react';
import { CustomerModel } from '@/models/customer';
import { customerService, CustomerListParams, CreateCustomerInput } from '@/services/customerService';

export function useCustomers(initialParams: CustomerListParams = {}) {
  const [customers, setCustomers] = useState<CustomerModel[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState<number>(0);
  const [params, setParams] = useState<CustomerListParams>(initialParams);

  useEffect(() => {
    setParams(initialParams);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initialParams.q, initialParams.page, initialParams.limit]);

  const fetchCustomers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await customerService.getCustomers(params);
      setCustomers(data.items);
      setTotal(data.total);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to load customers');
    } finally {
      setLoading(false);
    }
  }, [params]);

  useEffect(() => {
    fetchCustomers();
  }, [fetchCustomers]);

  const createCustomer = async (input: CreateCustomerInput) => {
    const created = await customerService.createCustomer(input);
    await fetchCustomers();
    return created;
  };

  const updateCustomer = async (id: string, input: Partial<CreateCustomerInput>) => {
    const updated = await customerService.updateCustomer(id, input);
    await fetchCustomers();
    return updated;
  };

  return {
    customers,
    loading,
    error,
    total,
    params,
    setParams,
    refetch: fetchCustomers,
    createCustomer,
    updateCustomer,
  };
}
