// lib/widgets/features/driver/quick_actions_grid.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/enhanced_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onStartTrip;
  final VoidCallback onPassengerCount;
  final VoidCallback onTripHistory;
  final VoidCallback onPerformance;
  final bool isOnline;

  const QuickActionsGrid({
    super.key,
    required this.onStartTrip,
    required this.onPassengerCount,
    required this.onTripHistory,
    required this.onPerformance,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      crossAxisSpacing: DesignSystem.spacing12,
      mainAxisSpacing: DesignSystem.spacing12,
      children: [
        _ActionCard(
          title: 'Start Trip',
          description: 'Begin route tracking',
          icon: Icons.play_arrow,
          color: DesignSystem.successColor,
          onTap: isOnline ? onStartTrip : null,
          enabled: isOnline,
        ),
        _ActionCard(
          title: 'Passenger Count',
          description: 'Update occupancy',
          icon: Icons.people_outline,
          color: DesignSystem.primaryColor,
          onTap: onPassengerCount,
        ),
        _ActionCard(
          title: 'Trip History',
          description: 'View completed trips',
          icon: Icons.history,
          color: DesignSystem.secondaryColor,
          onTap: onTripHistory,
        ),
        _ActionCard(
          title: 'Performance',
          description: 'View statistics',
          icon: Icons.analytics,
          color: DesignSystem.infoColor,
          onTap: onPerformance,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : DesignSystem.textDisabled;
    
    return EnhancedCard(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(enabled ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 28,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled ? DesignSystem.textPrimary : DesignSystem.textDisabled,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignSystem.spacing4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: enabled ? DesignSystem.textSecondary : DesignSystem.textDisabled,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}