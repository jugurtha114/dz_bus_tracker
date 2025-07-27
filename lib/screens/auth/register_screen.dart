// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';
import '../../helpers/error_handler.dart' hide ErrorType;
import '../../helpers/dialog_helper.dart';

/// Modern registration screen with optimized UX
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Create Account',
      backgroundColor: context.colors.background,
      child: ResponsivePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DesignSystem.space24),
              _buildHeader(context),
              const SizedBox(height: DesignSystem.space32),
              _buildRegistrationForm(context),
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
          padding: const EdgeInsets.all(DesignSystem.space16),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add,
            size: 40,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: DesignSystem.space16),
        Text(
          'Join DZ Bus Tracker',
          style: context.textStyles.headlineMedium?.copyWith(
            color: context.colors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignSystem.space8),
        Text(
          'Create your account to start tracking buses',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildFormContent(context),
      tablet: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: _buildFormContent(context),
        ),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AppCard(
            padding: const EdgeInsets.all(DesignSystem.space32),
            child: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return RegisterForm(
      onSubmit: _handleRegistration,
      isLoading: _isLoading,
      onLogin: _navigateToLogin,
      showDriverOption: true,
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
              'Already have an account? ',
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

  Future<void> _handleRegistration(RegisterFormData data) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        phoneNumber: data.phone,
        password: data.password,
        confirmPassword: data.password,
      );
      
      if (success && mounted) {
        // Show success message
        await DialogHelper.showSuccessDialog(
          context,
          title: 'Account Created Successfully',
          message: data.isDriver 
              ? 'Your driver application has been submitted for review. You will receive an email once approved.'
              : 'Welcome to DZ Bus Tracker! You can now start tracking buses.',
        );
        
        // Navigate based on account type
        if (data.isDriver) {
          // Driver needs approval, go to pending screen
          Navigator.of(context).pushReplacementNamed(AppRoutes.driverHome);
        } else {
          // Passenger can start using the app immediately
          Navigator.of(context).pushReplacementNamed(AppRoutes.passengerHome);
        }
      }
    } catch (error) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Registration Failed',
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
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }
}