// lib/widgets/features/passenger/line_list_item.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../../models/line_model.dart';

/// List item widget for displaying bus line information
class LineListItem extends StatelessWidget {
  final Line line;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool isSelected;

  const LineListItem({
    super.key,
    required this.line,
    this.onTap,
    this.showDetails = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = line.color != null
        ? Color(int.parse('0xFF${line.color!.replaceAll('#', '')}'))
        : DesignSystem.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.space8),
      decoration: BoxDecoration(
        color: isSelected 
            ? lineColor.withOpacity(0.1)
            : DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        border: Border.all(
          color: isSelected 
              ? lineColor
              : DesignSystem.outline,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: Row(
              children: [
                // Line indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      line.code,
                      style: DesignSystem.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: DesignSystem.space16),

                // Line details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line name
                      Text(
                        line.name,
                        style: DesignSystem.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignSystem.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: DesignSystem.space4),

                      // Route information
                      if (line.startLocation != null && line.endLocation != null)
                        Text(
                          '${line.startLocation} → ${line.endLocation}',
                          style: DesignSystem.bodySmall.copyWith(
                            color: DesignSystem.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      if (showDetails) ...[
                        const SizedBox(height: DesignSystem.space8),
                        
                        // Additional details
                        Row(
                          children: [
                            // Active status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignSystem.space8,
                                vertical: DesignSystem.space2,
                              ),
                              decoration: BoxDecoration(
                                color: (line.isActive ?? true)
                                    ? DesignSystem.success.withOpacity(0.1)
                                    : DesignSystem.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                              ),
                              child: Text(
                                (line.isActive ?? true) ? 'Active' : 'Inactive',
                                style: DesignSystem.labelSmall.copyWith(
                                  color: (line.isActive ?? true)
                                      ? DesignSystem.success
                                      : DesignSystem.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(width: DesignSystem.space8),

                            // Frequency info
                            if (line.frequency != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: DesignSystem.iconSmall,
                                    color: DesignSystem.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: DesignSystem.space4),
                                  Text(
                                    '${line.frequency} min',
                                    style: DesignSystem.labelSmall.copyWith(
                                      color: DesignSystem.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: DesignSystem.iconSmall,
                  color: DesignSystem.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}