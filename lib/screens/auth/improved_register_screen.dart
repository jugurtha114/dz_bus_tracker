// lib/screens/auth/improved_register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../helpers/error_handler.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_card.dart';

class ImprovedRegisterScreen extends StatefulWidget {
  const ImprovedRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ImprovedRegisterScreen> createState() => _ImprovedRegisterScreenState();
}

class _ImprovedRegisterScreenState extends State<ImprovedRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        _showSuccessAndNavigateToLogin();
      } else {
        _showError(authProvider.error ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError(ErrorHandler.handleError(e));
      }
    }
  }

  void _showSuccessAndNavigateToLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registration successful! Please login.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    AppRouter.navigateToAndClearStack(context, AppRoutes.login);
  }

  void _showError(String message) {
    ErrorHandler.showErrorSnackBar(context, message: message);
  }

  void _navigateToLogin() {
    AppRouter.navigateTo(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const AuthHeader(
                title: 'Create Account',
                subtitle: 'Join DZ Bus Tracker community',
                icon: Icons.person_add_rounded,
              ),

              // Registration form
              AuthCard(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // First Name field
                          AuthNameField(
                            label: 'First Name',
                            hintText: 'Enter your first name',
                            controller: _firstNameController,
                            validator: (value) => ValidationUtils.validateRequired(
                              value,
                              fieldName: 'First name',
                            ),
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Last Name field
                          AuthNameField(
                            label: 'Last Name',
                            hintText: 'Enter your last name',
                            controller: _lastNameController,
                            validator: (value) => ValidationUtils.validateRequired(
                              value,
                              fieldName: 'Last name',
                            ),
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Email field
                          AuthEmailField(
                            controller: _emailController,
                            validator: ValidationUtils.validateEmail,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Phone field
                          AuthPhoneField(
                            controller: _phoneController,
                            validator: ValidationUtils.validatePhone,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          AuthPasswordField(
                            label: 'Password',
                            hintText: 'Enter your password',
                            controller: _passwordController,
                            validator: ValidationUtils.validatePassword,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password field
                          AuthPasswordField(
                            label: 'Confirm Password',
                            hintText: 'Confirm your password',
                            controller: _confirmPasswordController,
                            validator: (value) => ValidationUtils.validateConfirmPassword(
                              _passwordController.text,
                              value,
                            ),
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 24),

                          // Register button
                          AuthButton.primary(
                            text: 'Register',
                            onPressed: authProvider.isLoading ? null : _handleRegister,
                            isLoading: authProvider.isLoading,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Login link
              AuthBottomAction(
                question: 'Already have an account?',
                actionText: 'Login',
                onActionPressed: _navigateToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}