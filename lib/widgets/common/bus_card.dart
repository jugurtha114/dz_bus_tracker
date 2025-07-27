// lib/widgets/common/bus_card.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../../models/bus_model.dart';
import '../foundation/app_card.dart';

/// Simple bus card widget for driver screens
class BusCard extends StatelessWidget {
  const BusCard({
    super.key,
    required this.bus,
    this.onTap,
    this.actions = const [],
    this.showStatus = true,
    this.showMaintenanceInfo = false,
    this.showETA = false,
  });

  final Bus bus;
  final VoidCallback? onTap;
  final List<Widget> actions;
  final bool showStatus;
  final bool showMaintenanceInfo;
  final bool showETA;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: DesignSystem.space12),
            _buildInfo(context),
            if (showMaintenanceInfo && bus.needsMaintenance) ...[
              const SizedBox(height: DesignSystem.space12),
              _buildMaintenanceInfo(context),
            ],
            if (showETA) ...[
              const SizedBox(height: DesignSystem.space12),
              _buildETAInfo(context),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.space12),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusColor = _getStatusColor(bus.status);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSystem.space8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Icon(
            Icons.directions_bus,
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bus.licensePlate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                bus.displayInfo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space8,
            vertical: DesignSystem.space4,
          ),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Text(
            bus.status.value.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Row(
      children: [
        _buildInfoItem(
          context,
          'Capacity',
          '${bus.capacity}',
          Icons.person,
        ),
        const SizedBox(width: DesignSystem.space16),
        _buildInfoItem(
          context,
          'Passengers',
          '${bus.currentPassengerCount}',
          Icons.people,
        ),
        const SizedBox(width: DesignSystem.space16),
        if (bus.isAirConditioned)
          _buildInfoItem(
            context,
            'A/C',
            'Yes',
            Icons.ac_unit,
          ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: DesignSystem.space4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaintenanceInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.orange,
            size: 16,
          ),
          const SizedBox(width: DesignSystem.space8),
          Expanded(
            child: Text(
              bus.maintenanceNotes ?? 'Maintenance required',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildETAInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: DesignSystem.space8),
          Text(
            'ETA: 5 min', // Mock ETA - should be calculated from real-time data
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

  Color _getStatusColor(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return Colors.green;
      case BusStatus.inactive:
        return Colors.grey;
      case BusStatus.maintenance:
        return Colors.orange;
    }
  }
}