// lib/screens/auth/improved_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../helpers/error_handler.dart';
import '../../models/user_model.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_card.dart';

class ImprovedLoginScreen extends StatefulWidget {
  const ImprovedLoginScreen({Key? key}) : super(key: key);

  @override
  State<ImprovedLoginScreen> createState() => _ImprovedLoginScreenState();
}

class _ImprovedLoginScreenState extends State<ImprovedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        _navigateBasedOnUserType(authProvider.userType);
      } else {
        _showError(authProvider.error ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError(ErrorHandler.handleError(e));
      }
    }
  }

  void _navigateBasedOnUserType(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        AppRouter.navigateToAndClearStack(context, AppRoutes.driverHome);
        break;
      case UserType.admin:
        AppRouter.navigateToAndClearStack(context, AppRoutes.adminDashboard);
        break;
      case UserType.passenger:
      default:
        AppRouter.navigateToAndClearStack(context, AppRoutes.passengerHome);
        break;
    }
  }

  void _showError(String message) {
    ErrorHandler.showErrorSnackBar(context, message: message);
  }

  void _navigateToRegister() {
    AppRouter.navigateTo(context, AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    AppRouter.navigateTo(context, AppRoutes.forgotPassword);
  }

  void _navigateToDriverRegister() {
    AppRouter.navigateTo(context, AppRoutes.driverRegister);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with app branding
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Sign in to continue',
                icon: Icons.directions_bus_rounded,
              ),

              // Login form
              AuthCard(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          AuthEmailField(
                            controller: _emailController,
                            validator: ValidationUtils.validateEmail,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          AuthPasswordField(
                            label: 'Password',
                            hintText: 'Enter your password',
                            controller: _passwordController,
                            validator: (value) => ValidationUtils.validateRequired(
                              value,
                              fieldName: 'Password',
                            ),
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 16),

                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: AuthTextButton(
                              text: 'Forgot Password?',
                              onPressed: _navigateToForgotPassword,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          AuthButton.primary(
                            text: 'Login',
                            onPressed: authProvider.isLoading ? null : _handleLogin,
                            isLoading: authProvider.isLoading,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Register link
              AuthBottomAction(
                question: "Don't have an account?",
                actionText: 'Register',
                onActionPressed: _navigateToRegister,
              ),

              const SizedBox(height: 16),

              // Driver Register Button
              AuthButton.outlined(
                text: 'Register as Bus Driver',
                onPressed: _navigateToDriverRegister,
                icon: Icons.person_add_alt_1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}