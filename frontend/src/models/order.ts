export type OrderStatus = 'COMPLETED' | 'PENDING' | 'CANCELLED';

export type PaymentMethod = 'CASH' | 'UPI' | 'CARD' | 'CREDIT';

export interface OrderItem {
  productId: string;
  productName: string;
  sku?: string;
  quantity: number;
  unitPrice: number;
  lineTotal?: number;
  subtotal?: number;
}

export interface OrderModel {
  id: string;
  orderId?: string;
  businessId?: string;
  orderNumber: string;
  customerId?: string | null;
  customerName: string;
  customerPhone?: string | null;
  items: OrderItem[];
  subtotal?: number;
  discount?: number;
  tax?: number;
  total?: number;
  totalAmount: number;
  paymentMethod: PaymentMethod;
  paymentStatus?: 'PAID' | 'PENDING' | 'FAILED';
  status: OrderStatus;
  orderStatus?: OrderStatus;
  idempotencyKey?: string | null;
  createdBy?: string;
  createdAt: string;
  updatedAt?: string;
}
