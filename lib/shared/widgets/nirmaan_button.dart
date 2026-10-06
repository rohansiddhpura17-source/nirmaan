import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, outline, danger, text }

class NirmaanButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const NirmaanButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.primaryNavy;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.primaryBlue;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primaryNavy;
        borderSide =
            const BorderSide(color: AppColors.surfaceBorder, width: 1.2);
        break;
      case ButtonVariant.danger:
        backgroundColor = AppColors.errorRed;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primaryBlue;
        break;
    }

    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: AppColors.surfaceSubtle,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          side: borderSide,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderMd,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: variant == ButtonVariant.outline ||
                          variant == ButtonVariant.text
                      ? AppColors.primaryNavy
                      : Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foregroundColor),
                    const SizedBox(width: AppDimensions.space8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.button.copyWith(
                        color: isDisabled ? AppColors.textMuted : foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
