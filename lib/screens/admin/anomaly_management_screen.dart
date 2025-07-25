// lib/screens/admin/anomaly_management_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/anomaly_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';

class AnomalyManagementScreen extends StatefulWidget {
  const AnomalyManagementScreen({Key? key}) : super(key: key);

  @override
  State<AnomalyManagementScreen> createState() => _AnomalyManagementScreenState();
}

class _AnomalyManagementScreenState extends State<AnomalyManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnomalyService _anomalyService = AnomalyService();
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _allAnomalies = [];
  List<Map<String, dynamic>> _newAnomalies = [];
  List<Map<String, dynamic>> _inProgressAnomalies = [];
  List<Map<String, dynamic>> _resolvedAnomalies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnomalies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnomalies() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading anomalies from API
      await Future.delayed(const Duration(seconds: 1));
      
      _allAnomalies = [
        {
          'id': '1',
          'type': 'traffic_jam',
          'title': 'Heavy Traffic on Line 1',
          'description': 'Unusual traffic congestion detected on Line 1 between City Center and Airport stops',
          'severity': 'high',
          'status': 'new',
          'line_id': '1',
          'line_name': 'Line 1 - City Center - Airport',
          'affected_stops': ['City Center Plaza', 'Business District', 'Airport Terminal 1'],
          'reporter_type': 'system',
          'reporter_name': 'Traffic Monitoring System',
          'created_at': '2024-07-24T09:15:00Z',
          'updated_at': '2024-07-24T09:15:00Z',
          'estimated_delay': '15-20 minutes',
          'affected_passengers': 120,
          'location': {'latitude': 36, 'longitude': 3},
        },
        {
          'id': '2',
          'type': 'bus_breakdown',
          'title': 'Bus Breakdown on Line 2',
          'description': 'Bus DZ-456-CD broke down near University Main Gate stop',
          'severity': 'medium',
          'status': 'in_progress',
          'line_id': '2',
          'line_name': 'Line 2 - University - Shopping Mall',
          'affected_stops': ['University Main Gate', 'Student Residence'],
          'reporter_type': 'driver',
          'reporter_name': 'Ahmed Benali',
          'created_at': '2024-07-24T08:45:00Z',
          'updated_at': '2024-07-24T09:30:00Z',
          'estimated_delay': '30-45 minutes',
          'affected_passengers': 85,
          'location': {'latitude': 36, 'longitude': 3},
          'assigned_to': 'Technical Team Alpha',
          'resolution_notes': 'Replacement bus dispatched, estimated arrival in 15 minutes',
        },
        {
          'id': '3',
          'type': 'route_deviation',
          'title': 'Route Deviation Detected',
          'description': 'Bus on Line 4 deviated from planned route near Beach Promenade',
          'severity': 'low',
          'status': 'resolved',
          'line_id': '4',
          'line_name': 'Line 4 - Beach - Downtown',
          'affected_stops': ['Beach Promenade'],
          'reporter_type': 'system',
          'reporter_name': 'GPS Monitoring System',
          'created_at': '2024-07-23T16:20:00Z',
          'updated_at': '2024-07-23T16:45:00Z',
          'estimated_delay': '5 minutes',
          'affected_passengers': 15,
          'location': {'latitude': 36, 'longitude': 2},
          'assigned_to': 'Dispatcher Team',
          'resolution_notes': 'Driver contacted and route corrected. Minor delay due to road construction.',
          'resolved_at': '2024-07-23T16:45:00Z',
        },
        {
          'id': '4',
          'type': 'passenger_complaint',
          'title': 'Service Quality Complaint',
          'description': 'Multiple complaints about overcrowding during peak hours on Line 5',
          'severity': 'medium',
          'status': 'in_progress',
          'line_id': '5',
          'line_name': 'Line 5 - Hospital - Train Station',
          'affected_stops': ['Central Hospital', 'Train Station Plaza'],
          'reporter_type': 'passenger',
          'reporter_name': 'Anonymous User',
          'created_at': '2024-07-23T18:30:00Z',
          'updated_at': '2024-07-24T08:00:00Z',
          'estimated_delay': 'N/A',
          'affected_passengers': 200,
          'location': {'latitude': 36, 'longitude': 3},
          'assigned_to': 'Operations Manager',
          'resolution_notes': 'Investigating passenger load patterns. Additional bus scheduled for peak hours.',
        },
        {
          'id': '5',
          'type': 'weather_impact',
          'title': 'Weather-Related Delays',
          'description': 'Heavy rain causing delays across multiple lines',
          'severity': 'high',
          'status': 'new',
          'line_id': null,
          'line_name': 'Multiple Lines',
          'affected_stops': ['Multiple stops city-wide'],
          'reporter_type': 'system',
          'reporter_name': 'Weather Monitoring System',
          'created_at': '2024-07-24T10:00:00Z',
          'updated_at': '2024-07-24T10:00:00Z',
          'estimated_delay': '10-30 minutes',
          'affected_passengers': 500,
          'location': null,
        },
        {
          'id': '6',
          'type': 'technical_issue',
          'title': 'GPS System Malfunction',
          'description': 'GPS tracking system experiencing intermittent connectivity issues',
          'severity': 'medium',
          'status': 'resolved',
          'line_id': null,
          'line_name': 'System-wide',
          'affected_stops': ['All monitored stops'],
          'reporter_type': 'system',
          'reporter_name': 'IT Monitoring System',
          'created_at': '2024-07-22T14:15:00Z',
          'updated_at': '2024-07-22T16:30:00Z',
          'estimated_delay': 'N/A',
          'affected_passengers': 0,
          'location': null,
          'assigned_to': 'IT Support Team',
          'resolution_notes': 'Network connectivity restored. All systems functioning normally.',
          'resolved_at': '2024-07-22T16:30:00Z',
        },
      ];

      _categorizeAnomalies();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _categorizeAnomalies() {
    _newAnomalies = _allAnomalies.where((a) => a['status'] == 'new').toList();
    _inProgressAnomalies = _allAnomalies.where((a) => a['status'] == 'in_progress').toList();
    _resolvedAnomalies = _allAnomalies.where((a) => a['status'] == 'resolved').toList();
  }

  List<Map<String, dynamic>> _getFilteredAnomalies(List<Map<String, dynamic>> anomalies) {
    if (_searchQuery.isEmpty) return anomalies;
    
    return anomalies.where((anomaly) {
      final title = anomaly['title'].toLowerCase();
      final description = anomaly['description'].toLowerCase();
      final lineName = (anomaly['line_name'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return title.contains(query) || description.contains(query) || lineName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Anomaly Management',
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
                _buildTabWithBadge('All', _allAnomalies.length),
                _buildTabWithBadge('New', _newAnomalies.length),
                _buildTabWithBadge('In Progress', _inProgressAnomalies.length),
                _buildTabWithBadge('Resolved', _resolvedAnomalies.length),
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
                      _buildAnomaliesList(_getFilteredAnomalies(_allAnomalies)),
                      _buildAnomaliesList(_getFilteredAnomalies(_newAnomalies)),
                      _buildAnomaliesList(_getFilteredAnomalies(_inProgressAnomalies)),
                      _buildAnomaliesList(_getFilteredAnomalies(_resolvedAnomalies)),
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
                hintText: 'Search anomalies...',
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
              icon: const Icon(Icons.add_alert, color: Colors.white),
              onPressed: _showReportAnomalyDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final highSeverityCount = _allAnomalies.where((a) => a['severity'] == 'high').length;
    final newCount = _newAnomalies.length;
    final totalAffectedPassengers = _allAnomalies.fold<int>(0, (sum, anomaly) => sum + (anomaly['affected_passengers'] as int));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Issues',
              '${_allAnomalies.length}',
              Icons.warning,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'High Priority',
              '$highSeverityCount',
              Icons.priority_high,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Affected Today',
              '$totalAffectedPassengers',
              Icons.people,
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

  Widget _buildAnomaliesList(List<Map<String, dynamic>> anomalies) {
    if (anomalies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(),
            Text('No anomalies found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnomalies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: anomalies.length,
        itemBuilder: (context, index) {
          final anomaly = anomalies[index];
          return _buildAnomalyCard(anomaly);
        },
      ),
    );
  }

  Widget _buildAnomalyCard(Map<String, dynamic> anomaly) {
    final severity = anomaly['severity'] as String;
    final status = anomaly['status'] as String;
    final createdDate = DateTime.tryParse(anomaly['created_at'] ?? '');

    Color severityColor;
    Color statusColor;
    IconData typeIcon;

    // Determine severity color
    switch (severity) {
      case 'high':
        severityColor = Theme.of(context).colorScheme.primary;
        break;
      case 'medium':
        severityColor = Theme.of(context).colorScheme.primary;
        break;
      default:
        severityColor = Theme.of(context).colorScheme.primary;
    }

    // Determine status color
    switch (status) {
      case 'new':
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      case 'in_progress':
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
    }

    // Determine type icon
    switch (anomaly['type']) {
      case 'traffic_jam':
        typeIcon = Icons.traffic;
        break;
      case 'bus_breakdown':
        typeIcon = Icons.build;
        break;
      case 'route_deviation':
        typeIcon = Icons.alt_route;
        break;
      case 'passenger_complaint':
        typeIcon = Icons.feedback;
        break;
      case 'weather_impact':
        typeIcon = Icons.wb_cloudy;
        break;
      case 'technical_issue':
        typeIcon = Icons.computer;
        break;
      default:
        typeIcon = Icons.warning;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAnomalyDetails(anomaly),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: severityColor, size: 20),
                  ),
                  const SizedBox(width: 12, height: 40),
                  
                  // Anomaly info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: severityColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                severity.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                status.replaceAll('_', ' ').toUpperCase(),
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
                          anomaly['title'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleAnomalyAction(value, anomaly),
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
                      if (status == 'new')
                        const PopupMenuItem(
                          value: 'assign',
                          child: Row(
                            children: [
                              Icon(Icons.assignment_ind),
                              SizedBox(width: 8),
                              Text('Assign to Team'),
                            ],
                          ),
                        ),
                      if (status == 'in_progress')
                        const PopupMenuItem(
                          value: 'resolve',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text('Mark as Resolved'),
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
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                anomaly['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Line and location info
              if (anomaly['line_name'] != null) ...[
                Row(
                  children: [
                    Icon(Icons.route, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4, height: 40),
                    Expanded(
                      child: Text(
                        anomaly['line_name'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Stats row
              Row(
                children: [
                  _buildStatChip(Icons.people, '${anomaly['affected_passengers']} affected', Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  if (anomaly['estimated_delay'] != 'N/A')
                    _buildStatChip(Icons.schedule, anomaly['estimated_delay'], Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  if (createdDate != null)
                    Text(
                      DzDateUtils.timeAgo(createdDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
              
              // Reporter info
              const SizedBox(height: 16),
              Row(  
                children: [
                  Icon(
                    anomaly['reporter_type'] == 'system' ? Icons.computer : Icons.person,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4, height: 40),
                  Text(
                    'Reported by ${anomaly['reporter_name']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              // Assignment info for in-progress items
              if (anomaly['assigned_to'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_ind, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8, height: 40),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned to: ${anomaly['assigned_to']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (anomaly['resolution_notes'] != null)
                              Text(
                                anomaly['resolution_notes'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  void _handleAnomalyAction(String action, Map<String, dynamic> anomaly) {
    switch (action) {
      case 'view':
        _showAnomalyDetails(anomaly);
        break;
      case 'assign':
        _assignAnomalyToTeam(anomaly);
        break;
      case 'resolve':
        _resolveAnomaly(anomaly);
        break;
      case 'location':
        _viewAnomalyOnMap(anomaly);
        break;
    }
  }

  void _showAnomalyDetails(Map<String, dynamic> anomaly) {
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
                      'Anomaly Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Type', anomaly['type'].replaceAll('_', ' ').toUpperCase()),
                    _buildDetailRow('Title', anomaly['title']),
                    _buildDetailRow('Description', anomaly['description']),
                    _buildDetailRow('Severity', anomaly['severity'].toUpperCase()),
                    _buildDetailRow('Status', anomaly['status'].replaceAll('_', ' ').toUpperCase()),
                    if (anomaly['line_name'] != null)
                      _buildDetailRow('Affected Line', anomaly['line_name']),
                    _buildDetailRow('Affected Passengers', '${anomaly['affected_passengers']}'),
                    _buildDetailRow('Estimated Delay', anomaly['estimated_delay']),
                    _buildDetailRow('Reporter Type', anomaly['reporter_type']),
                    _buildDetailRow('Reporter Name', anomaly['reporter_name']),
                    if (anomaly['assigned_to'] != null)
                      _buildDetailRow('Assigned To', anomaly['assigned_to']),
                    if (anomaly['resolution_notes'] != null)
                      _buildDetailRow('Resolution Notes', anomaly['resolution_notes']),
                    _buildDetailRow('Created', 
                      DateTime.tryParse(anomaly['created_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(anomaly['created_at']))
                          : 'Unknown'
                    ),
                    _buildDetailRow('Last Updated', 
                      DateTime.tryParse(anomaly['updated_at'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(anomaly['updated_at']))
                          : 'Unknown'
                    ),
                    if (anomaly['resolved_at'] != null)
                      _buildDetailRow('Resolved At', 
                        DateTime.tryParse(anomaly['resolved_at'] ?? '') != null
                            ? DzDateUtils.formatDateTime(DateTime.parse(anomaly['resolved_at']))
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportAnomalyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report anomaly functionality - to be implemented')),
    );
  }

  void _assignAnomalyToTeam(Map<String, dynamic> anomaly) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assign to team functionality - to be implemented')),
    );
  }

  void _resolveAnomaly(Map<String, dynamic> anomaly) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Resolve Anomaly',
      message: 'Are you sure you want to mark this anomaly as resolved?',
      confirmText: 'Resolve',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          anomaly['status'] = 'resolved';
          anomaly['resolved_at'] = DateTime.now().toIso8601String();
          anomaly['updated_at'] = DateTime.now().toIso8601String();
        });
        _categorizeAnomalies();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anomaly marked as resolved'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  void _viewAnomalyOnMap(Map<String, dynamic> anomaly) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View on map functionality - to be implemented')),
    );
  }
}