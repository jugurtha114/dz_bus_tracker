// lib/widgets/common/error_states.dart

import 'package:flutter/material.dart';
import 'custom_button.dart';

enum ErrorType { network, notFound, unauthorized, server, unknown, validation, timeout }

class ErrorStateWidget extends StatelessWidget {
  final ErrorType errorType;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? retryText;
  final String? backText;
  final Widget? customIcon;
  final bool showRetryButton;
  final bool showBackButton;

  const ErrorStateWidget({
    super.key,
    required this.errorType,
    this.title,
    this.message,
    this.onRetry,
    this.onBack,
    this.retryText,
    this.backText,
    this.customIcon,
    this.showRetryButton = true,
    this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getErrorColor(colorScheme).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: customIcon ?? Icon(
                _getErrorIcon(),
                size: 64,
                color: _getErrorColor(colorScheme),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Error Title
            Text(
              title ?? _getDefaultTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Error Message
            Text(
              message ?? _getDefaultMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.1),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Column(
              children: [
                if (showRetryButton && onRetry != null)
                  CustomButton(
        text: retryText ?? 'Try Again',
        onPressed: onRetry,
        type: ButtonType.primary,
        size: ButtonSize.large,
        fullWidth: true,
        ),
                
                if (showRetryButton && onRetry != null && showBackButton && onBack != null)
                  const SizedBox(height: 16),
                
                if (showBackButton && onBack != null)
                  CustomButton(
        text: backText ?? 'Go Back',
        onPressed: onBack,
        type: ButtonType.outline,
        size: ButtonSize.large,
        fullWidth: true,
        ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.unauthorized:
        return Icons.lock;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.timeout:
        return Icons.access_time;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getErrorColor(ColorScheme colorScheme) {
    switch (errorType) {
      case ErrorType.network:
      case ErrorType.timeout:
        return colorScheme.secondary;
      case ErrorType.unauthorized:
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.server:
      case ErrorType.unknown:
        return colorScheme.error;
      case ErrorType.notFound:
        return colorScheme.primary;
    }
  }

  String _getDefaultTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.unauthorized:
        return 'Access Denied';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.validation:
        return 'Invalid Input';
      case ErrorType.timeout:
        return 'Request Timeout';
      case ErrorType.unknown:
        return 'Something Went Wrong';
    }
  }

  String _getDefaultMessage() {
    switch (errorType) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.notFound:
        return 'The requested resource could not be found.';
      case ErrorType.unauthorized:
        return 'You don\'t have permission to access this resource.';
      case ErrorType.server:
        return 'Our servers are experiencing issues. Please try again later.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.timeout:
        return 'The request took too long to complete. Please try again.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.1),
          width: 1
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: textColor ?? colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12, height: 40),
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                color: textColor ?? colorScheme.onErrorContainer,
                size: 20,
              ),
              tooltip: 'Retry',
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionText,
    this.backgroundColor,
    this.textColor,
    this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: backgroundColor ?? colorScheme.errorContainer,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: textColor ?? colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 12, height: 40),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor ?? colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(width: 12, height: 40),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionText!,
                  style: TextStyle(
                    color: textColor ?? colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 8, height: 40),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: textColor ?? colorScheme.onErrorContainer,
                  size: 20,
                ),
                tooltip: 'Dismiss',
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ValidationErrorWidget extends StatelessWidget {
  final String? errorText;
  final EdgeInsetsGeometry? padding;

  const ValidationErrorWidget({
    super.key,
    this.errorText,
    this.padding});

  @override
  Widget build(BuildContext context) {
    if (errorText == null || errorText!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 4, left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error,
            size: 16,
            color: colorScheme.error,
          ),
          const SizedBox(width: 4, height: 40),
          Expanded(
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}