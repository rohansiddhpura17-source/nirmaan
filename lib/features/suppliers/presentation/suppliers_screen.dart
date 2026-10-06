import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/supplier.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../controllers/supplier_controller.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'General',
    'FMCG Wholesale',
    'Packaging',
    'Grains & Staples',
    'Beverages',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<SupplierController>();
      if (controller.suppliers.isEmpty) {
        controller.loadSuppliers();
      }
    });

    _searchController.addListener(() {
      context.read<SupplierController>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupplierController>();
    final suppliers = controller.filteredSuppliers;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Suppliers Directory',
        subtitle: '${controller.suppliers.length} active suppliers',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadSuppliers(forceRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.addSupplier),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search suppliers by name or phone...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textMuted),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: NirmaanChip(
                          label: cat,
                          isSelected: controller.selectedCategory == cat,
                          onSelected: (_) =>
                              controller.setSelectedCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                    onPressed: () => controller.loadSuppliers(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Suppliers List / Loading / Empty State
          Expanded(
            child: controller.isLoading && controller.suppliers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => controller.loadSuppliers(forceRefresh: true),
                    child: suppliers.isEmpty
                        ? const Center(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: EmptyStateView(
                                icon: Icons.local_shipping_outlined,
                                title: 'No Suppliers Found',
                                message:
                                    'No suppliers registered. Add a supplier to manage vendor accounts.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.all(AppDimensions.space16),
                            itemCount: suppliers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppDimensions.space12),
                            itemBuilder: (context, index) {
                              final s = suppliers[index];
                              return _buildSupplierCard(context, s);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'suppliers_fab',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addSupplier),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, SupplierModel s) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.name, style: AppTypography.cardTitle),
              ),
              NirmaanBadge(
                label: s.status,
                type: s.isActive ? BadgeType.success : BadgeType.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Category: ${s.category}', style: AppTypography.caption),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(s.phone, style: AppTypography.body),
              if (s.email != null && s.email!.isNotEmpty) ...[
                const SizedBox(width: 16),
                const Icon(Icons.email_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.email!,
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (s.address != null && s.address!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(s.address!, style: AppTypography.caption),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
                tooltip: 'Delete Supplier',
                onPressed: () => _confirmDeleteSupplier(context, s),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSupplier(BuildContext context, SupplierModel s) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to remove "${s.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final supplierCtrl = context.read<SupplierController>();
              final success = await supplierCtrl.deleteSupplier(s.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Supplier "${s.name}" removed')),
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
