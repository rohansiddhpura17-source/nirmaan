/**
 * Dashboard Aggregation Service for Nirmaan Web (Phase 5).
 * 
 * Aggregates real operational data from Products, Inventory, Customers, and Orders.
 * Strictly enforces multi-tenant boundary on all underlying queries.
 * Calculates daily performance using the business timezone (Asia/Kolkata).
 */

const productRepository = require('../repositories/productRepository');
const orderRepository = require('../repositories/orderRepository');
const customerRepository = require('../repositories/customerRepository');
const businessRepository = require('../repositories/businessRepository');
const { getTodayTimezoneRange, isDateInTodayRange, DEFAULT_BUSINESS_TIMEZONE } = require('../utils/dateUtils');

class DashboardService {
  constructor(prodRepo = productRepository, ordRepo = orderRepository, custRepo = customerRepository, bizRepo = businessRepository) {
    this.productRepo = prodRepo;
    this.orderRepo = ordRepo;
    this.customerRepo = custRepo;
    this.bizRepo = bizRepo;
  }

  /**
   * Aggregates live business metrics for the authenticated business tenant.
   *
   * @param {string} businessId - Tenant identifier
   * @param {Object} [options={}] - Optional overrides (e.g. referenceDate, timeZone)
   * @returns {Promise<Object>} Aggregated dashboard payload
   */
  async getDashboardData(businessId, options = {}) {
    if (!businessId) {
      throw new Error('businessId is required to aggregate dashboard metrics');
    }

    const timeZone = options.timeZone || DEFAULT_BUSINESS_TIMEZONE;
    const referenceDate = options.referenceDate || new Date();
    const { todayDateStr, startOfDayISO, endOfDayISO } = getTodayTimezoneRange(timeZone, referenceDate);

    // Parallel bounded execution for high performance (< 3s SRS target)
    const [ordersResult, productsResult, customersResult, businessResult] = await Promise.all([
      this.orderRepo.findByBusinessId(businessId, { limit: 500 }),
      this.productRepo.findByBusinessId(businessId, { status: 'ACTIVE', limit: 1000 }),
      this.customerRepo.findByBusinessId(businessId, { limit: 1000 }),
      this.bizRepo ? this.bizRepo.findById(businessId).catch(() => null) : null,
    ]);

    const allOrders = ordersResult.items || [];
    const allProducts = productsResult.items || [];
    const allCustomers = customersResult.items || [];

    // ==========================================
    // 1. TODAY'S REVENUE & ORDERS CALCULATION
    // ==========================================
    let todayRevenue = 0;
    let todayOrdersCount = 0;
    let todayCancelledOrdersCount = 0;
    let totalRevenue = 0;
    let completedOrdersCount = 0;
    let cancelledOrdersCount = 0;

    for (const order of allOrders) {
      const isToday = isDateInTodayRange(order.createdAt, timeZone, referenceDate);

      // Status rule: Only COMPLETED orders count toward revenue
      const status = (order.orderStatus || order.status || '').toUpperCase();
      const isCompleted = status === 'COMPLETED';
      const isCancelled = status === 'CANCELLED';
      const amount = Number(order.totalAmount ?? order.total ?? 0);
      const validAmount = isNaN(amount) ? 0 : amount;

      if (isCompleted) {
        totalRevenue += validAmount;
        completedOrdersCount += 1;
        if (isToday) {
          todayRevenue += validAmount;
          todayOrdersCount += 1;
        }
      } else if (isCancelled) {
        cancelledOrdersCount += 1;
        if (isToday) {
          todayCancelledOrdersCount += 1;
        }
      }
    }

    const averageOrderValue = todayOrdersCount > 0 ? Number((todayRevenue / todayOrdersCount).toFixed(2)) : 0;

    // ==========================================
    // 2. RECENT ORDERS (Latest 5)
    // ==========================================
    const recentOrders = allOrders
      .slice()
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(0, 5)
      .map((o) => {
        let createdISO = o.createdAt;
        if (o.createdAt instanceof Date) {
          createdISO = o.createdAt.toISOString();
        } else if (o.createdAt && typeof o.createdAt.toDate === 'function') {
          createdISO = o.createdAt.toDate().toISOString();
        } else if (typeof o.createdAt === 'string') {
          createdISO = o.createdAt;
        }

        return {
          id: o.orderId || o.id,
          orderNumber: o.orderNumber,
          customerName: o.customerName || 'Walk-in Customer',
          customerPhone: o.customerPhone || null,
          totalAmount: Number(o.totalAmount ?? o.total ?? 0),
          status: (o.orderStatus || o.status || 'COMPLETED').toUpperCase(),
          paymentMethod: o.paymentMethod || 'CASH',
          itemCount: Array.isArray(o.items) ? o.items.length : 0,
          createdAt: createdISO,
        };
      });

    // ==========================================
    // 3. TOP-SELLING PRODUCTS (From Completed Orders)
    // ==========================================
    const productSalesMap = new Map();

    for (const order of allOrders) {
      const status = (order.orderStatus || order.status || '').toUpperCase();
      if (status !== 'COMPLETED') continue;

      const items = Array.isArray(order.items) ? order.items : [];
      for (const item of items) {
        const prodId = item.productId;
        if (!prodId) continue;

        const qty = Number(item.quantity) || 0;
        const unitPrice = Number(item.unitPrice) || 0;
        const lineTotal = Number(item.lineTotal) || qty * unitPrice;

        if (!productSalesMap.has(prodId)) {
          productSalesMap.set(prodId, {
            productId: prodId,
            name: item.productName || 'Unknown Product',
            sku: item.sku || '',
            quantitySold: 0,
            revenue: 0,
          });
        }

        const existing = productSalesMap.get(prodId);
        existing.quantitySold += qty;
        existing.revenue += lineTotal;
      }
    }

    // Sort by quantitySold descending (primary), revenue descending (secondary)
    const topProducts = Array.from(productSalesMap.values())
      .sort((a, b) => b.quantitySold - a.quantitySold || b.revenue - a.revenue)
      .slice(0, 5);

    // ==========================================
    // 4. INVENTORY ALERTS (Stock Quantity vs Threshold)
    // ==========================================
    let lowStockCount = 0;
    let outOfStockCount = 0;
    let inStockCount = 0;
    let totalStockUnits = 0;
    let inventoryValuation = 0;
    const stockAlerts = [];

    for (const prod of allProducts) {
      const stock = Number(prod.stockQuantity ?? prod.currentStock ?? 0);
      const threshold = Number(prod.minStockThreshold ?? 5);
      const cost = Number(prod.costPrice ?? prod.purchasePrice ?? 0);

      totalStockUnits += stock;
      inventoryValuation += stock * cost;

      if (stock <= 0) {
        outOfStockCount += 1;
        stockAlerts.push({
          id: prod.productId || prod.id,
          name: prod.name,
          sku: prod.sku,
          category: prod.category,
          stockQuantity: stock,
          minStockThreshold: threshold,
          unit: prod.unit || 'pcs',
          stockStatus: 'OUT_OF_STOCK',
        });
      } else if (stock <= threshold) {
        lowStockCount += 1;
        stockAlerts.push({
          id: prod.productId || prod.id,
          name: prod.name,
          sku: prod.sku,
          category: prod.category,
          stockQuantity: stock,
          minStockThreshold: threshold,
          unit: prod.unit || 'pcs',
          stockStatus: 'LOW_STOCK',
        });
      } else {
        inStockCount += 1;
      }
    }

    // Sort alerts: Out of stock first, then lowest stock
    stockAlerts.sort((a, b) => {
      if (a.stockStatus === 'OUT_OF_STOCK' && b.stockStatus !== 'OUT_OF_STOCK') return -1;
      if (b.stockStatus === 'OUT_OF_STOCK' && a.stockStatus !== 'OUT_OF_STOCK') return 1;
      return a.stockQuantity - b.stockQuantity;
    });

    // ==========================================
    // 5. CUSTOMER SUMMARY
    // ==========================================
    let activeKhataCustomers = 0;
    let totalOutstandingKhata = 0;

    for (const cust of allCustomers) {
      const khataBal = Number(cust.outstandingKhataBalance ?? cust.outstandingCredit ?? 0);
      if (khataBal > 0) {
        activeKhataCustomers += 1;
        totalOutstandingKhata += khataBal;
      }
    }

    // ==========================================
    // 6. OPERATIONAL INSIGHTS (Real Data Only)
    // ==========================================
    const insights = [];
    if (outOfStockCount > 0) {
      insights.push(`${outOfStockCount} item(s) are completely out of stock. Restock immediately.`);
    }
    if (lowStockCount > 0) {
      insights.push(`${lowStockCount} item(s) are running below safe threshold.`);
    }
    if (todayRevenue > 0) {
      insights.push(`Today's revenue is ₹${todayRevenue.toFixed(0)} across ${todayOrdersCount} order(s).`);
    } else if (allProducts.length > 0) {
      insights.push(`Catalog contains ${allProducts.length} active products ready for billing.`);
    } else {
      insights.push('Add products to your catalog to start recording sales orders.');
    }

    // Business Profile Snapshot
    const businessProfile = businessResult ? {
      businessId: businessResult.businessId,
      name: businessResult.businessName || businessResult.name || 'Nirmaan Business',
      category: businessResult.businessCategory || businessResult.category || 'Retail',
      address: businessResult.contact?.address || businessResult.address,
      phone: businessResult.contact?.phone || businessResult.phone,
    } : null;

    // ==========================================
    // 7. BUSINESS HEALTH (Truthful Non-Fabricated State)
    // ==========================================
    const businessHealth = {
      status: 'UNAVAILABLE',
      score: null,
      message: 'Business Health scoring requires accumulated transaction history and will be evaluated in subsequent intelligence updates.',
      isConfigured: false,
    };

    return {
      businessId,
      timezone: timeZone,
      today: todayDateStr,
      businessProfile,
      metrics: {
        todayRevenue,
        todayOrdersCount,
        todayCancelledOrdersCount,
        averageOrderValue,
        totalRevenue,
        completedOrdersCount,
        cancelledOrdersCount,
        lowStockCount,
        outOfStockCount,
        inStockCount,
        totalStockAlerts: lowStockCount + outOfStockCount,
        totalStockUnits,
        inventoryValuation,
        totalCustomers: allCustomers.length,
        totalProducts: allProducts.length,
        activeKhataCustomers,
        totalOutstandingKhata,
      },
      recentOrders,
      stockAlerts: stockAlerts.slice(0, 5),
      topProducts,
      insights,
      businessHealth,
    };
  }
}

module.exports = new DashboardService();
module.exports.DashboardService = DashboardService;
