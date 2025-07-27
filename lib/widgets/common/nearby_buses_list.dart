// lib/widgets/common/nearby_buses_list.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../../models/bus_model.dart';

/// Widget to display a list of nearby buses
class NearbyBusesList extends StatelessWidget {
  final List<Bus> buses;
  final Function(Bus)? onBusTap;

  const NearbyBusesList({
    super.key,
    required this.buses,
    this.onBusTap,
  });

  @override
  Widget build(BuildContext context) {
    if (buses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(DesignSystem.space24),
        child: Column(
          children: [
            Icon(
              Icons.directions_bus_rounded,
              size: 64,
              color: DesignSystem.onSurfaceVariant,
            ),
            const SizedBox(height: DesignSystem.space16),
            Text(
              'No buses nearby',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignSystem.space8),
            Text(
              'Check back later or try searching for a specific line',
              style: DesignSystem.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buses.length,
      separatorBuilder: (context, index) => const SizedBox(height: DesignSystem.space8),
      itemBuilder: (context, index) {
        final bus = buses[index];
        return _buildBusCard(context, bus);
      },
    );
  }

  Widget _buildBusCard(BuildContext context, Bus bus) {
    return GestureDetector(
      onTap: () => onBusTap?.call(bus),
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.space16),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          border: Border.all(
            color: DesignSystem.outline,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bus Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getBusStatusColor(bus.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                color: _getBusStatusColor(bus.status),
                size: DesignSystem.iconMedium,
              ),
            ),

            const SizedBox(width: DesignSystem.space16),

            // Bus Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bus Number and Line
                  Row(
                    children: [
                      Text(
                        bus.licensePlate,
                        style: DesignSystem.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.space8,
                          vertical: DesignSystem.space2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary,
                          borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                        ),
                        child: Text(
                          bus.model,
                          style: DesignSystem.labelSmall.copyWith(
                            color: DesignSystem.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignSystem.space4),

                  // Current Location or Status
                  Text(
                    bus.currentLocation != null ? 'Location available' : 'Location unknown',
                    style: DesignSystem.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (bus.lastLocationUpdate != null) ...[
                    const SizedBox(height: DesignSystem.space4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: DesignSystem.iconSmall,
                          color: DesignSystem.onSurfaceVariant,
                        ),
                        const SizedBox(width: DesignSystem.space4),
                        Text(
                          'Updated: ${_formatTimeAgo(bus.lastLocationUpdate!)}',
                          style: DesignSystem.bodySmall.copyWith(
                            color: DesignSystem.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status and Capacity
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${bus.capacity} seats',
                  style: DesignSystem.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignSystem.space4),
                _buildStatusIndicator(bus.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BusStatus status) {
    late Color color;
    late String text;

    switch (status) {
      case BusStatus.active:
        color = DesignSystem.busActive;
        text = 'Active';
        break;
      case BusStatus.inactive:
        color = DesignSystem.busInactive;
        text = 'Inactive';
        break;
      case BusStatus.maintenance:
        color = DesignSystem.warning;
        text = 'Maintenance';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.space8,
        vertical: DesignSystem.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: DesignSystem.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBusStatusColor(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return DesignSystem.busActive;
      case BusStatus.inactive:
        return DesignSystem.busInactive;
      case BusStatus.maintenance:
        return DesignSystem.warning;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}