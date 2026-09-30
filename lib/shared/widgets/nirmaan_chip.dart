import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

class NirmaanChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const NirmaanChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      avatar: icon != null
          ? Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            )
          : null,
      backgroundColor: AppColors.surfaceWhite,
      selectedColor: AppColors.primaryNavy,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderPill,
        side: BorderSide(
          color: isSelected ? AppColors.primaryNavy : AppColors.surfaceBorder,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space2,
      ),
      onSelected: onSelected,
    );
  }
}
