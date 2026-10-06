import { useState, useEffect, useCallback } from 'react';
import { OrderModel } from '@/models/order';
import { orderService, OrderListParams, CreateOrderInput } from '@/services/orderService';

export function useOrders(initialParams: OrderListParams = {}) {
  const [orders, setOrders] = useState<OrderModel[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState<number>(0);
  const [params, setParams] = useState<OrderListParams>(initialParams);

  useEffect(() => {
    setParams(initialParams);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    initialParams.q,
    initialParams.status,
    initialParams.paymentStatus,
    initialParams.customerId,
    initialParams.page,
    initialParams.limit,
  ]);

  const fetchOrders = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await orderService.getOrders(params);
      setOrders(data.items);
      setTotal(data.total);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to load orders');
    } finally {
      setLoading(false);
    }
  }, [params]);

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  const createOrder = async (input: CreateOrderInput) => {
    const created = await orderService.createOrder(input);
    await fetchOrders();
    return created;
  };

  return {
    orders,
    loading,
    error,
    total,
    params,
    setParams,
    refetch: fetchOrders,
    createOrder,
  };
}
