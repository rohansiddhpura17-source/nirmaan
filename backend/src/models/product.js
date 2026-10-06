/**
 * Product Domain Model
 */
class Product {
  constructor(data = {}) {
    this.productId = data.productId || data.id || `prod_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    this.businessId = data.businessId;
    this.name = (data.name || '').trim();
    this.description = data.description || '';
    this.category = data.category || 'Other';
    this.sku = (data.sku || '').trim().toUpperCase();
    this.barcode = data.barcode ? data.barcode.trim() : null;
    this.purchasePrice = Number(data.purchasePrice !== undefined ? data.purchasePrice : (data.costPrice || 0));
    this.sellingPrice = Number(data.sellingPrice || 0);
    this.currentStock = Number(data.currentStock !== undefined ? data.currentStock : (data.stockQuantity || 0));
    this.minStockThreshold = Number(data.minStockThreshold !== undefined ? data.minStockThreshold : (data.minThreshold || 5));
    this.unit = data.unit || 'pcs';
    this.status = data.status || 'ACTIVE'; // ACTIVE | ARCHIVED | INACTIVE
    this.imageUrl = data.imageUrl || null;
    this.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
    this.updatedAt = data.updatedAt ? new Date(data.updatedAt) : new Date();
  }

  get isLowStock() {
    return this.currentStock <= this.minStockThreshold && this.currentStock > 0;
  }

  get isOutOfStock() {
    return this.currentStock <= 0;
  }

  get stockStatus() {
    if (this.currentStock <= 0) return 'OUT_OF_STOCK';
    if (this.currentStock <= this.minStockThreshold) return 'LOW_STOCK';
    return 'IN_STOCK';
  }

  toJSON() {
    return {
      productId: this.productId,
      id: this.productId,
      businessId: this.businessId,
      name: this.name,
      description: this.description,
      category: this.category,
      sku: this.sku,
      barcode: this.barcode,
      purchasePrice: this.purchasePrice,
      costPrice: this.purchasePrice,
      sellingPrice: this.sellingPrice,
      currentStock: this.currentStock,
      stockQuantity: this.currentStock,
      minStockThreshold: this.minStockThreshold,
      unit: this.unit,
      status: this.status,
      stockStatus: this.stockStatus,
      imageUrl: this.imageUrl,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  toFirestore() {
    return {
      productId: this.productId,
      businessId: this.businessId,
      name: this.name,
      description: this.description,
      category: this.category,
      sku: this.sku,
      barcode: this.barcode,
      purchasePrice: this.purchasePrice,
      sellingPrice: this.sellingPrice,
      currentStock: this.currentStock,
      minStockThreshold: this.minStockThreshold,
      unit: this.unit,
      status: this.status,
      imageUrl: this.imageUrl,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = Product;
