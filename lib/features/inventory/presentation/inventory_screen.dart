import 'package:flutter/material.dart';
import '../../../core/routing/app_routes.dart';
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
/// Inventory Management Screen (Figma Frame 3: Inventory)
/// ============================================================================
/// Displays inventory stock counts, reorder thresholds, low-stock warnings,
/// and live search. Uses ProductModel seed data from PresentationSeedData.
/// ============================================================================
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
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
    final allProducts = PresentationSeedData.seedProducts;
    final filteredProducts = allProducts.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery) ||
          (p.sku != null && p.sku!.toLowerCase().contains(_searchQuery)) ||
          p.category.toLowerCase().contains(_searchQuery);
    }).toList();

    final totalInventoryValue = allProducts.fold<double>(
      0.0,
      (sum, p) => sum + (p.currentStock * p.purchasePrice),
    );
    final lowStockCount = allProducts.where((p) => p.isLowStock).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Inventory Management',
        subtitle: '${allProducts.length} SKU items tracked',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.addProduct),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // KPI Summary Row
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'TOTAL VALUE',
                  value: '₹${totalInventoryValue.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: MetricCard(
                  title: 'LOW STOCK',
                  value: '$lowStockCount Items',
                  trend: 'Reorder needed',
                  isTrendPositive: false,
                  icon: Icons.warning_amber_rounded,
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
              hintText: 'Search SKU, name, or category...',
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

          // Stock Items List
          const Text('Stock Status', style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          if (filteredProducts.isEmpty)
            const EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Found',
              message: 'No inventory matches your search filter.',
            )
          else
            ...filteredProducts.map((product) {
              final badgeLabel = product.currentStock == 0
                  ? 'OUT OF STOCK'
                  : product.isLowStock
                      ? 'LOW STOCK'
                      : 'HEALTHY';
              final badgeType = product.currentStock == 0
                  ? BadgeType.error
                  : product.isLowStock
                      ? BadgeType.warning
                      : BadgeType.success;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                child: _buildStockItemCard(
                  name: product.name,
                  sku: product.sku ?? 'N/A',
                  category: product.category,
                  stock: product.currentStock,
                  threshold: product.minStockThreshold,
                  purchasePrice: '₹${product.purchasePrice.toStringAsFixed(0)}',
                  sellingPrice: '₹${product.sellingPrice.toStringAsFixed(0)}',
                  badge: badgeLabel,
                  badgeType: badgeType,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStockItemCard({
    required String name,
    required String sku,
    required String category,
    required int stock,
    required int threshold,
    required String purchasePrice,
    required String sellingPrice,
    required String badge,
    required BadgeType badgeType,
  }) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.toUpperCase(),
                  style: AppTypography.caption.copyWith(letterSpacing: 0.5)),
              NirmaanBadge(label: badge, type: badgeType),
            ],
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(name, style: AppTypography.cardTitle),
          Text('SKU: $sku', style: AppTypography.caption),
          const SizedBox(height: AppDimensions.space12),

          // Stock count & Reorder Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('In Stock', style: AppTypography.caption),
                  Text('$stock units',
                      style: AppTypography.cardTitle
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Min Threshold', style: AppTypography.caption),
                  Text('$threshold units', style: AppTypography.cardTitle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Sell Price', style: AppTypography.caption),
                  Text(sellingPrice,
                      style: AppTypography.cardTitle
                          .copyWith(color: AppColors.primaryBlue)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
