// lib/widgets/driver/bus_card.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../common/glassy_container.dart';

class BusCard extends StatelessWidget {
  final Map<String, dynamic> bus;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BusCard({
    Key? key,
    required this.bus,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract bus details
    final licensePlate = bus['license_plate'] ?? 'Unknown';
    final model = bus['model'] ?? '';
    final manufacturer = bus['manufacturer'] ?? '';
    final year = bus['year']?.toString() ?? '';
    final capacity = bus['capacity']?.toString() ?? '';
    final isAirConditioned = bus['is_air_conditioned'] == true;
    final isApproved = bus['is_approved'] == true;
    final status = bus['status'] ?? 'active';

    return GlassyContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.glassWhite,
      border: Border.all(
        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.2),
        width: isSelected ? 2 : 1,
      ),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus license and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // License plate with icon
              Row(
                children: [
                  const Icon(
                    Icons.directions_bus,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    licensePlate,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),

              // Status indicators
              Row(
                children: [
                  // Air conditioned indicator
                  if (isAirConditioned)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Tooltip(
                        message: 'Air Conditioned',
                        child: Icon(
                          Icons.ac_unit,
                          size: 18,
                          color: AppColors.info,
                        ),
                      ),
                    ),

                  // Approval status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isApproved ? 'Approved' : 'Pending',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Bus details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Model and year
              Expanded(
                child: Text(
                  '$manufacturer $model ${year.isNotEmpty ? '($year)' : ''}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),

              // Capacity
              if (capacity.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.darkGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        capacity,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Action buttons
          if (onEdit != null || onDelete != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit button
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                      ),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                  // Delete button
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                      ),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),

          // Selected indicator
          if (isSelected)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Selected',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}