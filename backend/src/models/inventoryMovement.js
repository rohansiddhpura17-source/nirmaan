/**
 * Inventory Movement Domain Model
 * Tracks all stock mutations: SALE, RESTOCK, ADJUSTMENT, RETURN
 */
class InventoryMovement {
  constructor(data = {}) {
    this.movementId = data.movementId || data.id || `mov_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.businessId = data.businessId;
    this.productId = data.productId;
    this.productName = data.productName || '';
    this.type = (data.type || 'ADJUSTMENT').toUpperCase(); // SALE | RESTOCK | ADJUSTMENT | RETURN
    this.quantity = Number(data.quantity || 0); // Quantity affected
    this.previousStock = Number(data.previousStock !== undefined ? data.previousStock : 0);
    this.resultingStock = Number(data.resultingStock !== undefined ? data.resultingStock : 0);
    this.reason = data.reason || 'Manual Adjustment';
    this.referenceId = data.referenceId || null; // e.g. orderId
    this.createdBy = data.createdBy || 'system';
    this.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
  }

  toJSON() {
    return {
      movementId: this.movementId,
      id: this.movementId,
      businessId: this.businessId,
      productId: this.productId,
      productName: this.productName,
      type: this.type,
      quantity: this.quantity,
      previousStock: this.previousStock,
      resultingStock: this.resultingStock,
      reason: this.reason,
      referenceId: this.referenceId,
      createdBy: this.createdBy,
      createdAt: this.createdAt.toISOString(),
    };
  }

  toFirestore() {
    return {
      movementId: this.movementId,
      businessId: this.businessId,
      productId: this.productId,
      productName: this.productName,
      type: this.type,
      quantity: this.quantity,
      previousStock: this.previousStock,
      resultingStock: this.resultingStock,
      reason: this.reason,
      referenceId: this.referenceId,
      createdBy: this.createdBy,
      createdAt: this.createdAt.toISOString(),
    };
  }
}

module.exports = InventoryMovement;
