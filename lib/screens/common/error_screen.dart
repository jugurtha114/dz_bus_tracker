// lib/screens/common/error_screen.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../../widgets/widgets.dart';

/// Error screen for displaying various error states
class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.errorCode,
    this.onRetry,
    this.onGoHome,
  });

  /// Factory constructor for network errors
  factory ErrorScreen.network({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return ErrorScreen(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      errorCode: 'NETWORK_ERROR',
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }

  /// Factory constructor for server errors
  factory ErrorScreen.server({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return ErrorScreen(
      title: 'Server Error',
      message: 'Our servers are experiencing issues. Please try again later.',
      errorCode: 'SERVER_ERROR',
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }

  /// Factory constructor for not found errors
  factory ErrorScreen.notFound({
    VoidCallback? onGoHome,
  }) {
    return ErrorScreen(
      title: 'Page Not Found',
      message: 'The page you\'re looking for doesn\'t exist or has been moved.',
      errorCode: '404',
      onGoHome: onGoHome,
    );
  }

  /// Factory constructor for permission errors
  factory ErrorScreen.permission({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return ErrorScreen(
      title: 'Permission Denied',
      message: 'You don\'t have permission to access this resource.',
      errorCode: 'PERMISSION_DENIED',
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }

  /// Factory constructor for maintenance mode
  factory ErrorScreen.maintenance({
    VoidCallback? onRetry,
  }) {
    return ErrorScreen(
      title: 'Under Maintenance',
      message: 'We\'re performing maintenance to improve your experience. Please check back soon.',
      errorCode: 'MAINTENANCE',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Error',
      showBackButton: Navigator.of(context).canPop(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSystem.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              _buildErrorIcon(context),
              
              const SizedBox(height: DesignSystem.space24),
              
              // Error Content
              _buildErrorContent(context),
              
              const SizedBox(height: DesignSystem.space32),
              
              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (errorCode) {
      case 'NETWORK_ERROR':
        iconData = Icons.wifi_off;
        iconColor = context.colors.error;
        break;
      case 'SERVER_ERROR':
        iconData = Icons.cloud_off;
        iconColor = context.colors.error;
        break;
      case '404':
        iconData = Icons.search_off;
        iconColor = context.warningColor;
        break;
      case 'PERMISSION_DENIED':
        iconData = Icons.lock;
        iconColor = context.colors.error;
        break;
      case 'MAINTENANCE':
        iconData = Icons.construction;
        iconColor = context.infoColor;
        break;
      default:
        iconData = Icons.error_outline;
        iconColor = context.colors.error;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 60,
        color: iconColor,
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space24),
        child: Column(
          children: [
            // Error Title
            Text(
              title ?? 'Something went wrong',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            // Error Message
            Text(
              message ?? 'An unexpected error occurred. Please try again.',
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Error Code (if provided)
            if (errorCode != null) ...[
              const SizedBox(height: DesignSystem.space16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space12,
                  vertical: DesignSystem.space6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Text(
                  'Error Code: $errorCode',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Retry Button (if callback provided)
        if (onRetry != null)
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Try Again',
              onPressed: onRetry!,
              icon: Icons.refresh,
            ),
          ),
        
        // Spacing between buttons
        if (onRetry != null && onGoHome != null)
          const SizedBox(height: DesignSystem.space12),
        
        // Go Home Button (if callback provided)
        if (onGoHome != null)
          SizedBox(
            width: double.infinity,
            child: AppButton.outlined(
              text: 'Go to Home',
              onPressed: onGoHome!,
              icon: Icons.home,
            ),
          ),
        
        // Default back button if no callbacks provided
        if (onRetry == null && onGoHome == null && Navigator.of(context).canPop())
          SizedBox(
            width: double.infinity,
            child: AppButton.outlined(
              text: 'Go Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.arrow_back,
            ),
          ),
        
        const SizedBox(height: DesignSystem.space24),
        
        // Additional Help
        _buildHelpSection(context),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return AppCard.outlined(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 20,
                  color: context.colors.primary,
                ),
                const SizedBox(width: DesignSystem.space8),
                Text(
                  'Need Help?',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            Text(
              'If this problem persists, please contact our support team.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            AppButton.text(
              text: 'Contact Support',
              onPressed: () => _contactSupport(context),
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support contact feature coming soon'),
      ),
    );
  }
}