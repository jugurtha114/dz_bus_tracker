/// lib/presentation/widgets/line/line_detail_header.dart

import 'package:flutter/material.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/logger.dart'; // Use Log if needed
import '../../../domain/entities/line_entity.dart';

/// Widget to display header information for the Line Details page.
/// Includes line name, color indicator, description, start/end stops, and counts.
class LineDetailHeader extends StatelessWidget {
  final LineEntity line;

  const LineDetailHeader({super.key, required this.line});

   // Helper to parse color
   Color _parseLineColor(BuildContext context, String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Theme.of(context).colorScheme.primary;
    try { String hex = colorHex.toUpperCase().replaceAll("#", ""); if (hex.length == 6) hex = "FF$hex"; if (hex.length == 8) return Color(int.parse("0x$hex")); } catch (e) { Log.e("Error parsing line color: $colorHex", error: e); }
    return Theme.of(context).colorScheme.primary;
   }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final lineColor = _parseLineColor(context, line.color);

    return Container(
       padding: const EdgeInsets.all(AppTheme.spacingMedium),
       // Add subtle background if needed, e.g., based on theme surface variant
       // color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Line name and color bar (optional if already in AppBar)
           // Row(
           //   children: [
           //      Container(width: 6, height: 24, color: lineColor, margin: const EdgeInsets.only(right: AppTheme.spacingSmall)),
           //      Expanded(child: Text(line.name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
           //   ],
           // ),
           // Description
           if (line.description != null && line.description!.isNotEmpty) ...[
             // const SizedBox(height: AppTheme.spacingSmall),
             Text(line.description!, style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium)),
             const SizedBox(height: AppTheme.spacingMedium),
           ],
           // Start/End Stops Row
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                _buildEndpointInfo(context, Icons.trip_origin, line.startStopName, 'Start'), // TODO: Localize 'Start'
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
                  child: Icon(Icons.arrow_forward, color: AppTheme.neutralMedium.withOpacity(0.7), size: 20),
                ),
                _buildEndpointInfo(context, Icons.place, line.endStopName, 'End', alignRight: true), // TODO: Localize 'End'
             ],
           ),
            const SizedBox(height: AppTheme.spacingMedium),
            // Counts Row
            Row(
               children: [
                   Icon(Icons.directions_bus_filled_outlined, size: 18, color: theme.colorScheme.primary),
                   const SizedBox(width: AppTheme.spacingSmall),
                   Text('${line.activeBusesCount} Active Buses', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)), // TODO: Localize
                   const SizedBox(width: AppTheme.spacingLarge),
                    Icon(Icons.signpost_outlined, size: 18, color: AppTheme.neutralMedium),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text('${line.stopsCount} Stops', style: textTheme.bodyMedium), // TODO: Localize
                    const Spacer(), // Pushes to edges if needed
                    if (line.estimatedDurationMinutes != null) ...[
                       Icon(Icons.timer_outlined, size: 18, color: AppTheme.neutralMedium),
                       const SizedBox(width: AppTheme.spacingXSmall),
                       Text('~${line.estimatedDurationMinutes} min', style: textTheme.bodyMedium), // TODO: Localize '~', 'min'
                    ]
               ],
            ),
         ],
       ),
    );
  }

  /// Builds the UI for displaying start or end stop information.
  Widget _buildEndpointInfo(BuildContext context, IconData icon, String name, String label, {bool alignRight = false}) {
     final textTheme = Theme.of(context).textTheme;
      return Expanded(
        child: Column(
           crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
             Text(label, style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium)),
             const SizedBox(height: 2),
             Row(
                mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Show icon after text if aligned right
                  if (!alignRight) ...[
                     Icon(icon, size: 16, color: AppTheme.neutralMedium),
                     const SizedBox(width: AppTheme.spacingXSmall),
                  ],
                  // Need Flexible/Expanded for text to wrap correctly
                  Flexible(
                     child: Text(
                        name,
                        style: textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: alignRight ? TextAlign.end : TextAlign.start,
                     )
                  ),
                   if (alignRight) ...[
                     const SizedBox(width: AppTheme.spacingXSmall),
                     Icon(icon, size: 16, color: AppTheme.neutralMedium),
                  ],
                ],
             ),
          ],
        ),
      );
  }
}
