import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../../../shared/widgets/nirmaan_chip.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../../business_setup/controllers/business_setup_controller.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'owner@nirmaan.com');
  final _passwordController = TextEditingController(text: 'Password@123');
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.businessOwner;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectQuickRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      switch (role) {
        case UserRole.businessOwner:
          _emailController.text = 'owner@nirmaan.com';
          break;
        case UserRole.storeManager:
          _emailController.text = 'manager@nirmaan.com';
          break;
        case UserRole.salesStaff:
          _emailController.text = 'staff@nirmaan.com';
          break;
        case UserRole.administrator:
          _emailController.text = 'admin@nirmaan.com';
          break;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final setupController = context.read<BusinessSetupController>();

    final success = await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      await setupController.loadBusinessProfile();
      if (!mounted) return;

      if (!setupController.isCompleted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.businessSetup);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space20,
              vertical: AppDimensions.space24,
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
                      'Welcome to ${AppConstants.appName}',
                      style: AppTypography.pageTitle,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  const Center(
                    child: Text(
                      'Sign in to manage your business operations',
                      style: AppTypography.bodySecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Role Selection Chips
                  NirmaanCard(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SELECT ROLE',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Wrap(
                          spacing: AppDimensions.space8,
                          runSpacing: AppDimensions.space8,
                          children: UserRole.values.map((role) {
                            return NirmaanChip(
                              label: role.label,
                              isSelected: _selectedRole == role,
                              onSelected: (_) => _selectQuickRole(role),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Error Message Banner if any
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

                  // Email Field
                  NirmaanTextField(
                    label: 'Business Email / Mobile',
                    hintText: 'Enter your email or phone',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline,
                        size: 20, color: AppColors.textMuted),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email or phone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Password Field
                  NirmaanTextField(
                    label: 'Password',
                    hintText: '••••••••',
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
                  const SizedBox(height: AppDimensions.space8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Sign In Button
                  NirmaanButton(
                    label: 'Sign In as ${_selectedRole.label}',
                    isLoading: authController.status == AuthStatus.loading,
                    onPressed: _handleLogin,
                    icon: Icons.login_rounded,
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Demo Note
                  Center(
                    child: Text(
                      'Ready for local businesses across India',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
