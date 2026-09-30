import 'package:flutter/material.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/seed/presentation_seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Grains & Staples',
    'Edible Oils',
    'Spices & Essentials',
  ];

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Products Catalog',
        subtitle:
            '${PresentationSeedData.seedProducts.length} registered products',
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
                    hintText: 'Search products by name, SKU or category...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
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
                          isSelected: _selectedCategory == cat,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products List or Empty State
          Expanded(
            child: Builder(
              builder: (context) {
                final allProducts = PresentationSeedData.seedProducts;
                final filtered = allProducts.where((p) {
                  final matchesCat = _selectedCategory == 'All' ||
                      p.category.toLowerCase() ==
                          _selectedCategory.toLowerCase();
                  final matchesQuery = _searchQuery.isEmpty ||
                      p.name.toLowerCase().contains(_searchQuery) ||
                      (p.sku != null &&
                          p.sku!.toLowerCase().contains(_searchQuery)) ||
                      p.category.toLowerCase().contains(_searchQuery);
                  return matchesCat && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Products Found',
                    message:
                        'No products match the selected category or search filter.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.space12),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
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

                    return _buildProductTile(
                      name: p.name,
                      category: p.category,
                      sku: p.sku ?? 'N/A',
                      barcode: p.barcode ?? 'N/A',
                      costPrice: '₹${p.purchasePrice.toStringAsFixed(0)}',
                      sellPrice: '₹${p.sellingPrice.toStringAsFixed(0)}',
                      stock: p.currentStock,
                      threshold: p.minStockThreshold,
                      badge: badge,
                      badgeType: badgeType,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addProduct),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildProductTile({
    required String name,
    required String category,
    required String sku,
    required String barcode,
    required String costPrice,
    required String sellPrice,
    required int stock,
    required int threshold,
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
              Text(category.toUpperCase(), style: AppTypography.caption),
              NirmaanBadge(label: badge, type: badgeType),
            ],
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(name, style: AppTypography.cardTitle),
          Text('SKU: $sku · Barcode: $barcode', style: AppTypography.caption),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cost / Sell', style: AppTypography.caption),
                  Text('$costPrice / $sellPrice',
                      style: AppTypography.cardTitle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Stock / Min', style: AppTypography.caption),
                  Text('$stock / $threshold units',
                      style: AppTypography.cardTitle
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
