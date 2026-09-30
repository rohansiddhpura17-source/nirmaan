import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

class BusinessHealthScreen extends StatelessWidget {
  const BusinessHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Business Health Score',
        subtitle: 'Composite operating vitality index',
        isDark: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Hero Health Score Card
          NirmaanCard(
            variant: CardVariant.navy,
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.primaryBlueLight, width: 6),
                    color: AppColors.primarySurface,
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '88',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '/ 100',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textOnNavySecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                const Text(
                  'Strong Operating Vitality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your store is in the top 15% of regional retailers in its category.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textOnNavySecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // 4 Core Health Pillars
          const Text('Health Score Components',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildPillarCard(
            title: 'Sales Growth & Velocity',
            score: '92/100',
            status: 'Excellent',
            badgeType: BadgeType.success,
            icon: Icons.trending_up,
            color: AppColors.successGreen,
            description:
                'Steady 14% week-on-week revenue growth with strong conversion.',
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildPillarCard(
            title: 'Inventory Turnover & Accuracy',
            score: '84/100',
            status: 'Good',
            badgeType: BadgeType.info,
            icon: Icons.inventory_2_outlined,
            color: AppColors.primaryBlue,
            description:
                'Stock holding cost is optimal, but 2 fast movers need restock.',
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildPillarCard(
            title: 'Customer Retention & Loyalty',
            score: '86/100',
            status: 'Good',
            badgeType: BadgeType.info,
            icon: Icons.repeat,
            color: AppColors.secondaryAmber,
            description:
                '68% repeat purchase rate. 12 patrons require re-engagement.',
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildPillarCard(
            title: 'Profit Margin Stability',
            score: '90/100',
            status: 'Excellent',
            badgeType: BadgeType.success,
            icon: Icons.pie_chart_outline,
            color: AppColors.successGreen,
            description:
                'Net margin healthy at 29.2%. Consistent pricing discipline.',
          ),
          const SizedBox(height: AppDimensions.space24),

          // Recommendations
          const Text('Health Improvement Guidance',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            variant: CardVariant.aiSpecial,
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.aiPurple, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Score: 95/100',
                          style: AppTypography.cardTitle
                              .copyWith(color: AppColors.aiPurple)),
                      const SizedBox(height: 4),
                      const Text(
                        'Restocking your top 2 low-stock SKUs before tomorrow and re-engaging your 12 dormant patrons can elevate your composite health score to 95.',
                        style: AppTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required String title,
    required String score,
    required String status,
    required BadgeType badgeType,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(title,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                ],
              ),
              NirmaanBadge(label: score, type: badgeType),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }
}
