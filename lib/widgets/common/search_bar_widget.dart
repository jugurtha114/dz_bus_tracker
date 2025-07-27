// lib/widgets/common/search_bar_widget.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Modern search bar widget for the DZ Bus Tracker app
class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onStopSearchTap;
  final String? hintText;
  final String? stopHintText;

  const SearchBarWidget({
    super.key,
    this.onSearchTap,
    this.onStopSearchTap,
    this.hintText,
    this.stopHintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main search bar
        GestureDetector(
          onTap: onSearchTap,
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            decoration: BoxDecoration(
              color: DesignSystem.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              border: Border.all(
                color: DesignSystem.outline,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: DesignSystem.onSurfaceVariant,
                  size: DesignSystem.iconMedium,
                ),
                const SizedBox(width: DesignSystem.space12),
                Expanded(
                  child: Text(
                    hintText ?? 'Search lines, stops, or routes...',
                    style: DesignSystem.bodyMedium.copyWith(
                      color: DesignSystem.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: DesignSystem.onSurfaceVariant,
                  size: DesignSystem.iconSmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: DesignSystem.space12),

        // Stop search option
        if (onStopSearchTap != null)
          GestureDetector(
            onTap: onStopSearchTap,
            child: Container(
              padding: const EdgeInsets.all(DesignSystem.space16),
              decoration: BoxDecoration(
                color: DesignSystem.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                border: Border.all(
                  color: DesignSystem.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: DesignSystem.primary,
                    size: DesignSystem.iconMedium,
                  ),
                  const SizedBox(width: DesignSystem.space12),
                  Expanded(
                    child: Text(
                      stopHintText ?? 'Search nearby stops...',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: DesignSystem.primary,
                    size: DesignSystem.iconSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}