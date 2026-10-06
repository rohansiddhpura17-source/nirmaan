import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
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
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Grocery & FMCG',
    'Retail & Apparel',
    'Electronics & Hardware',
    'Pharmacy & Health',
    'Food & Beverage',
    'Wholesale & Trade',
    'General Services',
  ];

  static final _phoneRegex = RegExp(r'^[+]?[\d\s-]{10,15}$');
  static final _gstinRegex =
      RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthController>();
      if (!auth.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        return;
      }
      final setup = context.read<BusinessSetupController>();
      if (auth.currentUser?.setupComplete == true && setup.isCompleted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
        return;
      }

      final authUser = auth.currentUser;
      final existingBiz = setup.businessProfile;
      final hasMatchingBiz = existingBiz != null &&
          authUser?.businessId != null &&
          authUser!.businessId!.isNotEmpty &&
          existingBiz.id == authUser.businessId;

      setState(() {
        if (hasMatchingBiz) {
          if (_businessNameController.text.isEmpty &&
              existingBiz.businessName.isNotEmpty) {
            _businessNameController.text = existingBiz.businessName;
          }
          if (_addressController.text.isEmpty &&
              existingBiz.address != null &&
              existingBiz.address!.isNotEmpty) {
            _addressController.text = existingBiz.address!;
          }
          if (_gstinController.text.isEmpty &&
              existingBiz.gstNumber != null &&
              existingBiz.gstNumber!.isNotEmpty) {
            _gstinController.text = existingBiz.gstNumber!;
          }
          if (_selectedCategory == null && existingBiz.category.isNotEmpty) {
            _selectedCategory = existingBiz.category;
          }
        }

        // Owner name may be prefilled ONLY from the authenticated user's actual profile
        if (_ownerNameController.text.isEmpty &&
            authUser != null &&
            authUser.name.isNotEmpty) {
          _ownerNameController.text = authUser.name;
        }

        // Mobile number may be prefilled ONLY from the authenticated user's actual profile
        if (_phoneController.text.isEmpty &&
            authUser != null &&
            authUser.phone != null &&
            authUser.phone!.isNotEmpty) {
          _phoneController.text = authUser.phone!;
        }
      });
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSetup() async {
    final setupController = context.read<BusinessSetupController>();
    setupController.clearError();

    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.isEmpty) return;

    final authController = context.read<AuthController>();
    final success = await setupController.saveProfile(
      businessName: _businessNameController.text.trim(),
      category: _selectedCategory!,
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      gstNumber: _gstinController.text.trim().isNotEmpty
          ? _gstinController.text.trim().toUpperCase()
          : null,
      currency: '₹',
      authController: authController,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BusinessSetupController>();
    final isSubmitting = controller.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const NirmaanAppBar(
        title: 'Business Setup',
        isDark: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner
                NirmaanCard(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: AppDimensions.borderMd,
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primaryBlueLight,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configure Your Store',
                              style: AppTypography.pageTitle,
                            ),
                            SizedBox(height: AppDimensions.space4),
                            Text(
                              'Establish tenant workspace & store parameters',
                              style: AppTypography.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Error Banner with Retry
                if (controller.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderMd,
                      border: Border.all(
                        color: AppColors.errorRed.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.errorRed,
                          size: 22,
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Text(
                            controller.errorMessage!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: isSubmitting ? null : _handleCompleteSetup,
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ],

                // Form Card
                NirmaanCard(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Business Name
                      NirmaanTextField(
                        label: 'Business / Store Name *',
                        hintText: 'e.g. Laxmi Retail Store',
                        controller: _businessNameController,
                        readOnly: isSubmitting,
                        prefixIcon: const Icon(
                          Icons.storefront_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Business name is required';
                          }
                          if (v.trim().length < 2) {
                            return 'Business name must be at least 2 characters';
                          }
                          return null;
                        },
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
                            isExpanded: true,
                            initialValue: _selectedCategory,
                            hint: Text(
                              'Select a business category',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.category_outlined,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                            items: _categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: AppTypography.body),
                              );
                            }).toList(),
                            onChanged: isSubmitting
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() => _selectedCategory = val);
                                    }
                                  },
                            validator: (v) => v == null || v.isEmpty
                                ? 'Category is required'
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Owner Name
                      NirmaanTextField(
                        label: 'Owner / Manager Name *',
                        hintText: 'e.g. Ramesh Patel',
                        controller: _ownerNameController,
                        readOnly: isSubmitting,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Owner name is required';
                          }
                          if (v.trim().length < 2) {
                            return 'Owner name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Phone / WhatsApp
                      NirmaanTextField(
                        label: 'WhatsApp / Mobile Number *',
                        hintText: 'e.g. +91 98765 43210',
                        controller: _phoneController,
                        readOnly: isSubmitting,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          if (!_phoneRegex.hasMatch(v.trim())) {
                            return 'Enter 10-15 digits with optional country code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Address
                      NirmaanTextField(
                        label: 'Store Location / Address *',
                        hintText: 'e.g. Shop 14, Market Road, Ahmedabad',
                        controller: _addressController,
                        readOnly: isSubmitting,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Store address is required (minimum 5 characters)';
                          }
                          if (v.trim().length < 5) {
                            return 'Store address must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // GSTIN (Optional)
                      NirmaanTextField(
                        label: 'GSTIN (Optional)',
                        hintText: 'e.g. 24ABCDE1234F1Z5',
                        controller: _gstinController,
                        readOnly: isSubmitting,
                        prefixIcon: const Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (!_gstinRegex.hasMatch(v.trim().toUpperCase())) {
                            return 'Invalid GSTIN format (e.g. 24ABCDE1234F1Z5)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Submit Button
                NirmaanButton(
                  label: 'Complete Setup & Launch',
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _handleCompleteSetup,
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
