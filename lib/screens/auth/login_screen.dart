// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/enhanced_text_field.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/mobile_optimized_background.dart';
import '../../widgets/common/modern_button.dart';
import '../../config/app_theme.dart';
import '../../config/app_icons.dart';
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
    return MobileOptimizedBackground(
      imagePath: 'images/backgrounds/auth_bg.jpg',
      blurIntensity: 1.5,
      opacity: 0.3,
      gradientColors: [
        Colors.black.withValues(alpha: 0.4),
        AppTheme.primary.withValues(alpha: 0.2),
        AppTheme.secondary.withValues(alpha: 0.15),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [

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
                    child: ModernCard(
                      type: ModernCardType.glass,
                      width: 120,
                      height: 120,
                      borderRadius: 60,
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Sign in to continue your journey',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Login Form in a Glass Container
                  ModernCard(
                    type: ModernCardType.glass,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          EnhancedTextField.email(
                            label: 'Email',
                            hintText: 'Enter your email',
                            controller: _emailController,
                            validator: ValidationUtils.validateEmail,
                            required: true,
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          EnhancedTextField.password(
                            label: 'Password',
                            hintText: 'Enter your password',
                            controller: _passwordController,
                            validator: (value) => ValidationUtils.validateRequired(
                              value,
                              fieldName: 'Password',
                            ),
                            required: true,
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
                          PrimaryButton(
                            text: 'Login',
                            onPressed: _isLoading ? null : _login,
                            isLoading: _isLoading,
                            size: ModernButtonSize.large,
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
                  SecondaryButton(
                    text: 'Register as Bus Driver',
                    onPressed: _goToDriverRegister,
                    leadingIcon: Icons.drive_eta_rounded,
                    size: ModernButtonSize.large,
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}