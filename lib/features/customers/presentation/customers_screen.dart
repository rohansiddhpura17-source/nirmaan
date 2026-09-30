import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Customer Directory',
        subtitle: '248 registered patrons',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined,
                color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Customer Metrics
          const Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'RETURNING',
                  value: '68%',
                  trend: '+4% this month',
                  icon: Icons.repeat_rounded,
                  iconColor: AppColors.successGreen,
                ),
              ),
              SizedBox(width: AppDimensions.space12),
              Expanded(
                child: MetricCard(
                  title: 'CHURN AT RISK',
                  value: '12 patrons',
                  trend: 'High priority',
                  isTrendPositive: false,
                  icon: Icons.person_off_outlined,
                  iconColor: AppColors.warningOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search customer name or phone...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune, color: AppColors.textMuted),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Customers List
          const Text('Customer Profiles', style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildCustomerCard(
            name: 'Suresh Kumar',
            phone: '+91 98234 11223',
            totalOrders: 24,
            totalSpent: '₹18,450',
            loyaltyPoints: 340,
            lastVisit: 'Today',
            churnRisk: 'Low Risk',
            churnRiskType: BadgeType.success,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildCustomerCard(
            name: 'Pooja Verma',
            phone: '+91 97123 45678',
            totalOrders: 18,
            totalSpent: '₹14,200',
            loyaltyPoints: 210,
            lastVisit: '2 days ago',
            churnRisk: 'Low Risk',
            churnRiskType: BadgeType.success,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildCustomerCard(
            name: 'Vikram Joshi',
            phone: '+91 98980 12345',
            totalOrders: 6,
            totalSpent: '₹4,100',
            loyaltyPoints: 40,
            lastVisit: '26 days ago',
            churnRisk: 'At Risk',
            churnRiskType: BadgeType.warning,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildCustomerCard(
            name: 'Meena Ben',
            phone: '+91 99112 33445',
            totalOrders: 32,
            totalSpent: '₹29,800',
            loyaltyPoints: 580,
            lastVisit: 'Yesterday',
            churnRisk: 'VIP Champion',
            churnRiskType: BadgeType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard({
    required String name,
    required String phone,
    required int totalOrders,
    required String totalSpent,
    required int loyaltyPoints,
    required String lastVisit,
    required String churnRisk,
    required BadgeType churnRiskType,
  }) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTypography.cardTitle),
              NirmaanBadge(label: churnRisk, type: churnRiskType),
            ],
          ),
          const SizedBox(height: AppDimensions.space4),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(phone, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Orders', style: AppTypography.caption),
                  Text('$totalOrders',
                      style: AppTypography.cardTitle
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Spent', style: AppTypography.caption),
                  Text(totalSpent,
                      style: AppTypography.cardTitle
                          .copyWith(color: AppColors.primaryNavy)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Loyalty Points', style: AppTypography.caption),
                  Text('$loyaltyPoints pts',
                      style: AppTypography.cardTitle
                          .copyWith(color: AppColors.secondaryAmberDark)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
