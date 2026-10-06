import { useState, useEffect, useCallback } from 'react';
import { ProductModel } from '@/models/product';
import { productService, ProductListParams, CreateProductInput } from '@/services/productService';

export function useProducts(initialParams: ProductListParams = {}) {
  const [products, setProducts] = useState<ProductModel[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState<number>(0);
  const [params, setParams] = useState<ProductListParams>(initialParams);

  useEffect(() => {
    setParams(initialParams);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    initialParams.q,
    initialParams.category,
    initialParams.stockStatus,
    initialParams.status,
    initialParams.page,
    initialParams.limit,
  ]);

  const fetchProducts = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await productService.getProducts(params);
      setProducts(data.items);
      setTotal(data.total);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to load products');
    } finally {
      setLoading(false);
    }
  }, [params]);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  const createProduct = async (input: CreateProductInput) => {
    const created = await productService.createProduct(input);
    await fetchProducts();
    return created;
  };

  const updateProduct = async (id: string, input: Partial<CreateProductInput>) => {
    const updated = await productService.updateProduct(id, input);
    await fetchProducts();
    return updated;
  };

  const archiveProduct = async (id: string) => {
    const archived = await productService.archiveProduct(id);
    await fetchProducts();
    return archived;
  };

  return {
    products,
    loading,
    error,
    total,
    params,
    setParams,
    refetch: fetchProducts,
    createProduct,
    updateProduct,
    archiveProduct,
  };
}
