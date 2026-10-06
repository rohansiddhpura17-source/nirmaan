import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../controllers/product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController(text: '5');
  String _selectedCategory = 'Grains & Staples';
  final String _unit = 'pcs';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Grains & Staples',
    'Edible Oils',
    'Beverages',
    'Spices & Essentials',
    'Packaged Foods',
    'Personal Care',
    'Household',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cost = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final sell = double.tryParse(_sellPriceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 5;

    final controller = context.read<ProductController>();
    final success = await controller.createProduct(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      sku: _skuController.text.trim().isNotEmpty ? _skuController.text.trim() : null,
      barcode: _barcodeController.text.trim().isNotEmpty
          ? _barcodeController.text.trim()
          : null,
      purchasePrice: cost,
      sellingPrice: sell,
      initialStock: stock,
      lowStockThreshold: threshold,
      unit: _unit,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = controller.errorMessage ?? 'Failed to add product';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Add New Product',
        isDark: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppDimensions.space16),
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.errorRed),
                      borderRadius: AppDimensions.borderMd,
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.errorRed),
                    ),
                  ),

                NirmaanTextField(
                  label: 'Product Name *',
                  hintText: 'e.g. Fortune Sunflower Oil 1L',
                  controller: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category *',
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppDimensions.space6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                Row(
                  children: [
                    Expanded(
                      child: NirmaanTextField(
                        label: 'SKU (Optional)',
                        hintText: 'e.g. OIL-FORT-1L',
                        controller: _skuController,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Barcode (Optional)',
                        hintText: 'e.g. 8901234567890',
                        controller: _barcodeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                Row(
                  children: [
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Cost Price (₹) *',
                        hintText: '110',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: _costPriceController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Cost price required';
                          final val = double.tryParse(v.trim());
                          if (val == null || val < 0) return 'Enter a valid cost';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Selling Price (₹) *',
                        hintText: '135',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: _sellPriceController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Selling price required';
                          final val = double.tryParse(v.trim());
                          if (val == null || val <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                Row(
                  children: [
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Initial Stock *',
                        hintText: '50',
                        keyboardType: TextInputType.number,
                        controller: _stockController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Stock required';
                          final val = int.tryParse(v.trim());
                          if (val == null || val < 0) return 'Must be >= 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Low Stock Threshold',
                        hintText: '5',
                        keyboardType: TextInputType.number,
                        controller: _thresholdController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Threshold required';
                          final val = int.tryParse(v.trim());
                          if (val == null || val < 0) return 'Must be >= 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space24),

                NirmaanButton(
                  label: 'Save Product',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
