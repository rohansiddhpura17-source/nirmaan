import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

enum BadgeType { success, warning, error, info, ai, neutral }

class NirmaanBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const NirmaanBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successGreenLight;
        fg = AppColors.successGreenDark;
        break;
      case BadgeType.warning:
        bg = AppColors.warningOrangeLight;
        fg = AppColors.warningOrange;
        break;
      case BadgeType.error:
        bg = AppColors.errorRedLight;
        fg = AppColors.errorRedDark;
        break;
      case BadgeType.info:
        bg = AppColors.primaryBlueSubtle;
        fg = AppColors.primaryBlueDark;
        break;
      case BadgeType.ai:
        bg = AppColors.aiPurpleLight;
        fg = AppColors.aiPurple;
        break;
      case BadgeType.neutral:
        bg = AppColors.surfaceSubtle;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimensions.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppDimensions.space4),
          ],
          Text(
            label,
            style: AppTypography.badge.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
