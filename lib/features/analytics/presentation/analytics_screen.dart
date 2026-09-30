import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedRange = '30D';
  final List<String> _ranges = ['Today', '7D', '30D', '90D', '1Y'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Business Analytics',
        subtitle: 'Historical trends & revenue',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Generating business analytics report (PDF/Excel)...')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Time range filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ranges.map((range) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: NirmaanChip(
                    label: range,
                    isSelected: _selectedRange == range,
                    onSelected: (_) => setState(() => _selectedRange = range),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Overview KPI Grid
          const Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'TOTAL REVENUE',
                  value: '₹6,48,200',
                  trend: '+18.4%',
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.primaryBlue,
                ),
              ),
              SizedBox(width: AppDimensions.space12),
              Expanded(
                child: MetricCard(
                  title: 'NET PROFIT',
                  value: '₹1,89,200',
                  trend: '29.2% margin',
                  icon: Icons.trending_up,
                  iconColor: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'TOTAL ORDERS',
                  value: '1,124',
                  trend: '+112 orders',
                  icon: Icons.shopping_bag_outlined,
                  iconColor: AppColors.secondaryAmber,
                ),
              ),
              SizedBox(width: AppDimensions.space12),
              Expanded(
                child: MetricCard(
                  title: 'AVG ORDER VALUE',
                  value: '₹576',
                  trend: '+₹42',
                  icon: Icons.receipt_long,
                  iconColor: AppColors.primaryBlueLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),

          // Category Sales Breakdown
          const Text('Sales by Category', style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),
          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                _buildCategoryRow('Grains & Flours', '₹2,34,000', 0.36,
                    AppColors.primaryNavy),
                const SizedBox(height: 12),
                _buildCategoryRow(
                    'Edible Oils', '₹1,82,000', 0.28, AppColors.primaryBlue),
                const SizedBox(height: 12),
                _buildCategoryRow('Beverages & Tea', '₹1,16,000', 0.18,
                    AppColors.secondaryAmber),
                const SizedBox(height: 12),
                _buildCategoryRow('Spices & Masalas', '₹78,000', 0.12,
                    AppColors.successGreen),
                const SizedBox(height: 12),
                _buildCategoryRow(
                    'Others', '₹38,200', 0.06, AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Top Products by Revenue
          const Text('Top Performing Products',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),
          NirmaanCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildTopProductTile('1', 'Royal Basmati Rice 5kg',
                    '342 bags sold', '₹1,57,320'),
                const Divider(height: 1),
                _buildTopProductTile('2', 'Fortune Sunflower Oil 1L',
                    '890 packs sold', '₹1,29,050'),
                const Divider(height: 1),
                _buildTopProductTile('3', 'Aashirvaad Chakki Atta 10kg',
                    '280 bags sold', '₹1,14,800'),
                const Divider(height: 1),
                _buildTopProductTile(
                    '4', 'Tata Tea Gold 500g', '310 packs sold', '₹83,700'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
      String name, String amount, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
            Text(amount,
                style: AppTypography.cardTitle
                    .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: AppColors.surfaceSubtle,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildTopProductTile(
      String rank, String title, String count, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(rank,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                Text(count, style: AppTypography.caption),
              ],
            ),
          ),
          Text(amount,
              style: AppTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.primaryNavy)),
        ],
      ),
    );
  }
}
