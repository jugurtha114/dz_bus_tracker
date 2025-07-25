// lib/widgets/auth/login_form.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password) onSubmit;
  final bool isLoading;
  final VoidCallback? onForgotPassword;

  const LoginForm({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            onSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 16),

          // Remember me checkbox and forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me
              Row(
                children: [
                  SizedBox(
                    width: 24,
        
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8, height: 40),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                    child: Text(
                      'Remember me',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // Forgot password
              if (widget.onForgotPassword != null)
                GestureDetector(
                  onTap: widget.onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Login button
          CustomButton(
        text: 'Login',
        onPressed: _submit,
        isLoading: widget.isLoading,
        color: Theme.of(context).colorScheme.primary
      ),
        ],
      ),
    );
  }
}