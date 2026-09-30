import 'package:flutter/material.dart';
import '../../../core/seed/presentation_seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<Map<String, dynamic>>.from(
      PresentationSeedData.initialNotifications.map(
        (n) => Map<String, dynamic>.from(n),
      ),
    );
  }

  int get _unreadCount =>
      _notifications.where((n) => n['isUnread'] == true).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All alerts marked as read')),
    );
  }

  BadgeType _mapBadgeType(String type) {
    switch (type) {
      case 'inventory':
        return BadgeType.error;
      case 'order':
        return BadgeType.success;
      case 'ai':
        return BadgeType.ai;
      default:
        return BadgeType.info;
    }
  }

  String _mapBadgeLabel(String type) {
    switch (type) {
      case 'inventory':
        return 'STOCK ALERT';
      case 'order':
        return 'SALES EVENT';
      case 'ai':
        return 'AI INSIGHT';
      default:
        return 'SYSTEM ALERT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _unreadCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Notifications & Alerts',
        subtitle: unread > 0 ? '$unread unread alerts' : 'All caught up',
        isDark: true,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyStateView(
              icon: Icons.notifications_none_outlined,
              title: 'No notifications',
              message: 'You have no pending alerts or announcements.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.space16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.space12),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _buildNotificationTile(
                  title: item['title'] as String,
                  message: item['body'] as String,
                  time: item['time'] as String,
                  type: _mapBadgeType(item['type'] as String),
                  typeLabel: _mapBadgeLabel(item['type'] as String),
                  isUnread: item['isUnread'] as bool,
                );
              },
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
