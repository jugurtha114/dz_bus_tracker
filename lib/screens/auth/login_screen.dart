// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_card.dart';
import '../../helpers/error_handler.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (success) {
          // Navigate to home screen based on user type
          final userType = authProvider.userType;
          
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
        } else {
          // Show error message
          if (mounted) {
            ErrorHandler.showErrorSnackBar(
              context,
              message: authProvider.error ?? 'Login failed. Please try again.',
            );
          }
        }
      } catch (e) {
        // Show error message
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

  void _goToRegister() {
    AppRouter.navigateTo(context, AppRoutes.register);
  }

  void _goToForgotPassword() {
    AppRouter.navigateTo(context, AppRoutes.forgotPassword);
  }

  void _goToDriverRegister() {
    AppRouter.navigateTo(context, AppRoutes.driverRegister);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          // Background image or gradient
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
                  const SizedBox(height: 16),

                  // App Logo
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
                          Icons.directions_bus_rounded,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Login Form in a Glass Container
                  CustomCard(type: CardType.elevated, 
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          CustomTextField(
                            label: 'Email',
                            hintText: 'Enter your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: ValidationUtils.validateEmail,
                            textInputAction: TextInputAction.next,
                            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          CustomTextField(
                            label: 'Password',
                            hintText: 'Enter your password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (value) => ValidationUtils.validateRequired(
                              value,
                              fieldName: 'Password',
                            ),
                            textInputAction: TextInputAction.done,
                            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ),

                          const SizedBox(height: 16),

                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _goToForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Login button
                          CustomButton(
        text: 'Login',
        onPressed: _login,
        isLoading: _isLoading,
        customColor: Theme.of(context).colorScheme.primary
      ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: _goToRegister,
                        child: Text(
                          'Register',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Driver Register Button
                  OutlinedButton(
                    onPressed: _goToDriverRegister,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Register as Bus Driver',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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
}