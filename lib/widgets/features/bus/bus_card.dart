// lib/widgets/features/bus/bus_card.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/foundation.dart';
import '../../common/common.dart';

/// Bus information card for displaying bus details
class BusInfoCard extends StatelessWidget {
  const BusInfoCard({
    super.key,
    required this.bus,
    this.onTap,
    this.onTrack,
    this.showActions = true,
    this.variant = AppCardVariant.elevated,
  });

  final BusCardData bus;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final bool showActions;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: DesignSystem.space12),
          _buildInfo(context),
          if (showActions) ...[
            const SizedBox(height: DesignSystem.space16),
            _buildActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSystem.space8),
          decoration: BoxDecoration(
            color: bus.isActive 
                ? DesignSystem.busActive.withValues(alpha: 0.1)
                : DesignSystem.busInactive.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Icon(
            Icons.directions_bus,
            color: bus.isActive ? DesignSystem.busActive : DesignSystem.busInactive,
            size: DesignSystem.iconMedium,
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bus ${bus.busNumber}',
                style: context.textStyles.titleMedium,
              ),
              if (bus.lineName != null)
                Text(
                  bus.lineName!,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        StatusBadge(
          status: bus.isActive ? 'Active' : 'Inactive',
          color: bus.isActive ? DesignSystem.busActive : DesignSystem.busInactive,
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      children: [
        if (bus.currentStop != null)
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: 'Current Stop',
            value: bus.currentStop!,
          ),
        if (bus.eta != null)
          _buildInfoRow(
            context,
            icon: Icons.schedule,
            label: 'ETA',
            value: bus.eta!,
          ),
        if (bus.passengerCount != null && bus.capacity != null)
          _buildOccupancyRow(context),
        if (bus.driverName != null)
          _buildInfoRow(
            context,
            icon: Icons.person,
            label: 'Driver',
            value: bus.driverName!,
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space4),
      child: Row(
        children: [
          Icon(
            icon,
            size: DesignSystem.iconSmall,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: DesignSystem.space8),
          Text(
            '$label: ',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyRow(BuildContext context) {
    final occupancyRatio = bus.passengerCount! / bus.capacity!;
    final occupancyColor = _getOccupancyColor(occupancyRatio);
    final occupancyText = '${bus.passengerCount}/${bus.capacity}';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space4),
      child: Row(
        children: [
          Icon(
            Icons.people,
            size: DesignSystem.iconSmall,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: DesignSystem.space8),
          Text(
            'Occupancy: ',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  occupancyText,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: occupancyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: occupancyRatio,
                    backgroundColor: context.colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            text: 'Details',
            onPressed: onTap,
            size: AppButtonSize.small,
          ),
        ),
        if (onTrack != null) ...[
          const SizedBox(width: DesignSystem.space8),
          Expanded(
            child: AppButton(
              text: 'Track',
              onPressed: onTrack,
              size: AppButtonSize.small,
              icon: Icons.my_location,
            ),
          ),
        ],
      ],
    );
  }

  Color _getOccupancyColor(double ratio) {
    if (ratio < 0.6) return DesignSystem.busLowOccupancy;
    if (ratio < 0.8) return DesignSystem.busMediumOccupancy;
    return DesignSystem.busHighOccupancy;
  }
}

/// Bus list item for compact display
class BusListItem extends StatelessWidget {
  const BusListItem({
    super.key,
    required this.bus,
    this.onTap,
    this.onTrack,
    this.showOccupancy = true,
  });

  final BusCardData bus;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final bool showOccupancy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bus.isActive 
            ? DesignSystem.busActive.withValues(alpha: 0.1)
            : DesignSystem.busInactive.withValues(alpha: 0.1),
        child: Icon(
          Icons.directions_bus,
          color: bus.isActive ? DesignSystem.busActive : DesignSystem.busInactive,
        ),
      ),
      title: Text('Bus ${bus.busNumber}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bus.lineName != null)
            Text(bus.lineName!),
          if (bus.eta != null)
            Text('ETA: ${bus.eta}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showOccupancy && bus.passengerCount != null && bus.capacity != null)
            _buildOccupancyIndicator(context),
          const SizedBox(width: DesignSystem.space8),
          StatusBadge(
            status: bus.isActive ? 'Active' : 'Inactive',
            color: bus.isActive ? DesignSystem.busActive : DesignSystem.busInactive,
          ),
          if (onTrack != null) ...[
            const SizedBox(width: DesignSystem.space8),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: onTrack,
              tooltip: 'Track bus',
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildOccupancyIndicator(BuildContext context) {
    final occupancyRatio = bus.passengerCount! / bus.capacity!;
    final occupancyColor = _getOccupancyColor(occupancyRatio);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${bus.passengerCount}/${bus.capacity}',
          style: context.textStyles.bodySmall?.copyWith(
            color: occupancyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          width: 40,
          child: LinearProgressIndicator(
            value: occupancyRatio,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
            minHeight: 3,
          ),
        ),
      ],
    );
  }

  Color _getOccupancyColor(double ratio) {
    if (ratio < 0.6) return DesignSystem.busLowOccupancy;
    if (ratio < 0.8) return DesignSystem.busMediumOccupancy;
    return DesignSystem.busHighOccupancy;
  }
}

/// Bus status widget for driver screens
class BusStatusWidget extends StatelessWidget {
  const BusStatusWidget({
    super.key,
    required this.bus,
    this.onStatusChange,
    this.onStartTrip,
    this.onEndTrip,
  });

  final BusCardData bus;
  final Function(bool isActive)? onStatusChange;
  final VoidCallback? onStartTrip;
  final VoidCallback? onEndTrip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: context.colors.primary,
                size: DesignSystem.iconLarge,
              ),
              const SizedBox(width: DesignSystem.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus ${bus.busNumber}',
                      style: context.textStyles.headlineSmall,
                    ),
                    if (bus.lineName != null)
                      Text(
                        bus.lineName!,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: bus.isActive,
                onChanged: onStatusChange,
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.space16),
          if (bus.isActive) ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Start Trip',
                    onPressed: onStartTrip,
                    icon: Icons.play_arrow,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: AppButton.outlined(
                    text: 'End Trip',
                    onPressed: onEndTrip,
                    icon: Icons.stop,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(DesignSystem.space12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignSystem.space8),
                  Text(
                    'Bus is currently inactive',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Data class for bus information
class BusCardData {
  const BusCardData({
    required this.id,
    required this.busNumber,
    required this.isActive,
    this.lineName,
    this.currentStop,
    this.eta,
    this.passengerCount,
    this.capacity,
    this.driverName,
    this.plateNumber,
  });

  final String id;
  final String busNumber;
  final bool isActive;
  final String? lineName;
  final String? currentStop;
  final String? eta;
  final int? passengerCount;
  final int? capacity;
  final String? driverName;
  final String? plateNumber;
}