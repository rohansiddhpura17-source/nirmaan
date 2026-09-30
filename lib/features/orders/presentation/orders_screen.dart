import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Pending', 'UPI', 'Cash'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Sales & Orders',
        subtitle: '38 orders today (₹28,450)',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: NirmaanChip(
                      label: filter,
                      isSelected: _selectedFilter == filter,
                      onSelected: (_) =>
                          setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              children: [
                _buildOrderCard(
                  orderId: 'ORD-1094',
                  customer: 'Suresh Kumar',
                  phone: '+91 98234 11223',
                  items: 'Basmati Rice (5kg), Sunflower Oil (1L), Atta (10kg)',
                  amount: '₹1,240',
                  status: 'COMPLETED',
                  paymentMethod: 'UPI',
                  date: 'Today, 2:45 PM',
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildOrderCard(
                  orderId: 'ORD-1093',
                  customer: 'Anjali Sharma',
                  phone: '+91 98451 98765',
                  items: 'Dairy Milk Silk (x2), Parle-G Family Pack',
                  amount: '₹680',
                  status: 'COMPLETED',
                  paymentMethod: 'CASH',
                  date: 'Today, 2:15 PM',
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildOrderCard(
                  orderId: 'ORD-1092',
                  customer: 'Pooja Verma',
                  phone: '+91 97123 45678',
                  items: 'Sugar (5kg), Tea 500g, Spices Pack, Dry Fruits',
                  amount: '₹3,450',
                  status: 'COMPLETED',
                  paymentMethod: 'UPI',
                  date: 'Today, 1:30 PM',
                ),
                const SizedBox(height: AppDimensions.space12),
                _buildOrderCard(
                  orderId: 'ORD-1091',
                  customer: 'Rajesh Bhai',
                  phone: '+91 99222 33445',
                  items: 'Soap 4-pack, Detergent 2kg',
                  amount: '₹420',
                  status: 'PENDING',
                  paymentMethod: 'CREDIT',
                  date: 'Today, 12:10 PM',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String customer,
    required String phone,
    required String items,
    required String amount,
    required String status,
    required String paymentMethod,
    required String date,
  }) {
    final isCompleted = status == 'COMPLETED';

    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#$orderId',
                  style: AppTypography.cardTitle
                      .copyWith(color: AppColors.primaryBlue)),
              NirmaanBadge(
                label: status,
                type: isCompleted ? BadgeType.success : BadgeType.warning,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(customer, style: AppTypography.cardTitle),
          Text(phone, style: AppTypography.caption),
          const SizedBox(height: AppDimensions.space8),
          Text(
            items,
            style: AppTypography.bodySecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      paymentMethod,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(date, style: AppTypography.caption),
                ],
              ),
              Text(
                amount,
                style: AppTypography.metricMedium
                    .copyWith(color: AppColors.primaryNavy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
