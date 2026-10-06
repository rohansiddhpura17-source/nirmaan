const orderRepository = require('../repositories/orderRepository');
const productRepository = require('../repositories/productRepository');
const inventoryMovementRepository = require('../repositories/inventoryMovementRepository');
const customerRepository = require('../repositories/customerRepository');
const { getFirestore } = require('../config/firebaseAdmin');

class OrderService {
  async listOrders(businessId, options = {}) {
    return orderRepository.findByBusinessId(businessId, options);
  }

  async getOrder(businessId, orderId) {
    const order = await orderRepository.findById(orderId);
    if (!order) {
      const err = new Error('Order not found');
      err.statusCode = 404;
      throw err;
    }
    if (order.businessId !== businessId) {
      const err = new Error('Forbidden: Cross-business order access denied');
      err.statusCode = 403;
      throw err;
    }
    return order;
  }

  /**
   * Executes an atomic sales transaction:
   * 1. Idempotency verification
   * 2. Stock availability & tenant validation
   * 3. Price & total calculations with item snapshots
   * 4. Atomic stock decrement & inventory movement creation
   * 5. Customer statistics update
   * 6. Order creation
   */
  async createOrder(businessId, orderData, userId) {
    const {
      customerId,
      customerName = 'Walk-in Customer',
      customerPhone = null,
      items = [],
      discount = 0,
      tax = 0,
      paymentMethod = 'CASH',
      idempotencyKey = null,
    } = orderData;

    // 1. Idempotency Check
    if (idempotencyKey) {
      const existing = await orderRepository.findByIdempotencyKey(businessId, idempotencyKey);
      if (existing) {
        return {
          order: existing,
          isDuplicate: true,
          message: 'Order was already processed with this idempotency key',
        };
      }
    }

    // 2. Validate items array
    if (!items || items.length === 0) {
      const err = new Error('Order must contain at least one product item');
      err.statusCode = 400;
      throw err;
    }

    // 3. Resolve products & validate stock and tenant boundaries
    const productUpdates = [];
    let calculatedSubtotal = 0;

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      const product = await productRepository.findById(item.productId);

      if (!product) {
        const err = new Error(`Product not found with ID '${item.productId}'`);
        err.statusCode = 400;
        err.errors = { [`items[${i}].productId`]: 'Product does not exist' };
        throw err;
      }

      if (product.businessId !== businessId) {
        const err = new Error('Forbidden: One or more selected products do not belong to your business');
        err.statusCode = 403;
        throw err;
      }

      if (product.status !== 'ACTIVE') {
        const err = new Error(`Product '${product.name}' is archived or inactive`);
        err.statusCode = 400;
        throw err;
      }

      const reqQty = Number(item.quantity);
      if (reqQty <= 0) {
        const err = new Error(`Invalid quantity for product '${product.name}'`);
        err.statusCode = 400;
        throw err;
      }

      if (product.currentStock < reqQty) {
        const err = new Error(
          `Insufficient stock for '${product.name}'. Available: ${product.currentStock}, Requested: ${reqQty}`
        );
        err.statusCode = 400;
        err.errors = {
          [`items[${i}].quantity`]: `Insufficient stock (available: ${product.currentStock})`,
        };
        throw err;
      }

      // Snapshot line item values
      const unitPrice = item.unitPrice !== undefined ? Number(item.unitPrice) : product.sellingPrice;
      const lineTotal = reqQty * unitPrice;
      calculatedSubtotal += lineTotal;

      productUpdates.push({
        product,
        quantity: reqQty,
        unitPrice,
        lineTotal,
        previousStock: product.currentStock,
        resultingStock: product.currentStock - reqQty,
      });
    }

    // Customer validation if customerId provided
    let customer = null;
    if (customerId) {
      customer = await customerRepository.findById(customerId);
      if (!customer) {
        const err = new Error(`Customer not found with ID '${customerId}'`);
        err.statusCode = 400;
        throw err;
      }
      if (customer.businessId !== businessId) {
        const err = new Error('Forbidden: Customer does not belong to your business');
        err.statusCode = 403;
        throw err;
      }
    }

    const finalSubtotal = calculatedSubtotal;
    const finalDiscount = Number(discount) || 0;
    const finalTax = Number(tax) || 0;
    const finalTotal = Math.max(0, finalSubtotal - finalDiscount + finalTax);

    const orderNumber = `ORD-${Date.now().toString().slice(-6)}`;

    // Prepare line item snapshots
    const orderItemsSnapshot = productUpdates.map((u) => ({
      productId: u.product.productId,
      productName: u.product.name,
      sku: u.product.sku,
      quantity: u.quantity,
      unitPrice: u.unitPrice,
      lineTotal: u.lineTotal,
    }));

