/// lib/presentation/widgets/common/empty_list_indicator.dart

import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart'; // For potential illustration

/// A reusable widget displayed when a list or search result is empty.
class EmptyListIndicator extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? iconData;
  final String? imageAsset; // Optional image instead of icon
  final VoidCallback? onRetry; // Optional action button
  final String? retryButtonText;

  const EmptyListIndicator({
    super.key,
    required this.message,
    this.title,
    this.iconData, // = Icons.search_off_rounded, // Default icon?
    this.imageAsset, // = AssetsConstants.emptyStateIllustration, // Default image?
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Image or Icon
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                height: 120,
                color: isDark ? AppTheme.neutralLight.withOpacity(0.6) : AppTheme.neutralMedium.withOpacity(0.6),
              )
            else if (iconData != null)
              Icon(
                iconData,
                size: 80,
                 color: isDark ? AppTheme.neutralLight.withOpacity(0.6) : AppTheme.neutralMedium.withOpacity(0.6),
              )
            else // Default if nothing provided
               Icon(
                Icons.info_outline_rounded,
                size: 80,
                color: isDark ? AppTheme.neutralLight.withOpacity(0.6) : AppTheme.neutralMedium.withOpacity(0.6),
              ),

            const SizedBox(height: AppTheme.spacingLarge),

             // Optional Title
            if (title != null && title!.isNotEmpty)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (title != null && title!.isNotEmpty)
                const SizedBox(height: AppTheme.spacingSmall),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
            ),

            // Optional Retry Button
            if (onRetry != null)
              const SizedBox(height: AppTheme.spacingLarge),
            if (onRetry != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  )
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(retryButtonText ?? 'Try Again'), // TODO: Localize 'Try Again'
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}
