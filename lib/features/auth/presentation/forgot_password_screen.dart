import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_button.dart';
import '../../../shared/widgets/nirmaan_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSent = true;
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
                NirmaanTextField(
                  label: 'Registered Email Address',
                  hintText: 'e.g. owner@business.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline,
                      size: 20, color: AppColors.textMuted),
                ),
                const SizedBox(height: AppDimensions.space24),
                NirmaanButton(
                  label: 'Send Reset Link',
                  isLoading: _isLoading,
                  onPressed: _handleReset,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
