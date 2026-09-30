import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _lowStockAlerts = true;
  bool _whatsappSync = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Settings & Preferences',
        isDark: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Notifications Settings
          const Text('Alerts & Notifications',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive order and business alerts',
                      style: TextStyle(fontSize: 12)),
                  value: _pushNotifications,
                  activeThumbColor: AppColors.primaryNavy,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Low Stock Alerts',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Notify when inventory hits threshold',
                      style: TextStyle(fontSize: 12)),
                  value: _lowStockAlerts,
                  activeThumbColor: AppColors.primaryNavy,
                  onChanged: (v) => setState(() => _lowStockAlerts = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('WhatsApp Notifications',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Send transaction receipts via WhatsApp',
                      style: TextStyle(fontSize: 12)),
                  value: _whatsappSync,
                  activeThumbColor: AppColors.primaryNavy,
                  onChanged: (v) => setState(() => _whatsappSync = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Business & Localization
          const Text('Localization & Display',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Language',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    DropdownButton<String>(
                      value: _language,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(
                            value: 'Hindi', child: Text('हिन्दी (Hindi)')),
                        DropdownMenuItem(
                            value: 'Gujarati',
                            child: Text('ગુજરાતી (Gujarati)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _language = v);
                      },
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Appearance',
                        style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    const Text('Material 3 Light (Default)',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // System Security & Governance per SRS
          const Text('Security & System Governance',
              style: AppTypography.sectionTitle),
          const SizedBox(height: AppDimensions.space12),

          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSecurityRow(Icons.lock_outline,
                    'Secure Session Lifecycle', 'Active token encrypted'),
                const Divider(height: 20),
                _buildSecurityRow(
                    Icons.history_outlined,
                    'Audit Logging (FR-05)',
                    'All administrative events recorded'),
                const Divider(height: 20),
                _buildSecurityRow(Icons.cloud_done_outlined,
                    'Cloud Synchronization', 'Encrypted TLS 1.3 / HTTPS'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Sign Out Action
          NirmaanCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            onTap: () async {
              await authController.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            child: const Row(
              children: [
                Icon(Icons.logout, color: AppColors.errorRed, size: 20),
                SizedBox(width: 12),
                Text(
                  'Sign Out of Business',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildSecurityRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryNavy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 13)),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
