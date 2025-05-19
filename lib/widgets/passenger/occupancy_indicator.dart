// lib/widgets/passenger/occupancy_indicator.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class OccupancyIndicator extends StatelessWidget {
  final int occupancyPercent;
  final double height;
  final bool showText;

  const OccupancyIndicator({
    Key? key,
    required this.occupancyPercent,
    this.height = 8.0,
    this.showText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on occupancy level
    Color color;
    String statusText;

    if (occupancyPercent < 50) {
      color = AppColors.lowOccupancy;
      statusText = 'Low Occupancy';
    } else if (occupancyPercent < 85) {
      color = AppColors.mediumOccupancy;
      statusText = 'Medium Occupancy';
    } else {
      color = AppColors.highOccupancy;
      statusText = 'High Occupancy';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            widthFactor: occupancyPercent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),

        // Status text
        if (showText)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              statusText,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}