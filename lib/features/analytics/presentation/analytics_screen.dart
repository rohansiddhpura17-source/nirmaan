import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/analytics.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final List<Map<String, String>> _ranges = const [
    {'label': 'Today', 'key': 'today'},
    {'label': 'Yesterday', 'key': 'yesterday'},
    {'label': '7 Days', 'key': '7d'},
    {'label': '30 Days', 'key': '30d'},
    {'label': 'Custom', 'key': 'custom'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AnalyticsController>();
      if (controller.analyticsData == null && !controller.isLoading) {
        controller.loadAnalytics();
      }
    });
  }

  Future<void> _handleRangeSelection(
      AnalyticsController controller, String rangeKey) async {
    if (rangeKey == 'custom') {
      final now = DateTime.now();
      final initialDateRange = DateTimeRange(
        start: controller.customStartDate ??
            now.subtract(const Duration(days: 14)),
        end: controller.customEndDate ?? now,
      );

      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: now,
        initialDateRange: initialDateRange,
        helpText: 'Select Custom Date Range',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryNavy,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        await controller.setRange(
          'custom',
          customStart: picked.start,
          customEnd: picked.end,
        );
      }
    } else {
      await controller.setRange(rangeKey);
    }
  }

  void _showReportBottomSheet(BuildContext context) {
    final controller = context.read<AnalyticsController>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider<AnalyticsController>.value(
        value: controller,
        child: const _ReportGenerationSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnalyticsController>();
    final data = controller.analyticsData;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Analytics & Reports',
        subtitle: data != null
            ? '${data.period.startDate} to ${data.period.endDate} (${data.period.range.toUpperCase()})'
            : 'Operational Intelligence',
        isDark: true,
        actions: [
          IconButton(
            tooltip: 'Generate Reports',
            icon: const Icon(Icons.summarize_outlined, color: Colors.white),
            onPressed: () => _showReportBottomSheet(context),
          ),
          IconButton(
            tooltip: 'Refresh Analytics',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: controller.isLoading
                ? null
                : () => controller.loadAnalytics(forceRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryNavy,
        onRefresh: () => controller.loadAnalytics(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.space16),
          children: [
            // Date Range Chips
            _buildRangeSelector(controller),
            const SizedBox(height: AppDimensions.space16),

            // Error Banner with Retry
            if (controller.errorMessage != null) ...[
              _buildErrorBanner(controller),
              const SizedBox(height: AppDimensions.space16),
            ],

            // Loading state indicator
            if (controller.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryNavy),
                      SizedBox(height: 12),
                      Text('Calculating business analytics...',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
            ] else if (data != null) ...[
              // Period Information Banner
              _buildPeriodHeader(data),
              const SizedBox(height: AppDimensions.space16),

              // 1. Sales & Revenue Summary Cards (4 Cards)
              _buildSalesKpiGrid(data.sales),
              const SizedBox(height: AppDimensions.space20),

              // 2. Sales Daily Trend Visualization
              _buildSalesTrendSection(data.sales),
              const SizedBox(height: AppDimensions.space20),

              // 3. Category Sales Breakdown
              _buildCategorySalesSection(data.products.categoryBreakdown),
              const SizedBox(height: AppDimensions.space20),

              // 4. Top Performing Products
              _buildTopProductsSection(data.products.topProducts),
              const SizedBox(height: AppDimensions.space20),

              // 5. Weak / Zero Sales Products
              if (data.products.weakOrNoSalesProducts.isNotEmpty) ...[
                _buildWeakProductsSection(data.products.weakOrNoSalesProducts),
                const SizedBox(height: AppDimensions.space20),
              ],

              // 6. Inventory Valuation & Movement Summary
              _buildInventorySummarySection(data.inventory),
              const SizedBox(height: AppDimensions.space20),

              // 7. Customer Network Analytics
              _buildCustomerAnalyticsSection(data.customers),
              const SizedBox(height: AppDimensions.space20),

              // 8. Generate Reports Action Card
              _buildReportsBanner(context),
              const SizedBox(height: AppDimensions.space32),
            ] else ...[
              // Empty state
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Text(
                    'No analytics data available for this range.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector(AnalyticsController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _ranges.map((item) {
          final isSelected = controller.selectedRange == item['key'];
          String label = item['label']!;
          if (item['key'] == 'custom' &&
              controller.customStartDate != null &&
              controller.customEndDate != null) {
            final f = DateFormat('dd MMM');
            label =
                '${f.format(controller.customStartDate!)} - ${f.format(controller.customEndDate!)}';
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: NirmaanChip(
              label: label,
              isSelected: isSelected,
              onSelected: (_) =>
                  _handleRangeSelection(controller, item['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorBanner(AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderSm,
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.errorRed, size: 20),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              controller.errorMessage!,
              style: AppTypography.caption.copyWith(color: AppColors.errorRed),
            ),
          ),
          TextButton(
            onPressed: () => controller.loadAnalytics(forceRefresh: true),
            child: const Text('RETRY',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader(AnalyticsDataModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.businessProfile?.name ?? 'Store Overview',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 2),
            Text(
              '${data.period.startDate} → ${data.period.endDate}',
              style: AppTypography.caption,
            ),
          ],
        ),
        NirmaanBadge(
          label: data.period.timezone,
          type: BadgeType.neutral,
          icon: Icons.schedule_rounded,
        ),
      ],
    );
  }

  Widget _buildSalesKpiGrid(SalesAnalyticsModel sales) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'TOTAL REVENUE',
                value: _currencyFormat.format(sales.totalRevenue),
                trend: '${sales.completedOrdersCount} orders',
                isTrendPositive: true,
                icon: Icons.currency_rupee_rounded,
                iconColor: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: MetricCard(
                title: 'COMPLETED ORDERS',
                value: '${sales.completedOrdersCount}',
                trend: 'Avg ${_currencyFormat.format(sales.averageOrderValue)}',
                isTrendPositive: sales.completedOrdersCount > 0,
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'AVG ORDER VALUE',
                value: _currencyFormat.format(sales.averageOrderValue),
                trend: sales.completedOrdersCount > 0
                    ? 'Per completed sale'
                    : 'No sales',
                isTrendPositive: sales.averageOrderValue > 0,
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: MetricCard(
                title: 'CANCELLED ORDERS',
                value: '${sales.cancelledOrdersCount}',
                trend:
                    '-${_currencyFormat.format(sales.cancelledRevenue)} (excluded)',
                isTrendPositive: false,
                icon: Icons.cancel_outlined,
                iconColor: AppColors.errorRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesTrendSection(SalesAnalyticsModel sales) {
    final trends = sales.dailyTrends;
    final maxRevenue = trends.fold<double>(
      0.0,
      (max, d) => d.revenue > max ? d.revenue : max,
    );

    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded,
                      size: 20, color: AppColors.primaryNavy),
                  SizedBox(width: 8),
                  Text('Daily Sales Trend', style: AppTypography.cardTitle),
                ],
              ),
              NirmaanBadge(
                label: '${trends.length} Days',
                type: BadgeType.info,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          if (trends.isEmpty || maxRevenue == 0) ...[
            Container(
              height: 120,
              alignment: Alignment.center,
              child: const Text('No sales activity recorded in this period.',
                  style: AppTypography.caption),
            ),
          ] else ...[
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trends.map((day) {
                  final ratio = maxRevenue > 0 ? (day.revenue / maxRevenue) : 0.0;
                  final height = (ratio * 90).clamp(6.0, 90.0);
                  final isPeak = day.revenue == maxRevenue && maxRevenue > 0;
                  final dateFormatted = day.date.length >= 10
                      ? day.date.substring(5) // MM-DD
                      : day.date;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Tooltip(
                        message:
                            '${day.date}\nRevenue: ${_currencyFormat.format(day.revenue)}\nOrders: ${day.completedOrdersCount}',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (day.revenue > 0)
                              Text(
                                '${day.completedOrdersCount}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isPeak
                                      ? AppColors.primaryNavy
                                      : AppColors.textMuted,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Container(
                              height: height,
                              decoration: BoxDecoration(
                                color: isPeak
                                    ? AppColors.primaryNavy
                                    : (day.revenue > 0
                                        ? AppColors.primaryBlue
                                        : AppColors.surfaceSubtle),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateFormatted,
                              style: TextStyle(
                                fontSize: 8,
                                color: isPeak
                                    ? AppColors.primaryNavy
                                    : AppColors.textMuted,
                                fontWeight: isPeak
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peak Day: ${_currencyFormat.format(maxRevenue)}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                Text(
                  'Total Period: ${_currencyFormat.format(sales.totalRevenue)}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySalesSection(List<CategorySalesModel> categories) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded,
                  size: 20, color: AppColors.primaryNavy),
              SizedBox(width: 8),
              Text('Sales by Category', style: AppTypography.cardTitle),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No category breakdown available.',
                    style: AppTypography.caption),
              ),
            )
          else
            ...categories.map((cat) {
              final ratio = (cat.shareOfRevenue / 100.0).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.category,
                            style: AppTypography.cardTitle
                                .copyWith(fontSize: 13)),
                        Text(
                          '${_currencyFormat.format(cat.revenue)} (${cat.shareOfRevenue.toStringAsFixed(1)}%)',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.surfaceSubtle,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryNavy),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection(List<TopProductAnalyticsModel> products) {
    return NirmaanCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                Icon(Icons.star_outline_rounded,
                    size: 20, color: AppColors.secondaryAmber),
                SizedBox(width: 8),
                Text('Top Performing Products', style: AppTypography.cardTitle),
              ],
            ),
          ),
          const Divider(height: 1),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.space24),
              child: Center(
                child: Text('No product sales recorded in this period.',
                    style: AppTypography.caption),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = products[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppColors.secondaryAmber.withValues(alpha: 0.2)
                              : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: index == 0
                                ? AppColors.secondaryAmber
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: AppTypography.cardTitle
                                    .copyWith(fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              'SKU: ${p.sku.isNotEmpty ? p.sku : 'N/A'} · ${p.quantitySold} units sold',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _currencyFormat.format(p.revenue),
                            style: AppTypography.cardTitle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          Text(
                            '${p.shareOfRevenue.toStringAsFixed(1)}% revenue',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWeakProductsSection(List<WeakProductAnalyticsModel> products) {
    return NirmaanCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 20, color: AppColors.errorRed),
                    SizedBox(width: 8),
                    Text('Slow / Zero Sales Items',
                        style: AppTypography.cardTitle),
                  ],
                ),
                NirmaanBadge(
                  label: '${products.length} Items',
                  type: BadgeType.warning,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = products[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: AppTypography.cardTitle
                                  .copyWith(fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            'Category: ${p.category} · In Stock: ${p.currentStock}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    const NirmaanBadge(
                      label: '0 Units Sold',
                      type: BadgeType.neutral,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySummarySection(InventoryAnalyticsModel inventory) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warehouse_rounded,
                  size: 20, color: AppColors.primaryNavy),
              SizedBox(width: 8),
              Text('Inventory Valuation & Movement',
                  style: AppTypography.cardTitle),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('VALUATION',
                  _currencyFormat.format(inventory.inventoryValuation),
                  AppColors.primaryNavy),
              _buildStatColumn('TOTAL STOCK',
                  '${inventory.totalStockUnits} units', AppColors.primaryNavy),
              _buildStatColumn('LOW STOCK', '${inventory.lowStockCount}',
                  AppColors.secondaryAmber),
              _buildStatColumn('OUT OF STOCK', '${inventory.outOfStockCount}',
                  AppColors.errorRed),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movements in range: ${inventory.stockMovementSummary.totalMovementsCount}',
                style: AppTypography.caption,
              ),
              Row(
                children: [
                  Text(
                    'In: +${inventory.stockMovementSummary.inwardUnits}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Out: -${inventory.stockMovementSummary.outwardUnits}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalyticsSection(CustomerAnalyticsModel customers) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 20, color: AppColors.primaryNavy),
              SizedBox(width: 8),
              Text('Customer Analytics', style: AppTypography.cardTitle),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('TOTAL REGISTERED',
                  '${customers.totalCustomers}', AppColors.primaryNavy),
              _buildStatColumn('ACTIVE IN PERIOD',
                  '${customers.activeCustomersCount}', AppColors.successGreen),
              _buildStatColumn('AVG FREQUENCY',
                  '${customers.averageOrderFrequency}x', AppColors.primaryBlue),
            ],
          ),
          if (customers.topCustomers.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.space12),
            Text('Top Spenders in Selected Period',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                )),
            const SizedBox(height: 8),
            ...customers.topCustomers.take(5).map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_rounded,
                              size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(c.customerName,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 6),
                          Text('(${c.ordersCount} orders)',
                              style: AppTypography.caption),
                        ],
                      ),
                      Text(
                        _currencyFormat.format(c.totalSpend),
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildReportsBanner(BuildContext context) {
    return NirmaanCard(
      variant: CardVariant.navy,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppDimensions.borderSm,
            ),
            child: const Icon(Icons.summarize_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppDimensions.space16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Structured Business Reports',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Generate printable reports for Sales, Inventory, and Customers',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textOnNavySecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => _showReportBottomSheet(context),
            child: const Text('GENERATE',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _ReportGenerationSheet extends StatefulWidget {
  const _ReportGenerationSheet();

  @override
  State<_ReportGenerationSheet> createState() => _ReportGenerationSheetState();
}

class _ReportGenerationSheetState extends State<_ReportGenerationSheet> {
  final List<Map<String, String>> _reportTypes = const [
    {'type': 'SALES', 'title': 'Sales & Revenue Report'},
    {'type': 'PRODUCTS', 'title': 'Product Performance Report'},
    {'type': 'INVENTORY', 'title': 'Inventory Valuation Report'},
    {'type': 'CUSTOMERS', 'title': 'Customer & Khata Report'},
  ];

  String _selectedType = 'SALES';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AnalyticsController>();
      controller.generateReport(_selectedType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnalyticsController>();
    final report = controller.reportData;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Business Reports',
                    style: AppTypography.pageTitle),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Report Type Selector Chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _reportTypes.map((item) {
                  final isSelected = _selectedType == item['type'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(item['title']!),
                      selected: isSelected,
                      selectedColor: AppColors.primaryNavy,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = item['type']!);
                          controller.generateReport(item['type']!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: controller.isReportLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: AppColors.primaryNavy),
                        SizedBox(height: 12),
                        Text('Compiling operational report records...',
                            style: AppTypography.caption),
                      ],
                    ),
                  )
                : controller.reportError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 40, color: AppColors.errorRed),
                              const SizedBox(height: 8),
                              Text(controller.reportError!,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.errorRed)),
                              const SizedBox(height: 12),
                              NirmaanButton(
                                label: 'Retry',
                                variant: ButtonVariant.outline,
                                onPressed: () =>
                                    controller.generateReport(_selectedType),
                              ),
                            ],
                          ),
                        ),
                      )
                    : report != null
                        ? _buildReportContent(report)
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportDataModel report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Report Meta Card
        NirmaanCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${report.reportType} REPORT',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  NirmaanBadge(
                    label: report.period.range.toUpperCase(),
                    type: BadgeType.info,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Business: ${report.businessProfile?.name ?? 'Nirmaan Business'}',
                style: AppTypography.caption,
              ),
              Text(
                'Period: ${report.period.startDate} to ${report.period.endDate}',
                style: AppTypography.caption,
              ),
              Text(
                'Generated: ${report.generatedAt}',
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Summary Statistics Grid
        if (report.summary.isNotEmpty) ...[
          const Text('Summary Metrics', style: AppTypography.sectionTitle),
          const SizedBox(height: 8),
          NirmaanCard(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: report.summary.entries.map((e) {
                return SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key.replaceAllMapped(
                            RegExp(r'([A-Z])'), (m) => ' ${m[1]}').toUpperCase(),
                        style: AppTypography.caption.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${e.value}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Data Table of Records
        Text('Report Records (${report.records.length})',
            style: AppTypography.sectionTitle),
        const SizedBox(height: 8),
        if (report.records.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No records found for this report period.',
                  style: AppTypography.caption),
            ),
          )
        else
          NirmaanCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    AppColors.surfaceSubtle),
                columns: report.records.first.keys.map((k) {
                  return DataColumn(
                    label: Text(
                      k.replaceAllMapped(
                          RegExp(r'([A-Z])'), (m) => ' ${m[1]}').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  );
                }).toList(),
                rows: report.records.map((row) {
                  return DataRow(
                    cells: row.values.map((v) {
                      return DataCell(
                        Text('$v', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
