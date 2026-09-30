import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class NirmaanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showNotificationAction;
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotifications;
  final bool isDark;

  const NirmaanAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showNotificationAction = false,
    this.onNotificationTap,
    this.hasUnreadNotifications = false,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.primaryNavy : AppColors.surfaceWhite;
    final fgColor = isDark ? AppColors.textOnNavy : AppColors.textPrimary;
    final subColor =
        isDark ? AppColors.textOnNavySecondary : AppColors.textSecondary;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.cardTitle.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(color: subColor),
            ),
          ],
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showNotificationAction)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: fgColor,
                ),
                onPressed: onNotificationTap,
              ),
              if (hasUnreadNotifications)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
