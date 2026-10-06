const productRepository = require('../repositories/productRepository');
const inventoryMovementRepository = require('../repositories/inventoryMovementRepository');

class InventoryService {
  async getInventorySummary(businessId) {
    const { items } = await productRepository.findByBusinessId(businessId, {
      status: 'ACTIVE',
      limit: 10000,
    });

    let totalStockUnits = 0;
    let lowStockCount = 0;
    let outOfStockCount = 0;
    let totalCostValue = 0;
    let totalRetailValue = 0;

    for (const p of items) {
      totalStockUnits += p.currentStock;
      if (p.currentStock <= 0) {
        outOfStockCount += 1;
      } else if (p.currentStock <= p.minStockThreshold) {
        lowStockCount += 1;
      }
      totalCostValue += p.currentStock * p.purchasePrice;
      totalRetailValue += p.currentStock * p.sellingPrice;
    }

    return {
      totalProducts: items.length,
      totalStockUnits,
      lowStockCount,
      outOfStockCount,
      inStockCount: items.length - lowStockCount - outOfStockCount,
      totalCostValue,
      inventoryValuation: totalCostValue,
      totalRetailValue,
      potentialProfit: totalRetailValue - totalCostValue,
    };
  }

  async listInventoryItems(businessId, options = {}) {
    return productRepository.findByBusinessId(businessId, options);
  }

  async adjustStock(businessId, { productId, type, quantity, reason, adjustmentMode = 'DELTA' }, userId) {
    const product = await productRepository.findById(productId);
    if (!product) {
      const err = new Error('Product not found');
      err.statusCode = 404;
      throw err;
    }
    if (product.businessId !== businessId) {
      const err = new Error('Forbidden: Cross-business inventory adjustment denied');
      err.statusCode = 403;
      throw err;
    }

    const previousStock = product.currentStock;
    const qty = Number(quantity);
    let resultingStock = previousStock;

    const normalizedType = type.toUpperCase();
    if (normalizedType === 'RESTOCK' || normalizedType === 'RETURN') {
      resultingStock = previousStock + qty;
    } else if (normalizedType === 'ADJUSTMENT') {
      // adjustmentMode can be SET or DELTA
      if (adjustmentMode === 'SET') {
        resultingStock = Math.max(0, qty);
      } else {
        // Delta adjustment
        resultingStock = previousStock + qty;
      }
    } else {
      resultingStock = previousStock + qty;
    }

    if (resultingStock < 0) {
      const err = new Error(`Stock adjustment cannot result in negative stock. Current: ${previousStock}, adjustment: ${qty}`);
      err.statusCode = 400;
      throw err;
    }

    // Update product stock
    await productRepository.update(productId, { currentStock: resultingStock });

    // Record inventory movement
    const movement = await inventoryMovementRepository.create({
      businessId,
      productId,
      productName: product.name,
      type: normalizedType,
      quantity: Math.abs(resultingStock - previousStock),
      previousStock,
      resultingStock,
      reason: reason || `Manual stock update (${normalizedType})`,
      createdBy: userId || 'system',
    });

    const updatedProduct = await productRepository.findById(productId);

    return {
      product: updatedProduct,
      movement,
    };
  }

  async getMovements(businessId, options = {}) {
    return inventoryMovementRepository.findByBusinessId(businessId, options);
  }
}

module.exports = new InventoryService();
