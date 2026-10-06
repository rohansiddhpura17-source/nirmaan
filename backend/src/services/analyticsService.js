const orderRepository = require('../repositories/orderRepository');
const productRepository = require('../repositories/productRepository');
const customerRepository = require('../repositories/customerRepository');
const inventoryMovementRepository = require('../repositories/inventoryMovementRepository');
const businessRepository = require('../repositories/businessRepository');
const {
  getDateRangeBoundaries,
  getISTDateString,
  isDateInRange,
  DEFAULT_BUSINESS_TIMEZONE,
} = require('../utils/dateUtils');

class AnalyticsService {
  constructor() {
    this.orderRepository = orderRepository;
    this.productRepository = productRepository;
    this.customerRepository = customerRepository;
    this.inventoryMovementRepository = inventoryMovementRepository;
    this.businessRepository = businessRepository;
  }

  /**
   * Aggregates comprehensive operational analytics for a business over a given date range.
   *
   * @param {string} businessId
   * @param {object} [options={}]
   * @param {string} [options.range='30d'] - 'today'|'yesterday'|'7d'|'30d'|'custom'
   * @param {string} [options.startDate] - YYYY-MM-DD
   * @param {string} [options.endDate] - YYYY-MM-DD
   * @param {Date} [options.referenceDate]
   * @returns {Promise<object>}
   */
  async getAnalyticsOverview(businessId, options = {}) {
    if (!businessId) {
      throw new Error('Business ID is required for analytics');
    }

    const { range = '30d', startDate, endDate, referenceDate } = options;

    const period = getDateRangeBoundaries(range, {
      customStart: startDate,
      customEnd: endDate,
      referenceDate,
      timeZone: DEFAULT_BUSINESS_TIMEZONE,
    });

    // Fetch operational records in parallel
    const [rawOrders, rawProducts, rawCustomers, rawMovements, businessRecord] =
      await Promise.all([
        this.orderRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.productRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.customerRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.inventoryMovementRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.businessRepository.findById(businessId),
      ]);

    const extractItems = (res) => {
      if (!res) return [];
      if (Array.isArray(res)) return res;
      if (Array.isArray(res.items)) return res.items;
      return [];
    };

    const orders = extractItems(rawOrders);
    const products = extractItems(rawProducts);
    const customers = extractItems(rawCustomers);
    const movements = extractItems(rawMovements);

    // Filter orders falling into the selected period [startISO, endISO]
    const ordersInRange = orders.filter((o) =>
      isDateInRange(o.createdAt, period.startISO, period.endISO)
    );

    // -------------------------------------------------------------------------
    // 1. SALES ANALYTICS
    // -------------------------------------------------------------------------
    const completedOrders = ordersInRange.filter((o) => o.orderStatus === 'COMPLETED');
    const cancelledOrders = ordersInRange.filter((o) => o.orderStatus === 'CANCELLED');

    const totalRevenue = completedOrders.reduce((sum, o) => sum + (Number(o.total) || 0), 0);
    const completedOrdersCount = completedOrders.length;
    const averageOrderValue =
      completedOrdersCount > 0 ? Math.round((totalRevenue / completedOrdersCount) * 100) / 100 : 0.0;

    const cancelledRevenue = cancelledOrders.reduce(
      (sum, o) => sum + (Number(o.total) || 0),
      0
    );
    const cancelledOrdersCount = cancelledOrders.length;

    // Daily Sales & Order Trends (zero-filled continuous series)
    const dailyMap = new Map();
    for (const d of period.days) {
      dailyMap.set(d, {
        date: d,
        revenue: 0.0,
        ordersCount: 0,
        completedOrdersCount: 0,
        cancelledOrdersCount: 0,
      });
    }

    for (const o of ordersInRange) {
      const orderDateStr = getISTDateString(new Date(o.createdAt));
      if (dailyMap.has(orderDateStr)) {
        const bucket = dailyMap.get(orderDateStr);
        bucket.ordersCount += 1;
        if (o.orderStatus === 'COMPLETED') {
          bucket.revenue += Number(o.total) || 0;
          bucket.completedOrdersCount += 1;
        } else if (o.orderStatus === 'CANCELLED') {
          bucket.cancelledOrdersCount += 1;
        }
      }
    }

    const dailyTrends = Array.from(dailyMap.values()).map((b) => ({
      ...b,
      revenue: Math.round(b.revenue * 100) / 100,
    }));

    // -------------------------------------------------------------------------
    // 2. PRODUCT ANALYTICS
    // -------------------------------------------------------------------------
    const productSalesMap = new Map();
    const categorySalesMap = new Map();

    for (const order of completedOrders) {
      if (Array.isArray(order.items)) {
        for (const item of order.items) {
          const pId = item.productId || 'unknown';
          const qty = Number(item.quantity) || 0;
          const rev = Number(item.lineTotal) || (Number(item.unitPrice) || 0) * qty;

          // By Product
          if (!productSalesMap.has(pId)) {
            productSalesMap.set(pId, {
              productId: pId,
              name: item.productName || 'Unnamed Product',
              sku: item.sku || '',
              quantitySold: 0,
              revenue: 0.0,
            });
          }
          const pEntry = productSalesMap.get(pId);
          pEntry.quantitySold += qty;
          pEntry.revenue += rev;

          // By Category (lookup product category if available)
          const matchedProduct = products.find((p) => p.productId === pId);
          const category = matchedProduct?.category || 'General';
          if (!categorySalesMap.has(category)) {
            categorySalesMap.set(category, {
              category,
              revenue: 0.0,
              quantitySold: 0,
            });
          }
          const cEntry = categorySalesMap.get(category);
          cEntry.revenue += rev;
          cEntry.quantitySold += qty;
        }
      }
    }

    // Top Selling Products (sorted primarily by quantitySold desc, then revenue desc)
    const topProducts = Array.from(productSalesMap.values())
      .sort((a, b) => b.quantitySold - a.quantitySold || b.revenue - a.revenue)
      .slice(0, 10)
      .map((p) => ({
        ...p,
        revenue: Math.round(p.revenue * 100) / 100,
        shareOfRevenue:
          totalRevenue > 0
            ? Math.round((p.revenue / totalRevenue) * 1000) / 10
            : 0.0,
      }));

    // Products with weak or zero sales in the range
    const soldProductIds = new Set(productSalesMap.keys());
    const weakOrNoSalesProducts = products
      .filter((p) => !soldProductIds.has(p.productId))
      .slice(0, 10)
      .map((p) => ({
        productId: p.productId,
        name: p.name,
        sku: p.sku || '',
        category: p.category || 'General',
        currentStock: p.currentStock || 0,
        quantitySold: 0,
        revenue: 0.0,
      }));

    // Category Performance Breakdown
    const categoryBreakdown = Array.from(categorySalesMap.values())
      .sort((a, b) => b.revenue - a.revenue)
      .map((c) => ({
        ...c,
        revenue: Math.round(c.revenue * 100) / 100,
        shareOfRevenue:
          totalRevenue > 0
            ? Math.round((c.revenue / totalRevenue) * 1000) / 10
            : 0.0,
      }));

    // -------------------------------------------------------------------------
    // 3. INVENTORY ANALYTICS
    // -------------------------------------------------------------------------
    let inventoryValuation = 0.0;
    let totalStockUnits = 0;
    let inStockCount = 0;
    let lowStockCount = 0;
    let outOfStockCount = 0;

    for (const p of products) {
      const stock = Number(p.currentStock) || 0;
      const cost = Number(p.costPrice || p.purchasePrice) || 0;
      const threshold = Number(p.minStockThreshold) || 5;

      totalStockUnits += stock;
      inventoryValuation += stock * cost;

      if (stock <= 0) {
        outOfStockCount++;
      } else if (stock <= threshold) {
        lowStockCount++;
      } else {
        inStockCount++;
      }
    }

    // Stock Movement Summary in Range
    const movementsInRange = movements.filter((m) =>
      isDateInRange(m.createdAt, period.startISO, period.endISO)
    );
    let inwardUnits = 0;
    let outwardUnits = 0;
    for (const m of movementsInRange) {
      const qty = Number(m.quantity) || 0;
      if (m.type === 'RESTOCK' || m.type === 'INWARD' || m.type === 'ADJUSTMENT_IN') {
        inwardUnits += qty;
      } else if (m.type === 'SALE' || m.type === 'OUTWARD' || m.type === 'ADJUSTMENT_OUT') {
        outwardUnits += qty;
      }
    }

    const stockMovementSummary = {
      totalMovementsCount: movementsInRange.length,
      inwardUnits,
      outwardUnits,
    };

    // -------------------------------------------------------------------------
    // 4. CUSTOMER ANALYTICS
    // -------------------------------------------------------------------------
    const totalCustomers = customers.length;
    const customerSpendMap = new Map();

    for (const o of completedOrders) {
      if (o.customerId) {
        if (!customerSpendMap.has(o.customerId)) {
          customerSpendMap.set(o.customerId, {
            customerId: o.customerId,
            customerName: o.customerName || 'Customer',
            customerPhone: o.customerPhone || '',
            ordersCount: 0,
            totalSpend: 0.0,
          });
        }
        const cEntry = customerSpendMap.get(o.customerId);
        cEntry.ordersCount += 1;
        cEntry.totalSpend += Number(o.total) || 0;
      }
    }

    const activeCustomersCount = customerSpendMap.size;
    const topCustomers = Array.from(customerSpendMap.values())
      .sort((a, b) => b.totalSpend - a.totalSpend)
      .slice(0, 10)
      .map((c) => ({
        ...c,
        totalSpend: Math.round(c.totalSpend * 100) / 100,
      }));

    const averageOrderFrequency =
      activeCustomersCount > 0
        ? Math.round((completedOrdersCount / activeCustomersCount) * 100) / 100
        : 0.0;

    // -------------------------------------------------------------------------
    // 5. ASSEMBLE OUTPUT
    // -------------------------------------------------------------------------
    return {
      businessId,
      businessProfile: {
        businessId,
        name: businessRecord?.businessName || 'Nirmaan Business',
        category: businessRecord?.category || 'Retail',
        address: businessRecord?.address || '',
        phone: businessRecord?.phone || '',
      },
      period: {
        range: period.range,
        startDate: period.startDateStr,
        endDate: period.endDateStr,
        startISO: period.startISO,
        endISO: period.endISO,
        timezone: period.timeZone,
      },
      sales: {
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        completedOrdersCount,
        averageOrderValue,
        cancelledRevenue: Math.round(cancelledRevenue * 100) / 100,
        cancelledOrdersCount,
        dailyTrends,
      },
      products: {
        topProducts,
        weakOrNoSalesProducts,
        categoryBreakdown,
      },
      inventory: {
        inventoryValuation: Math.round(inventoryValuation * 100) / 100,
        totalStockUnits,
        totalProducts: products.length,
        inStockCount,
        lowStockCount,
        outOfStockCount,
        stockMovementSummary,
      },
      customers: {
        totalCustomers,
        activeCustomersCount,
        topCustomers,
        averageOrderFrequency,
      },
    };
  }

