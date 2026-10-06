/**
 * Order Domain Model
 * Captures historical transaction snapshots: products, unit prices, line totals, and customer details.
 */
class Order {
  constructor(data = {}) {
    this.orderId = data.orderId || data.id || `ord_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.businessId = data.businessId;
    this.orderNumber = data.orderNumber || `ORD-${Date.now().toString().slice(-6)}`;
    this.customerId = data.customerId || null;
    this.customerName = (data.customerName || 'Walk-in Customer').trim();
    this.customerPhone = data.customerPhone ? data.customerPhone.trim() : null;
    
    // Items snapshot
    this.items = (data.items || []).map((item) => ({
      productId: item.productId,
      productName: item.productName || item.name || 'Unknown Item',
      sku: item.sku || '',
      quantity: Number(item.quantity || 1),
      unitPrice: Number(item.unitPrice !== undefined ? item.unitPrice : (item.price || 0)),
      lineTotal: Number(
        item.lineTotal !== undefined
          ? item.lineTotal
          : Number(item.quantity || 1) * Number(item.unitPrice || item.price || 0)
      ),
    }));

    this.subtotal = Number(
      data.subtotal !== undefined
        ? data.subtotal
        : this.items.reduce((sum, item) => sum + item.lineTotal, 0)
    );
    this.discount = Number(data.discount || 0);
    this.tax = Number(data.tax || 0);
    this.total = Number(
      data.total !== undefined
        ? data.total
        : Math.max(0, this.subtotal - this.discount + this.tax)
    );

    this.paymentMethod = (data.paymentMethod || 'CASH').toUpperCase(); // CASH | UPI | CARD | CREDIT
    this.paymentStatus = (data.paymentStatus || 'PAID').toUpperCase(); // PAID | PENDING | FAILED
    this.orderStatus = (data.orderStatus || data.status || 'COMPLETED').toUpperCase(); // COMPLETED | PENDING | CANCELLED
    this.idempotencyKey = data.idempotencyKey || null;
    this.createdBy = data.createdBy || 'system';
    this.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
    this.updatedAt = data.updatedAt ? new Date(data.updatedAt) : new Date();
  }

  toJSON() {
    return {
      orderId: this.orderId,
      id: this.orderId,
      businessId: this.businessId,
      orderNumber: this.orderNumber,
      customerId: this.customerId,
      customerName: this.customerName,
      customerPhone: this.customerPhone,
      items: this.items,
      subtotal: this.subtotal,
      discount: this.discount,
      tax: this.tax,
      total: this.total,
      totalAmount: this.total, // UI compatibility
      paymentMethod: this.paymentMethod,
      paymentStatus: this.paymentStatus,
      orderStatus: this.orderStatus,
      status: this.orderStatus, // UI compatibility
      idempotencyKey: this.idempotencyKey,
      createdBy: this.createdBy,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  toFirestore() {
    return {
      orderId: this.orderId,
      businessId: this.businessId,
      orderNumber: this.orderNumber,
      customerId: this.customerId,
      customerName: this.customerName,
      customerPhone: this.customerPhone,
      items: this.items,
      subtotal: this.subtotal,
      discount: this.discount,
      tax: this.tax,
      total: this.total,
      paymentMethod: this.paymentMethod,
      paymentStatus: this.paymentStatus,
      orderStatus: this.orderStatus,
      idempotencyKey: this.idempotencyKey,
      createdBy: this.createdBy,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = Order;
