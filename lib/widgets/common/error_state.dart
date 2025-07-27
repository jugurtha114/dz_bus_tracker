// lib/widgets/common/error_state.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../foundation/foundation.dart';

/// Error state components for consistent error handling
/// Provides user-friendly error displays throughout the app
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText = 'Retry',
    this.actions,
    this.type = ErrorType.general,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String retryText;
  final List<Widget>? actions;
  final ErrorType type;

  @override
  Widget build(BuildContext context) {
    final errorIcon = icon ?? _getDefaultIcon();
    final errorColor = _getErrorColor(context);
    final errorTitle = title ?? _getDefaultTitle();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              errorIcon,
              size: 64,
              color: errorColor,
            ),
            const SizedBox(height: DesignSystem.space16),
            if (errorTitle != null)
              Text(
                errorTitle,
                style: context.textStyles.headlineSmall?.copyWith(
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: DesignSystem.space8),
            Text(
              message,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space24),
            if (onRetry != null || actions != null)
              Wrap(
                spacing: DesignSystem.space8,
                children: [
                  if (onRetry != null)
                    AppButton(
                      text: retryText,
                      onPressed: onRetry,
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    return switch (type) {
      ErrorType.network => Icons.wifi_off,
      ErrorType.notFound => Icons.search_off,
      ErrorType.permission => Icons.lock,
      ErrorType.validation => Icons.warning,
      ErrorType.server => Icons.cloud_off,
      ErrorType.general => Icons.error_outline,
    };
  }

  Color _getErrorColor(BuildContext context) {
    return switch (type) {
      ErrorType.network => context.colors.error,
      ErrorType.notFound => context.colors.onSurfaceVariant,
      ErrorType.permission => context.colors.error,
      ErrorType.validation => context.warningColor,
      ErrorType.server => context.colors.error,
      ErrorType.general => context.colors.error,
    };
  }

  String? _getDefaultTitle() {
    return switch (type) {
      ErrorType.network => 'No Internet Connection',
      ErrorType.notFound => 'Not Found',
      ErrorType.permission => 'Access Denied',
      ErrorType.validation => 'Invalid Input',
      ErrorType.server => 'Server Error',
      ErrorType.general => 'Something went wrong',
    };
  }
}

/// Inline error display for forms and inputs
class InlineError extends StatelessWidget {
  const InlineError({
    super.key,
    required this.message,
    this.icon,
    this.padding,
  });

  final String message;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: DesignSystem.space8),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: DesignSystem.iconSmall,
            color: context.colors.error,
          ),
          const SizedBox(width: DesignSystem.space8),
          Expanded(
            child: Text(
              message,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error banner for non-blocking errors
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.onDismiss,
    this.onAction,
    this.actionText,
    this.type = ErrorType.general,
  });

  final String message;
  final String? title;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;
  final ErrorType type;

  @override
  Widget build(BuildContext context) {
    final bannerColor = _getBannerColor(context);
    final contentColor = _getContentColor(context);

    return Material(
      color: bannerColor,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: contentColor,
              size: DesignSystem.iconMedium,
            ),
            const SizedBox(width: DesignSystem.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: context.textStyles.titleSmall?.copyWith(
                        color: contentColor,
                      ),
                    ),
                  Text(
                    message,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: contentColor,
                    ),
                  ),
                ],
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(width: DesignSystem.space12),
              AppButton.text(
                text: actionText!,
                onPressed: onAction,
                size: AppButtonSize.small,
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: DesignSystem.space8),
              IconButton(
                icon: Icon(Icons.close, color: contentColor),
                onPressed: onDismiss,
                iconSize: DesignSystem.iconMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    return switch (type) {
      ErrorType.network => Icons.wifi_off,
      ErrorType.notFound => Icons.search_off,
      ErrorType.permission => Icons.lock,
      ErrorType.validation => Icons.warning,
      ErrorType.server => Icons.cloud_off,
      ErrorType.general => Icons.error_outline,
    };
  }

  Color _getBannerColor(BuildContext context) {
    return switch (type) {
      ErrorType.network => context.colors.errorContainer,
      ErrorType.notFound => context.colors.surfaceVariant,
      ErrorType.permission => context.colors.errorContainer,
      ErrorType.validation => context.warningColor.withOpacity(0.1),
      ErrorType.server => context.colors.errorContainer,
      ErrorType.general => context.colors.errorContainer,
    };
  }

  Color _getContentColor(BuildContext context) {
    return switch (type) {
      ErrorType.network => context.colors.onErrorContainer,
      ErrorType.notFound => context.colors.onSurfaceVariant,
      ErrorType.permission => context.colors.onErrorContainer,
      ErrorType.validation => context.warningColor,
      ErrorType.server => context.colors.onErrorContainer,
      ErrorType.general => context.colors.onErrorContainer,
    };
  }
}

/// Error dialog for critical errors
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.onDismiss,
    this.retryText = 'Retry',
    this.dismissText = 'Cancel',
    this.type = ErrorType.general,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String retryText;
  final String dismissText;
  final ErrorType type;

  /// Show error dialog with simplified API
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
    ErrorType type = ErrorType.general,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message: message,
        title: title,
        onRetry: onRetry,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        _getIcon(),
        color: _getIconColor(context),
        size: DesignSystem.iconLarge,
      ),
      title: title != null ? Text(title!) : null,
      content: Text(message),
      actions: [
        if (onDismiss != null)
          AppButton.text(
            text: dismissText,
            onPressed: onDismiss,
          ),
        if (onRetry != null)
          AppButton(
            text: retryText,
            onPressed: onRetry,
          ),
      ],
    );
  }

  IconData _getIcon() {
    return switch (type) {
      ErrorType.network => Icons.wifi_off,
      ErrorType.notFound => Icons.search_off,
      ErrorType.permission => Icons.lock,
      ErrorType.validation => Icons.warning,
      ErrorType.server => Icons.cloud_off,
      ErrorType.general => Icons.error_outline,
    };
  }

  Color _getIconColor(BuildContext context) {
    return switch (type) {
      ErrorType.network => context.colors.error,
      ErrorType.notFound => context.colors.onSurfaceVariant,
      ErrorType.permission => context.colors.error,
      ErrorType.validation => context.warningColor,
      ErrorType.server => context.colors.error,
      ErrorType.general => context.colors.error,
    };
  }
}

/// Empty state for when there's no data
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionText,
    this.illustration,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: context.colors.onSurfaceVariant.withOpacity(0.6),
              ),
            const SizedBox(height: DesignSystem.space24),
            if (title != null)
              Text(
                title!,
                style: context.textStyles.headlineSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: DesignSystem.space8),
            Text(
              message,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: DesignSystem.space24),
              AppButton.outlined(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum ErrorType {
  general,
  network,
  notFound,
  permission,
  validation,
  server,
}