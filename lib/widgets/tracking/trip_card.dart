// lib/widgets/tracking/trip_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';
import '../common/glassy_container.dart';

/// Display modes for trip cards
enum TripDisplayMode {
  compact,   // Minimal info for lists
  standard,  // Standard card with details
  detailed,  // Full trip information
  dashboard, // Dashboard widget format
}

/// Comprehensive trip card component
class TripCard extends StatelessWidget {
  final Trip trip;
  final TripDisplayMode displayMode;
  final VoidCallback? onTap;
  final VoidCallback? onEndTrip;
  final bool showActions;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const TripCard({
    super.key,
    required this.trip,
    this.displayMode = TripDisplayMode.standard,
    this.onTap,
    this.onEndTrip,
    this.showActions = true,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case TripDisplayMode.compact:
        return _buildCompactCard(context);
      case TripDisplayMode.detailed:
        return _buildDetailedCard(context);
      case TripDisplayMode.dashboard:
        return _buildDashboardCard(context);
      default:
        return _buildStandardCard(context);
    }
  }

  /// Build compact trip card
  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: trip.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  trip.statusIcon,
                  color: trip.statusColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Trip info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip #${trip.id.substring(0, 8)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.line['name']} • ${trip.formattedDuration}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trip.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: trip.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build standard trip card
  Widget _buildStandardCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: trip.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    trip.statusIcon,
                    color: trip.statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Trip details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip #${trip.id.substring(0, 8)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.line['name'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trip.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trip.statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trip.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.formattedDuration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Route info
            Row(
              children: [
                Expanded(
                  child: _buildRoutePoint(
                    context,
                    trip.startStop?['name'] ?? 'Unknown',
                    'From',
                    Icons.radio_button_checked,
                    Colors.green,
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Expanded(
                  child: _buildRoutePoint(
                    context,
                    trip.endStop?['name'] ?? (trip.isCompleted ? 'Completed' : 'In Progress'),
                    'To',
                    trip.isCompleted ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    trip.isCompleted ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Trip metrics
            _buildTripMetrics(context),

            // Actions
            if (showActions && (!trip.isCompleted)) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  if (!trip.isCompleted)
                    ElevatedButton.icon(
                      onPressed: () => _handleEndTrip(context),
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('End Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build detailed trip card
  Widget _buildDetailedCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with full details
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: trip.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    trip.statusIcon,
                    color: trip.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Trip #${trip.id.substring(0, 8)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: trip.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: trip.statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              trip.statusText,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: trip.statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.line['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bus: ${trip.bus['license_plate']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Detailed route information
            _buildDetailedRoute(context),

            const SizedBox(height: 24),

            // Comprehensive metrics
            _buildDetailedMetrics(context),

            const SizedBox(height: 24),

            // Timestamps
            _buildTimestamps(context),

            // Actions
            if (showActions) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('View on Map'),
                    ),
                  ),
                  if (!trip.isCompleted) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleEndTrip(context),
                        icon: const Icon(Icons.stop, size: 16),
                        label: const Text('End Trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build dashboard trip card
  Widget _buildDashboardCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      child: GlassyContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(trip.statusIcon, color: trip.statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Current Trip',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: trip.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              trip.line['name'],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trip.formattedDuration,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (trip.totalDistance > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${trip.formattedDistance} traveled',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build route point widget
  Widget _buildRoutePoint(
    BuildContext context,
    String location,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Build trip metrics
  Widget _buildTripMetrics(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            context,
            Icons.straighten,
            'Distance',
            trip.formattedDistance,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            context,
            Icons.schedule,
            'Duration',
            trip.formattedDuration,
          ),
        ),
        if (trip.averageSpeed! > 0)
          Expanded(
            child: _buildMetricItem(
              context,
              Icons.speed,
              'Avg Speed',
              '${trip.averageSpeed?.toStringAsFixed(1)} km/h',
            ),
          ),
      ],
    );
  }

  /// Build detailed route
  Widget _buildDetailedRoute(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailedRoutePoint(
                  context,
                  'Start',
                  trip.startStop?['name'] ?? 'Unknown',
                  trip.formattedStartTime,
                  Colors.green,
                  true,
                ),
              ),
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Expanded(
                child: _buildDetailedRoutePoint(
                  context,
                  'End',
                  trip.endStop?['name'] ?? (trip.isCompleted ? 'Completed' : 'In Progress'),
                  trip.isCompleted ? trip.formattedEndTime : 'Ongoing',
                  trip.isCompleted ? Colors.red : Colors.grey,
                  trip.isCompleted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build detailed route point
  Widget _buildDetailedRoutePoint(
    BuildContext context,
    String label,
    String location,
    String time,
    Color color,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build detailed metrics
  Widget _buildDetailedMetrics(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Metrics',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildMetricItem(context, Icons.straighten, 'Distance', trip.formattedDistance),
              _buildMetricItem(context, Icons.schedule, 'Duration', trip.formattedDuration),
              if (trip.averageSpeed! > 0)
                _buildMetricItem(context, Icons.speed, 'Avg Speed', '${trip.averageSpeed?.toStringAsFixed(1)} km/h'),
              if (trip.maxSpeed! > 0)
                _buildMetricItem(context, Icons.trending_up, 'Max Speed', '${trip.maxSpeed?.toStringAsFixed(1)} km/h'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build timestamps section
  Widget _buildTimestamps(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.play_arrow,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Started: ${trip.formattedStartTime}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (trip.isCompleted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.stop,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ended: ${trip.formattedEndTime}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build metric item
  Widget _buildMetricItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle end trip action
  void _handleEndTrip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Trip'),
        content: const Text('Are you sure you want to end this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = context.read<TrackingProvider>();
              provider.endTrip(trip.id);
              onEndTrip?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }
}