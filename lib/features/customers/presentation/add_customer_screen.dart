import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../controllers/customer_controller.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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

    final controller = context.read<CustomerController>();
    final success = await controller.createCustomer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = controller.errorMessage ?? 'Failed to add customer';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Add New Customer',
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
                  label: 'Customer Name *',
                  hintText: 'e.g. Ramesh Kumar',
                  controller: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Customer name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                NirmaanTextField(
                  label: 'Phone / WhatsApp *',
                  hintText: '+91 98765 43210',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final cleaned = v.trim().replaceAll(RegExp(r'[\s-]'), '');
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
                      return 'Enter a valid 10-15 digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                NirmaanTextField(
                  label: 'Email (Optional)',
                  hintText: 'customer@example.com',
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
                  label: 'Delivery Address (Optional)',
                  hintText: 'e.g. Flat 402, Sai Residency, Station Road',
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimensions.space24),

                NirmaanButton(
                  label: 'Save Customer',
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
