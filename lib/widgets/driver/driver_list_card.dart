// lib/widgets/driver/driver_list_card.dart

import 'package:flutter/material.dart';
import '../../models/driver_model.dart';
import '../common/enhanced_card.dart';
import '../common/enhanced_custom_button.dart';

/// Modular driver list card component with comprehensive functionality
class DriverListCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewRatings;
  final VoidCallback? onAssignBus;
  final bool showActions;
  final bool showApprovalActions;
  final bool isAdmin;

  const DriverListCard({
    Key? key,
    required this.driver,
    this.onTap,
    this.onEdit,
    this.onApprove,
    this.onReject,
    this.onViewRatings,
    this.onAssignBus,
    this.showActions = true,
    this.showApprovalActions = false,
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
          // Header with name and status
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: driver.statusColor.withOpacity(0.1),
                child: Text(
                  driver.initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: driver.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'License: ${driver.licenseNumber}',
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
          
          // Driver details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.star,
                  label: 'Rating',
                  value: '${driver.rating.toStringAsFixed(1)} ⭐',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.work,
                  label: 'Experience',
                  value: driver.experienceLevel,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: driver.isAvailable ? Icons.check_circle : Icons.cancel,
                  label: 'Available',
                  value: driver.isAvailable ? 'Yes' : 'No',
                  theme: theme,
                ),
              ),
            ],
          ),
          
          if (driver.phoneNumber?.isNotEmpty == true) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: colorScheme.primary),
                SizedBox(width: 4),
                Text(
                  driver.phoneNumber!,
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
    final statusColor = driver.statusColor;
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
        driver.status.name.toUpperCase(),
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

    // View ratings
    if (onViewRatings != null) {
      actions.add(
        EnhancedCustomButton.outline(
          text: 'Ratings',
          icon: Icons.star,
          onPressed: onViewRatings,
          size: EnhancedButtonSize.small,
        ),
      );
    }

    // Approval actions for pending drivers
    if (showApprovalActions && driver.status == DriverStatus.pending) {
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

    // Assign bus for approved drivers
    if (isAdmin && driver.status == DriverStatus.approved && onAssignBus != null) {
      actions.add(
        EnhancedCustomButton.primary(
          text: 'Assign Bus',
          icon: Icons.directions_bus,
          onPressed: onAssignBus,
          size: EnhancedButtonSize.small,
        ),
      );
    }

    // Edit action
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

    if (actions.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: actions,
    );
  }
}

/// Specialized driver card for minimal display
class DriverMinimalCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onTap;
  final bool showAvailability;

  const DriverMinimalCard({
    Key? key,
    required this.driver,
    this.onTap,
    this.showAvailability = true,
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
          CircleAvatar(
            radius: 16,
            backgroundColor: driver.statusColor.withOpacity(0.1),
            child: Text(
              driver.initials,
              style: theme.textTheme.labelMedium?.copyWith(
                color: driver.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.fullName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rating: ${driver.rating.toStringAsFixed(1)} ⭐',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (showAvailability)
            Icon(
              driver.isAvailable ? Icons.check_circle : Icons.cancel,
              color: driver.isAvailable ? Colors.green : Colors.red,
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// Driver rating card for displaying individual ratings
class DriverRatingCard extends StatelessWidget {
  final DriverRating rating;
  final bool showDriverName;

  const DriverRatingCard({
    Key? key,
    required this.rating,
    this.showDriverName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return EnhancedCard.outlined(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Star rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating.index + 1 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
              Spacer(),
              Text(
                rating.formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          if (rating.comment?.isNotEmpty == true) ...[
            SizedBox(height: 8),
            Text(
              rating.comment!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          
          if (showDriverName && rating.driverName?.isNotEmpty == true) ...[
            SizedBox(height: 8),
            Text(
              'Driver: ${rating.driverName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}