// lib/widgets/tracking/location_update_card.dart

import 'package:flutter/material.dart';

import '../../models/tracking_model.dart';
import '../common/glassy_container.dart';

/// Display modes for location update cards
enum LocationUpdateDisplayMode {
  compact,   // Minimal info for lists
  standard,  // Standard card with details
  detailed,  // Full location information
  timeline,  // Timeline-style display
}

/// Comprehensive location update card component
class LocationUpdateCard extends StatelessWidget {
  final LocationUpdate locationUpdate;
  final LocationUpdateDisplayMode displayMode;
  final VoidCallback? onTap;
  final bool showMap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const LocationUpdateCard({
    super.key,
    required this.locationUpdate,
    this.displayMode = LocationUpdateDisplayMode.standard,
    this.onTap,
    this.showMap = false,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case LocationUpdateDisplayMode.compact:
        return _buildCompactCard(context);
      case LocationUpdateDisplayMode.detailed:
        return _buildDetailedCard(context);
      case LocationUpdateDisplayMode.timeline:
        return _buildTimelineCard(context);
      default:
        return _buildStandardCard(context);
    }
  }

  /// Build compact location update card
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
              // Location indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Location info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationUpdate.formattedCoordinates,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locationUpdate.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Speed indicator
              if (locationUpdate.speed! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${locationUpdate.speed?.toStringAsFixed(1)} km/h',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
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

  /// Build standard location update card
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
                // Location icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Location details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Update',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locationUpdate.formattedCoordinates,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timestamp
                Text(
                  locationUpdate.timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Location metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    Icons.speed,
                    'Speed',
                    '${locationUpdate.speed?.toStringAsFixed(1)} km/h',
                    theme.colorScheme.secondary,
                  ),
                ),
                if (locationUpdate.heading! >= 0)
                  Expanded(
                    child: _buildMetricItem(
                      context,
                      Icons.navigation,
                      'Heading',
                      '${locationUpdate.heading?.toStringAsFixed(0)}°',
                      theme.colorScheme.tertiary,
                    ),
                  ),
                if (locationUpdate.accuracy! > 0)
                  Expanded(
                    child: _buildMetricItem(
                      context,
                      Icons.my_location,
                      'Accuracy',
                      '${locationUpdate.accuracy?.toStringAsFixed(1)}m',
                      Colors.orange,
                    ),
                  ),
              ],
            ),

            // Bus and trip info
            if (locationUpdate.bus != null || locationUpdate.trip != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    if (locationUpdate.bus != null) ...[
                      Icon(
                        Icons.directions_bus,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bus: ${locationUpdate.bus!['license_plate']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (locationUpdate.bus != null && locationUpdate.trip != null)
                      const SizedBox(width: 16),
                    if (locationUpdate.trip != null) ...[
                      Icon(
                        Icons.route,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trip: ${locationUpdate.trip!['id'].substring(0, 8)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Nearest stop if available
            if (locationUpdate.nearestStop != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Near: ${locationUpdate.nearestStop!['name']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Actions
            if (showMap) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('View on Map'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build detailed location update card
  Widget _buildDetailedCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with comprehensive details
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Update',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        locationUpdate.formattedTimestamp,
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

            // Coordinates section
            _buildDetailSection(
              context,
              'Coordinates',
              Icons.place,
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCoordinateItem(context, 'Latitude', locationUpdate.latitude),
                      ),
                      Expanded(
                        child: _buildCoordinateItem(context, 'Longitude', locationUpdate.longitude),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locationUpdate.formattedCoordinates,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Movement metrics
            _buildDetailSection(
              context,
              'Movement Data',
              Icons.directions,
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildDetailMetricItem(
                    context,
                    'Speed',
                    '${locationUpdate.speed?.toStringAsFixed(1)} km/h',
                    Icons.speed,
                  ),
                  if (locationUpdate.heading! >= 0)
                    _buildDetailMetricItem(
                      context,
                      'Heading',
                      '${locationUpdate.heading?.toStringAsFixed(0)}°',
                      Icons.navigation,
                    ),
                  if (locationUpdate.accuracy! > 0)
                    _buildDetailMetricItem(
                      context,
                      'Accuracy',
                      '${locationUpdate.accuracy?.toStringAsFixed(1)}m',
                      Icons.my_location,
                    ),
                  if (locationUpdate.altitude != null)
                    _buildDetailMetricItem(
                      context,
                      'Altitude',
                      '${locationUpdate.altitude!.toStringAsFixed(1)}m',
                      Icons.terrain,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Context information
            if (locationUpdate.bus != null || locationUpdate.trip != null) ...[
              _buildDetailSection(
                context,
                'Context',
                Icons.info,
                Column(
                  children: [
                    if (locationUpdate.bus != null)
                      Row(
                        children: [
                          Icon(
                            Icons.directions_bus,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bus: ${locationUpdate.bus!['license_plate']}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    if (locationUpdate.bus != null && locationUpdate.trip != null)
                      const SizedBox(height: 8),
                    if (locationUpdate.trip != null)
                      Row(
                        children: [
                          Icon(
                            Icons.route,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trip: ${locationUpdate.trip!['id'].substring(0, 8)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    if (locationUpdate.nearestStop != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nearest: ${locationUpdate.nearestStop!['name']}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Technical details
            _buildDetailSection(
              context,
              'Technical Info',
              Icons.settings,
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTechnicalItem(context, 'Update ID', locationUpdate.id.substring(0, 8)),
                      ),
                      Expanded(
                        child: _buildTechnicalItem(context, 'Timestamp', locationUpdate.formattedTime),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            if (showMap) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build timeline-style location update card
  Widget _buildTimelineCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: GlassyContainer(
                padding: padding ?? const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          locationUpdate.formattedTime,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        if (locationUpdate.speed != null && locationUpdate.speed! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${locationUpdate.speed?.toStringAsFixed(1)} km/h',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Text(
                      locationUpdate.formattedCoordinates,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Additional info
                    if (locationUpdate.nearestStop != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Near: ${locationUpdate.nearestStop!['name']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build metric item
  Widget _buildMetricItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
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
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail section
  Widget _buildDetailSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  /// Build coordinate item
  Widget _buildCoordinateItem(BuildContext context, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value.toStringAsFixed(6),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build detailed metric item
  Widget _buildDetailMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
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

  /// Build technical item
  Widget _buildTechnicalItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}