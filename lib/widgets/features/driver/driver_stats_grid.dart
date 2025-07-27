// lib/widgets/features/driver/driver_stats_grid.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/enhanced_card.dart';

class DriverStatsGrid extends StatelessWidget {
  final int todayTrips;
  final int totalPassengers;
  final double averageRating;
  final double hoursWorked;

  const DriverStatsGrid({
    super.key,
    required this.todayTrips,
    required this.totalPassengers,
    required this.averageRating,
    required this.hoursWorked,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: DesignSystem.spacing12,
      mainAxisSpacing: DesignSystem.spacing12,
      children: [
        _StatCard(
          label: 'Today\'s Trips',
          value: todayTrips.toString(),
          icon: Icons.route,
          color: DesignSystem.primaryColor,
        ),
        _StatCard(
          label: 'Passengers',
          value: totalPassengers.toString(),
          icon: Icons.people,
          color: DesignSystem.secondaryColor,
        ),
        _StatCard(
          label: 'Rating',
          value: averageRating.toStringAsFixed(1),
          icon: Icons.star,
          color: DesignSystem.accentColor,
        ),
        _StatCard(
          label: 'Hours',
          value: hoursWorked.toStringAsFixed(1),
          unit: 'h',
          icon: Icons.access_time,
          color: DesignSystem.infoColor,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: DesignSystem.spacing4),
                Text(
                  unit!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DesignSystem.spacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}