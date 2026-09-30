import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/business_setup_controller.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController =
      TextEditingController(text: 'Nirmaan General Store');
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _addressController =
      TextEditingController(text: 'Shop 14, Market Road, Ahmedabad');
  String _selectedCategory = 'Grocery & FMCG';

  final List<String> _categories = [
    'Grocery & FMCG',
    'Retail & Apparel',
    'Electronics & Hardware',
    'Pharmacy & Health',
    'Food & Beverage',
    'Wholesale & Trade',
    'General Services',
  ];

  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthController>().currentUser;
    _ownerNameController.text = authUser?.name ?? 'Rohan Siddhpura';
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSetup() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<BusinessSetupController>();
    await controller.saveProfile(
      businessName: _businessNameController.text.trim(),
      category: _selectedCategory,
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      currency: '₹',
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BusinessSetupController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Business Setup',
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
                const Text(
                  'Configure Your Store',
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: AppDimensions.space4),
                const Text(
                  'Set up your business profile to personalize analytics, inventory, and AI recommendations.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: AppDimensions.space24),

                // Business Name
                NirmaanTextField(
                  label: 'Business / Store Name *',
                  hintText: 'e.g. Laxmi Retail Store',
                  controller: _businessNameController,
                  prefixIcon: const Icon(Icons.storefront_outlined,
                      size: 20, color: AppColors.textMuted),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Business name is required'
                      : null,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Business Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Category *',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined,
                            size: 20, color: AppColors.textMuted),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: AppTypography.body));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedCategory = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Owner Name
                NirmaanTextField(
                  label: 'Owner / Manager Name *',
                  hintText: 'e.g. Ramesh Patel',
                  controller: _ownerNameController,
                  prefixIcon: const Icon(Icons.person_outline,
                      size: 20, color: AppColors.textMuted),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Owner name is required'
                      : null,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Phone / WhatsApp
                NirmaanTextField(
                  label: 'WhatsApp / Mobile Number *',
                  hintText: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      size: 20, color: AppColors.textMuted),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Address
                NirmaanTextField(
                  label: 'Store Location / City',
                  hintText: 'City, State or full address',
                  controller: _addressController,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      size: 20, color: AppColors.textMuted),
                ),
                const SizedBox(height: AppDimensions.space32),

                // Submit Button
                NirmaanButton(
                  label: 'Complete Setup & Launch',
                  isLoading: controller.isLoading,
                  onPressed: _handleCompleteSetup,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