  /**
   * Generates a formal, printable / exportable report.
   *
   * Supported types: 'SALES' | 'PRODUCTS' | 'INVENTORY' | 'CUSTOMERS'
   *
   * @param {string} businessId
   * @param {string} reportType
   * @param {object} [options={}]
   * @returns {Promise<object>}
   */
  async generateReport(businessId, reportType = 'SALES', options = {}) {
    const analytics = await this.getAnalyticsOverview(businessId, options);
    const normalizedType = (reportType || 'SALES').toUpperCase().trim();

    let summary = {};
    let records = [];

    switch (normalizedType) {
      case 'SALES': {
        summary = {
          totalRevenue: analytics.sales.totalRevenue,
          completedOrdersCount: analytics.sales.completedOrdersCount,
          averageOrderValue: analytics.sales.averageOrderValue,
          cancelledRevenue: analytics.sales.cancelledRevenue,
          cancelledOrdersCount: analytics.sales.cancelledOrdersCount,
        };
        // Daily records for report table
        records = analytics.sales.dailyTrends.map((d) => ({
          date: d.date,
          revenue: d.revenue,
          completedOrders: d.completedOrdersCount,
          cancelledOrders: d.cancelledOrdersCount,
        }));
        break;
      }

      case 'PRODUCTS': {
        summary = {
          totalProducts: analytics.inventory.totalProducts,
          topSellingCount: analytics.products.topProducts.length,
          unperformingCount: analytics.products.weakOrNoSalesProducts.length,
          totalSalesRevenue: analytics.sales.totalRevenue,
        };
        records = analytics.products.topProducts.map((p, index) => ({
          rank: index + 1,
          name: p.name,
          sku: p.sku,
          quantitySold: p.quantitySold,
          revenue: p.revenue,
          shareOfRevenue: `${p.shareOfRevenue}%`,
        }));
        break;
      }

      case 'INVENTORY': {
        const rawProducts = await this.productRepository.findByBusinessId(businessId, { limit: 10000 });
        const products = Array.isArray(rawProducts) ? rawProducts : (rawProducts?.items || []);

        summary = {
          inventoryValuation: analytics.inventory.inventoryValuation,
          totalStockUnits: analytics.inventory.totalStockUnits,
          inStockCount: analytics.inventory.inStockCount,
          lowStockCount: analytics.inventory.lowStockCount,
          outOfStockCount: analytics.inventory.outOfStockCount,
        };
        records = products.map((p) => {
          const stock = Number(p.currentStock) || 0;
          const threshold = Number(p.minStockThreshold) || 5;
          const cost = Number(p.costPrice || p.purchasePrice) || 0;
          let status = 'IN_STOCK';
          if (stock <= 0) status = 'OUT_OF_STOCK';
          else if (stock <= threshold) status = 'LOW_STOCK';

          return {
            productId: p.productId,
            name: p.name,
            sku: p.sku || '',
            category: p.category || 'General',
            currentStock: stock,
            minStockThreshold: threshold,
            unit: p.unit || 'pcs',
            costPrice: cost,
            sellingPrice: Number(p.sellingPrice) || 0,
            valuation: Math.round(stock * cost * 100) / 100,
            status,
          };
        });
        break;
      }

      case 'CUSTOMERS': {
        const rawCustomers = await this.customerRepository.findByBusinessId(businessId, { limit: 10000 });
        const customers = Array.isArray(rawCustomers) ? rawCustomers : (rawCustomers?.items || []);

        summary = {
          totalCustomers: analytics.customers.totalCustomers,
          activeCustomersCount: analytics.customers.activeCustomersCount,
          averageOrderFrequency: analytics.customers.averageOrderFrequency,
        };
        // Join with spend map
        const spendMap = new Map();
        for (const c of analytics.customers.topCustomers) {
          spendMap.set(c.customerId, c);
        }

        records = customers.map((c) => {
          const cId = c.customerId || c.id;
          const spendInfo = spendMap.get(cId);
          return {
            customerId: cId,
            name: c.name,
            phone: c.phone || '',
            email: c.email || '',
            ordersCountInRange: spendInfo?.ordersCount || 0,
            spendInRange: spendInfo?.totalSpend || 0.0,
            khataBalance: Number(c.outstandingCredit || c.outstandingBalance || c.khataBalance) || 0.0,
          };
        });
        break;
      }

      default:
        throw new Error(`Unsupported report type: ${reportType}. Expected SALES, PRODUCTS, INVENTORY, or CUSTOMERS.`);
    }

    return {
      reportType: normalizedType,
      businessProfile: analytics.businessProfile,
      period: analytics.period,
      generatedAt: new Date().toISOString(),
      summary,
      records,
    };
  }
}

module.exports = new AnalyticsService();
