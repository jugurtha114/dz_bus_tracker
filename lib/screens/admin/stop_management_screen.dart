// lib/screens/admin/stop_management_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/stop_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';

class StopManagementScreen extends StatefulWidget {
  const StopManagementScreen({Key? key}) : super(key: key);

  @override
  State<StopManagementScreen> createState() => _StopManagementScreenState();
}

class _StopManagementScreenState extends State<StopManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StopService _stopService = StopService();
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _allStops = [];
  List<Map<String, dynamic>> _activeStops = [];
  List<Map<String, dynamic>> _inactiveStops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStops();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStops() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading stops from API
      await Future.delayed(const Duration(seconds: 1));
      
      _allStops = [
        {
          'id': '1',
          'name': 'City Center Plaza',
          'code': 'CCP001',
          'address': '1st November Square, Algiers',
          'latitude': 36,
          'longitude': 3,
          'status': 'active',
          'line_ids': ['1', '2', '5'],
          'line_names': ['Line 1 - City Center - Airport', 'Line 2 - University - Shopping Mall', 'Line 5 - Hospital - Train Station'],
          'accessibility': true,
          'shelter': true,
          'digital_display': true,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-07-20T14:15:00Z',
          'daily_passengers': 850,
          'peak_hours': '8:00-10:00, 17:00-19:00',
        },
        {
          'id': '2',
          'name': 'Airport Terminal 1',
          'code': 'AT1002',
          'address': 'Houari Boumediene Airport, Terminal 1',
          'latitude': 36,
          'longitude': 3,
          'status': 'active',
          'line_ids': ['1'],
          'line_names': ['Line 1 - City Center - Airport'],
          'accessibility': true,
          'shelter': true,
          'digital_display': true,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-07-22T16:20:00Z',
          'daily_passengers': 650,
          'peak_hours': '6:00-9:00, 16:00-20:00',
        },
        {
          'id': '3',
          'name': 'University Main Gate',
          'code': 'UMG003',
          'address': 'University of Science and Technology, Main Entrance',
          'latitude': 36,
          'longitude': 3,
          'status': 'active',
          'line_ids': ['2'],
          'line_names': ['Line 2 - University - Shopping Mall'],
          'accessibility': false,
          'shelter': true,
          'digital_display': false,
          'created_at': '2024-02-01T09:00:00Z',
          'updated_at': '2024-07-18T12:45:00Z',
          'daily_passengers': 1200,
          'peak_hours': '7:00-9:00, 15:00-18:00',
        },
        {
          'id': '4',
          'name': 'Industrial Zone Entrance',
          'code': 'IZE004',
          'address': 'Industrial Zone Rouiba, Main Entrance',
          'latitude': 36,
          'longitude': 3,
          'status': 'inactive',
          'line_ids': ['3'],
          'line_names': ['Line 3 - Industrial Zone - Residential'],
          'accessibility': false,
          'shelter': false,
          'digital_display': false,
          'created_at': '2024-01-20T11:45:00Z',
          'updated_at': '2024-07-15T08:20:00Z',
          'daily_passengers': 0,
          'peak_hours': 'N/A',
        },
        {
          'id': '5',
          'name': 'Beach Promenade',
          'code': 'BP005',
          'address': 'Sidi Fredj Beach, Promenade Walk',
          'latitude': 36,
          'longitude': 2,
          'status': 'active',
          'line_ids': ['4'],
          'line_names': ['Line 4 - Beach - Downtown'],
          'accessibility': true,
          'shelter': true,
          'digital_display': true,
          'created_at': '2024-03-10T15:20:00Z',
          'updated_at': '2024-07-22T10:30:00Z',
          'daily_passengers': 420,
          'peak_hours': '10:00-12:00, 14:00-17:00',
        },
        {
          'id': '6',
          'name': 'Central Hospital',
          'code': 'CH006',
          'address': 'Mustapha Pacha Hospital, Main Building',
          'latitude': 36,
          'longitude': 3,
          'status': 'active',
          'line_ids': ['5'],
          'line_names': ['Line 5 - Hospital - Train Station'],
          'accessibility': true,
          'shelter': true,
          'digital_display': true,
          'created_at': '2024-02-15T13:10:00Z',
          'updated_at': '2024-07-19T14:55:00Z',
          'daily_passengers': 380,
          'peak_hours': '8:00-11:00, 14:00-17:00',
        },
        {
          'id': '7',
          'name': 'Train Station Plaza',
          'code': 'TSP007',
          'address': 'Agha Train Station, Main Plaza',
          'latitude': 36,
          'longitude': 3,
          'status': 'active',
          'line_ids': ['5'],
          'line_names': ['Line 5 - Hospital - Train Station'],
          'accessibility': true,
          'shelter': true,
          'digital_display': true,
          'created_at': '2024-02-15T13:10:00Z',
          'updated_at': '2024-07-21T09:25:00Z',
          'daily_passengers': 920,
          'peak_hours': '7:00-9:00, 17:00-19:00',
        },
      ];

      _categorizeStops();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _categorizeStops() {
    _activeStops = _allStops.where((s) => s['status'] == 'active').toList();
    _inactiveStops = _allStops.where((s) => s['status'] == 'inactive').toList();
  }

  List<Map<String, dynamic>> _getFilteredStops(List<Map<String, dynamic>> stops) {
    if (_searchQuery.isEmpty) return stops;
    
    return stops.where((stop) {
      final name = stop['name'].toLowerCase();
      final code = stop['code'].toLowerCase();
      final address = stop['address'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || code.contains(query) || address.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Stop Management',
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
                _buildTabWithBadge('All Stops', _allStops.length),
                _buildTabWithBadge('Active', _activeStops.length),
                _buildTabWithBadge('Inactive', _inactiveStops.length),
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
                      _buildStopsList(_getFilteredStops(_allStops)),
                      _buildStopsList(_getFilteredStops(_activeStops)),
                      _buildStopsList(_getFilteredStops(_inactiveStops)),
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
                hintText: 'Search stops...',
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
              onPressed: _showAddStopDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalPassengers = _allStops.fold<int>(0, (sum, stop) => sum + (stop['daily_passengers'] as int));
    final accessibleStops = _allStops.where((s) => s['accessibility'] == true).length;
    final digitalDisplayStops = _allStops.where((s) => s['digital_display'] == true).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Stops',
              '${_allStops.length}',
              Icons.location_on,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Accessible',
              '$accessibleStops',
              Icons.accessible,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Digital Displays',
              '$digitalDisplayStops',
              Icons.monitor,
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

  Widget _buildStopsList(List<Map<String, dynamic>> stops) {
    if (stops.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.grey),
            SizedBox(),
            Text('No stops found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStops,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stops.length,
        itemBuilder: (context, index) {
          final stop = stops[index];
          return _buildStopCard(stop);
        },
      ),
    );
  }

  Widget _buildStopCard(Map<String, dynamic> stop) {
    final isActive = stop['status'] == 'active';
    final createdDate = DateTime.tryParse(stop['created_at'] ?? '');
    final lineNames = stop['line_names'] as List<String>;

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStopDetails(stop),
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
                    width: 12,
        
                    decoration: BoxDecoration(
                      color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12, height: 40),
                  
                  // Stop info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              stop['code'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
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
                          stop['name'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleStopAction(value, stop),
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
                            Text('Edit Stop'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'location',
                        child: Row(
                          children: [
                            Icon(Icons.map),
                            SizedBox(width: 8),
                            Text('View on Map'),
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
                            Text('Delete Stop', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Address
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4, height: 40),
                  Expanded(
                    child: Text(
                      stop['address'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Features row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (stop['accessibility'] == true)
                    _buildFeatureChip(Icons.accessible, 'Accessible', Theme.of(context).colorScheme.primary),
                  if (stop['shelter'] == true)
                    _buildFeatureChip(Icons.house, 'Shelter', Theme.of(context).colorScheme.primary),
                  if (stop['digital_display'] == true)
                    _buildFeatureChip(Icons.monitor, 'Digital Display', Theme.of(context).colorScheme.primary),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Lines served
              if (lineNames.isNotEmpty) ...[
                Text(
                  'Lines Served:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: lineNames.take(2).map((lineName) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lineName.length > 25 ? '${lineName.substring(0, 25)}...' : lineName,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (lineNames.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${lineNames.length - 2} more lines',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              
              // Stats row
              Row(
                children: [
                  _buildStatChip(Icons.people, '${stop['daily_passengers']}/day', Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  if (stop['peak_hours'] != 'N/A')
                    _buildStatChip(Icons.schedule, stop['peak_hours'], Theme.of(context).colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text, Color color) {
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

  void _handleStopAction(String action, Map<String, dynamic> stop) {
    switch (action) {
      case 'view':
        _showStopDetails(stop);
        break;
      case 'edit':
        _showEditStopDialog(stop);
        break;
      case 'location':
        _viewStopOnMap(stop);
        break;
      case 'activate':
      case 'deactivate':
        _toggleStopStatus(stop);
        break;
      case 'delete':
        _deleteStop(stop);
        break;
    }
  }

  void _showStopDetails(Map<String, dynamic> stop) {
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
                      'Stop Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Code', stop['code']),
                    _buildDetailRow('Name', stop['name']),
                    _buildDetailRow('Address', stop['address']),
                    _buildDetailRow('Status', stop['status']),
                    _buildDetailRow('Coordinates', '${stop['latitude']}, ${stop['longitude']}'),
                    _buildDetailRow('Accessibility', stop['accessibility'] ? 'Yes' : 'No'),
                    _buildDetailRow('Shelter', stop['shelter'] ? 'Yes' : 'No'),
                    _buildDetailRow('Digital Display', stop['digital_display'] ? 'Yes' : 'No'),
                    _buildDetailRow('Daily Passengers', '${stop['daily_passengers']}'),
                    _buildDetailRow('Peak Hours', stop['peak_hours']),
                    _buildDetailRow('Lines Served', (stop['line_names'] as List<String>).join(', ')),
                    _buildDetailRow('Created', 
                      DateTime.tryParse(stop['created_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(stop['created_at']))
                          : 'Unknown'
                    ),
                    _buildDetailRow('Last Updated', 
                      DateTime.tryParse(stop['updated_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(stop['updated_at']))
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

  void _showAddStopDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add stop functionality - to be implemented')),
    );
  }

  void _showEditStopDialog(Map<String, dynamic> stop) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit stop functionality - to be implemented')),
    );
  }

  void _viewStopOnMap(Map<String, dynamic> stop) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View on map functionality - to be implemented')),
    );
  }

  void _toggleStopStatus(Map<String, dynamic> stop) {
    final isActive = stop['status'] == 'active';
    
    DialogHelper.showConfirmDialog(
      context,
      title: isActive ? 'Deactivate Stop' : 'Activate Stop',
      message: 'Are you sure you want to ${isActive ? 'deactivate' : 'activate'} this stop?',
      confirmText: isActive ? 'Deactivate' : 'Activate',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          stop['status'] = isActive ? 'inactive' : 'active';
          if (!isActive) {
            stop['daily_passengers'] = 500;
            stop['peak_hours'] = '8:00-10:00, 17:00-19:00';
          } else {
            stop['daily_passengers'] = 0;
            stop['peak_hours'] = 'N/A';
          }
        });
        _categorizeStops();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stop ${isActive ? 'deactivated' : 'activated'} successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  void _deleteStop(Map<String, dynamic> stop) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Delete Stop',
      message: 'Are you sure you want to delete this stop? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _allStops.remove(stop);
          _categorizeStops();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stop deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}