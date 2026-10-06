import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/product.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../controllers/product_controller.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Grains & Staples',
    'Edible Oils',
    'Spices & Essentials',
    'Packaged Foods',
    'Beverages',
    'Personal Care',
    'Household',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProductController>();
      if (controller.products.isEmpty) {
        controller.loadProducts();
      }
    });

    _searchController.addListener(() {
      context.read<ProductController>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    final products = controller.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Products Catalog',
        subtitle: '${controller.products.length} registered products',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadProducts(forceRefresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.addProduct),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products by name, SKU or category...',
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
                    onPressed: () => controller.loadProducts(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Product List / Loading / Empty State
          Expanded(
            child: controller.isLoading && controller.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => controller.loadProducts(forceRefresh: true),
                    child: products.isEmpty
                        ? const Center(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: EmptyStateView(
                                icon: Icons.inventory_2_outlined,
                                title: 'No Products Found',
                                message:
                                    'No products match the selected category or search filter.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.all(AppDimensions.space16),
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppDimensions.space12),
                            itemBuilder: (context, index) {
                              final p = products[index];
                              return _buildProductCard(context, p);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'products_fab',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addProduct),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel p) {
    final badge = p.currentStock == 0
        ? 'OUT OF STOCK'
        : p.isLowStock
            ? 'LOW STOCK'
            : 'IN STOCK';
    final badgeType = p.currentStock == 0
        ? BadgeType.error
        : p.isLowStock
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
                    Text(
                      p.name,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.category} · SKU: ${p.sku ?? "N/A"}',
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
                  const Text('Cost Price', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '₹${p.purchasePrice.toStringAsFixed(0)}',
                    style: AppTypography.body,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selling Price', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '₹${p.sellingPrice.toStringAsFixed(0)}',
                    style: AppTypography.metricMedium
                        .copyWith(color: AppColors.primaryBlue),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Available Stock', style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    '${p.currentStock} ${p.unit}',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: p.isLowStock
                          ? AppColors.alertAmber
                          : (p.currentStock == 0
                              ? AppColors.errorRed
                              : AppColors.textPrimary),
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
              Text(
                'Margin: ${p.profitMargin.toStringAsFixed(1)}%',
                style: AppTypography.caption
                    .copyWith(color: AppColors.successGreen, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
                tooltip: 'Archive Product',
                onPressed: () => _confirmArchiveProduct(context, p),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmArchiveProduct(BuildContext context, ProductModel p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Product'),
        content: Text('Are you sure you want to archive "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final productCtrl = context.read<ProductController>();
              final success = await productCtrl.archiveProduct(p.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product "${p.name}" archived successfully')),
                );
              }
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

}
