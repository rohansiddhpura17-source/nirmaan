import 'package:flutter/material.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
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
        title: 'Inventory Management',
        subtitle: '142 SKU items tracked',
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
          const Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'TOTAL VALUE',
                  value: '₹3,42,800',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.primaryBlue,
                ),
              ),
              SizedBox(width: AppDimensions.space12),
              Expanded(
                child: MetricCard(
                  title: 'LOW STOCK',
                  value: '3 Items',
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
              hintText: 'Search SKU, name, or barcode...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.textMuted),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Stock Items List
          const Text('Stock Status', style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildStockItemCard(
            name: 'Royal Basmati Rice 5kg',
            sku: 'SKU-RBR-05',
            category: 'Grains & Flours',
            stock: 4,
            threshold: 10,
            purchasePrice: '₹380',
            sellingPrice: '₹460',
            badge: 'LOW STOCK',
            badgeType: BadgeType.warning,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildStockItemCard(
            name: 'Fortune Sunflower Oil 1L',
            sku: 'SKU-FSO-01',
            category: 'Edible Oils',
            stock: 2,
            threshold: 15,
            purchasePrice: '₹120',
            sellingPrice: '₹145',
            badge: 'CRITICAL',
            badgeType: BadgeType.error,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildStockItemCard(
            name: 'Aashirvaad Shudh Chakki Atta 10kg',
            sku: 'SKU-ATT-10',
            category: 'Grains & Flours',
            stock: 28,
            threshold: 12,
            purchasePrice: '₹340',
            sellingPrice: '₹410',
            badge: 'HEALTHY',
            badgeType: BadgeType.success,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildStockItemCard(
            name: 'Tata Tea Gold 500g',
            sku: 'SKU-TTG-50',
            category: 'Beverages',
            stock: 45,
            threshold: 15,
            purchasePrice: '₹220',
            sellingPrice: '₹270',
            badge: 'FAST MOVING',
            badgeType: BadgeType.info,
          ),
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
