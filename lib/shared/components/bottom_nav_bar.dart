import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class NirmaanBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NirmaanBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: const Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Sales',
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Inventory',
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Customers',
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
              ),
              _buildNavItem(
                index: 4,
                label: 'More',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final bool isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryNavy : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlueSubtle
                    : Colors.transparent,
                borderRadius: AppDimensions.borderPill,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primaryNavy : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
