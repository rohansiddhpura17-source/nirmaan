import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

enum StatusType { active, pending, danger, offline }

class StatusIndicator extends StatelessWidget {
  final String label;
  final StatusType status;

  const StatusIndicator({
    super.key,
    required this.label,
    this.status = StatusType.active,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (status) {
      case StatusType.active:
        dotColor = AppColors.successGreen;
        break;
      case StatusType.pending:
        dotColor = AppColors.warningOrange;
        break;
      case StatusType.danger:
        dotColor = AppColors.errorRed;
        break;
      case StatusType.offline:
        dotColor = AppColors.textMuted;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.space6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
