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
import '../../widgets/common/custom_card.dart';
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
              backgroundColor: Theme.of(context).colorScheme.primary,
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary,
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App Logo or Icon
                  Center(
                    child: Container(
                      width: 100,
        
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isRequestSubmitted ? Icons.check_circle : Icons.lock_reset,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _isRequestSubmitted ? 'Check Your Email' : 'Forgot Password',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    _isRequestSubmitted
                        ? 'We\'ve sent a password reset link to your email address.'
                        : 'Enter your email to receive a password reset link',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Request form or success message in glass container
                  CustomCard(type: CardType.elevated, 
                    padding: const EdgeInsets.all(24),
                    child: _isRequestSubmitted
                        ? _buildSuccessContent()
                        : _buildRequestForm(),
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'Back to Login',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),

          const SizedBox(height: 16),

          // Submit button
          CustomButton(
        text: 'Reset Password',
        onPressed: _requestPasswordReset,
        isLoading: _isLoading,
        color: Theme.of(context).colorScheme.primary,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Email display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8, height: 40),
              Flexible(
                child: Text(
                  _emailController.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Go to login button
        CustomButton(
        text: 'Return to Login',
        onPressed: _goToLogin,
        color: Theme.of(context).colorScheme.primary,
      ),
      ],
    );
  }
}