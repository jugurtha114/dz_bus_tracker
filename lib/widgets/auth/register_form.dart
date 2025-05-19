// lib/widgets/auth/register_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class RegisterForm extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  final bool isLoading;
  final String userType;

  const RegisterForm({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
    this.userType = 'passenger',
  }) : super(key: key);

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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final userData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'password': _passwordController.text,
        'confirm_password': _confirmPasswordController.text,
      };

      widget.onSubmit(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First and last name
          Row(
            children: [
              // First name
              Expanded(
                child: CustomTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  validator: (value) => ValidationUtils.validateRequired(
                    value,
                    fieldName: 'First name',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),

              const SizedBox(width: 16),

              // Last name
              Expanded(
                child: CustomTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  validator: (value) => ValidationUtils.validateRequired(
                    value,
                    fieldName: 'Last name',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Email
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: ValidationUtils.validateEmail,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Phone
          CustomTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: ValidationUtils.validatePhone,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Password
          CustomTextField(
            label: 'Password',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: ValidationUtils.validatePassword,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Confirm Password
          CustomTextField(
            label: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
            validator: (value) => ValidationUtils.validateConfirmPassword(
              _passwordController.text,
              value,
            ),
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // Register button
          CustomButton(
            text: 'Register',
            onPressed: _submitForm,
            isLoading: widget.isLoading,
            height: 50,
          ),
        ],
      ),
    );
  }
}