// lib/widgets/features/driver/tracking_controls_widget.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/enhanced_card.dart';
import '../../foundation/status_badge.dart';

class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final bool isEnabled;
  final bool isLoading;
  final String? currentTrip;
  final Duration? tripDuration;

  const TrackingControls({
    super.key,
    required this.isTracking,
    required this.onStartTracking,
    required this.onStopTracking,
    this.isEnabled = true,
    this.isLoading = false,
    this.currentTrip,
    this.tripDuration,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Tracking',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              StatusBadge(
                status: isTracking ? 'Active' : 'Inactive',
                color: isTracking ? DesignSystem.successColor : DesignSystem.textSecondary,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          if (isTracking && currentTrip != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing12),
              decoration: BoxDecoration(
                color: DesignSystem.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                border: Border.all(
                  color: DesignSystem.successColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        size: 16,
                        color: DesignSystem.successColor,
                      ),
                      const SizedBox(width: DesignSystem.spacing8),
                      Expanded(
                        child: Text(
                          'Current Trip: $currentTrip',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DesignSystem.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (tripDuration != null) ...[
                    const SizedBox(height: DesignSystem.spacing8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: DesignSystem.successColor,
                        ),
                        const SizedBox(width: DesignSystem.spacing8),
                        Text(
                          'Duration: ${_formatDuration(tripDuration!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DesignSystem.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DesignSystem.spacing16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isEnabled && !isLoading
                  ? (isTracking ? onStopTracking : onStartTracking)
                  : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      isTracking ? Icons.stop : Icons.play_arrow,
                      size: 20,
                    ),
              label: Text(
                isLoading
                    ? (isTracking ? 'Stopping...' : 'Starting...')
                    : (isTracking ? 'Stop Tracking' : 'Start Tracking'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTracking 
                    ? DesignSystem.errorColor 
                    : DesignSystem.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
            ),
          ),
          if (!isEnabled) ...[
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              'Select a bus and go online to start tracking',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignSystem.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (isTracking) ...[
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              'Your location is being shared with passengers',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}