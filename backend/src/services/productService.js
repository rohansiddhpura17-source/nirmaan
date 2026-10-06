const productRepository = require('../repositories/productRepository');
const inventoryMovementRepository = require('../repositories/inventoryMovementRepository');

class ProductService {
  async listProducts(businessId, options = {}) {
    return productRepository.findByBusinessId(businessId, options);
  }

  async getProduct(businessId, productId) {
    const product = await productRepository.findById(productId);
    if (!product) {
      const err = new Error('Product not found');
      err.statusCode = 404;
      throw err;
    }
    if (product.businessId !== businessId) {
      const err = new Error('Forbidden: Cross-business product access denied');
      err.statusCode = 403;
      throw err;
    }
    return product;
  }

  async createProduct(businessId, productData, userId) {
    // 1. SKU uniqueness policy per business
    const sku = (productData.sku || `SKU-${Date.now().toString().slice(-6)}`).trim().toUpperCase();
    const existingWithSku = await productRepository.findBySku(businessId, sku);
    if (existingWithSku && existingWithSku.status === 'ACTIVE') {
      const err = new Error(`A product with SKU '${sku}' already exists in your business catalog`);
      err.statusCode = 409;
      err.errors = { sku: 'Duplicate SKU within business' };
      throw err;
    }

    // 2. Barcode uniqueness policy per business if provided
    if (productData.barcode && productData.barcode.trim()) {
      const barcode = productData.barcode.trim();
      const existingWithBarcode = await productRepository.findByBarcode(businessId, barcode);
      if (existingWithBarcode && existingWithBarcode.status === 'ACTIVE') {
        const err = new Error(`A product with Barcode '${barcode}' already exists in your business catalog`);
        err.statusCode = 409;
        err.errors = { barcode: 'Duplicate barcode within business' };
        throw err;
      }
    }

    const initialStock = Number(productData.currentStock !== undefined ? productData.currentStock : (productData.stockQuantity || 0));

    const product = await productRepository.create({
      ...productData,
      sku,
      currentStock: initialStock,
      businessId,
    });

    // 3. Record initial stock movement if currentStock > 0
    if (initialStock > 0) {
      await inventoryMovementRepository.create({
        businessId,
        productId: product.productId,
        productName: product.name,
        type: 'RESTOCK',
        quantity: initialStock,
        previousStock: 0,
        resultingStock: initialStock,
        reason: 'Initial inventory on product creation',
        createdBy: userId || 'system',
      });
    }

    return product;
  }

  async updateProduct(businessId, productId, updateData) {
    const existing = await this.getProduct(businessId, productId);

    if (updateData.sku && updateData.sku.trim().toUpperCase() !== existing.sku) {
      const normalizedSku = updateData.sku.trim().toUpperCase();
      const conflict = await productRepository.findBySku(businessId, normalizedSku);
      if (conflict && conflict.productId !== productId && conflict.status === 'ACTIVE') {
        const err = new Error(`A product with SKU '${normalizedSku}' already exists in your business catalog`);
        err.statusCode = 409;
        err.errors = { sku: 'Duplicate SKU within business' };
        throw err;
      }
    }

    return productRepository.update(productId, updateData);
  }

  async archiveProduct(businessId, productId) {
    await this.getProduct(businessId, productId);
    return productRepository.delete(productId);
  }
}

module.exports = new ProductService();
