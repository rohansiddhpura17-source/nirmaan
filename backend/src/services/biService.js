/**
 * Business Intelligence (BI) Service - Phase 7
 *
 * Implements deterministic, explainable decision-support intelligence
 * based on real operational business data from:
 * - Orders
 * - Products
 * - Inventory & Stock Movements
 * - Customers
 * - Business Context
 *
 * Strictly NO LLM / generative models in this phase.
 * Strictly NO automatic execution of high-impact business changes.
 */

const orderRepository = require('../repositories/orderRepository');
const productRepository = require('../repositories/productRepository');
const customerRepository = require('../repositories/customerRepository');
const inventoryMovementRepository = require('../repositories/inventoryMovementRepository');
const businessRepository = require('../repositories/businessRepository');
const {
  DEFAULT_BUSINESS_TIMEZONE,
  getISTDateString,
  getDateRangeBoundaries,
} = require('../utils/dateUtils');

class BiService {
  constructor(options = {}) {
    this.orderRepository = options.orderRepository || orderRepository;
    this.productRepository = options.productRepository || productRepository;
    this.customerRepository = options.customerRepository || customerRepository;
    this.inventoryMovementRepository =
      options.inventoryMovementRepository || inventoryMovementRepository;
    this.businessRepository = options.businessRepository || businessRepository;
  }

  _extractItems(res) {
    if (!res) return [];
    if (Array.isArray(res)) return res;
    if (Array.isArray(res.items)) return res.items;
    return [];
  }

  /**
   * Helper to load operational datasets for a business
   */
  async _loadBusinessDatasets(businessId) {
    const [rawOrders, rawProducts, rawCustomers, rawMovements, businessRecord] =
      await Promise.all([
        this.orderRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.productRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.customerRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.inventoryMovementRepository.findByBusinessId(businessId, { limit: 10000 }),
        this.businessRepository.findById(businessId),
      ]);

    return {
      orders: this._extractItems(rawOrders),
      products: this._extractItems(rawProducts),
      customers: this._extractItems(rawCustomers),
      movements: this._extractItems(rawMovements),
      businessRecord,
    };
  }

