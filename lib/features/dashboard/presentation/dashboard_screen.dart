import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../business_setup/controllers/business_setup_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final setupController = context.watch<BusinessSetupController>();

    final user = authController.currentUser;
    final role = user?.role ?? UserRole.businessOwner;
    final businessName =
        setupController.businessProfile?.businessName ?? 'Nirmaan Business';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
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
                          color:
                              AppColors.primaryBlueLight.withValues(alpha: 0.2),
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
                      Text(
                        'Live Operations',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined,
                    color: Colors.white),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.profile),
              ),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Daily Business Brief Banner
                  NirmaanCard(
                    variant: CardVariant.aiSpecial,
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.todaysBusiness),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space8),
                          decoration: const BoxDecoration(
                            color: AppColors.aiPurpleLight,
                            borderRadius: AppDimensions.borderSm,
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: AppColors.aiPurple, size: 20),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'AI Daily Business Brief',
                                    style: AppTypography.cardTitle.copyWith(
                                      color: AppColors.aiPurple,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right,
                                      size: 16, color: AppColors.aiPurple),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.space4),
                              Text(
                                'Sales are tracking +14% above last week. Reorder 2 fast-moving stock items before Friday rush.',
                                style: AppTypography.bodySecondary.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Section Title: Key Metrics
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Performance',
                          style: AppTypography.sectionTitle),
                      NirmaanBadge(
                        label: 'Updated 2m ago',
                        type: BadgeType.neutral,
                        icon: Icons.sync,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // 2x2 Metric Cards Grid
                  const Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'REVENUE',
                          value: '₹28,450',
                          trend: '+14.2%',
                          isTrendPositive: true,
                          icon: Icons.currency_rupee_rounded,
                          iconColor: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: MetricCard(
                          title: 'ORDERS',
                          value: '38',
                          trend: '+6 orders',
                          isTrendPositive: true,
                          icon: Icons.shopping_bag_outlined,
                          iconColor: AppColors.secondaryAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: [
                      const Expanded(
                        child: MetricCard(
                          title: 'NET PROFIT',
                          value: '₹8,320',
                          trend: '29.2% margin',
                          isTrendPositive: true,
                          icon: Icons.trending_up_rounded,
                          iconColor: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: MetricCard(
                          title: 'HEALTH SCORE',
                          value: '88/100',
                          trend: 'Strong',
                          isTrendPositive: true,
                          icon: Icons.health_and_safety_outlined,
                          iconColor: AppColors.primaryBlueLight,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.businessHealth),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Quick Operational Actions
                  const Text('Quick Actions',
                      style: AppTypography.sectionTitle),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: [
                      Expanded(
                        child: NirmaanButton(
                          label: 'Add Product',
                          variant: ButtonVariant.outline,
                          icon: Icons.add_circle_outline,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.addProduct),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: NirmaanButton(
                          label: 'AI Coach',
                          variant: ButtonVariant.primary,
                          icon: Icons.chat_bubble_outline,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.aiCoach),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Attention / Operational Alerts
                  const Text('Attention Items',
                      style: AppTypography.sectionTitle),
                  const SizedBox(height: AppDimensions.space12),
                  NirmaanCard(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    child: Column(
                      children: [
                        _buildAlertRow(
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.warningOrange,
                          title: '3 Products in Low Stock',
                          subtitle: 'Wheat Flour, Basmati Rice, Sunflower Oil',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.products),
                        ),
                        const Divider(height: 16),
                        _buildAlertRow(
                          icon: Icons.people_outline,
                          color: AppColors.primaryBlue,
                          title: '5 Inactive Regular Customers',
                          subtitle: 'Haven\'t visited in the last 21 days',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.analytics),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Transactions',
                          style: AppTypography.sectionTitle),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),

                  // Recent Transactions List
                  NirmaanCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildTransactionTile(
                          orderId: '#ORD-1094',
                          customer: 'Suresh Kumar',
                          itemsCount: '4 items',
                          amount: '₹1,240',
                          status: 'PAID',
                          statusType: BadgeType.success,
                          time: '12m ago',
                        ),
                        const Divider(height: 1),
                        _buildTransactionTile(
                          orderId: '#ORD-1093',
                          customer: 'Anjali Sharma',
                          itemsCount: '2 items',
                          amount: '₹680',
                          status: 'PAID',
                          statusType: BadgeType.success,
                          time: '34m ago',
                        ),
                        const Divider(height: 1),
                        _buildTransactionTile(
                          orderId: '#ORD-1092',
                          customer: 'Pooja Verma',
                          itemsCount: '6 items',
                          amount: '₹3,450',
                          status: 'UPI PAID',
                          statusType: BadgeType.info,
                          time: '1h ago',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required String orderId,
    required String customer,
    required String itemsCount,
    required String amount,
    required String status,
    required BadgeType statusType,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Text(customer,
                    style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                Text('$orderId · $itemsCount · $time',
                    style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: AppTypography.cardTitle
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              NirmaanBadge(label: status, type: statusType),
            ],
          ),
        ],
      ),
    );
  }
}
