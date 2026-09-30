import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

enum CardVariant { standard, elevated, navy, aiSpecial }

class NirmaanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final CardVariant variant;
  final double? width;
  final double? height;

  const NirmaanCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = CardVariant.standard,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Border? border;
    List<BoxShadow> shadows = [];

    switch (variant) {
      case CardVariant.standard:
        backgroundColor = AppColors.surfaceWhite;
        border = Border.all(color: AppColors.surfaceBorder, width: 1.0);
        shadows = AppDimensions.shadowSubtle;
        break;
      case CardVariant.elevated:
        backgroundColor = AppColors.surfaceWhite;
        border = Border.all(color: AppColors.surfaceBorder, width: 1.0);
        shadows = AppDimensions.shadowCard;
        break;
      case CardVariant.navy:
        backgroundColor = AppColors.primaryNavy;
        shadows = AppDimensions.shadowCard;
        break;
      case CardVariant.aiSpecial:
        backgroundColor = AppColors.surfaceWhite;
        border = Border.all(
            color: AppColors.aiPurple.withValues(alpha: 0.3), width: 1.5);
        shadows = [
          BoxShadow(
            color: AppColors.aiPurple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
        break;
    }

    final cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimensions.borderLg,
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.borderLg,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