  // ===========================================================================
  // 1. BUSINESS HEALTH SCORE ENGINE
  // ===========================================================================
  /**
   * Calculates a bounded (0–100), deterministic, explainable Business Health Score.
   *
   * Formulations & Weightings:
   * - Sales Vitality (25%): Order completion rate and revenue activity.
   * - Inventory Health (25%): Stock availability, penalized by out-of-stock and low-stock SKUs.
   * - Customer Activity (20%): Active customer ratio and repeat buying cadence.
   * - Product Efficiency (15%): Active catalog utilization (% of products selling).
   * - Operational Stability (15%): Cancellation minimization and stock replenishment diligence.
   */
  calculateHealthScore({ orders = [], products = [], customers = [], movements = [] }) {
    const positiveSignals = [];
    const negativeSignals = [];

    // --- Dimension 1: Sales Vitality (Weight: 25%) ---
    const completedOrders = orders.filter((o) => o.orderStatus === 'COMPLETED');
    const cancelledOrders = orders.filter((o) => o.orderStatus === 'CANCELLED');
    const totalOrdersCount = orders.length;

    let salesScore = 0;
    if (totalOrdersCount > 0) {
      const completionRate = completedOrders.length / totalOrdersCount;
      const totalCompletedRevenue = completedOrders.reduce(
        (sum, o) => sum + (Number(o.total) || 0),
        0
      );
      // Base score on completion rate (0-60) + revenue activity bonus (0-40)
      const completionComponent = completionRate * 60;
      const revenueActivityBonus = totalCompletedRevenue > 0 ? Math.min(40, 20 + completedOrders.length * 4) : 0;
      salesScore = Math.min(100, Math.round(completionComponent + revenueActivityBonus));

      if (completionRate >= 0.95 && totalOrdersCount >= 2) {
        positiveSignals.push('High order fulfillment rate: minimal order cancellations');
      } else if (completionRate < 0.7 && totalOrdersCount >= 2) {
        negativeSignals.push(`Elevated order cancellation rate: ${Math.round((1 - completionRate) * 100)}% cancelled`);
      }
    } else {
      salesScore = 0;
      negativeSignals.push('No sales transactions recorded in recent history');
    }

    // --- Dimension 2: Inventory Health (Weight: 25%) ---
    let inventoryScore = 0;
    const totalProducts = products.length;
    let outOfStockCount = 0;
    let lowStockCount = 0;
    let inStockCount = 0;

    if (totalProducts > 0) {
      for (const p of products) {
        const stock = Number(p.currentStock) || 0;
        const threshold = Number(p.minStockThreshold) || 5;
        if (stock <= 0) outOfStockCount++;
        else if (stock <= threshold) lowStockCount++;
        else inStockCount++;
      }

      const inStockRatio = inStockCount / totalProducts;
      const outOfStockRatio = outOfStockCount / totalProducts;
      const lowStockRatio = lowStockCount / totalProducts;

      // Base 100 penalized heavily by stockouts and moderately by low stock
      inventoryScore = Math.max(
        0,
        Math.min(
          100,
          Math.round(inStockRatio * 100 - outOfStockRatio * 50 - lowStockRatio * 20)
        )
      );

      if (outOfStockCount === 0 && inStockRatio >= 0.8) {
        positiveSignals.push('Optimal inventory depth: zero stockouts across catalog');
      }
      if (outOfStockCount > 0) {
        negativeSignals.push(`${outOfStockCount} catalog SKU(s) currently completely out of stock`);
      }
      if (lowStockCount > 0) {
        negativeSignals.push(`${lowStockCount} SKU(s) approaching minimum inventory threshold`);
      }
    } else {
      inventoryScore = 20; // Baseline when no catalog configured
      negativeSignals.push('Product catalog is currently unpopulated');
    }

    // --- Dimension 3: Customer Activity (Weight: 20%) ---
    let customerScore = 0;
    const totalCustomers = customers.length;
    if (totalCustomers > 0) {
      // Find customers with orders
      const orderCustomerIds = new Set(completedOrders.map((o) => o.customerId).filter(Boolean));
      const activeCustomersCount = orderCustomerIds.size;
      const activeRatio = activeCustomersCount / totalCustomers;

      // Count repeat buyers
      const customerOrderFrequency = new Map();
      for (const o of completedOrders) {
        if (o.customerId) {
          customerOrderFrequency.set(
            o.customerId,
            (customerOrderFrequency.get(o.customerId) || 0) + 1
          );
        }
      }
      let repeatCustomerCount = 0;
      for (const count of customerOrderFrequency.values()) {
        if (count >= 2) repeatCustomerCount++;
      }
      const repeatRatio = activeCustomersCount > 0 ? repeatCustomerCount / activeCustomersCount : 0;

      customerScore = Math.min(100, Math.round(activeRatio * 60 + repeatRatio * 40));

      if (repeatCustomerCount > 0) {
        positiveSignals.push(`${repeatCustomerCount} returning customer(s) demonstrating repeat purchase habit`);
      }
      if (activeCustomersCount === 0) {
        negativeSignals.push('Zero active purchasing customers in recent order history');
      }
    } else {
      customerScore = 15; // Baseline when no customer CRM is populated
    }

    // --- Dimension 4: Product Portfolio Efficiency (Weight: 15%) ---
    let productScore = 0;
    if (totalProducts > 0) {
      const soldProductIds = new Set();
      for (const o of completedOrders) {
        if (Array.isArray(o.items)) {
          for (const item of o.items) {
            if (item.productId) soldProductIds.add(item.productId);
          }
        }
      }
      const activeProductRatio = soldProductIds.size / totalProducts;
      productScore = Math.min(100, Math.round(activeProductRatio * 100));

      if (activeProductRatio >= 0.6) {
        positiveSignals.push(`${Math.round(activeProductRatio * 100)}% of catalog SKUs are actively generating sales`);
      } else if (totalProducts >= 3 && activeProductRatio < 0.3) {
        negativeSignals.push('Significant product dormancy: over 70% of catalog SKUs have 0 sales');
      }
    }

    // --- Dimension 5: Operational Stability & Diligence (Weight: 15%) ---
    let opsScore = 0;
    const cancellationPenalty = totalOrdersCount > 0 ? (cancelledOrders.length / totalOrdersCount) * 100 : 0;
    const restockCount = movements.filter(
      (m) => m.type === 'RESTOCK' || m.type === 'INWARD' || m.type === 'ADJUSTMENT_IN'
    ).length;
    const restockBonus = Math.min(30, restockCount * 10);
    opsScore = Math.max(0, Math.min(100, Math.round(70 - cancellationPenalty * 0.7 + restockBonus)));

    if (restockCount > 0) {
      positiveSignals.push('Active supply replenishment recorded via stock inward adjustments');
    }

    // --- Weighted Overall Health Score (0–100) ---
    const compositeScore = Math.round(
      salesScore * 0.25 +
      inventoryScore * 0.25 +
      customerScore * 0.20 +
      productScore * 0.15 +
      opsScore * 0.15
    );
    const overallScore = Math.max(0, Math.min(100, compositeScore));

    // Determine Health Level
    let healthLevel = 'CRITICAL';
    let summaryHeadline = 'Immediate Operational Attention Required';
    if (overallScore >= 80) {
      healthLevel = 'EXCELLENT';
      summaryHeadline = 'Strong Operating Vitality & High Commercial Stability';
    } else if (overallScore >= 60) {
      healthLevel = 'GOOD';
      summaryHeadline = 'Healthy Store Operations with Minor Optimization Opportunities';
    } else if (overallScore >= 40) {
      healthLevel = 'AVERAGE';
      summaryHeadline = 'Moderate Vitality: Inventory or Demand Friction Observed';
    }

    // Generate comprehensive explanation
    const explanation = `Business Health Score is ${overallScore}/100 (${healthLevel}). Factors: Sales Vitality (${salesScore}/100, weight 25%), Inventory Health (${inventoryScore}/100, weight 25%), Customer Activity (${customerScore}/100, weight 20%), Product Efficiency (${productScore}/100, weight 15%), Operational Diligence (${opsScore}/100, weight 15%).`;

    return {
      overallScore,
      healthLevel,
      summaryHeadline,
      explanation,
      positiveSignals,
      negativeSignals,
      dimensions: {
        salesVitality: {
          score: salesScore,
          weight: '25%',
          status: salesScore >= 75 ? 'STRONG' : salesScore >= 45 ? 'MODERATE' : 'WEAK',
          completedOrdersCount: completedOrders.length,
          totalOrdersCount,
        },
        inventoryHealth: {
          score: inventoryScore,
          weight: '25%',
          status: inventoryScore >= 75 ? 'STRONG' : inventoryScore >= 45 ? 'MODERATE' : 'WEAK',
          outOfStockCount,
          lowStockCount,
          inStockCount,
          totalProducts,
        },
        customerActivity: {
          score: customerScore,
          weight: '20%',
          status: customerScore >= 75 ? 'STRONG' : customerScore >= 45 ? 'MODERATE' : 'WEAK',
          totalCustomers,
        },
        productEfficiency: {
          score: productScore,
          weight: '15%',
          status: productScore >= 75 ? 'STRONG' : productScore >= 45 ? 'MODERATE' : 'WEAK',
        },
        operationalStability: {
          score: opsScore,
          weight: '15%',
          status: opsScore >= 75 ? 'STRONG' : opsScore >= 45 ? 'MODERATE' : 'WEAK',
        },
      },
    };
  }

