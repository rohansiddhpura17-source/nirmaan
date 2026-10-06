import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../controllers/supplier_controller.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'General',
    'FMCG Wholesale',
    'Packaging',
    'Grains & Staples',
    'Beverages',
    'Dairy & Fresh',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final controller = context.read<SupplierController>();
    final success = await controller.createSupplier(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      category: _selectedCategory,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier added successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = controller.errorMessage ?? 'Failed to add supplier';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Add New Supplier',
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
                  label: 'Supplier / Vendor Name *',
                  hintText: 'e.g. Mahavir Trading Agency',
                  controller: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Supplier name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                NirmaanTextField(
                  label: 'Mobile / WhatsApp Number *',
                  hintText: '+91 98765 43210',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final cleaned = v.trim().replaceAll(RegExp(r'[\s-]'), '');
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
                      return 'Enter a valid 10-15 digit mobile number';
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

                NirmaanTextField(
                  label: 'Email (Optional)',
                  hintText: 'vendor@example.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                NirmaanTextField(
                  label: 'Store / Warehouse Address (Optional)',
                  hintText: 'e.g. Shop 12, APMC Market Yard, Vashi',
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.space24),

                NirmaanButton(
                  label: 'Save Supplier',
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
