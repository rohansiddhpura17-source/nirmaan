import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import 'nirmaan_button.dart';

class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    this.title = 'Something went wrong',
    this.message =
        'Unable to load data. Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: const BoxDecoration(
                color: AppColors.errorRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              title,
              style: AppTypography.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              message,
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space20),
              NirmaanButton(
                label: 'Try Again',
                onPressed: onRetry,
                variant: ButtonVariant.primary,
                icon: Icons.refresh,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