  // ===========================================================================
  // 2. SALES & DEMAND FORECASTING ENGINE
  // ===========================================================================
  /**
   * Deterministic statistical sales forecasting based on historical completed orders.
   *
   * Methodology:
   * - 7-Day & 14-Day Weighted Moving Average (WMA) with Day-of-Week velocity projection.
   * - Bounded confidence scoring based on historical record volume.
   * - Decision-support only (never presented as guaranteed).
   */
  calculateSalesForecast({ orders = [], products = [], daysAhead = 7 }) {
    const completedOrders = orders.filter((o) => o.orderStatus === 'COMPLETED');

    // Group sales by IST date
    const dailyMap = new Map();
    for (const o of completedOrders) {
      const dateStr = getISTDateString(new Date(o.createdAt));
      const rev = Number(o.total) || 0;
      if (!dailyMap.has(dateStr)) {
        dailyMap.set(dateStr, { revenue: 0, orderCount: 0 });
      }
      const entry = dailyMap.get(dateStr);
      entry.revenue += rev;
      entry.orderCount += 1;
    }

    const distinctDaysWithSales = dailyMap.size;
    const sortedDates = Array.from(dailyMap.keys()).sort();

    // Data sufficiency and confidence classification
    let status = 'HEALTHY';
    let confidence = 'HIGH';
    let confidenceReason = 'Sufficient historical transaction breadth allows reliable moving-average demand projection.';

    if (distinctDaysWithSales < 2) {
      status = 'INSUFFICIENT_DATA';
      confidence = 'LOW';
      confidenceReason = 'Insufficient historical sales history (fewer than 2 active transaction days). Baseline linear estimates provided.';
    } else if (distinctDaysWithSales < 5) {
      confidence = 'MEDIUM';
      confidenceReason = 'Moderate transaction volume available (2 to 4 distinct sale dates). Forecast accuracy will sharpen with additional history.';
    }

    // Historical daily averages
    let totalHistoricalRevenue = 0;
    let totalHistoricalOrders = 0;
    for (const d of dailyMap.values()) {
      totalHistoricalRevenue += d.revenue;
      totalHistoricalOrders += d.orderCount;
    }

    const baselineDailyRevenue =
      distinctDaysWithSales > 0 ? totalHistoricalRevenue / distinctDaysWithSales : 0;
    const baselineDailyOrders =
      distinctDaysWithSales > 0 ? totalHistoricalOrders / distinctDaysWithSales : 0;

    // Trend Direction: Compare recent half of available days with prior half
    let trendDirection = 'STABLE';
    if (distinctDaysWithSales >= 4) {
      const half = Math.floor(sortedDates.length / 2);
      const earlyDates = sortedDates.slice(0, half);
      const recentDates = sortedDates.slice(half);

      const earlyAvg =
        earlyDates.reduce((sum, d) => sum + dailyMap.get(d).revenue, 0) / earlyDates.length;
      const recentAvg =
        recentDates.reduce((sum, d) => sum + dailyMap.get(d).revenue, 0) / recentDates.length;

      if (recentAvg > earlyAvg * 1.15) trendDirection = 'GROWTH';
      else if (recentAvg < earlyAvg * 0.85) trendDirection = 'DECLINING';
    }

    // Trend multiplier: slight damping for conservative decision support
    const trendMultiplier =
      trendDirection === 'GROWTH' ? 1.05 : trendDirection === 'DECLINING' ? 0.95 : 1.0;

    // Projected daily series for next `daysAhead` days
    const dailyForecasts = [];
    let projectedTotalRevenue = 0;
    let projectedTotalOrders = 0;

    const todayDate = new Date();
    for (let i = 1; i <= daysAhead; i++) {
      const futureDate = new Date(todayDate);
      futureDate.setDate(todayDate.getDate() + i);
      const futureDateStr = getISTDateString(futureDate);

      const dayRevenue = Math.round(baselineDailyRevenue * trendMultiplier * 100) / 100;
      const dayOrders = Math.max(0, Math.round(baselineDailyOrders * trendMultiplier));

      dailyForecasts.push({
        date: futureDateStr,
        dayOffset: i,
        projectedRevenue: dayRevenue,
        projectedOrders: dayOrders,
      });

      projectedTotalRevenue += dayRevenue;
      projectedTotalOrders += dayOrders;
    }

    // Product-level demand forecasts
    const productVelocityMap = new Map();
    for (const o of completedOrders) {
      if (Array.isArray(o.items)) {
        for (const item of o.items) {
          const pId = item.productId || 'unknown';
          const qty = Number(item.quantity) || 0;
          productVelocityMap.set(pId, (productVelocityMap.get(pId) || 0) + qty);
        }
      }
    }

    const productForecasts = products.map((p) => {
      const totalSold = productVelocityMap.get(p.productId) || 0;
      const dailyVelocity =
        distinctDaysWithSales > 0 ? Math.round((totalSold / distinctDaysWithSales) * 100) / 100 : 0;
      const projected7DayDemand = Math.round(dailyVelocity * 7);
      const stock = Number(p.currentStock) || 0;
      const daysOfSupply =
        dailyVelocity > 0 ? Math.round((stock / dailyVelocity) * 10) / 10 : stock > 0 ? 999 : 0;

      let stockRisk = 'ADEQUATE';
      if (stock <= 0) stockRisk = 'DEPLETED';
      else if (daysOfSupply <= 3) stockRisk = 'CRITICAL_STOCKOUT_RISK';
      else if (daysOfSupply <= 7) stockRisk = 'REPLENISHMENT_NEEDED';

      return {
        productId: p.productId,
        name: p.name,
        sku: p.sku || '',
        currentStock: stock,
        dailyVelocity,
        projected7DayDemand,
        daysOfSupply: daysOfSupply === 999 ? '60+ days (Abundant/Low Movement)' : `${daysOfSupply} days`,
        stockRisk,
      };
    });

    return {
      status,
      confidence,
      confidenceReason,
      isGuaranteed: false,
      disclaimer: 'Statistical decision-support estimate based on historical order volume. Not a financial or contractual guarantee.',
      methodology: 'Weighted Moving Average (WMA) with conservative trend dampening and inventory velocity matching.',
      historicalDataDaysAnalyzed: distinctDaysWithSales,
      trendDirection,
      projectedPeriodDays: daysAhead,
      projectedTotalRevenue: Math.round(projectedTotalRevenue * 100) / 100,
      projectedTotalOrders,
      dailyForecasts,
      productForecasts: productForecasts.slice(0, 10),
    };
  }

