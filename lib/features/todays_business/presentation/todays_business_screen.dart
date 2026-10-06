import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../ai_coach/controllers/ai_controller.dart';

class TodaysBusinessScreen extends StatefulWidget {
  const TodaysBusinessScreen({super.key});

  @override
  State<TodaysBusinessScreen> createState() => _TodaysBusinessScreenState();
}

class _TodaysBusinessScreenState extends State<TodaysBusinessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AiController>().loadDailyBrief();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiController = context.watch<AiController>();
    final brief = aiController.dailyBrief;
    final isLoading = aiController.isLoadingBrief;
    final errorMessage = aiController.briefErrorMessage;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Today\'s Business Brief',
        subtitle: 'Daily AI intelligence overview',
        isDark: true,
      ),
      body: _buildBody(context, aiController, brief, isLoading, errorMessage),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AiController controller,
    AiDailyBrief? brief,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading && brief == null) {
      return const LoadingIndicator(
        message: 'Synthesizing live store signals & AI brief...',
      );
    }

    if (errorMessage != null && brief == null) {
      return ErrorStateView(
        title: 'Unable to Load Daily Brief',
        message: errorMessage,
        onRetry: () => controller.loadDailyBrief(forceRefresh: true),
      );
    }

    if (brief == null) {
      return const Center(
        child: Text('No daily briefing data available.'),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryNavy,
      onRefresh: () => controller.loadDailyBrief(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Executive Summary Card
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
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.aiPurple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Executive Daily Briefing',
                            style: AppTypography.cardTitle.copyWith(fontSize: 16),
                          ),
                          Text(
                            '${brief.businessName} · Live store operational intelligence',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    NirmaanBadge(
                      label: brief.confidence,
                      type: BadgeType.ai,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  brief.summary,
                  style: AppTypography.body.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Key Operational Observations
          if (brief.observations.isNotEmpty) ...[
            const Text(
              'Key Operational Observations',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: AppDimensions.space12),
            ...brief.observations.map(
              (obs) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSignalCard(
                  icon: Icons.insights_rounded,
                  color: AppColors.primaryBlue,
                  title: 'Operational Observation',
                  description: obs,
                  badge: 'RECORD',
                  badgeType: BadgeType.info,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],

          // Opportunities
          if (brief.opportunities.isNotEmpty) ...[
            const Text(
              'Growth Opportunities',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: AppDimensions.space12),
            ...brief.opportunities.map(
              (opp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSignalCard(
                  icon: Icons.trending_up,
                  color: AppColors.successGreen,
                  title: 'Growth Signal',
                  description: opp,
                  badge: 'POTENTIAL',
                  badgeType: BadgeType.success,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],

          // Warnings & Attention Signals
          if (brief.warnings.isNotEmpty) ...[
            const Text(
              'Attention & Operational Alerts',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: AppDimensions.space12),
            ...brief.warnings.map(
              (warn) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSignalCard(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.alertAmber,
                  title: 'Attention Required',
                  description: warn,
                  badge: 'ACTIONABLE',
                  badgeType: BadgeType.warning,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],

          // Recommended Actions
          if (brief.recommendations.isNotEmpty) ...[
            const Text(
              'Recommended Actions for Today',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: AppDimensions.space12),
            NirmaanCard(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                children: List.generate(brief.recommendations.length, (idx) {
                  final rec = brief.recommendations[idx];
                  final isLast = idx == brief.recommendations.length - 1;
                  return Column(
                    children: [
                      _buildActionItem(context, idx + 1, rec),
                      if (!isLast) const Divider(height: 20),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
          ],

          // Safe Disclaimer Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: AppDimensions.borderSm,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    brief.disclaimer,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
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
                child: Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
              ),
              NirmaanBadge(label: badge, type: badgeType),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    int number,
    AiRecommendation rec,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${rec.category}: ${rec.title}',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              if (rec.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(rec.description, style: AppTypography.caption),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            rec.actionLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          onPressed: () {
            // User explicitly navigates to review and take action
            Navigator.of(context).pushNamed(rec.route);
          },
        ),
      ],
    );
  }
}
