import 'package:flutter/material.dart';
import '../../../core/seed/presentation_seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

/// ============================================================================
/// Customer Directory Screen (Figma Frame 4: Customers)
/// ============================================================================
/// Displays registered patrons, contact details, churn risk badges, and loyalty.
/// Driven by CustomerModel seed data from PresentationSeedData.
/// ============================================================================
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCustomers = PresentationSeedData.seedCustomers;
    final filteredCustomers = allCustomers.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.phone.toLowerCase().contains(_searchQuery) ||
          (c.email?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    final churnAtRiskCount = allCustomers.where((c) => c.isChurnRisk).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Customer Directory',
        subtitle: '${allCustomers.length} registered patrons',
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
          Row(
            children: [
              const Expanded(
                child: MetricCard(
                  title: 'RETURNING',
                  value: '68%',
                  trend: '+4% this month',
                  icon: Icons.repeat_rounded,
                  iconColor: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: MetricCard(
                  title: 'CHURN AT RISK',
                  value: '$churnAtRiskCount patrons',
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () => _searchController.clear(),
                    )
                  : const Icon(Icons.tune, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Customers List
          const Text('Customer Profiles', style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          if (filteredCustomers.isEmpty)
            const EmptyStateView(
              icon: Icons.people_outline,
              title: 'No Customers Found',
              message: 'No customers match the entered search term.',
            )
          else
            ...filteredCustomers.map((customer) {
              final churnRiskLabel =
                  customer.isChurnRisk ? 'At Risk' : 'Healthy';
              final churnRiskType =
                  customer.isChurnRisk ? BadgeType.warning : BadgeType.success;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                child: _buildCustomerCard(
                  name: customer.name,
                  phone: customer.phone,
                  totalOrders: customer.totalOrders,
                  totalSpent: '₹${customer.totalSpend.toStringAsFixed(0)}',
                  loyaltyPoints: customer.loyaltyPoints,
                  lastVisit: customer.lastVisit != null
                      ? '${DateTime.now().difference(customer.lastVisit!).inDays}d ago'
                      : 'Never',
                  churnRisk: churnRiskLabel,
                  churnRiskType: churnRiskType,
                ),
              );
            }),
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
