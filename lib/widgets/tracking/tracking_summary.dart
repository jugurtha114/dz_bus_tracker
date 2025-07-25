// lib/widgets/tracking/tracking_summary.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';
import '../common/glassy_container.dart';

/// Compact tracking summary widget for dashboards
class TrackingSummary extends StatelessWidget {
  final String? busId;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const TrackingSummary({
    super.key,
    this.busId,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: margin ?? const EdgeInsets.all(16),
            child: GlassyContainer(
              padding: padding ?? const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(context, provider),
                  const SizedBox(height: 16),
                  _buildRecentActivity(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build header
  Widget _buildHeader(BuildContext context, TrackingProvider provider) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.track_changes,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tracking Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (busId != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Bus: $busId',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (provider.isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          )
        else
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
      ],
    );
  }

  /// Build metrics grid
  Widget _buildMetricsGrid(BuildContext context, TrackingProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            context,
            'Active Trips',
            provider.trips.where((t) => !t.isCompleted).length.toString(),
            Icons.directions_bus,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricItem(
            context,
            'Anomalies',
            provider.anomalies.where((a) => !a.resolved).length.toString(),
            Icons.warning,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricItem(
            context,
            'Updates',
            provider.locationUpdates.where((u) => u.isRecent).length.toString(),
            Icons.location_on,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// Build metric item
  Widget _buildMetricItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build recent activity
  Widget _buildRecentActivity(BuildContext context, TrackingProvider provider) {
    final theme = Theme.of(context);
    
    // Get the most recent activity items
    final recentActivities = _getRecentActivities(provider);
    
    if (recentActivities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'No recent activity',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        ...recentActivities.take(3).map(
          (activity) => _buildActivityItem(context, activity),
        ),
      ],
    );
  }

  /// Build activity item
  Widget _buildActivityItem(BuildContext context, _ActivityItem activity) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            activity.icon,
            size: 14,
            color: activity.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity.title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            activity.timeAgo,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Get recent activities from all tracking data
  List<_ActivityItem> _getRecentActivities(TrackingProvider provider) {
    final activities = <_ActivityItem>[];

    // Add recent trips
    for (final trip in provider.trips.take(2)) {
      activities.add(_ActivityItem(
        title: trip.isCompleted 
            ? 'Trip completed on ${trip.line['name']}'
            : 'Trip started on ${trip.line['name']}',
        timeAgo: trip.timeAgo,
        icon: trip.isCompleted ? Icons.check_circle : Icons.play_arrow,
        color: trip.isCompleted ? Colors.green : Colors.blue,
        timestamp: trip.createdAt,
      ));
    }

    // Add recent anomalies
    for (final anomaly in provider.anomalies.where((a) => !a.resolved).take(2)) {
      activities.add(_ActivityItem(
        title: '${anomaly.typeDisplayName} detected',
        timeAgo: anomaly.timeAgo,
        icon: Icons.warning,
        color: anomaly.severityColor,
        timestamp: anomaly.createdAt,
      ));
    }

    // Add recent location updates
    for (final update in provider.locationUpdates.take(1)) {
      activities.add(_ActivityItem(
        title: 'Location updated',
        timeAgo: update.timeAgo,
        icon: Icons.location_on,
        color: Colors.green,
        timestamp: update.createdAt,
      ));
    }

    // Sort by timestamp (most recent first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return activities;
  }
}

/// Internal class for activity items
class _ActivityItem {
  final String title;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final DateTime timestamp;

  const _ActivityItem({
    required this.title,
    required this.timeAgo,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}