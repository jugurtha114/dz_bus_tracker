// lib/widgets/common/error_widget.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import 'custom_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool useGlassyContainer;

  const ErrorDisplayWidget({
    Key? key,
    this.title = 'Oops!',
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.error_outline,
    this.useGlassyContainer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error icon
        Icon(
          icon,
          size: 64,
          color: useGlassyContainer ? AppColors.white : AppColors.error,
        ),

        const SizedBox(height: 16),

        // Error title
        Text(
          title,
          style: AppTextStyles.h2.copyWith(
            color: useGlassyContainer ? AppColors.white : AppColors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Error message
        Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: useGlassyContainer
                ? AppColors.white.withOpacity(0.8)
                : AppColors.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),

        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 24),

          // Action button
          CustomButton(
            text: actionText!,
            onPressed: onAction!, // Fix: Non-null assertion since we already check it's not null
            type: useGlassyContainer
                ? ButtonType.filled
                : ButtonType.outlined,
            color: useGlassyContainer ? AppColors.white : AppColors.primary,
            textColor: useGlassyContainer ? AppColors.primary : AppColors.white,
            icon: Icons.refresh, // Fixed: Remove the conditional check since we know onAction isn't null here
          ),
        ],
      ],
    );

    if (useGlassyContainer) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}

class ErrorFullScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool useAppBar;
  final String appBarTitle;

  const ErrorFullScreen({
    Key? key,
    this.title = 'Oops!',
    required this.message,
    this.actionText = 'Try Again',
    this.onAction,
    this.icon = Icons.error_outline,
    this.useAppBar = false,
    this.appBarTitle = 'Error',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: useAppBar
          ? AppBar(
        title: Text(appBarTitle),
        backgroundColor: AppColors.error,
      )
          : null,
      backgroundColor: AppColors.background,
      body: Center(
        child: ErrorDisplayWidget(
          title: title,
          message: message,
          actionText: actionText,
          onAction: onAction,
          icon: icon,
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;
  final bool useGlassyContainer;

  const EmptyStateWidget({
    Key? key,
    this.title = 'Nothing Found',
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.search_off,
    this.useGlassyContainer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
      icon: icon,
      useGlassyContainer: useGlassyContainer,
    );
  }
}