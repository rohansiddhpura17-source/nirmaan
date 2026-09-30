import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Notifications & Alerts',
        subtitle: '3 unread alerts',
        isDark: true,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All alerts marked as read')),
              );
            },
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          _buildNotificationTile(
            title: 'Critical Low Stock: Fortune Sunflower Oil 1L',
            message:
                'Only 2 units remaining in stock. Minimum threshold is 15 units. Reorder immediately.',
            time: '10m ago',
            type: BadgeType.error,
            typeLabel: 'STOCK ALERT',
            isUnread: true,
          ),
          const SizedBox(height: AppDimensions.space12),
          _buildNotificationTile(
            title: 'AI Margin Optimization Insight',
            message:
                'Your gross margin improved by 1.8% today due to higher spice sales. Review recommendations.',
            time: '1h ago',
            type: BadgeType.ai,
            typeLabel: 'AI INSIGHT',
            isUnread: true,
          ),
          const SizedBox(height: AppDimensions.space12),
          _buildNotificationTile(
            title: 'Customer Churn Risk Detected',
            message:
                '5 regular customers have not ordered in over 21 days. Automated broadcast coupon ready.',
            time: '3h ago',
            type: BadgeType.warning,
            typeLabel: 'CUSTOMER ALERT',
            isUnread: true,
          ),
          const SizedBox(height: AppDimensions.space12),
          _buildNotificationTile(
            title: 'Daily Business Backup Successful',
            message:
                'Cloud backup of 142 products, 38 orders and audit logs completed securely.',
            time: 'Yesterday',
            type: BadgeType.success,
            typeLabel: 'SYSTEM BACKUP',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String message,
    required String time,
    required BadgeType type,
    required String typeLabel,
    required bool isUnread,
  }) {
    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NirmaanBadge(label: typeLabel, type: type),
              Row(
                children: [
                  if (isUnread) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(time, style: AppTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(message, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }
}
