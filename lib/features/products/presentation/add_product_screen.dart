import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';

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
  final _thresholdController = TextEditingController(text: '10');
  String _selectedCategory = 'Grains & Flours';
  bool _isLoading = false;

  final List<String> _categories = [
    'Grains & Flours',
    'Edible Oils',
    'Beverages',
    'Spices & Masala',
    'Snacks & Biscuits',
    'Personal Care',
    'Household Cleaning',
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
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.of(context).pop();
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
                NirmaanTextField(
                  label: 'Product Name *',
                  hintText: 'e.g. Fortune Sunflower Oil 1L',
                  controller: _nameController,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Product name is required'
                      : null,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Category
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category *',
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppDimensions.space6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: AppTypography.body)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // SKU & Barcode
                Row(
                  children: [
                    Expanded(
                      child: NirmaanTextField(
                        label: 'SKU Code',
                        hintText: 'e.g. SKU-OIL-01',
                        controller: _skuController,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Barcode',
                        hintText: 'Scan or type',
                        controller: _barcodeController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              size: 20, color: AppColors.primaryNavy),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Pricing
                Row(
                  children: [
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Purchase Cost (₹) *',
                        hintText: '0.00',
                        controller: _costPriceController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Cost is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Selling Price (₹) *',
                        hintText: '0.00',
                        controller: _sellPriceController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Price is required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Stock & Threshold
                Row(
                  children: [
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Opening Stock *',
                        hintText: '0',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Stock is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: NirmaanTextField(
                        label: 'Low Stock Alert Threshold',
                        hintText: '10',
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space32),

                NirmaanButton(
                  label: 'Save Product',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
