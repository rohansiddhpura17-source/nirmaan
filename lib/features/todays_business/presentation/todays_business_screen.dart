import 'package:flutter/material.dart';
import '../../../core/seed/presentation_seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

class TodaysBusinessScreen extends StatelessWidget {
  const TodaysBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const recommendations = PresentationSeedData.dailyRecommendations;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Today\'s Business Brief',
        subtitle: 'Daily AI intelligence overview',
        isDark: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // AI Brief Header
          NirmaanCard(
            variant: CardVariant.aiSpecial,
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.aiPurpleLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppColors.aiPurple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Morning Executive Summary',
                              style: AppTypography.cardTitle),
                          Text('Generated at 8:00 AM based on live store data',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Your store is exhibiting strong momentum this week. Total sales are +${PresentationSeedData.salesGrowthPercent}% higher than last week, driven primarily by household staples and edible oils. Footfall conversion reached 78%.',
                  style: AppTypography.body.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Operational Signals
          const Text('Key Operational Signals',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildSignalCard(
            icon: Icons.trending_up,
            color: AppColors.successGreen,
            title: 'Sales & Margin Signal',
            description:
                'Today\'s sales tracking ₹${PresentationSeedData.todaySales.toStringAsFixed(0)}. Gross margin steady at 29.4%.',
            badge: 'POSITIVE',
            badgeType: BadgeType.success,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildSignalCard(
            icon: Icons.inventory_2_outlined,
            color: AppColors.warningOrange,
            title: 'Inventory Stock Signal',
            description:
                '${PresentationSeedData.lowStockCount} items approaching depletion threshold. Wholesale reorder advised before 6 PM.',
            badge: 'ATTENTION',
            badgeType: BadgeType.warning,
          ),
          const SizedBox(height: AppDimensions.space12),

          _buildSignalCard(
            icon: Icons.people_outline,
            color: AppColors.primaryBlue,
            title: 'Customer Engagement Signal',
            description:
                '12 inactive patrons flagged for re-engagement via WhatsApp coupon to protect store retention.',
            badge: 'ACTIONABLE',
            badgeType: BadgeType.info,
          ),
          const SizedBox(height: AppDimensions.space20),

          // Recommended Action Items
          const Text('Recommended Actions for Today',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: List.generate(recommendations.length, (idx) {
                final rec = recommendations[idx];
                final isLast = idx == recommendations.length - 1;
                return Column(
                  children: [
                    _buildActionItem(
                      number: '${idx + 1}',
                      text:
                          '${rec['category']}: ${rec['text']} (${rec['impact']})',
                    ),
                    if (!isLast) const Divider(height: 20),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildSignalCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String badge,
    required BadgeType badgeType,
  }) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderSm,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(title,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14))),
              NirmaanBadge(label: badge, type: badgeType),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }

  Widget _buildActionItem({required String number, required String text}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTypography.body),
        ),
      ],
    );
  }
}
