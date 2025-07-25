// lib/widgets/tracking/anomaly_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';
import '../common/glassy_container.dart';

/// Display modes for anomaly cards
enum AnomalyDisplayMode {
  compact,   // Minimal info for lists
  standard,  // Standard card with details
  detailed,  // Full anomaly information
  alert,     // Alert-style display
}

/// Comprehensive anomaly card component
class AnomalyCard extends StatelessWidget {
  final Anomaly anomaly;
  final AnomalyDisplayMode displayMode;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;
  final bool showActions;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const AnomalyCard({
    super.key,
    required this.anomaly,
    this.displayMode = AnomalyDisplayMode.standard,
    this.onTap,
    this.onResolve,
    this.showActions = true,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case AnomalyDisplayMode.compact:
        return _buildCompactCard(context);
      case AnomalyDisplayMode.detailed:
        return _buildDetailedCard(context);
      case AnomalyDisplayMode.alert:
        return _buildAlertCard(context);
      default:
        return _buildStandardCard(context);
    }
  }

  /// Build compact anomaly card
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
              // Severity indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: anomaly.severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  anomaly.typeIcon,
                  color: anomaly.severityColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Anomaly info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anomaly.typeDisplayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      anomaly.timeAgo,
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
                  color: anomaly.resolved 
                      ? Colors.green.withOpacity(0.1)
                      : anomaly.severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  anomaly.resolved ? 'Resolved' : anomaly.severityDisplayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: anomaly.resolved ? Colors.green : anomaly.severityColor,
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

  /// Build standard anomaly card
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
                // Type icon with severity color
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: anomaly.severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    anomaly.typeIcon,
                    color: anomaly.severityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Anomaly details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anomaly.typeDisplayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (anomaly.bus != null)
                        Text(
                          'Bus: ${anomaly.bus!['license_plate']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status and severity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: anomaly.resolved 
                            ? Colors.green.withOpacity(0.1)
                            : anomaly.severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            anomaly.resolved ? Icons.check_circle : Icons.warning,
                            size: 12,
                            color: anomaly.resolved ? Colors.green : anomaly.severityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            anomaly.resolved ? 'Resolved' : anomaly.severityDisplayName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: anomaly.resolved ? Colors.green : anomaly.severityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anomaly.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Description
            if (anomaly.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  anomaly.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],

            // Location if available
            if (anomaly.hasLocation) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ${anomaly.latitude.toStringAsFixed(6)}, ${anomaly.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],

            // Actions
            if (showActions) ...[
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
                  if (!anomaly.resolved)
                    ElevatedButton.icon(
                      onPressed: () => _handleResolve(context),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Resolve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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

  /// Build detailed anomaly card
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
                    color: anomaly.severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    anomaly.typeIcon,
                    color: anomaly.severityColor,
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
                          Expanded(
                            child: Text(
                              anomaly.typeDisplayName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: anomaly.resolved 
                                  ? Colors.green.withOpacity(0.1)
                                  : anomaly.severityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: anomaly.resolved 
                                    ? Colors.green.withOpacity(0.3)
                                    : anomaly.severityColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  anomaly.resolved ? Icons.check_circle : Icons.warning,
                                  size: 14,
                                  color: anomaly.resolved ? Colors.green : anomaly.severityColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  anomaly.resolved ? 'Resolved' : anomaly.severityDisplayName,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: anomaly.resolved ? Colors.green : anomaly.severityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (anomaly.bus != null) ...[
                        Text(
                          'Bus: ${anomaly.bus!['license_plate']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (anomaly.trip != null)
                        Text(
                          'Trip: ${anomaly.trip!['id'].substring(0, 8)}',
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

            // Description section
            if (anomaly.description.isNotEmpty) ...[
              _buildDetailSection(
                context,
                'Description',
                Icons.description,
                anomaly.description,
              ),
              const SizedBox(height: 16),
            ],

            // Technical details
            _buildTechnicalDetails(context),

            const SizedBox(height: 16),

            // Location details
            if (anomaly.hasLocation) ...[
              _buildLocationDetails(context),
              const SizedBox(height: 16),
            ],

            // Resolution details
            if (anomaly.resolved) ...[
              _buildResolutionDetails(context),
              const SizedBox(height: 16),
            ],

            // Timeline
            _buildTimeline(context),

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
                  if (!anomaly.resolved) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleResolve(context),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Mark Resolved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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

  /// Build alert-style anomaly card
  Widget _buildAlertCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shadowColor: anomaly.severityColor.withOpacity(0.3),
        color: anomaly.severityColor.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: anomaly.severityColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: Column(
            children: [
              // Alert header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: anomaly.severityColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      anomaly.typeIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANOMALY DETECTED',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: anomaly.severityColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          anomaly.typeDisplayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Alert details
              if (anomaly.description.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    anomaly.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Alert actions
              if (showActions && !anomaly.resolved)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleResolve(context),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('RESOLVE NOW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: anomaly.severityColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build detail section
  Widget _buildDetailSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
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
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build technical details
  Widget _buildTechnicalDetails(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.bug_report, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'Technical Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(context, 'Type', anomaly.typeDisplayName),
              ),
              Expanded(
                child: _buildDetailItem(context, 'Severity', anomaly.severityDisplayName),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(context, 'ID', anomaly.id.substring(0, 8)),
              ),
              Expanded(
                child: _buildDetailItem(context, 'Status', anomaly.resolved ? 'Resolved' : 'Active'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build location details
  Widget _buildLocationDetails(BuildContext context) {
    return _buildDetailSection(
      context,
      'Location',
      Icons.location_on,
      'Lat: ${anomaly.latitude.toStringAsFixed(6)}, Lng: ${anomaly.longitude.toStringAsFixed(6)}',
    );
  }

  /// Build resolution details
  Widget _buildResolutionDetails(BuildContext context) {
    return _buildDetailSection(
      context,
      'Resolution',
      Icons.check_circle,
      'Resolved on ${anomaly.formattedResolvedAt ?? 'Unknown'}',
    );
  }

  /// Build timeline
  Widget _buildTimeline(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.timeline, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'Timeline',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                'Detected: ${anomaly.formattedCreatedAt}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (anomaly.resolved) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resolved: ${anomaly.formattedResolvedAt ?? 'Unknown'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build detail item
  Widget _buildDetailItem(BuildContext context, String label, String value) {
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

  /// Handle resolve action
  void _handleResolve(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Anomaly'),
        content: const Text('Mark this anomaly as resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = context.read<TrackingProvider>();
              provider.resolveAnomaly(anomaly.id);
              onResolve?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}