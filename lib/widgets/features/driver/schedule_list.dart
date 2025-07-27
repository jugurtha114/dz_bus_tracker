// lib/widgets/features/driver/schedule_list.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/enhanced_card.dart';
import '../../foundation/status_badge.dart';

class ScheduleList extends StatelessWidget {
  final List<ScheduleItem> schedules;
  final VoidCallback? onViewFullSchedule;

  const ScheduleList({
    super.key,
    required this.schedules,
    this.onViewFullSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onViewFullSchedule != null)
              TextButton(
                onPressed: onViewFullSchedule,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing12),
        if (schedules.isEmpty)
          _EmptySchedule()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: DesignSystem.spacing12),
            itemBuilder: (context, index) => _ScheduleItemCard(schedule: schedules[index]),
          ),
      ],
    );
  }
}

class _ScheduleItemCard extends StatelessWidget {
  final ScheduleItem schedule;

  const _ScheduleItemCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      borderColor: schedule.isCompleted
          ? DesignSystem.successColor.withOpacity(0.3)
          : DesignSystem.surfaceBorder,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: schedule.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            ),
            child: Icon(
              schedule.isCompleted ? Icons.check : Icons.schedule,
              color: schedule.statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignSystem.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.timeRange,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacing4),
                Text(
                  schedule.route,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            status: schedule.status,
            color: schedule.statusColor,
          ),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 48,
            color: DesignSystem.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Text(
            'No schedule for today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing4),
          Text(
            'Your schedule will appear here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItem {
  final String timeRange;
  final String route;
  final String status;
  final Color statusColor;
  final bool isCompleted;

  const ScheduleItem({
    required this.timeRange,
    required this.route,
    required this.status,
    required this.statusColor,
    required this.isCompleted,
  });
}