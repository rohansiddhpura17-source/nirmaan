import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/inventory.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../controllers/inventory_controller.dart';
import 'adjust_stock_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  final List<String> _statusFilters = ['ALL', 'LOW_STOCK', 'OUT_OF_STOCK', 'IN_STOCK'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<InventoryController>();
      if (controller.items.isEmpty) {
        controller.loadInventory();
      }
    });

    _searchController.addListener(() {
      context.read<InventoryController>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAdjustDialog(BuildContext context, {String? productId}) async {
    final controller = context.read<InventoryController>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AdjustStockDialog(
        items: controller.items,
        initialProductId: productId,
      ),
    );

    if (result == true && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Stock adjustment applied successfully!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    final summary = controller.summary;
    final items = controller.filteredItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Inventory Management',
        subtitle: '${summary.totalProducts} items · ${summary.totalStockUnits} units tracked',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadInventory(forceRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Adjust Stock',
            onPressed: () => _openAdjustDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // KPI Summary Row
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'TOTAL VALUATION',
                        value: '₹${summary.inventoryValuation.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: MetricCard(
                        title: 'LOW STOCK',
                        value: '${summary.lowStockCount} Items',
                        trend: summary.lowStockCount > 0 ? 'Action required' : 'Stock healthy',
                        isTrendPositive: summary.lowStockCount == 0,
                        icon: Icons.warning_amber_rounded,
                        iconColor: summary.lowStockCount > 0 ? AppColors.alertAmber : AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items by name, SKU or category...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusFilters.map((s) {
                      final label = s.replaceAll('_', ' ');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: NirmaanChip(
                          label: label,
                          isSelected: controller.selectedStatus == s,
                          onSelected: (_) => controller.setSelectedStatus(s),
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
                    onPressed: () => controller.loadInventory(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Inventory Items List / Loading / Empty State
          Expanded(
            child: controller.isLoading && controller.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => controller.loadInventory(forceRefresh: true),
                    child: items.isEmpty
                        ? const Center(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: EmptyStateView(
                                icon: Icons.inventory_2_outlined,
                                title: 'No Inventory Items Found',
                                message:
                                    'No stock matches your search filter or inventory is empty.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppDimensions.space16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppDimensions.space12),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _buildInventoryCard(context, item);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'inventory_fab',
        onPressed: () => _openAdjustDialog(context),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.tune),
        label: const Text('Adjust Stock'),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItemModel item) {
    final badge = item.isOutOfStock
        ? 'OUT OF STOCK'
        : item.isLowStock
            ? 'LOW STOCK'
            : 'IN STOCK';
    final badgeType = item.isOutOfStock
        ? BadgeType.error
        : item.isLowStock
            ? BadgeType.warning
            : BadgeType.success;

    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      '${item.category} · SKU: ${item.sku ?? "N/A"}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              NirmaanBadge(label: badge, type: badgeType),
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
                  const Text('Current Stock', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '${item.currentStock} ${item.unit}',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.isOutOfStock
                          ? AppColors.errorRed
                          : (item.isLowStock
                              ? AppColors.alertAmber
                              : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reorder Level', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '${item.minStockThreshold} ${item.unit}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Valuation', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '₹${item.valuation.toStringAsFixed(0)}',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),

            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Adjust'),
                onPressed: () => _openAdjustDialog(context, productId: item.productId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
