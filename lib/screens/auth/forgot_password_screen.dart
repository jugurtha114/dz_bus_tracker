// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';
import '../../helpers/error_handler.dart' hide ErrorType;
import '../../helpers/dialog_helper.dart';

/// Forgot password screen with clean UX
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  bool _isEmailSent = false;
  String _submittedEmail = '';

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Reset Password',
      backgroundColor: context.colors.background,
      child: ResponsivePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DesignSystem.space32),
              _buildHeader(context),
              const SizedBox(height: DesignSystem.space32),
              _buildContent(context),
              const SizedBox(height: DesignSystem.space24),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSystem.space20),
          decoration: BoxDecoration(
            color: _isEmailSent 
                ? context.successColor.withOpacity(0.1)
                : context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isEmailSent ? Icons.mark_email_read : Icons.lock_reset,
            size: 48,
            color: _isEmailSent 
                ? context.successColor
                : context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: DesignSystem.space16),
        Text(
          _isEmailSent ? 'Check Your Email' : 'Forgot Password?',
          style: context.textStyles.headlineMedium?.copyWith(
            color: context.colors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignSystem.space8),
        Text(
          _isEmailSent 
              ? 'We\'ve sent a password reset link to $_submittedEmail'
              : 'No worries! Enter your email and we\'ll send you a reset link.',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isEmailSent) {
      return _buildEmailSentContent(context);
    }

    return ResponsiveLayout(
      mobile: _buildFormContent(context),
      tablet: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildFormContent(context),
        ),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AppCard(
            padding: const EdgeInsets.all(DesignSystem.space32),
            child: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return ForgotPasswordForm(
      onSubmit: _handlePasswordReset,
      isLoading: _isLoading,
      onBackToLogin: _navigateToLogin,
    );
  }

  Widget _buildEmailSentContent(BuildContext context) {
    return Column(
      children: [
        AppCard(
          // variant: AppCardVariant.filled, // Use default variant
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colors.primary,
                size: DesignSystem.iconMedium,
              ),
              const SizedBox(height: DesignSystem.space12),
              Text(
                'Didn\'t receive the email?',
                style: context.textStyles.titleMedium,
              ),
              const SizedBox(height: DesignSystem.space8),
              Text(
                'Check your spam folder or try again with a different email address.',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignSystem.space24),
        AppButton.outlined(
          text: 'Resend Email',
          onPressed: _isLoading ? null : _resendEmail,
          isLoading: _isLoading,
          width: double.infinity,
          icon: Icons.refresh,
        ),
        const SizedBox(height: DesignSystem.space12),
        AppButton.text(
          text: 'Try Different Email',
          onPressed: _isLoading ? null : _tryDifferentEmail,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: DesignSystem.space16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password? ',
              style: context.textStyles.bodyMedium,
            ),
            AppButton.text(
              text: 'Sign In',
              onPressed: _isLoading ? null : _navigateToLogin,
              size: AppButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handlePasswordReset(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.resetPassword(email: email);
      
      if (mounted) {
        setState(() {
          _isEmailSent = true;
          _submittedEmail = email;
        });
      }
    } catch (error) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Reset Failed',
          message: ErrorHandler.getErrorMessage(error),
          type: ErrorType.validation,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendEmail() async {
    await _handlePasswordReset(_submittedEmail);
  }

  void _tryDifferentEmail() {
    setState(() {
      _isEmailSent = false;
      _submittedEmail = '';
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }
}

/// Password reset confirmation screen (when user clicks email link)
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    super.key,
    required this.resetToken,
  });

  final String resetToken;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Reset Password',
      backgroundColor: context.colors.background,
      child: ResponsivePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DesignSystem.space32),
              _buildHeader(context),
              const SizedBox(height: DesignSystem.space32),
              _buildForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSystem.space20),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.key,
            size: 48,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: DesignSystem.space16),
        Text(
          'Create New Password',
          style: context.textStyles.headlineMedium?.copyWith(
            color: context.colors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignSystem.space8),
        Text(
          'Enter a new password for your account',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildFormContent(context),
      tablet: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildFormContent(context),
        ),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AppCard(
            padding: const EdgeInsets.all(DesignSystem.space32),
            child: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: 'New Password',
            hint: 'Enter your new password',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: _validatePassword,
          ),
          const SizedBox(height: DesignSystem.space16),
          AppInput(
            label: 'Confirm Password',
            hint: 'Confirm your new password',
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: _validateConfirmPassword,
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: DesignSystem.space24),
          AppButton(
            text: 'Update Password',
            onPressed: _isLoading ? null : _handleSubmit,
            isLoading: _isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: DesignSystem.space16),
          AppButton.text(
            text: 'Back to Sign In',
            onPressed: _isLoading ? null : _navigateToLogin,
          ),
        ],
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.confirmPasswordReset(
        token: widget.resetToken,
        newPassword: _passwordController.text,
      );
      
      if (mounted) {
        await DialogHelper.showSuccessDialog(
          context,
          title: 'Password Updated',
          message: 'Your password has been updated successfully. You can now sign in with your new password.',
        );
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Reset Failed',
          message: ErrorHandler.getErrorMessage(error),
          type: ErrorType.validation,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}