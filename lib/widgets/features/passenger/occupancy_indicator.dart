// lib/widgets/features/passenger/occupancy_indicator.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';

/// Widget to display bus occupancy level with visual indicator
class OccupancyIndicator extends StatelessWidget {
  final int currentCount;
  final int maxCapacity;
  final bool showText;
  final double size;

  const OccupancyIndicator({
    super.key,
    required this.currentCount,
    required this.maxCapacity,
    this.showText = true,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyRatio = maxCapacity > 0 ? currentCount / maxCapacity : 0.0;
    final occupancyPercentage = (occupancyRatio * 100).round();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Visual indicator
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getOccupancyColor(occupancyRatio).withOpacity(0.1),
            border: Border.all(
              color: _getOccupancyColor(occupancyRatio),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              _getOccupancyIcon(occupancyRatio),
              color: _getOccupancyColor(occupancyRatio),
              size: size * 0.6,
            ),
          ),
        ),
        
        if (showText) ...[
          const SizedBox(width: DesignSystem.space8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${occupancyPercentage}% full',
                style: DesignSystem.labelMedium.copyWith(
                  color: _getOccupancyColor(occupancyRatio),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$currentCount/$maxCapacity passengers',
                style: DesignSystem.labelSmall.copyWith(
                  color: DesignSystem.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getOccupancyColor(double ratio) {
    if (ratio <= 0.5) {
      return DesignSystem.busLowOccupancy;
    } else if (ratio <= 0.8) {
      return DesignSystem.busMediumOccupancy;
    } else {
      return DesignSystem.busHighOccupancy;
    }
  }

  IconData _getOccupancyIcon(double ratio) {
    if (ratio <= 0.5) {
      return Icons.person_outline_rounded;
    } else if (ratio <= 0.8) {
      return Icons.people_outline_rounded;
    } else {
      return Icons.people_rounded;
    }
  }
}