/// lib/presentation/widgets/line/line_stop_list.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For ETA time formatting

import '../../../config/themes/app_theme.dart';
import '../../../core/enums/eta_status.dart'; // For ETA status handling
import '../../../core/utils/date_utils.dart'; // For timeAgoOrUntil
import '../../../core/utils/logger.dart'; // For logging
import '../../../domain/entities/eta_entity.dart';
import '../../../domain/entities/stop_entity.dart';

/// Widget to display the list of stops for a specific line, including ETA information,
/// intended for use within a CustomScrollView (uses SliverList).
class LineStopList extends StatelessWidget {
  final List<StopEntity> stops;
  final Map<String, List<EtaEntity>>? etasByStopId; // Nullable map of ETAs

  const LineStopList({
    super.key,
    required this.stops,
    this.etasByStopId,
  });

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Center(child: Text('No stops found for this line.')), // TODO: Localize
        ),
      );
    }

    // Use SliverList as this widget is intended to be placed inside a CustomScrollView
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final stop = stops[index];
          // Find and sort ETAs for this specific stop
          final List<EtaEntity> stopEtas = (etasByStopId?[stop.id] ?? [])
              .sortedBy<DateTime>((eta) => eta.estimatedArrivalTime)
              .toList();

          return _StopListItemWithEta(
            stop: stop,
            stopEtas: stopEtas,
            isFirst: index == 0,
            isLast: index == stops.length - 1,
          );
        },
        childCount: stops.length,
      ),
    );
  }
}

/// Represents a single stop item within the list, including ETA display and timeline.
class _StopListItemWithEta extends StatelessWidget {
  final StopEntity stop;
  final List<EtaEntity> stopEtas;
  final bool isFirst;
  final bool isLast;

  const _StopListItemWithEta({
    required this.stop,
    required this.stopEtas,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return IntrinsicHeight( // Ensure Row children determine height together
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          _buildTimelineIndicator(context, theme),
          // Stop Name and ETAs
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppTheme.spacingMedium,
                bottom: AppTheme.spacingMedium,
                right: AppTheme.spacingMedium, // Add padding on the right
                left: AppTheme.spacingSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stop.name, style: textTheme.titleMedium),
                  if (stop.code != null && stop.code!.isNotEmpty) ...[
                     const SizedBox(height: 2),
                     Text('Code: ${stop.code}', style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium)), // TODO: Localize
                  ],
                  if (stopEtas.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSmall),
                    _buildEtaDisplay(context, stopEtas),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the vertical timeline indicator (circle and connecting lines).
  Widget _buildTimelineIndicator(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: 40, // Fixed width for the timeline elements
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Line above the circle (only visible if not the first item)
          Expanded(
            child: Container(
              width: 2,
              color: isFirst ? Colors.transparent : AppTheme.neutralLight,
            ),
          ),
          // Circle indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.background, // Background color for "punch-hole" effect
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2.5, // Slightly thicker border
              ),
            ),
          ),
          // Line below the circle (only visible if not the last item)
          Expanded(
            child: Container(
              width: 2,
              color: isLast ? Colors.transparent : AppTheme.neutralLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the display for ETAs using Chips.
  Widget _buildEtaDisplay(BuildContext context, List<EtaEntity> etas) {
     final theme = Theme.of(context);
     final textTheme = theme.textTheme;
     // Display first 1 or 2 ETAs for brevity
     final displayEtas = etas.take(2).toList();

     return Wrap(
         spacing: AppTheme.spacingSmall,
         runSpacing: AppTheme.spacingXSmall,
         children: displayEtas.map((eta) {
            final minutes = eta.minutesRemaining;
            final timeStr = DateFormat.Hm().format(eta.estimatedArrivalTime.toLocal()); // Ensure local time
            final color = _getEtaStatusColor(eta.status, theme);
            final textStyle = textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w500);

            String etaText;
            if (eta.status == EtaStatus.arrived) { etaText = 'Arrived at $timeStr'; } // TODO: Localize
            else if (eta.status == EtaStatus.cancelled) { etaText = 'Cancelled'; } // TODO: Localize
            else if (minutes != null && minutes <= 1) { etaText = 'Due'; } // TODO: Localize
            else if (minutes != null) { etaText = '$minutes min'; } // TODO: Localize 'min'
            else { etaText = timeStr; } // Fallback to time

            return Chip(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                backgroundColor: color.withOpacity(0.1),
                avatar: Icon(Icons.access_time_filled, size: 14, color: color), // Filled icon
                label: Text(etaText, style: textStyle?.copyWith(fontSize: 13)),
                side: BorderSide.none, // Remove border for cleaner look
             );

         }).toList(),
       );
   }

   /// Determines the color based on ETA status.
   Color _getEtaStatusColor(EtaStatus status, ThemeData theme) {
      switch (status) {
         case EtaStatus.approaching: return AppTheme.successColor;
         case EtaStatus.arrived: return AppTheme.successColor.withOpacity(0.7); // Slightly faded if arrived
         case EtaStatus.delayed: return AppTheme.warningColor;
         case EtaStatus.cancelled: return AppTheme.errorColor;
         case EtaStatus.scheduled:
         case EtaStatus.unknown:
         default: return theme.colorScheme.primary;
      }
   }
}

