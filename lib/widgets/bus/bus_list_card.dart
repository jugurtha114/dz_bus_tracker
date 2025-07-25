// lib/widgets/bus/bus_list_card.dart

import 'package:flutter/material.dart';
import '../../models/bus_model.dart';
import '../common/enhanced_card.dart';
import '../common/enhanced_custom_button.dart';

/// Modular bus list card component with comprehensive functionality
class BusListCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onTrack;
  final bool showActions;
  final bool showApprovalActions;
  final bool showTrackingActions;
  final bool isAdmin;

  const BusListCard({
    Key? key,
    required this.bus,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.onActivate,
    this.onDeactivate,
    this.onTrack,
    this.showActions = true,
    this.showApprovalActions = false,
    this.showTrackingActions = true,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return EnhancedCard.outlined(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with license plate and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.licensePlate,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${bus.manufacturer} ${bus.model} (${bus.year})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(theme, colorScheme),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Bus details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.airline_seat_recline_normal,
                  label: 'Capacity',
                  value: '${bus.capacity}',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: bus.isAirConditioned ? Icons.ac_unit : Icons.air,
                  label: 'AC',
                  value: bus.isAirConditioned ? 'Yes' : 'No',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.people,
                  label: 'Occupancy',
                  value: '${bus.occupancyPercentage.toStringAsFixed(0)}%',
                  theme: theme,
                ),
              ),
            ],
          ),
          
          if (bus.driverName?.isNotEmpty == true) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: colorScheme.primary),
                SizedBox(width: 4),
                Text(
                  'Driver: ${bus.driverName}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
          
          if (showActions) ...[
            SizedBox(height: 12),
            _buildActionButtons(theme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, ColorScheme colorScheme) {
    final statusColor = bus.statusColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        bus.status.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    final actions = <Widget>[];

    // Tracking actions for drivers
    if (showTrackingActions && bus.isOperational) {
      if (onTrack != null) {
        actions.add(
          EnhancedCustomButton.primary(
            text: 'Track',
            icon: Icons.location_on,
            onPressed: onTrack,
            size: EnhancedButtonSize.small,
          ),
        );
      }
    }

    // Activation/Deactivation for admins
    if (isAdmin) {
      if (bus.status == BusStatus.active && onDeactivate != null) {
        actions.add(
          EnhancedCustomButton.outline(
            text: 'Deactivate',
            icon: Icons.stop,
            onPressed: onDeactivate,
            size: EnhancedButtonSize.small,
          ),
        );
      } else if (bus.status == BusStatus.inactive && onActivate != null) {
        actions.add(
          EnhancedCustomButton.success(
            text: 'Activate',
            icon: Icons.play_arrow,
            onPressed: onActivate,
            size: EnhancedButtonSize.small,
          ),
        );
      }
    }

    // Approval actions for pending buses
    if (showApprovalActions && !bus.isApproved) {
      if (onApprove != null) {
        actions.add(
          EnhancedCustomButton.success(
            text: 'Approve',
            icon: Icons.check,
            onPressed: onApprove,
            size: EnhancedButtonSize.small,
          ),
        );
      }
      if (onReject != null) {
        actions.add(
          EnhancedCustomButton.error(
            text: 'Reject',
            icon: Icons.close,
            onPressed: onReject,
            size: EnhancedButtonSize.small,
          ),
        );
      }
    }

    // Edit and delete actions
    if (onEdit != null) {
      actions.add(
        EnhancedCustomButton.outline(
          text: 'Edit',
          icon: Icons.edit,
          onPressed: onEdit,
          size: EnhancedButtonSize.small,
        ),
      );
    }

    if (onDelete != null && isAdmin) {
      actions.add(
        EnhancedCustomButton.error(
          text: 'Delete',
          icon: Icons.delete,
          onPressed: onDelete,
          size: EnhancedButtonSize.small,
        ),
      );
    }

    if (actions.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: actions,
    );
  }
}

/// Specialized bus card for minimal display
class BusMinimalCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback? onTap;

  const BusMinimalCard({
    Key? key,
    required this.bus,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return EnhancedCard.filled(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.directions_bus,
            color: bus.statusColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.licensePlate,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${bus.manufacturer} ${bus.model}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${bus.currentPassengerCount}/${bus.capacity}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: bus.statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}