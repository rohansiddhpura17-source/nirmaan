import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/inventory.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../controllers/inventory_controller.dart';

class AdjustStockDialog extends StatefulWidget {
  final List<InventoryItemModel> items;
  final String? initialProductId;

  const AdjustStockDialog({
    super.key,
    required this.items,
    this.initialProductId,
  });

  @override
  State<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends State<AdjustStockDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String _adjustmentType = 'RESTOCK'; // RESTOCK, ADJUSTMENT, DAMAGE, RETURN
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _types = ['RESTOCK', 'ADJUSTMENT', 'DAMAGE', 'RETURN'];

  @override
  void initState() {
    super.initState();
    if (widget.initialProductId != null && widget.items.any((i) => i.productId == widget.initialProductId)) {
      _selectedProductId = widget.initialProductId;
    } else if (widget.items.isNotEmpty) {
      _selectedProductId = widget.items.first.productId;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedProductId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final controller = context.read<InventoryController>();

    final success = await controller.adjustStock(
      productId: _selectedProductId!,
      type: _adjustmentType,
      quantity: qty,
      reason: _reasonController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = controller.errorMessage ?? 'Failed to adjust stock';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderLg),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Adjust Stock', style: AppTypography.sectionTitle),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppDimensions.space12),
                    padding: const EdgeInsets.all(AppDimensions.space8),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.errorRed),
                      borderRadius: AppDimensions.borderSm,
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(color: AppColors.errorRed),
                    ),
                  ),

                // Select Product
                Text('Select Product *',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.space6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedProductId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: widget.items
                      .map((item) => DropdownMenuItem(
                            value: item.productId,
                            child: Text(
                              '${item.name} (Stock: ${item.currentStock})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedProductId = v),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Adjustment Type
                Text('Adjustment Type *',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.space6),
                DropdownButtonFormField<String>(
                  initialValue: _adjustmentType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _types
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _adjustmentType = v);
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Quantity
                NirmaanTextField(
                  label: 'Quantity Units *',
                  hintText: 'e.g. 10',
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Quantity required';
                    final val = int.tryParse(v.trim());
                    if (val == null || val == 0) return 'Must be non-zero';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Reason
                NirmaanTextField(
                  label: 'Reason / Note *',
                  hintText: 'e.g. Weekly inventory replenishment',
                  controller: _reasonController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Reason required';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space20),

                NirmaanButton(
                  label: 'Confirm Adjustment',
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
