/// lib/presentation/widgets/bus/driver_bus_list_item.dart

import 'package:flutter/material.dart';

import '../../../config/themes/app_theme.dart';
import '../../../domain/entities/bus_entity.dart';

/// Widget to display a single bus item in the driver's management list.
/// Shows key details and status indicators.
class DriverBusListItem extends StatelessWidget {
  final BusEntity bus;
  final VoidCallback onTap;

  const DriverBusListItem({
    super.key,
    required this.bus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: AppTheme.elevationSmall,
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            children: [
              // Bus Icon / Indicator
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                foregroundColor: colorScheme.primary,
                child: const Icon(Icons.directions_bus_filled, size: 28),
              ),
              const SizedBox(width: AppTheme.spacingMedium),

              // Bus Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.matricule, // Show matricule prominently
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall / 2),
                    Text(
                      '${bus.brand} ${bus.model} ${bus.year != null ? '(${bus.year})' : ''}',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.neutralMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    // Status Chips/Indicators
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingXSmall,
                      children: [
                        _StatusChip(
                          label: bus.isActive ? 'Active' : 'Inactive', // TODO: Localize
                          icon: bus.isActive ? Icons.power_settings_new : Icons.cancel_outlined,
                          color: bus.isActive ? AppTheme.successColor : AppTheme.neutralMedium,
                        ),
                         _StatusChip(
                          label: bus.isVerified ? 'Verified' : 'Pending', // TODO: Localize
                          icon: bus.isVerified ? Icons.verified_user_outlined : Icons.hourglass_empty_rounded,
                          color: bus.isVerified ? colorScheme.primary : AppTheme.warningColor,
                        ),
                         if (bus.isTracking) // Only show if actively tracking
                           const _StatusChip(
                             label: 'Tracking', // TODO: Localize
                             icon: Icons.location_on,
                             color: AppTheme.infoColor,
                           ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),

              // Trailing Arrow
              Icon(
                Icons.chevron_right,
                color: AppTheme.neutralMedium.withOpacity(0.7),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small chip widget for displaying status.
class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w500),
      backgroundColor: color.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Smaller tap area
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
