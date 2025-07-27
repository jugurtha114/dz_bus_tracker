// lib/screens/admin/schedule_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';

/// Schedule management screen for admins to manage bus schedules
class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _allSchedules = [];
  List<Map<String, dynamic>> _todaySchedules = [];
  List<Map<String, dynamic>> _weeklySchedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadSchedules();
      setState(() {
        _allSchedules = adminProvider.allSchedules;
        _todaySchedules = adminProvider.todaySchedules;
        _weeklySchedules = adminProvider.weeklySchedules;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load schedules: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Schedule Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_alarm),
          onPressed: _showAddScheduleDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadSchedules,
        ),
      ],
      child: Column(
        children: [
          // Statistics
          Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: StatsSection(
              crossAxisCount: 3,
              stats: [
                StatItem(
                  value: '${_allSchedules.length}',
                  label: 'Total\\nSchedules',
                  icon: Icons.schedule,
                  color: context.colors.primary,
                ),
                StatItem(
                  value: '${_todaySchedules.length}',
                  label: 'Today\'s\\nTrips',
                  icon: Icons.today,
                  color: context.successColor,
                ),
                StatItem(
                  value: '${_weeklySchedules.length}',
                  label: 'Weekly\\nTrips',
                  icon: Icons.date_range,
                  color: context.infoColor,
                ),
              ],
            ),
          ),
          
          // Tab Bar
          AppTabBar(
            controller: _tabController,
            tabs: const [
              AppTab(label: 'All', icon: Icons.schedule),
              AppTab(label: 'Today', icon: Icons.today),
              AppTab(label: 'Weekly', icon: Icons.date_range),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: _isLoading
                ? const LoadingState.fullScreen()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSchedulesList(_allSchedules),
                      _buildSchedulesList(_todaySchedules),
                      _buildSchedulesList(_weeklySchedules),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesList(List<Map<String, dynamic>> schedules) {
    if (schedules.isEmpty) {
      return const EmptyState(
        title: 'No schedules found',
        message: 'No schedules in this category',
        icon: Icons.schedule_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.space16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSystem.space12),
          child: AppCard(
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: DesignSystem.space8),
                      Expanded(
                        child: Text(
                          schedule['line_name'] ?? 'Unknown Line',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(
                        status: schedule['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                        color: _getScheduleStatusColor(schedule['status']),
                        
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.space8),
                  Text(
                    'Departure: ${schedule['departure_time'] ?? 'Unknown'}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Driver: ${schedule['driver_name'] ?? 'Unassigned'}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getScheduleStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DesignSystem.busActive;
      case 'completed':
        return DesignSystem.info;
      case 'cancelled':
        return DesignSystem.error;
      default:
        return DesignSystem.busInactive;
    }
  }

  void _showAddScheduleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add schedule form coming soon')),
    );
  }
}