import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../models/product.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../customers/controllers/customer_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../controllers/order_controller.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  CustomerModel? _selectedCustomer;
  final Map<String, int> _selectedQuantities = {}; // productId -> quantity
  String _paymentMethod = 'UPI'; // UPI, CASH, CARD
  final _discountController = TextEditingController(text: '0');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productController = context.read<ProductController>();
      if (productController.products.isEmpty) {
        productController.loadProducts();
      }
      final customerController = context.read<CustomerController>();
      if (customerController.customers.isEmpty) {
        customerController.loadCustomers();
      }
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  double _calculateSubtotal(List<ProductModel> products) {
    double sum = 0.0;
    for (final entry in _selectedQuantities.entries) {
      final p = products.cast<ProductModel?>().firstWhere(
            (item) => item?.id == entry.key,
            orElse: () => null,
          );
      if (p != null) {
        sum += (p.sellingPrice * entry.value);
      }
    }
    return sum;
  }

  Future<void> _handlePlaceOrder(List<ProductModel> products) async {
    if (_selectedQuantities.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one product');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final items = <Map<String, dynamic>>[];
    for (final entry in _selectedQuantities.entries) {
      final p = products.cast<ProductModel?>().firstWhere(
            (item) => item?.id == entry.key,
            orElse: () => null,
          );
      if (p != null) {
        items.add({
          'productId': p.id,
          'productName': p.name,
          'quantity': entry.value,
          'unitPrice': p.sellingPrice,
        });
      }
    }

    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;
    final orderController = context.read<OrderController>();

    final createdOrder = await orderController.createOrder(
      items: items,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      customerPhone: _selectedCustomer?.phone,
      discount: discount,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (createdOrder != null) {
      // Reload products to reflect decremented stock in products view
      unawaited(context.read<ProductController>().loadProducts(forceRefresh: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${createdOrder.orderNumber} completed successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = orderController.errorMessage ?? 'Failed to complete order';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final customers = context.watch<CustomerController>().customers;
    final subtotal = _calculateSubtotal(products);
    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;
    final grandTotal = (subtotal - discount).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'New Sales Order',
        isDark: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(AppDimensions.space16),
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.errorRed),
                  borderRadius: AppDimensions.borderMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Product Selection List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.space16),
                children: [
                  // Customer Picker
                  Text('Customer (Optional)',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<CustomerModel?>(
                    initialValue: _selectedCustomer,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      hintText: 'Walk-in Customer (Select to attach profile)',
                    ),
                    items: [
                      const DropdownMenuItem<CustomerModel?>(
                        value: null,
                        child: Text('Walk-in Customer'),
                      ),
                      ...customers.map((c) => DropdownMenuItem<CustomerModel?>(
                            value: c,
                            child: Text('${c.name} (${c.phone})'),
                          )),
                    ],
                    onChanged: (c) => setState(() => _selectedCustomer = c),
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Products List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Products', style: AppTypography.sectionTitle),
                      Text(
                        '${_selectedQuantities.length} items selected',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('No products available for sale.')),
                    )
                  else
                    ...products.map((p) {
                      final currentQty = _selectedQuantities[p.id] ?? 0;
                      final isOutOfStock = p.currentStock <= 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                        child: NirmaanCard(
                          padding: const EdgeInsets.all(AppDimensions.space12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${p.sellingPrice.toStringAsFixed(0)} · In Stock: ${p.currentStock}',
                                      style: AppTypography.caption.copyWith(
                                        color: isOutOfStock ? AppColors.errorRed : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOutOfStock)
                                const Text('OUT OF STOCK',
                                    style: TextStyle(color: AppColors.errorRed, fontSize: 11, fontWeight: FontWeight.bold))
                              else
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      color: currentQty > 0 ? AppColors.primaryNavy : AppColors.textMuted,
                                      onPressed: currentQty > 0
                                          ? () {
                                              setState(() {
                                                if (currentQty == 1) {
                                                  _selectedQuantities.remove(p.id);
                                                } else {
                                                  _selectedQuantities[p.id] = currentQty - 1;
                                                }
                                              });
                                            }
                                          : null,
                                    ),
                                    Text(
                                      '$currentQty',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: currentQty < p.currentStock ? AppColors.primaryBlue : AppColors.textMuted,
                                      onPressed: currentQty < p.currentStock
                                          ? () {
                                              setState(() {
                                                _selectedQuantities[p.id] = currentQty + 1;
                                              });
                                            }
                                          : () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Cannot order more than available stock (${p.currentStock})')),
                                              );
                                            },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: AppDimensions.space16),

                  // Payment & Discounts Section
                  const Text('Payment & Billing', style: AppTypography.sectionTitle),
                  const SizedBox(height: AppDimensions.space12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Method',
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _paymentMethod,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'UPI', child: Text('UPI / QR')),
                                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                                DropdownMenuItem(value: 'CARD', child: Text('Card / POS')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _paymentMethod = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Discount (₹)',
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _discountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Checkout Footer
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Subtotal: ₹${subtotal.toStringAsFixed(0)}', style: AppTypography.caption),
                        Text(
                          'Total: ₹${grandTotal.toStringAsFixed(0)}',
                          style: AppTypography.metricLarge.copyWith(color: AppColors.primaryNavy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: NirmaanButton(
                      label: 'Complete Order',
                      isLoading: _isLoading,
                      onPressed: _selectedQuantities.isNotEmpty
                          ? () => _handlePlaceOrder(products)
                          : null,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
