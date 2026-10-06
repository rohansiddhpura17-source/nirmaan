const supplierRepository = require('../repositories/supplierRepository');

class SupplierService {
  async listSuppliers(businessId, options = {}) {
    return supplierRepository.findByBusinessId(businessId, options);
  }

  async getSupplier(businessId, supplierId) {
    const supplier = await supplierRepository.findById(supplierId);
    if (!supplier) {
      const err = new Error('Supplier not found');
      err.statusCode = 404;
      throw err;
    }
    if (supplier.businessId !== businessId) {
      const err = new Error('Forbidden: Cross-business supplier access denied');
      err.statusCode = 403;
      throw err;
    }
    return supplier;
  }

  async createSupplier(businessId, data) {
    return supplierRepository.create({
      ...data,
      businessId,
    });
  }

  async updateSupplier(businessId, supplierId, updateData) {
    await this.getSupplier(businessId, supplierId);
    return supplierRepository.update(supplierId, updateData);
  }

  async deactivateSupplier(businessId, supplierId) {
    await this.getSupplier(businessId, supplierId);
    return supplierRepository.delete(supplierId);
  }
}

module.exports = new SupplierService();
