import 'package:flutter/material.dart';
import '../../../core/seed/presentation_seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/order.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';

/// ============================================================================
/// Orders & Sales Screen (Figma Frame 2: Sales / Orders)
/// ============================================================================
/// Displays recent transactions, order states, payment types, and order items.
/// In Phase 1, consumes typed OrderModel seed data from PresentationSeedData.
/// In Phase 4, will connect to OrderRepository and Firestore streams.
/// ============================================================================
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
    // Filter orders from PresentationSeedData
    final allOrders = PresentationSeedData.seedOrders;
    final filteredOrders = allOrders.where((order) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Completed') {
        return order.status == OrderStatus.completed;
      }
      if (_selectedFilter == 'Pending') {
        return order.status == OrderStatus.pending;
      }
      if (_selectedFilter == 'UPI') {
        return (order.paymentMethod ?? '').toUpperCase() == 'UPI';
      }
      if (_selectedFilter == 'Cash') {
        return (order.paymentMethod ?? '').toUpperCase() == 'CASH';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Sales & Orders',
        subtitle: '${allOrders.length} orders loaded',
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

          // Orders List or Empty State
          Expanded(
            child: filteredOrders.isEmpty
                ? const EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Orders Found',
                    message: 'No orders match the selected filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.space12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final itemsSummary = order.items
                          .map((i) => '${i.productName} (x${i.quantity})')
                          .join(', ');
                      return _buildOrderCard(
                        orderId: order.orderNumber,
                        customer: order.customerName ?? 'Walk-in Customer',
                        phone: order.customerPhone ?? 'Walk-in Customer',
                        items: itemsSummary.isEmpty
                            ? 'General Items'
                            : itemsSummary,
                        amount: '₹${order.totalAmount.toStringAsFixed(0)}',
                        status: order.status.name.toUpperCase(),
                        paymentMethod: order.paymentMethod ?? 'UPI',
                        date: 'Today, ${_formatTime(order.createdAt)}',
                      );
                    },
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

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
