import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authController = context.read<AuthController>();
    final success =
        await authController.sendPasswordReset(_emailController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _isSent = true;
        } else {
          _errorMessage = authController.errorMessage ??
              'Failed to send reset link. Please check your email.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NirmaanAppBar(
        title: 'Reset Password',
        isDark: false,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.space16),
              const Text(
                'Forgot your password?',
                style: AppTypography.pageTitle,
              ),
              const SizedBox(height: AppDimensions.space8),
              const Text(
                'Enter the email address registered with your business account. We will send you instructions to reset your password.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.space24),
              if (_errorMessage != null) ...[
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
                          _errorMessage!,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.errorRedDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
              ],
              if (_isSent) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenLight,
                    borderRadius: AppDimensions.borderMd,
                    border: Border.all(
                        color: AppColors.successGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.successGreenDark),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text(
                          'Password reset instructions have been sent to ${_emailController.text.trim()}',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.successGreenDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),
                NirmaanButton(
                  label: 'Back to Login',
                  variant: ButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NirmaanTextField(
                        label: 'Registered Email Address',
                        hintText: 'e.g. owner@business.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.mail_outline,
                            size: 20, color: AppColors.textMuted),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(val.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      NirmaanButton(
                        label: 'Send Reset Link',
                        isLoading: _isLoading,
                        onPressed: _handleReset,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
