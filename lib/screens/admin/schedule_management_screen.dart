// lib/screens/admin/schedule_management_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/schedule_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _allSchedules = [];
  List<Map<String, dynamic>> _activeSchedules = [];
  List<Map<String, dynamic>> _upcomingSchedules = [];
  List<Map<String, dynamic>> _completedSchedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading schedules from API
      await Future.delayed(const Duration(seconds: 1));
      
      _allSchedules = [
        {
          'id': '1',
          'line_id': '1',
          'line_name': 'Line 1 - City Center - Airport',
          'driver_id': '1',
          'driver_name': 'Ahmed Ben Ali',
          'bus_id': '1',
          'bus_number': 'DZ-001-AB',
          'start_time': '08:00',
          'end_time': '20:00',
          'date': '2024-07-24',
          'status': 'active',
          'frequency': '15 minutes',
          'total_trips': 24,
          'completed_trips': 18,
          'created_at': '2024-07-20T10:00:00Z',
          'updated_at': '2024-07-24T06:00:00Z',
        },
        {
          'id': '2',
          'line_id': '2',
          'line_name': 'Line 2 - University - Shopping Mall',
          'driver_id': '2',
          'driver_name': 'Fatima Zohra',
          'bus_id': '2',
          'bus_number': 'DZ-002-CD',
          'start_time': '07:30',
          'end_time': '19:30',
          'date': '2024-07-24',
          'status': 'active',
          'frequency': '20 minutes',
          'total_trips': 18,
          'completed_trips': 12,
          'created_at': '2024-07-20T09:30:00Z',
          'updated_at': '2024-07-24T05:30:00Z',
        },
        {
          'id': '3',
          'line_id': '3',
          'line_name': 'Line 3 - Industrial Zone - Residential',
          'driver_id': '3',
          'driver_name': 'Mohammed Kassim',
          'bus_id': '3',
          'bus_number': 'DZ-003-EF',
          'start_time': '06:00',
          'end_time': '22:00',
          'date': '2024-07-25',
          'status': 'upcoming',
          'frequency': '25 minutes',
          'total_trips': 32,
          'completed_trips': 0,
          'created_at': '2024-07-22T14:00:00Z',
          'updated_at': '2024-07-23T16:00:00Z',
        },
        {
          'id': '4',
          'line_id': '4',
          'line_name': 'Line 4 - Beach - Downtown',
          'driver_id': '4',
          'driver_name': 'Aicha Benali',
          'bus_id': '4',
          'bus_number': 'DZ-004-GH',
          'start_time': '09:00',
          'end_time': '18:00',
          'date': '2024-07-23',
          'status': 'completed',
          'frequency': '30 minutes',
          'total_trips': 18,
          'completed_trips': 18,
          'created_at': '2024-07-22T12:00:00Z',
          'updated_at': '2024-07-23T18:30:00Z',
        },
        {
          'id': '5',
          'line_id': '5',
          'line_name': 'Line 5 - Hospital - Train Station',
          'driver_id': '5',
          'driver_name': 'Omar Abdullah',
          'bus_id': '5',
          'bus_number': 'DZ-005-IJ',
          'start_time': '07:00',
          'end_time': '21:00',
          'date': '2024-07-25',
          'status': 'upcoming',
          'frequency': '12 minutes',
          'total_trips': 42,
          'completed_trips': 0,
          'created_at': '2024-07-23T11:00:00Z',
          'updated_at': '2024-07-23T17:00:00Z',
        },
      ];

      _categorizeSchedules();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _categorizeSchedules() {
    _activeSchedules = _allSchedules.where((s) => s['status'] == 'active').toList();
    _upcomingSchedules = _allSchedules.where((s) => s['status'] == 'upcoming').toList();
    _completedSchedules = _allSchedules.where((s) => s['status'] == 'completed').toList();
  }

  List<Map<String, dynamic>> _getFilteredSchedules(List<Map<String, dynamic>> schedules) {
    if (_searchQuery.isEmpty) return schedules;
    
    return schedules.where((schedule) {
      final lineName = schedule['line_name'].toLowerCase();
      final driverName = schedule['driver_name'].toLowerCase();
      final busNumber = schedule['bus_number'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return lineName.contains(query) || driverName.contains(query) || busNumber.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Schedule Management',
      child: Column(
        children: [
          // Search and filters
          _buildSearchSection(),
          
          // Stats overview
          _buildStatsOverview(),
          
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              isScrollable: true,
              tabs: [
                _buildTabWithBadge('All', _allSchedules.length),
                _buildTabWithBadge('Active', _activeSchedules.length),
                _buildTabWithBadge('Upcoming', _upcomingSchedules.length),
                _buildTabWithBadge('Completed', _completedSchedules.length),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSchedulesList(_getFilteredSchedules(_allSchedules)),
                      _buildSchedulesList(_getFilteredSchedules(_activeSchedules)),
                      _buildSchedulesList(_getFilteredSchedules(_upcomingSchedules)),
                      _buildSchedulesList(_getFilteredSchedules(_completedSchedules)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search schedules...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12, height: 40),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _showAddScheduleDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalTrips = _allSchedules.fold<int>(0, (sum, schedule) => sum + (schedule['total_trips'] as int));
    final completedTrips = _allSchedules.fold<int>(0, (sum, schedule) => sum + (schedule['completed_trips'] as int));
    final activeSchedulesCount = _activeSchedules.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Schedules',
              '${_allSchedules.length}',
              Icons.schedule,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Active Today',
              '$activeSchedulesCount',
              Icons.play_circle,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Trip Progress',
              '$completedTrips/$totalTrips',
              Icons.trending_up,
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return CustomCard(type: CardType.elevated, 
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8, height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesList(List<Map<String, dynamic>> schedules) {
    if (schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(),
            Text('No schedules found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final status = schedule['status'] as String;
    final completionPercentage = ((schedule['completed_trips'] as int) / (schedule['total_trips'] as int) * 100).toInt();
    final createdDate = DateTime.tryParse(schedule['created_at'] ?? '');

    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'active':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.play_circle;
        break;
      case 'upcoming':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.help;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showScheduleDetails(schedule),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12, height: 40),
                  
                  // Schedule info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              schedule['bus_number'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8, height: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          schedule['line_name'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleScheduleAction(value, schedule),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit Schedule'),
                          ],
                        ),
                      ),
                      if (status == 'upcoming')
                        const PopupMenuItem(
                          value: 'start',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text('Start Schedule'),
                            ],
                          ),
                        ),
                      if (status == 'active')
                        const PopupMenuItem(
                          value: 'pause',
                          child: Row(
                            children: [
                              Icon(Icons.pause),
                              SizedBox(width: 8),
                              Text('Pause Schedule'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Schedule', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Driver and time info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4, height: 40),
                  Text(
                    schedule['driver_name'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4, height: 40),
                  Text(
                    '${schedule['start_time']} - ${schedule['end_time']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress info
              if (status == 'active') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$completionPercentage%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: completionPercentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Stats row
              Row(
                children: [
                  _buildStatChip(Icons.repeat, schedule['frequency'], Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  _buildStatChip(Icons.trip_origin, '${schedule['completed_trips']}/${schedule['total_trips']} trips', Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  Text(
                    schedule['date'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4, height: 40),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleScheduleAction(String action, Map<String, dynamic> schedule) {
    switch (action) {
      case 'view':
        _showScheduleDetails(schedule);
        break;
      case 'edit':
        _showEditScheduleDialog(schedule);
        break;
      case 'start':
        _startSchedule(schedule);
        break;
      case 'pause':
        _pauseSchedule(schedule);
        break;
      case 'delete':
        _deleteSchedule(schedule);
        break;
    }
  }

  void _showScheduleDetails(Map<String, dynamic> schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0,
        minChildSize: 0,
        maxChildSize: 0,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
        
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Schedule Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Schedule ID', schedule['id']),
                    _buildDetailRow('Line', schedule['line_name']),
                    _buildDetailRow('Driver', schedule['driver_name']),
                    _buildDetailRow('Bus Number', schedule['bus_number']),
                    _buildDetailRow('Date', schedule['date']),
                    _buildDetailRow('Start Time', schedule['start_time']),
                    _buildDetailRow('End Time', schedule['end_time']),
                    _buildDetailRow('Frequency', schedule['frequency']),
                    _buildDetailRow('Status', schedule['status'].toUpperCase()),
                    _buildDetailRow('Total Trips', '${schedule['total_trips']}'),
                    _buildDetailRow('Completed Trips', '${schedule['completed_trips']}'),
                    _buildDetailRow('Created', 
                      DateTime.tryParse(schedule['created_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(schedule['created_at']))
                          : 'Unknown'
                    ),
                    _buildDetailRow('Last Updated', 
                      DateTime.tryParse(schedule['updated_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(schedule['updated_at']))
                          : 'Unknown'
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add schedule functionality - to be implemented')),
    );
  }

  void _showEditScheduleDialog(Map<String, dynamic> schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit schedule functionality - to be implemented')),
    );
  }

  void _startSchedule(Map<String, dynamic> schedule) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Start Schedule',
      message: 'Are you sure you want to start this schedule?',
      confirmText: 'Start',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          schedule['status'] = 'active';
          schedule['updated_at'] = DateTime.now().toIso8601String();
        });
        _categorizeSchedules();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Schedule started successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  void _pauseSchedule(Map<String, dynamic> schedule) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Pause Schedule',
      message: 'Are you sure you want to pause this schedule?',
      confirmText: 'Pause',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          schedule['status'] = 'upcoming';
          schedule['updated_at'] = DateTime.now().toIso8601String();
        });
        _categorizeSchedules();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Schedule paused successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  void _deleteSchedule(Map<String, dynamic> schedule) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Delete Schedule',
      message: 'Are you sure you want to delete this schedule? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _allSchedules.remove(schedule);
          _categorizeSchedules();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}