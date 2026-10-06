const customerRepository = require('../repositories/customerRepository');

class CustomerService {
  async listCustomers(businessId, options = {}) {
    return customerRepository.findByBusinessId(businessId, options);
  }

  async getCustomer(businessId, customerId) {
    const customer = await customerRepository.findById(customerId);
    if (!customer) {
      const err = new Error('Customer not found');
      err.statusCode = 404;
      throw err;
    }
    if (customer.businessId !== businessId) {
      const err = new Error('Forbidden: Cross-business customer access denied');
      err.statusCode = 403;
      throw err;
    }
    return customer;
  }

  async createCustomer(businessId, data) {
    const phone = data.phone ? data.phone.trim() : '';
    if (phone) {
      const existing = await customerRepository.findByPhone(businessId, phone);
      if (existing) {
        const err = new Error(`Customer with phone '${phone}' already exists`);
        err.statusCode = 409;
        err.errors = { phone: 'Phone number already registered' };
        throw err;
      }
    }

    return customerRepository.create({
      ...data,
      businessId,
    });
  }

  async updateCustomer(businessId, customerId, updateData) {
    await this.getCustomer(businessId, customerId);

    if (updateData.phone) {
      const existing = await customerRepository.findByPhone(businessId, updateData.phone);
      if (existing && existing.customerId !== customerId) {
        const err = new Error(`Customer with phone '${updateData.phone}' already exists`);
        err.statusCode = 409;
        err.errors = { phone: 'Phone number already in use' };
        throw err;
      }
    }

    return customerRepository.update(customerId, updateData);
  }

  async deleteCustomer(businessId, customerId) {
    await this.getCustomer(businessId, customerId);
    return customerRepository.remove(customerId);
  }
}

module.exports = new CustomerService();