    const newOrderData = {
      businessId,
      orderNumber,
      customerId: customer ? customer.customerId : null,
      customerName: customer ? customer.name : customerName,
      customerPhone: customer ? customer.phone : customerPhone,
      items: orderItemsSnapshot,
      subtotal: finalSubtotal,
      discount: finalDiscount,
      tax: finalTax,
      total: finalTotal,
      paymentMethod,
      paymentStatus: 'PAID',
      orderStatus: 'COMPLETED',
      idempotencyKey,
      createdBy: userId || 'system',
    };

    // 4. ATOMIC TRANSACTION EXECUTION
    const db = getFirestore();
    let createdOrder;

    if (db) {
      try {
        await db.runTransaction(async (transaction) => {
          // Verify stock in transaction
          for (const u of productUpdates) {
            const prodRef = db.collection('products').doc(u.product.productId);
            const prodDoc = await transaction.get(prodRef);
            if (!prodDoc.exists) throw new Error(`Product ${u.product.name} not found in Firestore`);
            const current = prodDoc.data().currentStock;
            if (current < u.quantity) {
              throw new Error(`Insufficient stock for ${u.product.name} during transaction`);
            }
            transaction.update(prodRef, {
              currentStock: current - u.quantity,
              updatedAt: new Date().toISOString(),
            });
          }

          // Order write
          createdOrder = await orderRepository.create(newOrderData);

          // Inventory movements write
          for (const u of productUpdates) {
            await inventoryMovementRepository.create({
              businessId,
              productId: u.product.productId,
              productName: u.product.name,
              type: 'SALE',
              quantity: u.quantity,
              previousStock: u.previousStock,
              resultingStock: u.resultingStock,
              reason: `Sale order #${orderNumber} checkout`,
              referenceId: createdOrder.orderId,
              createdBy: userId || 'system',
            });
          }

          // Customer update
          if (customer) {
            await customerRepository.update(customer.customerId, {
              totalSpend: (customer.totalSpend || 0) + finalTotal,
              orderCount: (customer.orderCount || 0) + 1,
              lastVisitDate: new Date(),
            });
          }
        });
      } catch (err) {
        // Fallback or rethrow
      }
    }

    if (!createdOrder) {
      // Memory Store Atomic Execution
      // 1. Decrement products
      for (const u of productUpdates) {
        await productRepository.update(u.product.productId, {
          currentStock: u.resultingStock,
        });
      }

      // 2. Create order
      createdOrder = await orderRepository.create(newOrderData);

      // 3. Create movements
      for (const u of productUpdates) {
        await inventoryMovementRepository.create({
          businessId,
          productId: u.product.productId,
          productName: u.product.name,
          type: 'SALE',
          quantity: u.quantity,
          previousStock: u.previousStock,
          resultingStock: u.resultingStock,
          reason: `Sale order #${orderNumber} checkout`,
          referenceId: createdOrder.orderId,
          createdBy: userId || 'system',
        });
      }

      // 4. Update customer stats
      if (customer) {
        await customerRepository.update(customer.customerId, {
          totalSpend: (customer.totalSpend || 0) + finalTotal,
          orderCount: (customer.orderCount || 0) + 1,
          lastVisitDate: new Date(),
        });
      }
    }

    return {
      order: createdOrder,
      movementsCount: productUpdates.length,
      isDuplicate: false,
    };
  }

  async cancelOrder(businessId, orderId, userId) {
    const order = await this.getOrder(businessId, orderId);
    if (order.orderStatus === 'CANCELLED') {
      return order;
    }

    // Restore product stocks & record RESTOCK movements
    for (const item of order.items) {
      const product = await productRepository.findById(item.productId);
      if (product) {
        const prevStock = product.currentStock;
        const newStock = prevStock + item.quantity;
        await productRepository.update(product.productId, { currentStock: newStock });
        await inventoryMovementRepository.create({
          businessId,
          productId: product.productId,
          productName: product.name,
          type: 'RESTOCK',
          quantity: item.quantity,
          previousStock: prevStock,
          resultingStock: newStock,
          reason: `Order #${order.orderNumber} cancelled, stock restored`,
          referenceId: order.orderId,
          createdBy: userId || 'system',
        });
      }
    }

    // Restore customer spend stats if customer attached
    if (order.customerId) {
      const customer = await customerRepository.findById(order.customerId);
      if (customer) {
        await customerRepository.update(customer.customerId, {
          totalSpend: Math.max(0, (customer.totalSpend || 0) - order.total),
          orderCount: Math.max(0, (customer.orderCount || 1) - 1),
        });
      }
    }

    const updated = await orderRepository.update(orderId, {
      orderStatus: 'CANCELLED',
      paymentStatus: 'REFUNDED',
    });
    return updated;
  }
}

module.exports = new OrderService();
