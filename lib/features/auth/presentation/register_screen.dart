import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../../business_setup/controllers/business_setup_controller.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.businessOwner;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final setupController = context.read<BusinessSetupController>();

    final success = await authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : null,
    );

    if (success && mounted) {
      await setupController.loadBusinessProfile(
          currentUser: authController.currentUser);
      if (!mounted) return;

      final user = authController.currentUser;
      final isComplete =
          (user != null && user.setupComplete) || setupController.isCompleted;
      if (!isComplete) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.businessSetup);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    // Exclude Administrator from public self-registration
    final selectableRoles = [
      UserRole.businessOwner,
      UserRole.storeManager,
      UserRole.salesStaff,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryNavy, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space20,
              vertical: AppDimensions.space8,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Branding
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: AppDimensions.borderLg,
                        boxShadow: AppDimensions.shadowSubtle,
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        color: AppColors.primaryBlueLight,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  const Center(
                    child: Text(
                      'Create Business Account',
                      style: AppTypography.pageTitle,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  const Center(
                    child: Text(
                      'Join ${AppConstants.appName} and digitize your operations',
                      style: AppTypography.bodySecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Error Message Banner
                  if (authController.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRedLight,
                        borderRadius: AppDimensions.borderMd,
                        border: Border.all(
                            color: AppColors.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 18, color: AppColors.errorRed),
                          const SizedBox(width: AppDimensions.space8),
                          Expanded(
                            child: Text(
                              authController.errorMessage!,
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.errorRedDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],

                  // Role Selection Pills
                  Text(
                    'I am registering as:',
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Wrap(
                    spacing: AppDimensions.space8,
                    runSpacing: AppDimensions.space8,
                    children: selectableRoles.map((role) {
                      return NirmaanChip(
                        label: role.label,
                        isSelected: _selectedRole == role,
                        onSelected: (_) {
                          setState(() => _selectedRole = role);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Full Name
                  NirmaanTextField(
                    label: 'Full Name',
                    hintText: 'e.g. Ramesh Patel',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline,
                        size: 20, color: AppColors.textMuted),
                    validator: (val) {
                      if (val == null || val.trim().length < 2) {
                        return 'Please enter your name (at least 2 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Business Name
                  NirmaanTextField(
                    label: 'Business Name',
                    hintText: 'e.g. Patel Supermarket',
                    controller: _businessNameController,
                    prefixIcon: const Icon(Icons.storefront_outlined,
                        size: 20, color: AppColors.textMuted),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your business name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Work Email
                  NirmaanTextField(
                    label: 'Email Address',
                    hintText: 'e.g. name@business.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline,
                        size: 20, color: AppColors.textMuted),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an email address';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Phone Number
                  NirmaanTextField(
                    label: 'Phone Number (Optional)',
                    hintText: '+91 98765 43210',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined,
                        size: 20, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Password
                  NirmaanTextField(
                    label: 'Password',
                    hintText: 'Minimum 6 characters',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline,
                        size: 20, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Confirm Password
                  NirmaanTextField(
                    label: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    prefixIcon: const Icon(Icons.lock_outline,
                        size: 20, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (val) {
                      if (val != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Register Button
                  NirmaanButton(
                    label: 'Register & Continue',
                    isLoading: authController.status == AuthStatus.loading,
                    onPressed: _handleRegister,
                    icon: Icons.person_add_rounded,
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Existing Account Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.login);
                          }
                        },
                        child: Text(
                          'Sign In',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
