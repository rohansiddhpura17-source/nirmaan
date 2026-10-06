import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/seed/presentation_seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/order.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../controllers/order_controller.dart';

/// ============================================================================
/// Orders & Sales Screen (Figma Frame 2: Sales / Orders)
/// ============================================================================
/// Displays real transactions, order states, payment types, and order items.
/// Consumes OrderController with fallback to seed data.
/// ============================================================================
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Completed',
    'Pending',
    'Cancelled',
    'UPI',
    'Cash',
  ];
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<OrderController>();
      if (controller.orders.isEmpty) {
        controller.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderController = context.watch<OrderController>();
    final rawOrders = orderController.orders.isNotEmpty
        ? orderController.orders
        : PresentationSeedData.seedOrders;

    final filteredOrders = rawOrders.where((order) {
      if (_selectedFilter == 'Completed' &&
          order.status != OrderStatus.completed) {
        return false;
      }
      if (_selectedFilter == 'Pending' && order.status != OrderStatus.pending) {
        return false;
      }
      if (_selectedFilter == 'Cancelled' &&
          order.status != OrderStatus.cancelled) {
        return false;
      }
      if (_selectedFilter == 'UPI' &&
          (order.paymentMethod ?? '').toUpperCase() != 'UPI') {
        return false;
      }
      if (_selectedFilter == 'Cash' &&
          (order.paymentMethod ?? '').toUpperCase() != 'CASH') {
        return false;
      }

      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.trim().toLowerCase();
        final matchesId = order.orderNumber.toLowerCase().contains(query);
        final matchesName =
            (order.customerName ?? '').toLowerCase().contains(query);
        final matchesPhone = (order.customerPhone ?? '').contains(query);
        if (!matchesId && !matchesName && !matchesPhone) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'Sales & Orders',
        subtitle: '${filteredOrders.length} orders displayed',
        isDark: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchOpen ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => orderController.loadOrders(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchOpen)
            Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search order number or customer...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _searchController.clear());
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

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
            child: orderController.isLoading && rawOrders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        orderController.loadOrders(forceRefresh: true),
                    child: filteredOrders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              EmptyStateView(
                                icon: Icons.receipt_long_outlined,
                                title: 'No Orders Found',
                                message:
                                    'No orders match the selected filters or query.',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppDimensions.space16),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppDimensions.space12),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return _buildOrderCard(context, order);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'orders_fab',
        onPressed: () async {
          final orderController = context.read<OrderController>();
          await Navigator.of(context).pushNamed(AppRoutes.createOrder);
          if (mounted) {
            unawaited(orderController.loadOrders(forceRefresh: true));
          }
        },
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final isCompleted = order.status == OrderStatus.completed;
    final isCancelled = order.status == OrderStatus.cancelled;
    final badgeType = isCompleted
        ? BadgeType.success
        : (isCancelled ? BadgeType.error : BadgeType.warning);

    final itemsSummary = order.items.isNotEmpty
        ? order.items.map((i) => '${i.productName} (x${i.quantity})').join(', ')
        : 'General Items';

    return NirmaanCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      onTap: () => _showOrderDetailsSheet(context, order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderNumber}',
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              NirmaanBadge(
                label: order.status.name.toUpperCase(),
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(
            order.customerName ?? 'Walk-in Customer',
            style: AppTypography.cardTitle,
          ),
          if (order.customerPhone != null &&
              order.customerPhone!.isNotEmpty &&
              order.customerPhone != 'Walk-in Customer')
            Text(order.customerPhone!, style: AppTypography.caption),
          const SizedBox(height: AppDimensions.space8),
          Text(
            itemsSummary,
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
                      order.paymentMethod?.toUpperCase() ?? 'UPI',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_formatTime(order.createdAt),
                      style: AppTypography.caption),
                ],
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: AppTypography.metricMedium.copyWith(
                  color: isCancelled
                      ? AppColors.errorRed
                      : AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final isCancelled = order.status == OrderStatus.cancelled;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(AppDimensions.space20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: AppTypography.sectionTitle,
                      ),
                      Text(
                        'Created on ${_formatFullDate(order.createdAt)}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  NirmaanBadge(
                    label: order.status.name.toUpperCase(),
                    type: order.status == OrderStatus.completed
                        ? BadgeType.success
                        : (isCancelled ? BadgeType.error : BadgeType.warning),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Customer Information',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                order.customerName ?? 'Walk-in Customer',
                style: AppTypography.body,
              ),
              if (order.customerPhone != null &&
                  order.customerPhone!.isNotEmpty)
                Text(
                  order.customerPhone!,
                  style: AppTypography.caption,
                ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Items Purchased',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, idx) {
                    final item = order.items[idx];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)}',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          style: AppTypography.cardTitle,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: AppTypography.bodySecondary),
                  Text('₹${order.subtotal.toStringAsFixed(2)}',
                      style: AppTypography.body),
                ],
              ),
              if (order.discount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount', style: AppTypography.bodySecondary),
                    Text('-₹${order.discount.toStringAsFixed(2)}',
                        style: AppTypography.body
                            .copyWith(color: AppColors.successGreen)),
                  ],
                ),
              ],
              if (order.tax > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax', style: AppTypography.bodySecondary),
                    Text('+₹${order.tax.toStringAsFixed(2)}',
                        style: AppTypography.body),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: AppTypography.cardTitle),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: AppTypography.sectionTitle.copyWith(
                      color: isCancelled
                          ? AppColors.errorRed
                          : AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),
              if (!isCancelled)
                NirmaanButton(
                  label: 'Cancel Order',
                  variant: ButtonVariant.danger,
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    Navigator.of(modalContext).pop();
                    _confirmCancelOrder(context, order);
                  },
                ),

            ],
          ),
        );
      },
    );
  }

  void _confirmCancelOrder(BuildContext context, OrderModel order) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Text(
          'Are you sure you want to cancel order #${order.orderNumber}? '
          'Stock for all products in this order will be automatically restocked into inventory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final success = await context
                  .read<OrderController>()
                  .cancelOrder(order.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Order #${order.orderNumber} successfully cancelled and restocked'
                          : 'Failed to cancel order: ${context.read<OrderController>().errorMessage}',
                    ),
                    backgroundColor:
                        success ? AppColors.successGreen : AppColors.errorRed,
                  ),
                );
              }
            },
            child: const Text('Cancel Order'),
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

  String _formatFullDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${_formatTime(dt)}';
  }
}

