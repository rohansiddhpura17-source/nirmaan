import 'package:flutter/material.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
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
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Grains',
    'Oils',
    'Beverages',
    'Spices',
    'Snacks'
  ];

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
        subtitle: '142 registered products',
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
                  decoration: const InputDecoration(
                    hintText: 'Search products by name, SKU or barcode...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
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

          // Products List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              children: [
                _buildProductTile(
                  name: 'Royal Basmati Rice 5kg',
                  category: 'Grains',
                  sku: 'SKU-RBR-05',
                  barcode: '8901234567890',
                  costPrice: '₹380',
                  sellPrice: '₹460',
                  stock: 4,
                  threshold: 10,
                  badge: 'LOW STOCK',
                  badgeType: BadgeType.warning,
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildProductTile(
                  name: 'Fortune Sunflower Oil 1L',
                  category: 'Oils',
                  sku: 'SKU-FSO-01',
                  barcode: '8901234567891',
                  costPrice: '₹120',
                  sellPrice: '₹145',
                  stock: 2,
                  threshold: 15,
                  badge: 'CRITICAL',
                  badgeType: BadgeType.error,
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildProductTile(
                  name: 'Aashirvaad Shudh Chakki Atta 10kg',
                  category: 'Grains',
                  sku: 'SKU-ATT-10',
                  barcode: '8901234567892',
                  costPrice: '₹340',
                  sellPrice: '₹410',
                  stock: 28,
                  threshold: 12,
                  badge: 'IN STOCK',
                  badgeType: BadgeType.success,
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildProductTile(
                  name: 'Tata Tea Gold 500g',
                  category: 'Beverages',
                  sku: 'SKU-TTG-50',
                  barcode: '8901234567893',
                  costPrice: '₹220',
                  sellPrice: '₹270',
                  stock: 45,
                  threshold: 15,
                  badge: 'IN STOCK',
                  badgeType: BadgeType.success,
                ),
              ],
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