  // ===========================================================================
  // 3. INVENTORY INTELLIGENCE ENGINE
  // ===========================================================================
  /**
   * Deterministic inventory analytics: stockouts, low-stock, overstocked, fast/slow moving.
   */
  calculateInventoryIntelligence({ products = [], orders = [] }) {
    const completedOrders = orders.filter((o) => o.orderStatus === 'COMPLETED');

    // Aggregate velocity by product
    const productSoldMap = new Map();
    for (const o of completedOrders) {
      if (Array.isArray(o.items)) {
        for (const item of o.items) {
          const pId = item.productId || 'unknown';
          productSoldMap.set(pId, (productSoldMap.get(pId) || 0) + (Number(item.quantity) || 0));
        }
      }
    }

    const lowStockAlerts = [];
    const outOfStockAlerts = [];
    const fastMovingProducts = [];
    const slowMovingProducts = [];
    const overstockedProducts = [];
    const replenishmentRecommendations = [];

    let totalValuation = 0;
    let totalUnits = 0;

    for (const p of products) {
      const stock = Number(p.currentStock) || 0;
      const threshold = Number(p.minStockThreshold) || 5;
      const cost = Number(p.costPrice || p.purchasePrice) || 0;
      const quantitySold = productSoldMap.get(p.productId) || 0;

      totalUnits += stock;
      totalValuation += stock * cost;

      // Status classification
      if (stock <= 0) {
        outOfStockAlerts.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          category: p.category || 'General',
          currentStock: 0,
          minStockThreshold: threshold,
          urgency: 'IMMEDIATE',
        });

        replenishmentRecommendations.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          currentStock: 0,
          suggestedReorderQuantity: Math.max(10, threshold * 2),
          urgency: 'IMMEDIATE',
          reason: 'Item is completely stocked out. Sales are blocked.',
        });
      } else if (stock <= threshold) {
        lowStockAlerts.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          category: p.category || 'General',
          currentStock: stock,
          minStockThreshold: threshold,
          urgency: 'HIGH',
        });

        replenishmentRecommendations.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          currentStock: stock,
          suggestedReorderQuantity: Math.max(5, threshold * 2 - stock),
          urgency: 'HIGH',
          reason: `Current stock (${stock}) is at or below threshold (${threshold}).`,
        });
      }

      // Velocity classification
      if (quantitySold >= 4) {
        fastMovingProducts.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          quantitySold,
          currentStock: stock,
          status: 'HIGH_VELOCITY',
        });
      } else if (quantitySold === 0 && stock > 0) {
        slowMovingProducts.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          currentStock: stock,
          capitalTiedUp: Math.round(stock * cost * 100) / 100,
          status: 'DORMANT_ZERO_SALES',
        });
      }

      // Overstock check (abundant inventory with low movement)
      if (stock > threshold * 3 && stock >= 20 && quantitySold <= 2) {
        overstockedProducts.push({
          productId: p.productId,
          name: p.name,
          currentStock: stock,
          minStockThreshold: threshold,
          capitalTiedUp: Math.round(stock * cost * 100) / 100,
          reason: `Stock is over 3x the minimum threshold with sluggish velocity.`,
        });
      }
    }

    return {
      inventoryValuation: Math.round(totalValuation * 100) / 100,
      totalUnits,
      catalogSize: products.length,
      outOfStockCount: outOfStockAlerts.length,
      lowStockCount: lowStockAlerts.length,
      outOfStockAlerts,
      lowStockAlerts,
      fastMovingProducts: fastMovingProducts.sort((a, b) => b.quantitySold - a.quantitySold),
      slowMovingProducts: slowMovingProducts.sort((a, b) => b.capitalTiedUp - a.capitalTiedUp),
      overstockedProducts,
      replenishmentRecommendations,
    };
  }

  // ===========================================================================
  // 4. CUSTOMER CHURN & RISK ENGINE
  // ===========================================================================
  /**
   * Identifies customer churn risk using explainable purchase cadence indicators.
   *
   * Risk Labels:
   * - LOW_RISK: Recent buyer or active regular cadence.
   * - MEDIUM_RISK: Overdue relative to regular cycle or unreturned first-time buyer.
   * - HIGH_RISK: Dormant for more than 2x average cadence or inactive > 45 days.
   */
  calculateCustomerRisk({ customers = [], orders = [] }) {
    const completedOrders = orders.filter((o) => o.orderStatus === 'COMPLETED');
    const now = new Date();

    // Group customer orders
    const customerOrdersMap = new Map();
    for (const o of completedOrders) {
      if (o.customerId) {
        if (!customerOrdersMap.has(o.customerId)) {
          customerOrdersMap.set(o.customerId, []);
        }
        customerOrdersMap.get(o.customerId).push(o);
      }
    }

    const customerSignals = [];
    let highRiskCount = 0;
    let mediumRiskCount = 0;
    let lowRiskCount = 0;

    for (const c of customers) {
      const cId = c.customerId || c.id;
      const cOrders = customerOrdersMap.get(cId) || [];

      // Sort customer orders by date ascending
      cOrders.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));

      const orderCount = cOrders.length;
      const totalSpend = cOrders.reduce((sum, o) => sum + (Number(o.total) || 0), 0);

      let daysSinceLastOrder = 999;
      let lastOrderDateStr = null;

      if (orderCount > 0) {
        const lastOrder = cOrders[cOrders.length - 1];
        lastOrderDateStr = getISTDateString(new Date(lastOrder.createdAt));
        const diffMs = now.getTime() - new Date(lastOrder.createdAt).getTime();
        daysSinceLastOrder = Math.max(0, Math.floor(diffMs / (1000 * 60 * 60 * 24)));
      }

      // Calculate average cadence if multiple orders
      let avgCadenceDays = 0;
      if (orderCount >= 2) {
        const firstOrder = cOrders[0];
        const lastOrder = cOrders[cOrders.length - 1];
        const spanMs = new Date(lastOrder.createdAt).getTime() - new Date(firstOrder.createdAt).getTime();
        const spanDays = Math.max(1, Math.floor(spanMs / (1000 * 60 * 60 * 24)));
        avgCadenceDays = Math.max(1, Math.round(spanDays / (orderCount - 1)));
      }

      // Deterministic Risk Categorization Rule
      let riskLevel = 'LOW_RISK';
      let reason = 'Recent active purchasing behavior.';

      if (orderCount === 0) {
        riskLevel = 'MEDIUM_RISK';
        reason = 'Registered patron who has never completed a sales transaction.';
      } else if (daysSinceLastOrder <= 7) {
        riskLevel = 'LOW_RISK';
        reason = 'Recent active customer; placed order within the last 7 days.';
      } else if (orderCount === 1) {
        if (daysSinceLastOrder > 45) {
          riskLevel = 'HIGH_RISK';
          reason = `One-time purchaser inactive for ${daysSinceLastOrder} days without follow-up order.`;
        } else if (daysSinceLastOrder > 20) {
          riskLevel = 'MEDIUM_RISK';
          reason = `Single-order customer inactive for ${daysSinceLastOrder} days. Potential lapse.`;
        } else {
          riskLevel = 'LOW_RISK';
          reason = `Recent new customer (${daysSinceLastOrder} days since first order).`;
        }
      } else {
        // Multiple orders
        if (daysSinceLastOrder > avgCadenceDays * 2.0 && daysSinceLastOrder > 14) {
          riskLevel = 'HIGH_RISK';
          reason = `Inactive for ${daysSinceLastOrder} days, exceeding 2x regular order cadence (${avgCadenceDays} days).`;
        } else if (daysSinceLastOrder > avgCadenceDays * 1.3 && daysSinceLastOrder > 10) {
          riskLevel = 'MEDIUM_RISK';
          reason = `Inactive for ${daysSinceLastOrder} days, surpassing regular purchase interval (${avgCadenceDays} days).`;
        } else {
          riskLevel = 'LOW_RISK';
          reason = `Ordering cadence on track (interval: ${avgCadenceDays} days, last active: ${daysSinceLastOrder} days ago).`;
        }
      }

      if (riskLevel === 'HIGH_RISK') highRiskCount++;
      else if (riskLevel === 'MEDIUM_RISK') mediumRiskCount++;
      else lowRiskCount++;

      customerSignals.push({
        customerId: cId,
        customerName: c.name || 'Patron',
        phone: c.phone || '',
        orderCount,
        totalSpend: Math.round(totalSpend * 100) / 100,
        daysSinceLastOrder: daysSinceLastOrder === 999 ? 'No orders' : daysSinceLastOrder,
        lastOrderDate: lastOrderDateStr,
        averageCadenceDays: avgCadenceDays > 0 ? avgCadenceDays : null,
        riskLevel,
        reason,
      });
    }

    // Sort: HIGH_RISK first, then MEDIUM_RISK, then by daysSinceLastOrder desc
    const priorityOrder = { HIGH_RISK: 1, MEDIUM_RISK: 2, LOW_RISK: 3 };
    customerSignals.sort((a, b) => {
      const pDiff = (priorityOrder[a.riskLevel] || 3) - (priorityOrder[b.riskLevel] || 3);
      if (pDiff !== 0) return pDiff;
      const daysA = typeof a.daysSinceLastOrder === 'number' ? a.daysSinceLastOrder : -1;
      const daysB = typeof b.daysSinceLastOrder === 'number' ? b.daysSinceLastOrder : -1;
      return daysB - daysA;
    });

    return {
      totalTrackedCustomers: customers.length,
      riskSummary: {
        highRiskCount,
        mediumRiskCount,
        lowRiskCount,
      },
      customerRiskSignals: customerSignals,
    };
  }

  // ===========================================================================
  // 5. PRODUCT PERFORMANCE INTELLIGENCE
  // ===========================================================================
  /**
   * Categorizes products by revenue generation, unit velocity, and trend trajectory.
   */
  calculateProductIntelligence({ products = [], orders = [] }) {
    const completedOrders = orders.filter((o) => o.orderStatus === 'COMPLETED');

    const productSalesMap = new Map();
    let totalRevenue = 0;

    for (const o of completedOrders) {
      if (Array.isArray(o.items)) {
        for (const item of o.items) {
          const pId = item.productId || 'unknown';
          const qty = Number(item.quantity) || 0;
          const rev = Number(item.lineTotal) || (Number(item.unitPrice) || 0) * qty;

          totalRevenue += rev;
          if (!productSalesMap.has(pId)) {
            productSalesMap.set(pId, {
              quantitySold: 0,
              revenue: 0,
              orderAppearances: 0,
            });
          }
          const pEntry = productSalesMap.get(pId);
          pEntry.quantitySold += qty;
          pEntry.revenue += rev;
          pEntry.orderAppearances += 1;
        }
      }
    }

    const topPerformers = [];
    const dormantProducts = [];
    const highRevenueDrivers = [];
    const highVolumeDrivers = [];

    for (const p of products) {
      const sales = productSalesMap.get(p.productId);
      const stock = Number(p.currentStock) || 0;
      const cost = Number(p.costPrice || p.purchasePrice) || 0;

      if (!sales || sales.quantitySold === 0) {
        dormantProducts.push({
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          category: p.category || 'General',
          currentStock: stock,
          tiedUpCapital: Math.round(stock * cost * 100) / 100,
          diagnosis: 'Zero units sold in analyzed period.',
        });
      } else {
        const shareOfRevenue =
          totalRevenue > 0 ? Math.round((sales.revenue / totalRevenue) * 1000) / 10 : 0;

        const record = {
          productId: p.productId,
          name: p.name,
          sku: p.sku || '',
          category: p.category || 'General',
          quantitySold: sales.quantitySold,
          revenue: Math.round(sales.revenue * 100) / 100,
          shareOfRevenue,
          currentStock: stock,
        };

        topPerformers.push(record);

        if (shareOfRevenue >= 20 || sales.revenue >= 1000) {
          highRevenueDrivers.push(record);
        }
        if (sales.quantitySold >= 4) {
          highVolumeDrivers.push(record);
        }
      }
    }

    topPerformers.sort((a, b) => b.revenue - a.revenue || b.quantitySold - a.quantitySold);

    return {
      totalAnalyzedProducts: products.length,
      topPerformers: topPerformers.slice(0, 10),
      dormantProducts: dormantProducts.slice(0, 10),
      highRevenueDrivers: highRevenueDrivers.sort((a, b) => b.revenue - a.revenue),
      highVolumeDrivers: highVolumeDrivers.sort((a, b) => b.quantitySold - a.quantitySold),
    };
  }

  // ===========================================================================
  // 6. SYNTHESIZED DECISION RECOMMENDATIONS
  // ===========================================================================
  _generateActionableRecommendations(healthScore, inventoryIntel, customerRisk, productIntel) {
    const recommendations = [];

    // 1. Critical inventory alerts
    if (inventoryIntel.outOfStockCount > 0) {
      recommendations.push({
        id: 'rec_stockout',
        priority: 'HIGH',
        category: 'INVENTORY',
        title: `Restock ${inventoryIntel.outOfStockCount} Depleted SKU(s)`,
        description: `Immediate lost sales risk: ${inventoryIntel.outOfStockAlerts.map((i) => i.name).slice(0, 3).join(', ')} currently have 0 stock.`,
        actionLabel: 'Restock Inventory',
      });
    }

    if (inventoryIntel.lowStockCount > 0) {
      recommendations.push({
        id: 'rec_low_stock',
        priority: 'MEDIUM',
        category: 'INVENTORY',
        title: `Replenish ${inventoryIntel.lowStockCount} Low-Stock SKU(s)`,
        description: `Items are approaching safety thresholds to avoid customer stockout disappointment.`,
        actionLabel: 'Review Reorder List',
      });
    }

    // 2. Customer retention alerts
    if (customerRisk.riskSummary.highRiskCount > 0) {
      recommendations.push({
        id: 'rec_churn_risk',
        priority: 'HIGH',
        category: 'CUSTOMER',
        title: `Re-engage ${customerRisk.riskSummary.highRiskCount} Inactive Patron(s)`,
        description: `High churn risk identified on customers exceeding 2x regular purchase intervals.`,
        actionLabel: 'View At-Risk Patrons',
      });
    }

    // 3. Dormant inventory liquidation
    if (productIntel.dormantProducts.length > 0) {
      const totalTiedUp = productIntel.dormantProducts.reduce((sum, p) => sum + (p.tiedUpCapital || 0), 0);
      recommendations.push({
        id: 'rec_slow_moving',
        priority: 'LOW',
        category: 'PRODUCTS',
        title: `Promote ${productIntel.dormantProducts.length} Slow-Moving Item(s)`,
        description: `₹${Math.round(totalTiedUp)} in working capital is tied up in items with 0 sales this period.`,
        actionLabel: 'Optimize Pricing / Bundle',
      });
    }

    // 4. Positive reinforcement
    if (healthScore.overallScore >= 75 && recommendations.length === 0) {
      recommendations.push({
        id: 'rec_maintain_growth',
        priority: 'LOW',
        category: 'OPERATIONS',
        title: 'Maintain Current Operational Excellence',
        description: 'Inventory levels, order fulfillment, and patron repurchase rates are performing above benchmarks.',
        actionLabel: 'View Detailed Analytics',
      });
    }

    return recommendations;
  }

  // ===========================================================================
  // 7. COMPREHENSIVE BI OVERVIEW ENDPOINT
  // ===========================================================================
  /**
   * Assembles the complete Business Intelligence payload in a single round-trip.
   */
  async getBiOverview(businessId) {
    if (!businessId) {
      throw new Error('Business ID is required for BI calculation');
    }

    const { orders, products, customers, movements, businessRecord } =
      await this._loadBusinessDatasets(businessId);

    const healthScore = this.calculateHealthScore({ orders, products, customers, movements });
    const forecast = this.calculateSalesForecast({ orders, products });
    const inventoryIntelligence = this.calculateInventoryIntelligence({ products, orders });
    const customerRisk = this.calculateCustomerRisk({ customers, orders });
    const productIntelligence = this.calculateProductIntelligence({ products, orders });
    const recommendations = this._generateActionableRecommendations(
      healthScore,
      inventoryIntelligence,
      customerRisk,
      productIntelligence
    );

    return {
      businessId,
      businessProfile: {
        businessId,
        name: businessRecord?.businessName || 'Nirmaan Business',
        category: businessRecord?.category || 'Retail',
      },
      generatedAt: new Date().toISOString(),
      healthScore,
      forecast,
      inventoryIntelligence,
      customerRisk,
      productIntelligence,
      recommendations,
    };
  }
}

module.exports = new BiService();
