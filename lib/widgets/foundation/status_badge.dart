// lib/widgets/foundation/status_badge.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Status badge widget for displaying status with color coding
class StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final bool showDot;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    required this.color,
    this.showDot = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? DesignSystem.spacing6 : DesignSystem.spacing8,
        vertical: isCompact ? DesignSystem.spacing2 : DesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: DesignSystem.spacing4),
          ],
          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}