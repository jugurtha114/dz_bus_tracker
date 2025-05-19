// lib/widgets/driver/tracking_controls.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../common/custom_button.dart';

class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final bool isEnabled;

  const TrackingControls({
    Key? key,
    required this.isTracking,
    required this.onStartTracking,
    required this.onStopTracking,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tracking status
        Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isTracking ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Status text
            Text(
              'Tracking Status: ${isTracking ? 'Active' : 'Inactive'}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Tracking button
        CustomButton(
          text: isTracking ? 'Stop Tracking' : 'Start Tracking',
          onPressed: isEnabled
              ? (isTracking ? onStopTracking : onStartTracking)
              : () {}, // No-op function instead of null
          isDisabled: !isEnabled,
          color: isTracking ? AppColors.error : AppColors.success,
          icon: isTracking ? Icons.stop_circle_outlined : Icons.play_circle_outline,
        ),
      ],
    );
  }
}