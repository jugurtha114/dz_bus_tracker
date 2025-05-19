// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/glassy_container.dart';
import '../../helpers/error_handler.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isRequestSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final success = await authProvider.resetPassword(
          email: _emailController.text.trim(),
        );

        if (success && mounted) {
          setState(() {
            _isRequestSubmitted = true;
          });
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Password reset request failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            message: ErrorHandler.handleError(e),
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
  }

  void _goToLogin() {
    AppRouter.navigateToReplacement(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App Logo or Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isRequestSubmitted ? Icons.check_circle : Icons.lock_reset,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isRequestSubmitted ? 'Check Your Email' : 'Forgot Password',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    _isRequestSubmitted
                        ? 'We\'ve sent a password reset link to your email address.'
                        : 'Enter your email to receive a password reset link',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Request form or success message in glass container
                  GlassyContainer(
                    padding: const EdgeInsets.all(24),
                    child: _isRequestSubmitted
                        ? _buildSuccessContent()
                        : _buildRequestForm(),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'Back to Login',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: ValidationUtils.validateEmail,
            textInputAction: TextInputAction.done,
            fillColor: AppColors.white.withOpacity(0.8),
            borderColor: AppColors.white.withOpacity(0.5),
          ),

          const SizedBox(height: 24),

          // Submit button
          CustomButton(
            text: 'Reset Password',
            onPressed: _requestPasswordReset,
            isLoading: _isLoading,
            height: 50,
            color: AppColors.white,
            textColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Success message with instructions
        Text(
          'If an account exists with the email you entered, we\'ve sent instructions on how to reset your password.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.darkGrey,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Email display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _emailController.text,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tip
        Text(
          'Don\'t forget to check your spam folder if you don\'t see the email in your inbox.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mediumGrey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Go to login button
        CustomButton(
          text: 'Return to Login',
          onPressed: _goToLogin,
          height: 50,
          color: AppColors.white,
          textColor: AppColors.primary,
        ),
      ],
    );
  }
}