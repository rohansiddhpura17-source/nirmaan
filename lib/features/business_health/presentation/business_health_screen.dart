import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/bi.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../controllers/bi_controller.dart';

class BusinessHealthScreen extends StatefulWidget {
  const BusinessHealthScreen({super.key});

  @override
  State<BusinessHealthScreen> createState() => _BusinessHealthScreenState();
}

class _BusinessHealthScreenState extends State<BusinessHealthScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<BiController>();
      if (controller.biData == null && !controller.isLoading) {
        controller.loadBiOverview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BiController>(
      builder: (context, controller, _) {
        final biData = controller.biData;
        final isLoading = controller.isLoading;
        final errorMessage = controller.errorMessage;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: NirmaanAppBar(
            title: 'Business Intelligence',
            subtitle: 'Operational health, forecast & signals',
            isDark: true,
            actions: [
              IconButton(
                tooltip: 'Refresh Intelligence',
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => controller.refresh(),
              ),
            ],
          ),
          body: _buildBody(context, controller, biData, isLoading, errorMessage),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    BiController controller,
    BiOverviewModel? biData,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading && biData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryNavy),
            SizedBox(height: AppDimensions.space16),
            Text(
              'Computing Business Intelligence & Health...',
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && biData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Intelligence Calculation Failed',
                style: AppTypography.sectionTitle.copyWith(color: AppColors.errorRed),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                errorMessage,
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space24),
              NirmaanButton(
                label: 'Retry Intelligence Analysis',
                onPressed: () => controller.loadBiOverview(forceRefresh: true),
              ),
            ],
          ),
        ),
      );
    }

    if (biData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.space16),
            const Text('No intelligence data generated yet.',
                style: AppTypography.bodySecondary),
            const SizedBox(height: AppDimensions.space16),
            NirmaanButton(
              label: 'Analyze Store Data',
              onPressed: () => controller.loadBiOverview(forceRefresh: true),
            ),
          ],
        ),
      );
    }

    final health = biData.healthScore;
    final forecast = biData.forecast;
    final inventory = biData.inventoryIntelligence;
    final customers = biData.customerRisk;
    final products = biData.productIntelligence;
    final recommendations = biData.recommendations;
    final currentTab = controller.selectedIntelligenceTab;

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      color: AppColors.primaryNavy,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              margin: const EdgeInsets.only(bottom: AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.errorRedLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.errorRed),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(errorMessage,
                        style: const TextStyle(
                            color: AppColors.errorRedDark, fontSize: 13)),
                  ),
                  TextButton(
                    onPressed: () => controller.refresh(),
                    child: const Text('RETRY',
                        style: TextStyle(
                            color: AppColors.errorRedDark,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],

          // 1. HERO HEALTH SCORE GAUGE CARD
          _buildHeroHealthGaugeCard(health),
          const SizedBox(height: AppDimensions.space16),

          // 2. 5 CORE HEALTH DIMENSIONS BREAKDOWN
          _buildDimensionsSection(health),
          const SizedBox(height: AppDimensions.space16),

          // 3. POSITIVE & WARNING SIGNALS
          _buildSignalsSection(health),
          const SizedBox(height: AppDimensions.space20),

          // 4. INTELLIGENCE TABS / FILTERS
          _buildIntelligenceTabs(controller, currentTab),
          const SizedBox(height: AppDimensions.space16),

          // Tab-specific or all content
          if (currentTab == 'ALL' || currentTab == 'FORECAST') ...[
            _buildSalesForecastCard(forecast),
            const SizedBox(height: AppDimensions.space20),
          ],

          if (currentTab == 'ALL' || currentTab == 'INVENTORY') ...[
            _buildInventoryIntelligenceSection(inventory),
            const SizedBox(height: AppDimensions.space20),
          ],

          if (currentTab == 'ALL' || currentTab == 'CUSTOMERS') ...[
            _buildCustomerRiskSection(customers),
            const SizedBox(height: AppDimensions.space20),
          ],

          if (currentTab == 'ALL' || currentTab == 'PRODUCTS') ...[
            _buildProductIntelligenceSection(products),
            const SizedBox(height: AppDimensions.space20),
          ],

          // 5. ACTIONABLE DECISION RECOMMENDATIONS
          if (recommendations.isNotEmpty) ...[
            _buildRecommendationsSection(recommendations),
            const SizedBox(height: AppDimensions.space24),
          ],
        ],
      ),
    );
  }

  // ==================== HERO GAUGE ====================

  Widget _buildHeroHealthGaugeCard(BusinessHealthScoreModel health) {
    Color levelColor;
    BadgeType badgeType;

    switch (health.healthLevel) {
      case 'EXCELLENT':
        levelColor = AppColors.successGreen;
        badgeType = BadgeType.success;
        break;
      case 'GOOD':
        levelColor = AppColors.primaryBlueLight;
        badgeType = BadgeType.info;
        break;
      case 'AVERAGE':
        levelColor = AppColors.warningOrange;
        badgeType = BadgeType.warning;
        break;
      case 'CRITICAL':
      default:
        levelColor = AppColors.errorRed;
        badgeType = BadgeType.error;
        break;
    }

    return NirmaanCard(
      variant: CardVariant.navy,
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COMPOSITE HEALTH INDEX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnNavySecondary,
                  letterSpacing: 1.0,
                ),
              ),
              NirmaanBadge(label: health.healthLevel, type: badgeType),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Circular gauge
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: levelColor, width: 7),
              color: AppColors.primarySurface,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${health.overallScore}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'OUT OF 100',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnNavySecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          if (health.summaryHeadline.isNotEmpty) ...[
            Text(
              health.summaryHeadline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
          ],

          if (health.explanation.isNotEmpty)
            Text(
              health.explanation,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textOnNavySecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  // ==================== 5 DIMENSIONS ====================

  Widget _buildDimensionsSection(BusinessHealthScoreModel health) {
    final dimensions = health.dimensions;
    if (dimensions.isEmpty) return const SizedBox.shrink();

    final dimKeys = ['sales', 'inventory', 'customers', 'products', 'operations'];
    final labels = {
      'sales': 'Sales Performance',
      'inventory': 'Inventory Health',
      'customers': 'Customer Vitality',
      'products': 'Product Catalog',
      'operations': 'Store Operations',
    };
    final icons = {
      'sales': Icons.trending_up,
      'inventory': Icons.inventory_2_outlined,
      'customers': Icons.people_outline,
      'products': Icons.category_outlined,
      'operations': Icons.settings_suggest_outlined,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health Score Dimensions', style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space8),
        ...dimKeys.map((key) {
          final dim = dimensions[key];
          if (dim == null) return const SizedBox.shrink();

          final name = labels[key] ?? key.toUpperCase();
          final icon = icons[key] ?? Icons.circle;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space8),
            child: _buildDimensionBarCard(name, dim, icon),
          );
        }),
      ],
    );
  }

  Widget _buildDimensionBarCard(
      String title, HealthDimensionModel dimension, IconData icon) {
    Color progressColor;
    if (dimension.score >= 80) {
      progressColor = AppColors.successGreen;
    } else if (dimension.score >= 50) {
      progressColor = AppColors.warningOrange;
    } else {
      progressColor = AppColors.errorRed;
    }

    return NirmaanCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryNavy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
              ),
              Text(
                'Weight: ${dimension.weight}',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Text(
                '${dimension.score}/100',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (dimension.score.clamp(0, 100)) / 100.0,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SIGNALS ====================

  Widget _buildSignalsSection(BusinessHealthScoreModel health) {
    final pos = health.positiveSignals;
    final neg = health.negativeSignals;

    if (pos.isEmpty && neg.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operational Signals & Alerts',
            style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space8),
        if (neg.isNotEmpty) ...[
          ...neg.map(
            (signal) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space6),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space10),
                decoration: BoxDecoration(
                  color: AppColors.warningOrangeLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                      color: AppColors.warningOrange.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warningOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        signal,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (pos.isNotEmpty) ...[
          ...pos.map(
            (signal) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space6),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space10),
                decoration: BoxDecoration(
                  color: AppColors.successGreenLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.successGreenDark, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        signal,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreenDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==================== TABS ====================

  Widget _buildIntelligenceTabs(BiController controller, String activeTab) {
    final tabs = [
      {'key': 'ALL', 'label': 'All Insights'},
      {'key': 'FORECAST', 'label': 'Forecast'},
      {'key': 'INVENTORY', 'label': 'Inventory'},
      {'key': 'CUSTOMERS', 'label': 'Churn Risk'},
      {'key': 'PRODUCTS', 'label': 'Products'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final isSelected = activeTab == t['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t['label']!),
              selected: isSelected,
              selectedColor: AppColors.primaryNavy,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: AppColors.surfaceWhite,
              onSelected: (_) =>
                  controller.setSelectedIntelligenceTab(t['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== SALES FORECAST ====================

  Widget _buildSalesForecastCard(SalesForecastModel forecast) {
    BadgeType confBadge;
    switch (forecast.confidence) {
      case 'HIGH':
        confBadge = BadgeType.success;
        break;
      case 'MEDIUM':
        confBadge = BadgeType.info;
        break;
      case 'LOW':
      case 'INSUFFICIENT_DATA':
      default:
        confBadge = BadgeType.warning;
        break;
    }

    IconData trendIcon;
    Color trendColor;
    switch (forecast.trendDirection) {
      case 'GROWTH':
        trendIcon = Icons.trending_up;
        trendColor = AppColors.successGreen;
        break;
      case 'DECLINING':
        trendIcon = Icons.trending_down;
        trendColor = AppColors.errorRed;
        break;
      case 'STABLE':
      default:
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.primaryBlueLight;
        break;
    }

    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_graph,
                      color: AppColors.primaryNavy, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '7-Day Sales & Demand Forecast',
                    style: AppTypography.cardTitle.copyWith(fontSize: 15),
                  ),
                ],
              ),
              NirmaanBadge(
                label: 'Confidence: ${forecast.confidence}',
                type: confBadge,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Trend & Projection Summary
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Projected Revenue (7d)',
                  value: _currencyFormat.format(forecast.projectedTotalRevenue),
                  subtitle: '${forecast.projectedTotalOrders} projected orders',
                  icon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trend Direction',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            forecast.trendDirection,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${forecast.historicalDataDaysAnalyzed} days analyzed',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (forecast.confidenceReason.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space8),
            Text(
              forecast.confidenceReason,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],

          // Daily Projections row
          if (forecast.dailyForecasts.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            const Text('Daily Breakdown',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimensions.space8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: forecast.dailyForecasts.map((df) {
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        Text(
                          df.date.length >= 5 ? df.date.substring(5) : df.date,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currencyFormat.format(df.projectedRevenue),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${df.projectedOrders} ord',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // Product velocity table
          if (forecast.productForecasts.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space12),
            const Text('Product Demand & Velocity',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimensions.space8),
            ...forecast.productForecasts.take(4).map((pf) {
              final Color riskColor = pf.stockRisk == 'OUT_OF_STOCK'
                  ? AppColors.errorRed
                  : (pf.stockRisk == 'HIGH_RISK'
                      ? AppColors.warningOrange
                      : AppColors.successGreen);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pf.name,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            'Vel: ${pf.dailyVelocity.toStringAsFixed(1)}/day | Supply: ${pf.daysOfSupply}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Stock: ${pf.currentStock}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: riskColor)),
                        Text('7d est: ${pf.projected7DayDemand}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],

          // Disclaimer (mandatory statistical decision-support rule)
          const SizedBox(height: AppDimensions.space12),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    forecast.disclaimer.isNotEmpty
                        ? forecast.disclaimer
                        : 'Statistical decision-support projection based on historical velocity. Not guaranteed.',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== INVENTORY INTELLIGENCE ====================

  Widget _buildInventoryIntelligenceSection(
      InventoryIntelligenceModel inventory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Inventory Intelligence & Stock Health',
            style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Out of Stock',
                value: '${inventory.outOfStockCount}',
                icon: Icons.error_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                title: 'Low Stock',
                value: '${inventory.lowStockCount}',
                icon: Icons.warning_amber_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                title: 'Dormant SKUs',
                value: '${inventory.slowMovingProducts.length}',
                icon: Icons.snooze,
              ),
            ),
          ],
        ),

        // Replenishment Recommendations
        if (inventory.replenishmentRecommendations.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),
          const Text('Replenishment Recommendations',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppDimensions.space8),
          ...inventory.replenishmentRecommendations.take(5).map((rep) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: rep.currentStock == 0
                          ? AppColors.errorRedLight
                          : AppColors.warningOrangeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      rep.currentStock == 0
                          ? Icons.priority_high
                          : Icons.add_shopping_cart,
                      size: 16,
                      color: rep.currentStock == 0
                          ? AppColors.errorRed
                          : AppColors.warningOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rep.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          rep.reason.isNotEmpty
                              ? 'Stock: ${rep.currentStock} | ${rep.reason}'
                              : 'Current Stock: ${rep.currentStock}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (rep.urgency.isNotEmpty)
                          Text(
                            'Urgency: ${rep.urgency}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: rep.urgency == 'HIGH'
                                  ? AppColors.errorRed
                                  : AppColors.warningOrange,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Reorder',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text(
                        '+${rep.suggestedReorderQuantity} units',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ==================== CUSTOMER RISK ====================

  Widget _buildCustomerRiskSection(CustomerRiskModel customers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Customer Churn & Retention Risk',
            style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.errorRedLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('High Risk',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.errorRedDark)),
                    const SizedBox(height: 4),
                    Text('${customers.riskSummary.highRiskCount}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.errorRedDark)),
                    const Text('Requires win-back',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.errorRedDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.warningOrangeLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                      color: AppColors.warningOrange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medium Risk',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warningOrange)),
                    const SizedBox(height: 4),
                    Text('${customers.riskSummary.mediumRiskCount}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warningOrange)),
                    const Text('Slowing cadence',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.successGreenLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Patrons',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreenDark)),
                    const SizedBox(height: 4),
                    Text('${customers.riskSummary.lowRiskCount}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successGreenDark)),
                    const Text('Healthy frequency',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.successGreenDark)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Inactive / at-risk customers listing
        if (customers.customerRiskSignals.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),
          const Text('At-Risk Inactive Customers',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppDimensions.space8),
          ...customers.customerRiskSignals.take(4).map((CustomerRiskSignalModel c) {
            BadgeType bType;
            if (c.riskLevel == 'HIGH_RISK') {
              bType = BadgeType.error;
            } else if (c.riskLevel == 'MEDIUM_RISK') {
              bType = BadgeType.warning;
            } else {
              bType = BadgeType.success;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(AppDimensions.space10),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.primaryNavy, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.customerName,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          c.phone.isNotEmpty
                              ? '${c.phone} • ${c.daysSinceLastOrder} days inactive'
                              : '${c.daysSinceLastOrder} days inactive',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  NirmaanBadge(label: c.riskLevel, type: bType),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ==================== PRODUCT INTELLIGENCE ====================

  Widget _buildProductIntelligenceSection(ProductIntelligenceModel products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Catalog Intelligence',
            style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space12),

        // Top Performers
        if (products.topPerformers.isNotEmpty) ...[
          const Text('Top Revenue Generators',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppDimensions.space8),
          ...products.topPerformers.take(4).map((prod) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(AppDimensions.space10),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_outline,
                      color: AppColors.warningOrange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prod.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          'Units sold: ${prod.quantitySold} | Stock: ${prod.currentStock}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _currencyFormat.format(prod.revenue),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Dormant Products
        if (products.dormantProducts.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),
          const Text('Dormant Products (Zero Recent Sales)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppDimensions.space8),
          ...products.dormantProducts.take(3).map((prod) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(AppDimensions.space10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty,
                      color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prod.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          'Stock: ${prod.currentStock} units tied in inventory',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const NirmaanBadge(label: 'DORMANT', type: BadgeType.neutral),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ==================== RECOMMENDATIONS ====================

  Widget _buildRecommendationsSection(
      List<BiRecommendationModel> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operational Decision Guidance',
            style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space12),
        ...recommendations.map((rec) {
          BadgeType pBadge;
          switch (rec.priority) {
            case 'HIGH':
              pBadge = BadgeType.error;
              break;
            case 'MEDIUM':
              pBadge = BadgeType.warning;
              break;
            case 'LOW':
            default:
              pBadge = BadgeType.info;
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space10),
            child: NirmaanCard(
              variant: CardVariant.elevated,
              padding: const EdgeInsets.all(AppDimensions.space14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NirmaanBadge(label: rec.category, type: BadgeType.neutral),
                      NirmaanBadge(label: '${rec.priority} PRIORITY', type: pBadge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(rec.title,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(rec.description, style: AppTypography.bodySecondary),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
