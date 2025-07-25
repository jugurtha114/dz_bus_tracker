// lib/screens/admin/fleet_management_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/fleet_management_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';

class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({Key? key}) : super(key: key);

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FleetManagementService _fleetService = FleetManagementService();
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _buses = [];
  List<Map<String, dynamic>> _drivers = [];
  Map<String, dynamic> _fleetStats = {};
  List<Map<String, dynamic>> _maintenanceSchedule = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFleetData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFleetData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _fleetService.getAllBuses(),
        _fleetService.getAllDrivers(),
        _fleetService.getFleetStatistics(),
        _fleetService.getMaintenanceSchedule(),
      ]);
      
      setState(() {
        _buses = results[0] as List<Map<String, dynamic>>;
        _drivers = results[1] as List<Map<String, dynamic>>;
        _fleetStats = results[2] as Map<String, dynamic>;
        _maintenanceSchedule = results[3] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Fleet Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddVehicleDialog,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() => _selectedFilter = value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'all', child: Text('All Vehicles')),
            const PopupMenuItem(value: 'active', child: Text('Active')),
            const PopupMenuItem(value: 'maintenance', child: Text('In Maintenance')),
            const PopupMenuItem(value: 'offline', child: Text('Offline')),
          ],
        ),
      ],
      child: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _loadFleetData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fleet overview stats
                    _buildFleetOverview(),
                    const SizedBox(height: 16),
                    
                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    
                    // Tab navigation
                    _buildTabNavigation(),
                    const SizedBox(height: 16),
                    
                    // Tab content
                    SizedBox(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildVehiclesTab(),
                          _buildDriversTab(),
                          _buildMaintenanceTab(),
                          _buildAnalyticsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFleetOverview() {
    final stats = _fleetStats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fleet Overview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Vehicles',
                '${stats['total_vehicles'] ?? 0}',
                Icons.directions_bus,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'Active',
                '${stats['active_vehicles'] ?? 0}',
                Icons.check_circle,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'In Service',
                '${stats['in_service'] ?? 0}',
                Icons.build,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'Offline',
                '${stats['offline_vehicles'] ?? 0}',
                Icons.offline_bolt,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Drivers',
                '${stats['total_drivers'] ?? 0}',
                Icons.person,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'On Duty',
                '${stats['drivers_on_duty'] ?? 0}',
                Icons.work,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'Utilization',
                '${stats['fleet_utilization'] ?? 0}%',
                Icons.analytics,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'Efficiency',
                '${stats['fleet_efficiency'] ?? 0}%',
                Icons.speed,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search vehicles, drivers, or license plates...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.primary,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Vehicles'),
          Tab(text: 'Drivers'),
          Tab(text: 'Maintenance'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildVehiclesTab() {
    final filteredBuses = _getFilteredBuses();
    
    return Column(
      children: [
        // Vehicle controls
        Row(
          children: [
            Expanded(
              child: CustomButton(
        text: 'Add Vehicle',
        onPressed: _showAddVehicleDialog,
        icon: Icons.add,
        type: ButtonType.outline
      ),
            ),
            const SizedBox(width: 8, height: 40),
            Expanded(
              child: CustomButton(
        text: 'Bulk Import',
        onPressed: _showBulkImportDialog,
        icon: Icons.upload_file,
        type: ButtonType.outline
      ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Vehicle list
        Expanded(
          child: filteredBuses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                      SizedBox(),
                      Text('No vehicles found'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredBuses.length,
                  itemBuilder: (context, index) {
                    final bus = filteredBuses[index];
                    return _buildVehicleCard(bus);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> bus) {
    final status = bus['status'] ?? 'unknown';
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'active':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case 'maintenance':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.build;
        break;
      case 'offline':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.offline_bolt;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.help;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showVehicleDetails(bus),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12, height: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus ${bus['license_plate'] ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${bus['make'] ?? 'Unknown'} ${bus['model'] ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleVehicleAction(value, bus),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'assign', child: Text('Assign Driver')),
                      const PopupMenuItem(value: 'maintenance', child: Text('Schedule Maintenance')),
                      const PopupMenuItem(value: 'disable', child: Text('Disable')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Vehicle details
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleDetailItem(
                      'Capacity',
                      '${bus['capacity'] ?? 0} seats',
                      Icons.airline_seat_recline_normal,
                    ),
                  ),
                  Expanded(
                    child: _buildVehicleDetailItem(
                      'Mileage',
                      '${bus['mileage'] ?? 0} km',
                      Icons.speed,
                    ),
                  ),
                  Expanded(
                    child: _buildVehicleDetailItem(
                      'Driver',
                      bus['driver_name'] ?? 'Unassigned',
                      Icons.person,
                    ),
                  ),
                ],
              ),
              
              if (bus['line_name'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Route: ${bus['line_name']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDriversTab() {
    final filteredDrivers = _getFilteredDrivers();
    
    return Column(
      children: [
        // Driver controls
        Row(
          children: [
            Expanded(
              child: CustomButton(
        text: 'Add Driver',
        onPressed: _showAddDriverDialog,
        icon: Icons.person_add,
        type: ButtonType.outline
      ),
            ),
            const SizedBox(width: 8, height: 40),
            Expanded(
              child: CustomButton(
        text: 'Assign Routes',
        onPressed: _showRouteAssignmentDialog,
        icon: Icons.route,
        type: ButtonType.outline
      ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Driver list
        Expanded(
          child: filteredDrivers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 64, color: Colors.grey),
                      SizedBox(),
                      Text('No drivers found'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];
                    return _buildDriverCard(driver);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final status = driver['status'] ?? 'offline';
    Color statusColor;
    
    switch (status) {
      case 'online':
      case 'on_duty':
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      case 'break':
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      case 'offline':
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDriverDetails(driver),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                child: Text(
                  _getInitials(driver['name'] ?? ''),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16, height: 40),
              
              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'] ?? 'Unknown Driver',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'License: ${driver['license_number'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (driver['assigned_bus'] != null)
                      Text(
                        'Bus: ${driver['assigned_bus']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Status and rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 2, height: 40),
                      Text(
                        '${driver['rating'] ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return Column(
      children: [
        // Maintenance controls
        Row(
          children: [
            Expanded(
              child: CustomButton(
        text: 'Schedule Maintenance',
        onPressed: _showScheduleMaintenanceDialog,
        icon: Icons.schedule,
        type: ButtonType.outline
      ),
            ),
            const SizedBox(width: 8, height: 40),
            Expanded(
              child: CustomButton(
        text: 'Maintenance Log',
        onPressed: _showMaintenanceLogDialog,
        icon: Icons.history,
        type: ButtonType.outline
      ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Maintenance schedule
        Expanded(
          child: _maintenanceSchedule.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build, size: 64, color: Colors.grey),
                      SizedBox(),
                      Text('No maintenance scheduled'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _maintenanceSchedule.length,
                  itemBuilder: (context, index) {
                    final maintenance = _maintenanceSchedule[index];
                    return _buildMaintenanceCard(maintenance);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> maintenance) {
    final priority = maintenance['priority'] ?? 'medium';
    Color priorityColor;
    
    switch (priority) {
      case 'high':
        priorityColor = Theme.of(context).colorScheme.primary;
        break;
      case 'medium':
        priorityColor = Theme.of(context).colorScheme.primary;
        break;
      case 'low':
        priorityColor = Theme.of(context).colorScheme.primary;
        break;
      default:
        priorityColor = Theme.of(context).colorScheme.primary;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: priorityColor, size: 20),
                const SizedBox(width: 8, height: 40),
                Expanded(
                  child: Text(
                    maintenance['type'] ?? 'Maintenance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Vehicle: ${maintenance['vehicle_id'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Scheduled: ${DzDateUtils.formatDate(DateTime.tryParse(maintenance['scheduled_date'] ?? '') ?? DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (maintenance['description'] != null) ...[
              const SizedBox(height: 16),
              Text(
                maintenance['description'],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Fleet efficiency chart
          CustomCard(type: CardType.elevated, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fleet Efficiency Trends',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateEfficiencyData(),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Vehicle utilization
          CustomCard(type: CardType.elevated, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Utilization',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  child: PieChart(
                    PieChartData(
                      sections: _generateUtilizationData(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBuses() {
    var filtered = _buses;
    
    if (_selectedFilter != 'all') {
      filtered = filtered.where((bus) => bus['status'] == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bus) {
        final query = _searchQuery.toLowerCase();
        return (bus['license_plate']?.toLowerCase().contains(query) ?? false) ||
               (bus['make']?.toLowerCase().contains(query) ?? false) ||
               (bus['model']?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    return filtered;
  }

  List<Map<String, dynamic>> _getFilteredDrivers() {
    if (_searchQuery.isEmpty) return _drivers;
    
    return _drivers.where((driver) {
      final query = _searchQuery.toLowerCase();
      return (driver['name']?.toLowerCase().contains(query) ?? false) ||
             (driver['license_number']?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  List<FlSpot> _generateEfficiencyData() {
    return [
      const FlSpot(0, 75),
      const FlSpot(1, 78),
      const FlSpot(2, 82),
      const FlSpot(3, 79),
      const FlSpot(4, 85),
      const FlSpot(5, 88),
      const FlSpot(6, 87),
    ];
  }

  List<PieChartSectionData> _generateUtilizationData() {
    return [
      PieChartSectionData(
        value: 65,
        color: Theme.of(context).colorScheme.primary,
        title: 'Active\n65%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: 20,
        color: Theme.of(context).colorScheme.primary,
        title: 'Maintenance\n20%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: 15,
        color: Theme.of(context).colorScheme.primary,
        title: 'Offline\n15%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  void _showAddVehicleDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'Add Vehicle',
      message: 'Vehicle addition form would be implemented here.',
    );
  }

  void _showBulkImportDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'Bulk Import',
      message: 'Bulk import functionality would be implemented here.',
    );
  }

  void _showVehicleDetails(Map<String, dynamic> bus) {
    DialogHelper.showInfoDialog(
      context,
      title: 'Vehicle Details',
      message: 'Detailed vehicle information for ${bus['license_plate']} would be shown here.',
    );
  }

  void _showAddDriverDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'Add Driver',
      message: 'Driver registration form would be implemented here.',
    );
  }

  void _showRouteAssignmentDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'Route Assignment',
      message: 'Route assignment interface would be implemented here.',
    );
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
    DialogHelper.showInfoDialog(
      context,
      title: 'Driver Details',
      message: 'Detailed driver information for ${driver['name']} would be shown here.',
    );
  }

  void _showScheduleMaintenanceDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'Schedule Maintenance',
      message: 'Maintenance scheduling form would be implemented here.',
    );
  }

  void _showMaintenanceLogDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'Maintenance Log',
      message: 'Maintenance history and logs would be shown here.',
    );
  }

  void _handleVehicleAction(String action, Map<String, dynamic> bus) {
    DialogHelper.showInfoDialog(
      context,
      title: 'Vehicle Action',
      message: 'Action "$action" for vehicle ${bus['license_plate']} would be implemented here.',
    );
  }
}