// lib/widgets/passenger/bus_list_item.dart

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/theme_config.dart';
import '../../widgets/common/glassy_container.dart';
import 'occupancy_indicator.dart';

class BusListItem extends StatelessWidget {
  final Map<String, dynamic> bus;
  final VoidCallback? onTap;
  final bool showOccupancy;
  final bool showDistance;
  final bool showEta;

  const BusListItem({
    Key? key,
    required this.bus,
    this.onTap,
    this.showOccupancy = true,
    this.showDistance = true,
    this.showEta = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from bus object
    final licensePlate = bus['license_plate'] ?? 'Unknown';
    final model = bus['model'] ?? '';
    final manufacturer = bus['manufacturer'] ?? '';
    final capacity = int.tryParse(bus['capacity']?.toString() ?? '0') ?? 0;

    // Get current passengers if available
    int currentPassengers = 0;
    if (bus.containsKey('current_location') &&
        bus['current_location'] != null &&
        bus['current_location'].containsKey('passenger_count')) {
      currentPassengers = int.tryParse(bus['current_location']['passenger_count']?.toString() ?? '0') ?? 0;
    }

    // Calculate occupancy percentage
    final occupancyPercent = capacity > 0 ? (currentPassengers / capacity * 100).round() : 0;

    // Get line info if available
    String lineName = '';
    String lineCode = '';
    if (bus.containsKey('line') && bus['line'] != null) {
      lineName = bus['line']['name'] ?? '';
      lineCode = bus['line']['code'] ?? '';
    }

    // Get last update time if available
    String lastUpdateText = '';
    if (bus.containsKey('current_location') &&
        bus['current_location'] != null &&
        bus['current_location'].containsKey('created_at')) {
      final lastUpdate = DateTime.parse(bus['current_location']['created_at']);
      lastUpdateText = 'Updated ${timeago.format(lastUpdate)}';
    }

    return GlassyContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      color: AppColors.glassWhite,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus info and line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bus license and model
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bus $licensePlate',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  if (model.isNotEmpty || manufacturer.isNotEmpty)
                    Text(
                      '$manufacturer $model',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                ],
              ),

              // Line info
              if (lineCode.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Line $lineCode',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Occupancy indicator
          if (showOccupancy && capacity > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Occupancy: $currentPassengers / $capacity passengers',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                OccupancyIndicator(
                  occupancyPercent: occupancyPercent,
                ),
              ],
            ),

          const SizedBox(height: 8),

          // Bottom info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ETA if available
              if (showEta && bus.containsKey('eta'))
                Text(
                  'Arriving in ${bus['eta']} min',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              // Distance if available
              if (showDistance && bus.containsKey('distance'))
                Text(
                  '${bus['distance']} away',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),

              // Last update time
              if (lastUpdateText.isNotEmpty)
                Text(
                  lastUpdateText,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}