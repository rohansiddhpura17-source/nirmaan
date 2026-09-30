import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import 'nirmaan_badge.dart';
import 'nirmaan_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool isTrendPositive;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.isTrendPositive = true,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NirmaanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space6),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryBlue)
                        .withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderSm,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: iconColor ?? AppColors.primaryBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            value,
            style: AppTypography.metricLarge,
          ),
          if (trend != null || subtitle != null) ...[
            const SizedBox(height: AppDimensions.space8),
            Row(
              children: [
                if (trend != null) ...[
                  NirmaanBadge(
                    label: trend!,
                    type: isTrendPositive ? BadgeType.success : BadgeType.error,
                    icon: isTrendPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
