import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/dashboard.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../business_setup/controllers/business_setup_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final controller = context.read<DashboardController>();
        if (controller.dashboardData == null && !controller.isLoading) {
          controller.loadDashboard();
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final setupController = context.watch<BusinessSetupController>();
    DashboardController? dashboardController;
    try {
      dashboardController = context.watch<DashboardController>();
    } catch (_) {}

    final user = authController.currentUser;
    final role = user?.role ?? UserRole.businessOwner;

    final dashboardData = dashboardController?.dashboardData;
    final businessName = dashboardData?.businessProfile?.name ??
        setupController.businessProfile?.businessName ??
        'Nirmaan Business';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.primaryNavy,
        onRefresh: () async {
          if (dashboardController != null) {
            await dashboardController.loadDashboard(forceRefresh: true);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Navy Hero App Bar
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLight
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role.label.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlueLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Live Operations',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh Dashboard',
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    dashboardController?.loadDashboard(forceRefresh: true);
                  },
                ),
                IconButton(
                  tooltip: 'Notifications',
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(Icons.account_circle_outlined,
                      color: Colors.white),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.profile),
                ),
              ],
            ),

            // Body Area
            if (dashboardController?.isLoading == true && dashboardData == null)
              const SliverFillRemaining(
                child: Center(
                  child: LoadingIndicator(
                    message: 'Loading business dashboard...',
                  ),
                ),
              )
            else if (dashboardController?.errorMessage != null &&
                dashboardData == null)
              SliverFillRemaining(
                child: Center(
                  child: ErrorStateView(
                    title: 'Dashboard Error',
                    message: dashboardController!.errorMessage!,
                    onRetry: () =>
                        dashboardController?.loadDashboard(forceRefresh: true),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Operational Insights Banner (Strictly Real Data, No Gemini/AI)
                      if (dashboardData != null &&
                          dashboardData.insights.isNotEmpty) ...[
                        _buildOperationalInsightsCard(dashboardData.insights),
                        const SizedBox(height: AppDimensions.space16),
                      ],

                      // Today's Performance Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Today\'s Performance',
                              style: AppTypography.sectionTitle),
                          NirmaanBadge(
                            label: dashboardData?.today.isNotEmpty == true
                                ? 'IST ${dashboardData!.today}'
                                : 'Live IST',
                            type: BadgeType.neutral,
                            icon: Icons.access_time_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      // 2x2 Primary KPI Metric Cards Grid
                      _buildMetricCardsGrid(
                          dashboardData?.metrics ?? const DashboardMetricsModel()),
                      const SizedBox(height: AppDimensions.space16),

                      // Inventory & Catalog Status Card
                      _buildInventoryStatusCard(
                        context,
                        dashboardData?.metrics ?? const DashboardMetricsModel(),
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Customers & Khata Status Card
                      _buildCustomerStatusCard(
                        context,
                        dashboardData?.metrics ?? const DashboardMetricsModel(),
                      ),
                      const SizedBox(height: AppDimensions.space20),

                      // Quick Operational Actions
                      const Text('Quick Actions',
                          style: AppTypography.sectionTitle),
                      const SizedBox(height: AppDimensions.space12),
                      _buildQuickActions(context),
                      const SizedBox(height: AppDimensions.space20),

                      // Top Selling Products Section
                      _buildTopProductsSection(
                        dashboardData?.topProducts ?? const [],
                      ),
                      const SizedBox(height: AppDimensions.space20),

                      // Stock Alerts Section
                      _buildStockAlertsSection(
                        context,
                        dashboardData?.stockAlerts ?? const [],
                      ),
                      const SizedBox(height: AppDimensions.space20),

                      // Recent Real Transactions Section
                      _buildRecentOrdersSection(
                        context,
                        dashboardData?.recentOrders ?? const [],
                      ),
                      const SizedBox(height: AppDimensions.space32),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalInsightsCard(List<String> insights) {
    return NirmaanCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space6),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderSm,
                ),
                child: const Icon(Icons.insights_rounded,
                    color: AppColors.primaryNavy, size: 20),
              ),
              const SizedBox(width: AppDimensions.space10),
              Text(
                'Operational Insights',
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          for (int i = 0; i < insights.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      insights[i],
                      style: AppTypography.bodySecondary.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCardsGrid(DashboardMetricsModel metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'TODAY\'S REVENUE',
                value: '₹${metrics.todayRevenue.toStringAsFixed(0)}',
                trend: '${metrics.todayOrdersCount} orders',
                isTrendPositive: metrics.todayRevenue > 0,
                icon: Icons.currency_rupee_rounded,
                iconColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: MetricCard(
                title: 'TODAY\'S ORDERS',
                value: '${metrics.todayOrdersCount}',
                trend: metrics.todayCancelledOrdersCount > 0
                    ? '${metrics.todayCancelledOrdersCount} cancelled'
                    : 'Active',
                isTrendPositive: metrics.todayCancelledOrdersCount == 0,
                icon: Icons.shopping_bag_outlined,
                iconColor: AppColors.secondaryAmber,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'TOTAL REVENUE',
                value: '₹${metrics.totalRevenue.toStringAsFixed(0)}',
                trend: '${metrics.completedOrdersCount} completed',
                isTrendPositive: true,
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: MetricCard(
                title: 'INVENTORY VALUE',
                value: '₹${metrics.inventoryValuation.toStringAsFixed(0)}',
                trend: '${metrics.totalStockUnits} units',
                isTrendPositive: metrics.inventoryValuation > 0,
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primaryNavy,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventory),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryStatusCard(
      BuildContext context, DashboardMetricsModel metrics) {
    return NirmaanCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventory),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warehouse_rounded,
                      size: 20, color: AppColors.primaryNavy),
                  SizedBox(width: 8),
                  Text('Inventory Overview', style: AppTypography.cardTitle),
                ],
              ),
              Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInventoryStatColumn(
                label: 'Total SKUs',
                value: '${metrics.totalProducts}',
                color: AppColors.primaryNavy,
              ),
              _buildInventoryStatColumn(
                label: 'In Stock',
                value: '${metrics.inStockCount}',
                color: AppColors.successGreen,
              ),
              _buildInventoryStatColumn(
                label: 'Low Stock',
                value: '${metrics.lowStockCount}',
                color: AppColors.warningOrange,
              ),
              _buildInventoryStatColumn(
                label: 'Out of Stock',
                value: '${metrics.outOfStockCount}',
                color: AppColors.errorRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCustomerStatusCard(
      BuildContext context, DashboardMetricsModel metrics) {
    return NirmaanCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.customers),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight.withValues(alpha: 0.15),
              borderRadius: AppDimensions.borderSm,
            ),
            child: const Icon(Icons.people_alt_outlined,
                color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Network & Khata',
                    style: AppTypography.cardTitle),
                const SizedBox(height: 2),
                Text(
                  '${metrics.totalCustomers} registered customers · ${metrics.activeKhataCustomers} active khata',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${metrics.totalOutstandingKhata.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorRed,
                ),
              ),
              Text(
                'Khata Due',
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NirmaanButton(
                label: 'Create Order',
                variant: ButtonVariant.primary,
                icon: Icons.add_shopping_cart,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createOrder),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: NirmaanButton(
                label: 'Add Product',
                variant: ButtonVariant.outline,
                icon: Icons.add_box_outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.addProduct),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space10),
        Row(
          children: [
            Expanded(
              child: NirmaanButton(
                label: 'Adjust Stock',
                variant: ButtonVariant.outline,
                icon: Icons.tune,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.inventory),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: NirmaanButton(
                label: 'Add Customer',
                variant: ButtonVariant.outline,
                icon: Icons.person_add_outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.addCustomer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProductsSection(List<DashboardTopProductModel> topProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top-Selling Products', style: AppTypography.sectionTitle),
        const SizedBox(height: AppDimensions.space10),
        if (topProducts.isEmpty)
          const NirmaanCard(
            padding: EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                Icon(Icons.bar_chart_outlined,
                    color: AppColors.textMuted, size: 24),
                SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Text(
                    'No completed order sales recorded yet. Completed orders will rank bestsellers here.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          NirmaanCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < topProducts.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? AppColors.secondaryAmber.withValues(alpha: 0.2)
                                : AppColors.surfaceSubtle,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: i == 0
                                  ? AppColors.secondaryAmber
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topProducts[i].name,
                                style: AppTypography.cardTitle
                                    .copyWith(fontSize: 14),
                              ),
                              Text(
                                '${topProducts[i].sku.isNotEmpty ? "SKU: ${topProducts[i].sku} · " : ""}${topProducts[i].quantitySold} units sold',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${topProducts[i].revenue.toStringAsFixed(0)}',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStockAlertsSection(
      BuildContext context, List<DashboardStockAlertModel> stockAlerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Stock Alerts (${stockAlerts.length})',
                style: AppTypography.sectionTitle),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.inventory),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        if (stockAlerts.isEmpty)
          const NirmaanCard(
            padding: EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.successGreen, size: 24),
                SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Text(
                    'All inventory levels are healthy. No items below threshold.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          NirmaanCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < stockAlerts.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.inventory),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: stockAlerts[i].isOutOfStock
                                  ? AppColors.errorRedLight
                                  : AppColors.warningOrangeLight,
                              borderRadius: AppDimensions.borderSm,
                            ),
                            child: Icon(
                              stockAlerts[i].isOutOfStock
                                  ? Icons.error_outline
                                  : Icons.warning_amber_rounded,
                              color: stockAlerts[i].isOutOfStock
                                  ? AppColors.errorRed
                                  : AppColors.warningOrange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stockAlerts[i].name,
                                  style: AppTypography.cardTitle
                                      .copyWith(fontSize: 13),
                                ),
                                Text(
                                  '${stockAlerts[i].stockQuantity} ${stockAlerts[i].unit} left (Threshold: ${stockAlerts[i].minStockThreshold})',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          NirmaanBadge(
                            label: stockAlerts[i].isOutOfStock
                                ? 'OUT OF STOCK'
                                : 'LOW STOCK',
                            type: stockAlerts[i].isOutOfStock
                                ? BadgeType.error
                                : BadgeType.warning,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentOrdersSection(
      BuildContext context, List<DashboardOrderModel> recentOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Orders', style: AppTypography.sectionTitle),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.orders),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        if (recentOrders.isEmpty)
          const NirmaanCard(
            padding: EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    color: AppColors.textMuted, size: 24),
                SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Text(
                    'No orders placed yet. Tap Create Order above to record a transaction.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          NirmaanCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < recentOrders.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  InkWell(
                    onTap: () {
                      _showOrderDetailsDialog(context, recentOrders[i]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_outlined,
                                size: 18, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recentOrders[i].customerName,
                                  style: AppTypography.cardTitle
                                      .copyWith(fontSize: 14),
                                ),
                                Text(
                                  '#${recentOrders[i].orderNumber} · ${recentOrders[i].itemCount} items · ${recentOrders[i].paymentMethod}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${recentOrders[i].totalAmount.toStringAsFixed(0)}',
                                style: AppTypography.cardTitle
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              NirmaanBadge(
                                label: recentOrders[i].status,
                                type: recentOrders[i].status == 'COMPLETED'
                                    ? BadgeType.success
                                    : (recentOrders[i].status == 'PENDING'
                                        ? BadgeType.warning
                                        : BadgeType.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  void _showOrderDetailsDialog(
      BuildContext context, DashboardOrderModel order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Order #${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName}',
                style: AppTypography.body),
            if (order.customerPhone != null &&
                order.customerPhone!.isNotEmpty)
              Text('Phone: ${order.customerPhone}',
                  style: AppTypography.bodySecondary),
            const SizedBox(height: 8),
            Text('Items: ${order.itemCount}',
                style: AppTypography.bodySecondary),
            Text('Payment Method: ${order.paymentMethod}',
                style: AppTypography.bodySecondary),
            Text('Status: ${order.status}',
                style: AppTypography.bodySecondary),
            const SizedBox(height: 12),
            Text(
              'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
              style: AppTypography.cardTitle
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AppRoutes.orders);
            },
            child: const Text('View All Orders'),
          ),
        ],
      ),
    );
  }
}
