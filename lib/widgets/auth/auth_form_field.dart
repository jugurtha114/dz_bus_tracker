// lib/widgets/auth/auth_form_field.dart

import 'package:flutter/material.dart';
import '../common/custom_text_field.dart';

/// Reusable auth form field with consistent styling
class AuthFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;

  const AuthFormField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      validator: validator,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
      borderColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }
}

/// Password field with toggle visibility
class AuthPasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AuthPasswordField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      obscureText: _isObscured,
      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
      borderColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }
}

/// Email field with validation
class AuthEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AuthEmailField({
    Key? key,
    required this.controller,
    this.validator,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      label: 'Email',
      hintText: 'Enter your email address',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: validator,
      textInputAction: textInputAction,
    );
  }
}

/// Phone field with validation
class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AuthPhoneField({
    Key? key,
    required this.controller,
    this.validator,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      label: 'Phone Number',
      hintText: 'Enter your phone number',
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      validator: validator,
      textInputAction: textInputAction,
    );
  }
}

/// Name field (first name, last name, etc.)
class AuthNameField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AuthNameField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      label: label,
      hintText: hintText,
      controller: controller,
      keyboardType: TextInputType.name,
      prefixIcon: Icons.person_outline,
      validator: validator,
      textInputAction: textInputAction,
    );
  }
}