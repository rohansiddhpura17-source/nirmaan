import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import { ProductsPage } from '@/pages/ProductsPage';
import { AddProductPage } from '@/pages/AddProductPage';
import { InventoryPage } from '@/pages/InventoryPage';
import { CustomersPage } from '@/pages/CustomersPage';
import { OrdersPage } from '@/pages/OrdersPage';
import { productService } from '@/services/productService';
import { inventoryService } from '@/services/inventoryService';
import { customerService } from '@/services/customerService';
import { orderService } from '@/services/orderService';
import { ProductModel } from '@/models/product';
import { CustomerModel } from '@/models/customer';
import { OrderModel } from '@/models/order';

describe('Nirmaan Web — Phase 4: Core Business Operations Suite', () => {
  const sampleProducts: ProductModel[] = [
    {
      id: 'prod_1',
      productId: 'prod_1',
      name: 'Tata Tea Gold 500g',
      sku: 'TATA-TEA-500G',
      category: 'Beverages',
      costPrice: 200,
      sellingPrice: 250,
      stockQuantity: 20,
      currentStock: 20,
      minStockThreshold: 5,
      unit: 'pack',
      status: 'ACTIVE',
      updatedAt: '2026-10-01T10:00:00.000Z',
    },
    {
      id: 'prod_2',
      productId: 'prod_2',
      name: 'Fortune Sunflower Oil 1L',
      sku: 'FORT-OIL-1L',
      category: 'Groceries',
      costPrice: 120,
      sellingPrice: 150,
      stockQuantity: 3, // Low stock <= 5
      currentStock: 3,
      minStockThreshold: 5,
      unit: 'pouch',
      status: 'ACTIVE',
      updatedAt: '2026-10-01T10:00:00.000Z',
    },
    {
      id: 'prod_3',
      productId: 'prod_3',
      name: 'Aashirvaad Atta 10kg',
      sku: 'AASH-ATTA-10KG',
      category: 'Groceries',
      costPrice: 380,
      sellingPrice: 440,
      stockQuantity: 0, // Out of stock
      currentStock: 0,
      minStockThreshold: 8,
      unit: 'pack',
      status: 'ACTIVE',
      updatedAt: '2026-10-01T10:00:00.000Z',
    },
  ];

  const sampleCustomers: CustomerModel[] = [
    {
      id: 'cust_1',
      name: 'Ramesh Patel',
      phone: '+91 98200 12345',
      totalPurchases: 5000,
      outstandingCredit: 450,
      lastVisitDate: '2026-10-01T10:00:00.000Z',
      loyaltyPoints: 50,
    },
    {
      id: 'cust_2',
      name: 'Pooja Verma',
      phone: '+91 98200 54321',
      totalPurchases: 3200,
      outstandingCredit: 0,
      lastVisitDate: '2026-10-01T10:00:00.000Z',
      loyaltyPoints: 32,
    },
  ];

  const sampleOrders: OrderModel[] = [
    {
      id: 'ord_1',
      orderNumber: 'ORD-10023',
      customerName: 'Ramesh Patel',
      customerId: 'cust_1',
      items: [
        {
          productId: 'prod_1',
          productName: 'Tata Tea Gold 500g',
          quantity: 2,
          unitPrice: 250,
        },
      ],
      totalAmount: 500,
      total: 500,
      paymentMethod: 'UPI',
      status: 'COMPLETED',
      orderStatus: 'COMPLETED',
      createdAt: '2026-10-01T10:00:00.000Z',
    },
  ];

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  // ==========================================
  // PRODUCTS SUITE (1 - 6)
  // ==========================================

  it('1. product list rendering renders product names, SKUs, and pricing correctly', async () => {
    vi.spyOn(productService, 'getProducts').mockResolvedValue({
      items: sampleProducts,
      total: sampleProducts.length,
      page: 1,
      limit: 50,
    });

    render(
      <MemoryRouter>
        <ProductsPage />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByText('Tata Tea Gold 500g')).toBeDefined();
      expect(screen.getByText('Fortune Sunflower Oil 1L')).toBeDefined();
      expect(screen.getByText('Aashirvaad Atta 10kg')).toBeDefined();
      expect(screen.getByText('TATA-TEA-500G')).toBeDefined();
    });
  });

  it('2. product search queries the product service with search keyword', async () => {
    const getSpy = vi.spyOn(productService, 'getProducts').mockResolvedValue({
      items: [sampleProducts[0]],
      total: 1,
      page: 1,
      limit: 50,
    });

    render(
      <MemoryRouter>
        <ProductsPage />
      </MemoryRouter>
    );

    const searchInput = screen.getByPlaceholderText(/search catalog by name or sku/i);
    fireEvent.change(searchInput, { target: { value: 'Tata' } });

    await waitFor(() => {
      expect(getSpy).toHaveBeenCalledWith(expect.objectContaining({ q: 'Tata' }));
    });
  });

  it('3. product category filter filters by category chip selection', async () => {
    const getSpy = vi.spyOn(productService, 'getProducts').mockResolvedValue({
      items: [sampleProducts[0]],
      total: 1,
      page: 1,
      limit: 50,
    });

    render(
      <MemoryRouter>
        <ProductsPage />
      </MemoryRouter>
    );

    const fmcgChip = screen.getByRole('button', { name: 'Beverages' });
    fireEvent.click(fmcgChip);

    await waitFor(() => {
      expect(getSpy).toHaveBeenCalledWith(expect.objectContaining({ category: 'Beverages' }));
    });
  });

  it('4. product creation validation prevents submission when required fields are empty', async () => {
    render(
      <MemoryRouter>
        <AddProductPage />
      </MemoryRouter>
    );

    const saveButton = screen.getByRole('button', { name: /save product to catalog/i });
    fireEvent.submit(saveButton.closest('form')!);

    await waitFor(() => {
      expect(screen.getByText(/product name is required/i)).toBeDefined();
    });
  });

  it('5. product create flow successfully creates product and redirects', async () => {
    const createSpy = vi.spyOn(productService, 'createProduct').mockResolvedValue(sampleProducts[0]);

    render(
      <MemoryRouter initialEntries={['/products/add']}>
        <Routes>
          <Route path="/products/add" element={<AddProductPage />} />
          <Route path="/products" element={<div data-testid="products-catalog-view">Catalog View</div>} />
        </Routes>
      </MemoryRouter>
    );

    const nameInput = screen.getByLabelText(/product name/i);
    fireEvent.change(nameInput, { target: { value: 'Taj Mahal Tea 250g' } });

    const costInput = screen.getByLabelText(/cost price/i);
    fireEvent.change(costInput, { target: { value: '110' } });

    const sellingInput = screen.getByLabelText(/selling price/i);
    fireEvent.change(sellingInput, { target: { value: '140' } });

    const saveButton = screen.getByRole('button', { name: /save product to catalog/i });
    fireEvent.submit(saveButton.closest('form')!);

    await waitFor(() => {
      expect(createSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          name: 'Taj Mahal Tea 250g',
          costPrice: 110,
          sellingPrice: 140,
        })
      );
      expect(screen.getByTestId('products-catalog-view')).toBeDefined();
    });
  });

  it('6. product edit flow updates existing product via modal', async () => {
    vi.spyOn(productService, 'getProducts').mockResolvedValue({
      items: [sampleProducts[0]],
      total: 1,
      page: 1,
      limit: 50,
    });
    const updateSpy = vi.spyOn(productService, 'updateProduct').mockResolvedValue({
      ...sampleProducts[0],
      sellingPrice: 270,
    });

    render(
      <MemoryRouter>
        <ProductsPage />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByText('Tata Tea Gold 500g')).toBeDefined();
    });

    const editBtn = screen.getByRole('button', { name: /edit/i });
    fireEvent.click(editBtn);

    expect(screen.getByText(/edit product details/i)).toBeDefined();

    const sellingInput = screen.getByLabelText(/selling price/i);
    fireEvent.change(sellingInput, { target: { value: '270' } });

    const saveChangesBtn = screen.getByRole('button', { name: /save changes/i });
    fireEvent.submit(saveChangesBtn.closest('form')!);

    await waitFor(() => {
      expect(updateSpy).toHaveBeenCalledWith(
        'prod_1',
        expect.objectContaining({ sellingPrice: 270 })
      );
    });
  });

  // ==========================================
  // INVENTORY SUITE (7 - 9)
  // ==========================================

  it('7. inventory stock status renders In Stock, Low Stock, and Out of Stock badges', async () => {
    vi.spyOn(inventoryService, 'getSummary').mockResolvedValue({
      totalProducts: 3,
      totalStockUnits: 23,
      lowStockCount: 1,
      outOfStockCount: 1,
      inStockCount: 1,
      totalCostValue: 4720,
      totalRetailValue: 5850,
      potentialProfit: 1130,
    });
    vi.spyOn(inventoryService, 'getInventoryItems').mockResolvedValue({
      items: sampleProducts,
      total: 3,
      page: 1,
      limit: 50,
    });

    render(
      <MemoryRouter>
        <InventoryPage />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getAllByText('In Stock').length).toBeGreaterThan(0);
      expect(screen.getAllByText('Low Stock').length).toBeGreaterThan(0);
      expect(screen.getAllByText('Out of Stock').length).toBeGreaterThan(0);
    });
  });

  it('8. inventory filtering filters items by stock status pill', async () => {
    vi.spyOn(inventoryService, 'getSummary').mockResolvedValue({
      totalProducts: 3,
      totalStockUnits: 23,
      lowStockCount: 1,
      outOfStockCount: 1,
      inStockCount: 1,
      totalCostValue: 4720,
      totalRetailValue: 5850,
      potentialProfit: 1130,
    });
    const invSpy = vi.spyOn(inventoryService, 'getInventoryItems').mockResolvedValue({
      items: [sampleProducts[1]],
      total: 1,
      page: 1,
      limit: 50,
    });

    render(
      <MemoryRouter>
        <InventoryPage />
      </MemoryRouter>
    );

    const lowStockPill = screen.getByRole('button', { name: 'LOW STOCK' });
    fireEvent.click(lowStockPill);

    await waitFor(() => {
      expect(invSpy).toHaveBeenCalledWith(
        expect.objectContaining({ stockStatus: 'LOW_STOCK' })
      );
    });
  });

  it('9. inventory stock movement display opens history modal with past movements', async () => {
    vi.spyOn(inventoryService, 'getSummary').mockResolvedValue({
      totalProducts: 1,
      totalStockUnits: 20,
      lowStockCount: 0,
      outOfStockCount: 0,
      inStockCount: 1,
      totalCostValue: 4000,
      totalRetailValue: 5000,
      potentialProfit: 1000,
    });
    vi.spyOn(inventoryService, 'getInventoryItems').mockResolvedValue({
      items: [sampleProducts[0]],
      total: 1,
      page: 1,
      limit: 50,
    });
    vi.spyOn(inventoryService, 'getMovements').mockResolvedValue({
      items: [
        {
          id: 'mov_1',
          productId: 'prod_1',
          productName: 'Tata Tea Gold 500g',
          type: 'RESTOCK',
          quantity: 20,
          previousStock: 0,
          resultingStock: 20,
          reason: 'Initial supplier restock',
          createdAt: '2026-10-01T10:00:00.000Z',
        },
      ],
      total: 1,
    });

    render(
      <MemoryRouter>
        <InventoryPage />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByText('Tata Tea Gold 500g')).toBeDefined();
    });

    const historyBtn = screen.getByTitle(/view stock movement history/i);
    fireEvent.click(historyBtn);

    await waitFor(() => {
      expect(screen.getByText(/stock movement history/i)).toBeDefined();
      expect(screen.getByText(/initial supplier restock/i)).toBeDefined();
      expect(screen.getByText(/Stock: 0 → 20/i)).toBeDefined();
    });
  });

  // ==========================================
  // CUSTOMERS SUITE (10 - 11)
  // ==========================================

  it('10. customer search filters customers by phone or name', async () => {
    const custSpy = vi.spyOn(customerService, 'getCustomers').mockResolvedValue({
      items: [sampleCustomers[0]],
      total: 1,
      page: 1,
      limit: 50,
    });

    render(
      <MemoryRouter>
        <CustomersPage />
      </MemoryRouter>
    );

    const searchInput = screen.getByPlaceholderText(/search customers by name or phone/i);
    fireEvent.change(searchInput, { target: { value: 'Ramesh' } });

    await waitFor(() => {
      expect(custSpy).toHaveBeenCalledWith(expect.objectContaining({ q: 'Ramesh' }));
    });
  });

  it('11. customer creation validates inputs and saves new customer', async () => {
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({
      items: sampleCustomers,
      total: 2,
      page: 1,
      limit: 50,
    });
    const createSpy = vi.spyOn(customerService, 'createCustomer').mockResolvedValue({
      id: 'cust_new',
      name: 'Sunil Gavaskar',
      phone: '+91 98333 44556',
      totalPurchases: 0,
      outstandingCredit: 0,
      lastVisitDate: '2026-10-01T10:00:00.000Z',
      loyaltyPoints: 0,
    });

    render(
      <MemoryRouter>
        <CustomersPage />
      </MemoryRouter>
    );

    const addBtn = screen.getByRole('button', { name: /add customer/i });
    fireEvent.click(addBtn);

    const nameInput = screen.getByLabelText(/customer full name/i);
    fireEvent.change(nameInput, { target: { value: 'Sunil Gavaskar' } });

    const phoneInput = screen.getByLabelText(/phone contact/i);
    fireEvent.change(phoneInput, { target: { value: '+91 98333 44556' } });

    const submitBtn = screen.getByRole('button', { name: /save customer/i });
    fireEvent.click(submitBtn);

    await waitFor(() => {
      expect(createSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          name: 'Sunil Gavaskar',
          phone: '+91 98333 44556',
        })
      );
    });
  });

  // ==========================================
  // ORDERS SUITE (12 - 17)
  // ==========================================

  it('12. order calculation computes line totals, subtotal, and grand total', async () => {
    vi.spyOn(orderService, 'getOrders').mockResolvedValue({
      items: sampleOrders,
      total: 1,
      page: 1,
      limit: 50,
    });
    vi.spyOn(productService, 'getProducts').mockResolvedValue({
      items: sampleProducts,
      total: 3,
      page: 1,
      limit: 100,
    });
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({
      items: sampleCustomers,
      total: 2,
      page: 1,
      limit: 100,
    });

    render(
      <MemoryRouter>
        <OrdersPage />
      </MemoryRouter>
    );

    const createSaleBtn = screen.getByTestId('btn-create-sale');
    fireEvent.click(createSaleBtn);

    await waitFor(() => {
      expect(screen.getByText(/new sale \/ pos counter/i)).toBeDefined();
    });

    const addBtn = screen.getByRole('button', { name: /^Add$/i });
    fireEvent.click(addBtn);

    await waitFor(() => {
      // 1 item of Tata Tea Gold 500g at 250
      expect(screen.getByText(/Order Items \(1\)/i)).toBeDefined();
      expect(screen.getAllByText(/₹250/i).length).toBeGreaterThan(0);
    });
  });

  it('13. invalid quantity rejection prevents adding 0 or negative items to cart', async () => {
    vi.spyOn(orderService, 'getOrders').mockResolvedValue({ items: [], total: 0, page: 1, limit: 50 });
    vi.spyOn(productService, 'getProducts').mockResolvedValue({ items: sampleProducts, total: 3, page: 1, limit: 100 });
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({ items: [], total: 0, page: 1, limit: 100 });

    render(
      <MemoryRouter>
        <OrdersPage />
      </MemoryRouter>
    );

    fireEvent.click(screen.getByTestId('btn-create-sale'));

    await waitFor(() => {
      expect(screen.getByText(/new sale \/ pos counter/i)).toBeDefined();
    });

    const qtyInput = screen.getByPlaceholderText(/qty/i);
    fireEvent.change(qtyInput, { target: { value: '0' } });

    fireEvent.click(screen.getByRole('button', { name: /^Add$/i }));

    await waitFor(() => {
      expect(screen.getByText(/quantity must be greater than 0/i)).toBeDefined();
    });
  });

  it('14. insufficient stock rejection rejects quantities exceeding available inventory', async () => {
    vi.spyOn(orderService, 'getOrders').mockResolvedValue({ items: [], total: 0, page: 1, limit: 50 });
    // Product 1 has only 20 units
    vi.spyOn(productService, 'getProducts').mockResolvedValue({ items: sampleProducts, total: 3, page: 1, limit: 100 });
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({ items: [], total: 0, page: 1, limit: 100 });

    render(
      <MemoryRouter>
        <OrdersPage />
      </MemoryRouter>
    );

    fireEvent.click(screen.getByTestId('btn-create-sale'));

    await waitFor(() => {
      expect(screen.getByText(/new sale \/ pos counter/i)).toBeDefined();
    });

    const qtyInput = screen.getByPlaceholderText(/qty/i);
    fireEvent.change(qtyInput, { target: { value: '999' } });

    fireEvent.click(screen.getByRole('button', { name: /^Add$/i }));

    await waitFor(() => {
      expect(screen.getByText(/cannot add 999 units\. only 20 units available/i)).toBeDefined();
    });
  });

  it('15. successful order flow creates order and refetches list', async () => {
    vi.spyOn(orderService, 'getOrders').mockResolvedValue({ items: [], total: 0, page: 1, limit: 50 });
    vi.spyOn(productService, 'getProducts').mockResolvedValue({ items: sampleProducts, total: 3, page: 1, limit: 100 });
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({ items: sampleCustomers, total: 2, page: 1, limit: 100 });
    const createSpy = vi.spyOn(orderService, 'createOrder').mockResolvedValue(sampleOrders[0]);

    render(
      <MemoryRouter>
        <OrdersPage />
      </MemoryRouter>
    );

    fireEvent.click(screen.getByTestId('btn-create-sale'));

    await waitFor(() => {
      expect(screen.getByText(/new sale \/ pos counter/i)).toBeDefined();
    });

    // Add item
    fireEvent.click(screen.getByRole('button', { name: /^Add$/i }));

    await waitFor(() => {
      expect(screen.getByText(/Order Items \(1\)/i)).toBeDefined();
    });

    // Complete order
    const completeBtn = screen.getByTestId('btn-complete-order');
    fireEvent.submit(completeBtn.closest('form')!);

    await waitFor(() => {
      expect(createSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          customerName: 'Walk-in Customer',
          items: expect.arrayContaining([
            expect.objectContaining({
              productId: 'prod_1',
              quantity: 1,
              unitPrice: 250,
            }),
          ]),
          paymentMethod: 'CASH',
        })
      );
    });
  });

  it('16. duplicate submit prevention disables complete order button while submitting', async () => {
    vi.spyOn(orderService, 'getOrders').mockResolvedValue({ items: [], total: 0, page: 1, limit: 50 });
    vi.spyOn(productService, 'getProducts').mockResolvedValue({ items: sampleProducts, total: 3, page: 1, limit: 100 });
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({ items: [], total: 0, page: 1, limit: 100 });

    let resolveOrder: (val: OrderModel) => void;
    vi.spyOn(orderService, 'createOrder').mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveOrder = resolve;
        })
    );

    render(
      <MemoryRouter>
        <OrdersPage />
      </MemoryRouter>
    );

    fireEvent.click(screen.getByTestId('btn-create-sale'));

    await waitFor(() => {
      expect(screen.getByText(/new sale \/ pos counter/i)).toBeDefined();
    });

    fireEvent.click(screen.getByRole('button', { name: /^Add$/i }));

    await waitFor(() => {
      expect(screen.getByText(/Order Items \(1\)/i)).toBeDefined();
    });

    const completeBtn = screen.getByTestId('btn-complete-order') as HTMLButtonElement;
    fireEvent.submit(completeBtn.closest('form')!);

    // Button should be disabled during submission
    await waitFor(() => {
      expect(completeBtn.disabled).toBe(true);
    });

    // Resolve the promise
    resolveOrder!(sampleOrders[0]);
  });

  it('17. error state displays actionable error message when order creation fails', async () => {
    vi.spyOn(orderService, 'getOrders').mockResolvedValue({ items: [], total: 0, page: 1, limit: 50 });
    vi.spyOn(productService, 'getProducts').mockResolvedValue({ items: sampleProducts, total: 3, page: 1, limit: 100 });
    vi.spyOn(customerService, 'getCustomers').mockResolvedValue({ items: [], total: 0, page: 1, limit: 100 });
    vi.spyOn(orderService, 'createOrder').mockRejectedValue(
      new Error('Insufficient stock for Tata Tea Gold 500g')
    );

    render(
      <MemoryRouter>
        <OrdersPage />
      </MemoryRouter>
    );

    fireEvent.click(screen.getByTestId('btn-create-sale'));

    await waitFor(() => {
      expect(screen.getByText(/new sale \/ pos counter/i)).toBeDefined();
    });

    fireEvent.click(screen.getByRole('button', { name: /^Add$/i }));

    const completeBtn = screen.getByTestId('btn-complete-order');
    fireEvent.click(completeBtn);

    await waitFor(() => {
      expect(screen.getByText(/insufficient stock for tata tea gold 500g/i)).toBeDefined();
    });
  });
});
