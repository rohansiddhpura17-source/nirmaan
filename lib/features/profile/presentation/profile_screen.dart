import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../business_setup/controllers/business_setup_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final setupController = context.watch<BusinessSetupController>();

    final user = authController.currentUser;
    final role = user?.role ?? UserRole.businessOwner;
    final profile = setupController.businessProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Business & Account Profile',
        isDark: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // User Card
          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNavy,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name[0].toUpperCase()
                          : 'N',
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Business User',
                          style: AppTypography.cardTitle),
                      Text(user?.email ?? 'user@nirmaan.com',
                          style: AppTypography.caption),
                      const SizedBox(height: 6),
                      NirmaanBadge(label: role.label, type: BadgeType.info),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Business Details
          const Text('Store & Business Details',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                _buildInfoRow('Store Name',
                    profile?.businessName ?? 'Nirmaan General Store'),
                const Divider(height: 20),
                _buildInfoRow(
                    'Category', profile?.category ?? 'Grocery & FMCG'),
                const Divider(height: 20),
                _buildInfoRow(
                    'WhatsApp / Phone', profile?.phone ?? '+91 98765 43210'),
                const Divider(height: 20),
                _buildInfoRow('Store Location',
                    profile?.address ?? 'Shop 14, Market Road, Ahmedabad'),
                const Divider(height: 20),
                _buildInfoRow('Default Currency', '₹ (INR - Indian Rupee)'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Operational Access Summary per SRS
          const Text('Role Permissions (SRS)',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                _buildPermissionRow('Business Intelligence & Forecasts',
                    role.canAccessBusinessIntelligence),
                const Divider(height: 16),
                _buildPermissionRow(
                    'Manage Products & Inventory', role.canManageProducts),
                const Divider(height: 16),
                _buildPermissionRow(
                    'Record & Process Orders', role.canProcessOrders),
                const Divider(height: 16),
                _buildPermissionRow(
                    'Run Business Twin Simulations', role.canRunBusinessTwin),
                const Divider(height: 16),
                _buildPermissionRow('System Governance & Backups',
                    role.canAccessSystemGovernance),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPermissionRow(String label, bool isAllowed) {
    return Row(
      children: [
        Icon(
          isAllowed ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isAllowed ? AppColors.successGreen : AppColors.errorRed,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTypography.bodySecondary)),
        Text(
          isAllowed ? 'Allowed' : 'Restricted',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color:
                isAllowed ? AppColors.successGreenDark : AppColors.errorRedDark,
          ),
        ),
      ],
    );
  }
}
