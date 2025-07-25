// lib/widgets/auth/auth_button.dart

import 'package:flutter/material.dart';
import '../common/custom_button.dart';

/// Primary authentication button with consistent styling
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonType type;

  const AuthButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = ButtonType.primary,
  }) : super(key: key);

  const AuthButton.primary({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : type = ButtonType.primary, super(key: key);

  const AuthButton.secondary({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : type = ButtonType.secondary, super(key: key);

  const AuthButton.outlined({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : type = ButtonType.outline, super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      type: type,
      fullWidth: true,
    );
  }
}

/// Text button for auth actions (forgot password, register, etc.)
class AuthTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  const AuthTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color ?? Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Link-style button for secondary actions
class AuthLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool underline;

  const AuthLinkButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.underline = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
          decoration: underline ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}