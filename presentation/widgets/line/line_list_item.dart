/// lib/presentation/widgets/line/line_list_item.dart

import 'dart:math' as Log;

import 'package:flutter/material.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/helpers.dart'; // For parsing color
import '../../../domain/entities/line_entity.dart';

/// Widget to display a single bus line in a list format.
/// Shows line name, start/end stops, color indicator, and active bus count.
class LineListItem extends StatelessWidget {
  final LineEntity line;
  final VoidCallback onTap;

  const LineListItem({
    super.key,
    required this.line,
    required this.onTap,
  });

  /// Parses the hex color string (e.g., "#FF0000" or "FF0000") into a Color object.
  /// Returns a default color if parsing fails or input is invalid.
  Color _parseLineColor(BuildContext context) {
    final colorString = line.color;
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.7); // Default color
    }
    try {
      String hexColor = colorString.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor"; // Add alpha if missing
      }
      if (hexColor.length == 8) {
        return Color(int.parse("0x$hexColor"));
      }
    } catch (e) {
      Log.e;
       // Log.e("Error parsing line color: $colorString", error: e);
    }
     return Theme.of(context).colorScheme.primary.withOpacity(0.7); // Fallback default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final lineColor = _parseLineColor(context);

    return Card(
      // Use Card for subtle elevation and background
      elevation: AppTheme.elevationSmall,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall / 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
      clipBehavior: Clip.antiAlias, // Clip InkWell ripple
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            children: [
              // Line Color Indicator
              Container(
                width: 10,
                height: 60, // Adjust height to match content roughly
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall / 2),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),

              // Line Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall / 2),
                    Text(
                      '${line.startStopName} → ${line.endStopName}',
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                     const SizedBox(height: AppTheme.spacingXSmall),
                     Row(
                        children: [
                          Icon(Icons.directions_bus, size: 16, color: colorScheme.primary),
                          const SizedBox(width: AppTheme.spacingXSmall),
                          Text(
                            '${line.activeBusesCount}',
                             style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.primary),
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                           Icon(Icons.signpost_outlined, size: 16, color: AppTheme.neutralMedium),
                           const SizedBox(width: AppTheme.spacingXSmall),
                          Text(
                            '${line.stopsCount} stops', // TODO: Localize 'stops'
                             style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
                          ),
                        ],
                     )
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),

              // Trailing Arrow
              Icon(
                Icons.chevron_right,
                color: AppTheme.neutralMedium.withOpacity(0.7),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
