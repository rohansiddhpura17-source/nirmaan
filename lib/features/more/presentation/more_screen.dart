import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../business_setup/controllers/business_setup_controller.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final setupController = context.watch<BusinessSetupController>();

    final user = authController.currentUser;
    final role = user?.role ?? UserRole.businessOwner;
    final businessProfile = setupController.businessProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'More & Intelligence',
        isDark: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Business Profile Header Card
          NirmaanCard(
            variant: CardVariant.navy,
            padding: const EdgeInsets.all(AppDimensions.space16),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront,
                      color: AppColors.primaryBlueLight, size: 26),
                ),
                const SizedBox(width: AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessProfile?.businessName ?? 'Nirmaan Business',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user?.name ?? 'User'} · ${role.label}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textOnNavySecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Role Switcher for Evaluation (DEVELOPMENT / TEST ONLY)
          if (kDebugMode) ...[
            NirmaanCard(
              padding: const EdgeInsets.all(AppDimensions.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.alertAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEV ONLY',
                          style: AppTypography.badge
                              .copyWith(color: AppColors.alertAmber),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Text(
                        'TEST ROLE-BASED ACCESS',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Wrap(
                    spacing: 8,
                    children: UserRole.values.map((r) {
                      final isCurrent = role == r;
                      return ChoiceChip(
                        label: Text(r.label),
                        selected: isCurrent,
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: isCurrent
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                        onSelected: (_) => authController.switchRoleForDemo(r),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
          ],

          // Intelligence & AI Section
          const Text('Intelligence & Decision Support',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildMenuTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: AppColors.aiPurple,
            title: 'AI Business Coach',
            subtitle: 'Ask questions, get margins & inventory guidance',
            badge: 'GEMINI AI',
            badgeType: BadgeType.ai,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.aiCoach),
          ),
          const SizedBox(height: AppDimensions.space8),

          _buildMenuTile(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.secondaryAmber,
            title: 'Today\'s Business Brief',
            subtitle: 'AI sales, inventory & customer signals',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.todaysBusiness),
          ),
          const SizedBox(height: AppDimensions.space8),

          _buildMenuTile(
            icon: Icons.insights_rounded,
            iconColor: AppColors.primaryBlue,
            title: 'Business Analytics',
            subtitle: 'Historical trends, revenue & top products',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.analytics),
          ),
          const SizedBox(height: AppDimensions.space8),

          _buildMenuTile(
            icon: Icons.health_and_safety_outlined,
            iconColor: AppColors.successGreen,
            title: 'Business Health Score',
            subtitle: 'Comprehensive performance & health indicators',
            badge: '88/100',
            badgeType: BadgeType.success,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.businessHealth),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Operational Modules
          const Text('Store Operations', style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildMenuTile(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primaryNavy,
            title: 'Products Catalog',
            subtitle: 'Manage items, pricing, barcodes, and SKUs',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.products),
          ),
          const SizedBox(height: AppDimensions.space8),

          _buildMenuTile(
            icon: Icons.add_box_outlined,
            iconColor: AppColors.primaryNavy,
            title: 'Add New Product',
            subtitle: 'Register items, cost price, and stock levels',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.addProduct),
          ),
          const SizedBox(height: AppDimensions.space24),

          // System & Settings
          const Text('Preferences & Governance',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          _buildMenuTile(
            icon: Icons.settings_outlined,
            iconColor: AppColors.textSecondary,
            title: 'Settings',
            subtitle: 'Theme, business details, notifications, backup',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
          const SizedBox(height: AppDimensions.space8),

          _buildMenuTile(
            icon: Icons.notifications_none_rounded,
            iconColor: AppColors.textSecondary,
            title: 'Notifications & Alerts',
            subtitle: 'Operational and inventory threshold alerts',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
          const SizedBox(height: AppDimensions.space8),

          _buildMenuTile(
            icon: Icons.logout,
            iconColor: AppColors.errorRed,
            title: 'Sign Out',
            subtitle: 'End secure business session',
            onTap: () async {
              await authController.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    BadgeType? badgeType,
    required VoidCallback onTap,
  }) {
    return NirmaanCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderSm,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    if (badge != null && badgeType != null) ...[
                      const SizedBox(width: 8),
                      NirmaanBadge(label: badge, type: badgeType),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
