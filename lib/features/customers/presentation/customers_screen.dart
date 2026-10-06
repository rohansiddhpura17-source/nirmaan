import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../controllers/customer_controller.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CustomerController>();
      if (controller.customers.isEmpty) {
        controller.loadCustomers();
      }
    });

    _searchController.addListener(() {
      context.read<CustomerController>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomerController>();
    final customers = controller.filteredCustomers;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Customer Directory',
        subtitle: '${controller.customers.length} registered customers',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadCustomers(forceRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.addCustomer),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers by name, phone or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          const Divider(height: 1),

          // Error Banner with Retry
          if (controller.errorMessage != null)
            Container(
              margin: const EdgeInsets.all(AppDimensions.space16),
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.errorRed),
                borderRadius: AppDimensions.borderMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorRed),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Text(
                      controller.errorMessage!,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.errorRed),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.loadCustomers(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Customer List / Loading / Empty State
          Expanded(
            child: controller.isLoading && controller.customers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => controller.loadCustomers(forceRefresh: true),
                    child: customers.isEmpty
                        ? const Center(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: EmptyStateView(
                                icon: Icons.people_outline,
                                title: 'No Customers Found',
                                message:
                                    'No customers match the search or directory is empty. Add a customer to build patron accounts.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppDimensions.space16),
                            itemCount: customers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppDimensions.space12),
                            itemBuilder: (context, index) {
                              final c = customers[index];
                              return _buildCustomerCard(context, c);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customers_fab',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addCustomer),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel c) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.name, style: AppTypography.cardTitle),
              ),
              NirmaanBadge(
                label: '${c.orderCount} Orders',
                type: BadgeType.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(c.phone, style: AppTypography.body),
              if (c.email != null && c.email!.isNotEmpty) ...[
                const SizedBox(width: 16),
                const Icon(Icons.email_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    c.email!,
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Spend', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '₹${c.totalSpend.toStringAsFixed(0)}',
                    style: AppTypography.metricMedium
                        .copyWith(color: AppColors.primaryBlue),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Loyalty Points', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '${c.loyaltyPoints} pts',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
                tooltip: 'Delete Customer',
                onPressed: () => _confirmDeleteCustomer(context, c),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context, CustomerModel c) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to remove "${c.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final customerCtrl = context.read<CustomerController>();
              final success = await customerCtrl.deleteCustomer(c.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Customer "${c.name}" removed')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}
