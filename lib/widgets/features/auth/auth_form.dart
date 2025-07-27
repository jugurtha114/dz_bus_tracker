// lib/widgets/features/auth/auth_form.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/foundation.dart';

/// Authentication form components optimized for login and registration
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.emailController,
    this.passwordController,
    this.onForgotPassword,
    this.onRegister,
  });

  final Function(String email, String password) onSubmit;
  final bool isLoading;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegister;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController = widget.emailController ?? TextEditingController();
    _passwordController = widget.passwordController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.emailController == null) _emailController.dispose();
    if (widget.passwordController == null) _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: 'Email',
            hint: 'Enter your email address',
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: _validateEmail,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: DesignSystem.space16),
          AppInput(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: _validatePassword,
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: DesignSystem.space8),
          if (widget.onForgotPassword != null)
            Align(
              alignment: Alignment.centerRight,
              child: AppButton.text(
                text: 'Forgot Password?',
                onPressed: widget.isLoading ? null : widget.onForgotPassword,
                size: AppButtonSize.small,
              ),
            ),
          const SizedBox(height: DesignSystem.space24),
          AppButton(
            text: 'Sign In',
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: DesignSystem.space16),
          if (widget.onRegister != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account? ',
                  style: context.textStyles.bodyMedium,
                ),
                AppButton.text(
                  text: 'Sign Up',
                  onPressed: widget.isLoading ? null : widget.onRegister,
                  size: AppButtonSize.small,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailController.text, _passwordController.text);
    }
  }
}

/// Registration form for new users
class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.onLogin,
    this.showDriverOption = false,
  });

  final Function(RegisterFormData data) onSubmit;
  final bool isLoading;
  final VoidCallback? onLogin;
  final bool showDriverOption;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isDriver = false;
  bool _acceptTerms = false;

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  enabled: !widget.isLoading,
                  validator: _validateRequired,
                ),
              ),
              const SizedBox(width: DesignSystem.space16),
              Expanded(
                child: AppInput(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  enabled: !widget.isLoading,
                  validator: _validateRequired,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.space16),
          AppInput(
            label: 'Email',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: _validateEmail,
          ),
          const SizedBox(height: DesignSystem.space16),
          AppInput(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: _validatePhone,
          ),
          const SizedBox(height: DesignSystem.space16),
          AppInput(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: _validatePassword,
          ),
          const SizedBox(height: DesignSystem.space16),
          AppInput(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: _validateConfirmPassword,
          ),
          if (widget.showDriverOption) ...[
            const SizedBox(height: DesignSystem.space16),
            CheckboxListTile(
              title: const Text('Register as Driver'),
              subtitle: const Text('I want to register as a bus driver'),
              value: _isDriver,
              onChanged: widget.isLoading ? null : (value) {
                setState(() {
                  _isDriver = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
          const SizedBox(height: DesignSystem.space16),
          CheckboxListTile(
            title: const Text('I accept the Terms of Service'),
            value: _acceptTerms,
            onChanged: widget.isLoading ? null : (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: DesignSystem.space24),
          AppButton(
            text: 'Create Account',
            onPressed: widget.isLoading || !_acceptTerms ? null : _handleSubmit,
            isLoading: widget.isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: DesignSystem.space16),
          if (widget.onLogin != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: context.textStyles.bodyMedium,
                ),
                AppButton.text(
                  text: 'Sign In',
                  onPressed: widget.isLoading ? null : widget.onLogin,
                  size: AppButtonSize.small,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
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

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = RegisterFormData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        isDriver: _isDriver,
      );
      widget.onSubmit(data);
    }
  }
}

/// Forgot password form
class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.onBackToLogin,
  });

  final Function(String email) onSubmit;
  final bool isLoading;
  final VoidCallback? onBackToLogin;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignSystem.space24),
          AppInput(
            label: 'Email',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: _validateEmail,
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: DesignSystem.space24),
          AppButton(
            text: 'Send Reset Link',
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: DesignSystem.space16),
          if (widget.onBackToLogin != null)
            AppButton.text(
              text: 'Back to Sign In',
              onPressed: widget.isLoading ? null : widget.onBackToLogin,
            ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailController.text.trim());
    }
  }
}

/// Data class for registration form
class RegisterFormData {
  const RegisterFormData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.isDriver,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final bool isDriver;
}