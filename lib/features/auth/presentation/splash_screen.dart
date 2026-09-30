import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../business_setup/controllers/business_setup_controller.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppEntry();
  }

  Future<void> _checkAppEntry() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final authController = context.read<AuthController>();
    final setupController = context.read<BusinessSetupController>();

    await authController.checkAuthStatus();
    await setupController.loadBusinessProfile();

    if (!mounted) return;

    if (authController.isAuthenticated) {
      if (!setupController.isCompleted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.businessSetup);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nirmaan Emblem / Logo Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    AppColors.primarySurface,
                    AppColors.primaryDark,
                  ],
                ),
                border: Border.all(
                  color: AppColors.primaryBlueLight.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.business_center_rounded,
                      size: 44,
                      color: AppColors.primaryBlueLight,
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.secondaryAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // App Title
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppDimensions.space6),

            // Subtitle
            Text(
              'Business, made intelligent.',
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.textOnNavySecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppDimensions.space40),

            // Subtle loading bar
            const SizedBox(
              width: 48,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.primarySurface,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlueLight),
                minHeight: 2.5,
              ),
            ),
            const SizedBox(height: AppDimensions.space48),

            // Tagline from SRS
            Text(
              AppConstants.appTagline.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
