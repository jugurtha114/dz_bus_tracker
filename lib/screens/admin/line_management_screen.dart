// lib/screens/admin/line_management_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/line_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';

class LineManagementScreen extends StatefulWidget {
  const LineManagementScreen({Key? key}) : super(key: key);

  @override
  State<LineManagementScreen> createState() => _LineManagementScreenState();
}

class _LineManagementScreenState extends State<LineManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LineService _lineService = LineService();
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _allLines = [];
  List<Map<String, dynamic>> _activeLines = [];
  List<Map<String, dynamic>> _inactiveLines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLines();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLines() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading lines from API
      await Future.delayed(const Duration(seconds: 1));
      
      _allLines = [
        {
          'id': '1',
          'name': 'Line 1 - City Center - Airport',
          'code': 'L001',
          'description': 'Main route connecting city center to airport',
          'status': 'active',
          'total_stops': 15,
          'distance': 25,
          'estimated_duration': '45 minutes',
          'fare': 150,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-07-20T14:15:00Z',
          'active_buses': 8,
          'total_buses': 10,
          'daily_trips': 32,
          'color': '#2196F3',
        },
        {
          'id': '2',
          'name': 'Line 2 - University - Shopping Mall',
          'code': 'L002',
          'description': 'Student route connecting university to main shopping areas',
          'status': 'active',
          'total_stops': 12,
          'distance': 18,
          'estimated_duration': '35 minutes',
          'fare': 120,
          'created_at': '2024-02-01T09:00:00Z',
          'updated_at': '2024-07-18T16:30:00Z',
          'active_buses': 6,
          'total_buses': 8,
          'daily_trips': 28,
          'color': '#4CAF50',
        },
        {
          'id': '3',
          'name': 'Line 3 - Industrial Zone - Residential',
          'code': 'L003',
          'description': 'Worker route connecting industrial areas to residential zones',
          'status': 'inactive',
          'total_stops': 20,
          'distance': 32,
          'estimated_duration': '55 minutes',
          'fare': 180,
          'created_at': '2024-01-20T11:45:00Z',
          'updated_at': '2024-07-15T08:20:00Z',
          'active_buses': 0,
          'total_buses': 12,
          'daily_trips': 0,
          'color': '#FF9800',
        },
        {
          'id': '4',
          'name': 'Line 4 - Beach - Downtown',
          'code': 'L004',
          'description': 'Tourist route connecting beach areas to downtown',
          'status': 'active',
          'total_stops': 8,
          'distance': 12,
          'estimated_duration': '25 minutes',
          'fare': 100,
          'created_at': '2024-03-10T15:20:00Z',
          'updated_at': '2024-07-22T12:45:00Z',
          'active_buses': 4,
          'total_buses': 6,
          'daily_trips': 24,
          'color': '#9C27B0',
        },
        {
          'id': '5',
          'name': 'Line 5 - Hospital - Train Station',
          'code': 'L005',
          'description': 'Essential services route connecting hospital to train station',
          'status': 'active',
          'total_stops': 10,
          'distance': 15,
          'estimated_duration': '30 minutes',
          'fare': 130,
          'created_at': '2024-02-15T13:10:00Z',
          'updated_at': '2024-07-19T10:25:00Z',
          'active_buses': 5,
          'total_buses': 7,
          'daily_trips': 30,
          'color': '#F44336',
        },
      ];

      _categorizeLines();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _categorizeLines() {
    _activeLines = _allLines.where((l) => l['status'] == 'active').toList();
    _inactiveLines = _allLines.where((l) => l['status'] == 'inactive').toList();
  }

  List<Map<String, dynamic>> _getFilteredLines(List<Map<String, dynamic>> lines) {
    if (_searchQuery.isEmpty) return lines;
    
    return lines.where((line) {
      final name = line['name'].toLowerCase();
      final code = line['code'].toLowerCase();
      final description = line['description'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || code.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Line Management',
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
              tabs: [
                _buildTabWithBadge('All Lines', _allLines.length),
                _buildTabWithBadge('Active', _activeLines.length),
                _buildTabWithBadge('Inactive', _inactiveLines.length),
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
                      _buildLinesList(_getFilteredLines(_allLines)),
                      _buildLinesList(_getFilteredLines(_activeLines)),
                      _buildLinesList(_getFilteredLines(_inactiveLines)),
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
                hintText: 'Search lines...',
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
              onPressed: _showAddLineDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalBuses = _allLines.fold<int>(0, (sum, line) => sum + (line['total_buses'] as int));
    final activeBuses = _allLines.fold<int>(0, (sum, line) => sum + (line['active_buses'] as int));
    final totalTrips = _allLines.fold<int>(0, (sum, line) => sum + (line['daily_trips'] as int));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Lines',
              '${_allLines.length}',
              Icons.route,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Active Buses',
              '$activeBuses/$totalBuses',
              Icons.directions_bus,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Daily Trips',
              '$totalTrips',
              Icons.trip_origin,
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

  Widget _buildLinesList(List<Map<String, dynamic>> lines) {
    if (lines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 64, color: Colors.grey),
            SizedBox(),
            Text('No lines found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLines,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          return _buildLineCard(line);
        },
      ),
    );
  }

  Widget _buildLineCard(Map<String, dynamic> line) {
    final isActive = line['status'] == 'active';
    final lineColor = Color(int.parse(line['color'].replaceFirst('#', '0xFF')));
    final createdDate = DateTime.tryParse(line['created_at'] ?? '');

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLineDetails(line),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Line color indicator
                  Container(
                    width: 4,
        
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12, height: 40),
                  
                  // Line info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              line['code'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: lineColor,
                              ),
                            ),
                            const SizedBox(width: 8, height: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
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
                          line['name'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleLineAction(value, line),
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
                            Text('Edit Line'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'stops',
                        child: Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8),
                            Text('Manage Stops'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(isActive ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8, height: 40),
                            Text(isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Line', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                line['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Stats row
              Row(
                children: [
                  _buildStatChip(Icons.location_on, '${line['total_stops']} stops', Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  _buildStatChip(Icons.straighten, '${line['distance']} km', Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  _buildStatChip(Icons.access_time, line['estimated_duration'], Theme.of(context).colorScheme.primary),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Additional info row
              Row(
                children: [
                  _buildStatChip(Icons.directions_bus, '${line['active_buses']}/${line['total_buses']} buses', Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  _buildStatChip(Icons.trip_origin, '${line['daily_trips']} trips/day', Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  Text(
                    '${line['fare']} DA',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  void _handleLineAction(String action, Map<String, dynamic> line) {
    switch (action) {
      case 'view':
        _showLineDetails(line);
        break;
      case 'edit':
        _showEditLineDialog(line);
        break;
      case 'stops':
        _manageLineStops(line);
        break;
      case 'activate':
      case 'deactivate':
        _toggleLineStatus(line);
        break;
      case 'delete':
        _deleteLine(line);
        break;
    }
  }

  void _showLineDetails(Map<String, dynamic> line) {
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
                      'Line Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Code', line['code']),
                    _buildDetailRow('Name', line['name']),
                    _buildDetailRow('Description', line['description']),
                    _buildDetailRow('Status', line['status']),
                    _buildDetailRow('Total Stops', '${line['total_stops']}'),
                    _buildDetailRow('Distance', '${line['distance']} km'),
                    _buildDetailRow('Duration', line['estimated_duration']),
                    _buildDetailRow('Fare', '${line['fare']} DA'),
                    _buildDetailRow('Active Buses', '${line['active_buses']}/${line['total_buses']}'),
                    _buildDetailRow('Daily Trips', '${line['daily_trips']}'),
                    _buildDetailRow('Created', 
                      DateTime.tryParse(line['created_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(line['created_at']))
                          : 'Unknown'
                    ),
                    _buildDetailRow('Last Updated', 
                      DateTime.tryParse(line['updated_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(line['updated_at']))
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

  void _showAddLineDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add line functionality - to be implemented')),
    );
  }

  void _showEditLineDialog(Map<String, dynamic> line) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit line functionality - to be implemented')),
    );
  }

  void _manageLineStops(Map<String, dynamic> line) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage stops functionality - to be implemented')),
    );
  }

  void _toggleLineStatus(Map<String, dynamic> line) {
    final isActive = line['status'] == 'active';
    
    DialogHelper.showConfirmDialog(
      context,
      title: isActive ? 'Deactivate Line' : 'Activate Line',
      message: 'Are you sure you want to ${isActive ? 'deactivate' : 'activate'} this line?',
      confirmText: isActive ? 'Deactivate' : 'Activate',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          line['status'] = isActive ? 'inactive' : 'active';
          if (!isActive) {
            line['active_buses'] = line['total_buses'];
            line['daily_trips'] = 24;
          } else {
            line['active_buses'] = 0;
            line['daily_trips'] = 0;
          }
        });
        _categorizeLines();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Line ${isActive ? 'deactivated' : 'activated'} successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  void _deleteLine(Map<String, dynamic> line) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Delete Line',
      message: 'Are you sure you want to delete this line? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _allLines.remove(line);
          _categorizeLines();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Line deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}