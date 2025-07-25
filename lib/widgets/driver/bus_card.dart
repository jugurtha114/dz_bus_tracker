// lib/widgets/driver/bus_card.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../models/bus_model.dart';
import '../common/glassy_container.dart';
import '../common/custom_card.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
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
    final licensePlate = bus.licensePlate ?? 'Unknown';
    final model = bus.model ?? '';
    final manufacturer = bus.manufacturer ?? '';
    final year = bus.year?.toString() ?? '';
    final capacity = bus.capacity?.toString() ?? '';
    final isAirConditioned = bus.isAirConditioned == true;
    final isApproved = bus.isApproved == true;
    final status = bus.status ?? 'active';

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
      borderColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.white.withOpacity(0.1),
      borderWidth: isSelected ? 2 : 1,
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
                  Icon(
                    Icons.directions_bus,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8, height: 40),
                  Text(
                    licensePlate,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                  // Approval status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isApproved ? 'Approved' : 'Pending',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bus details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Model and year
              Expanded(
                child: Text(
                  '$manufacturer $model ${year.isNotEmpty ? '($year)' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Capacity
              if (capacity.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4, height: 40),
                      Text(
                        capacity,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
                        foregroundColor: Theme.of(context).colorScheme.primary,
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
                        foregroundColor: Theme.of(context).colorScheme.primary,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
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