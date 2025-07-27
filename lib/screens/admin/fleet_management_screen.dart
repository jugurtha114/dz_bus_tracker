// lib/screens/admin/fleet_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/bus_model.dart';
import '../../models/driver_model.dart';

/// Modern fleet management screen for comprehensive vehicle and driver oversight
class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  
  List<Bus> _vehicles = [];
  List<Driver> _drivers = [];
  Map<String, dynamic> _fleetStats = {};
  List<Map<String, dynamic>> _maintenanceRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFleetData();
  }

  Future<void> _loadFleetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadFleetData();
      
      setState(() {
        _vehicles = adminProvider.fleetVehicles;
        _drivers = adminProvider.fleetDrivers;
        _fleetStats = adminProvider.fleetStatistics;
        _maintenanceRecords = adminProvider.maintenanceRecords;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load fleet data: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      title: 'Fleet Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddVehicleDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadFleetData,
        ),
      ],
      child: Column(
        children: [
          // Fleet Statistics Header
          _buildFleetStatistics(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Tab Bar
          AppTabBar(
            controller: _tabController,
            tabs: const [
              AppTab(label: 'Vehicles', icon: Icons.directions_bus),
              AppTab(label: 'Drivers', icon: Icons.person),
              AppTab(label: 'Maintenance', icon: Icons.build),
              AppTab(label: 'Analytics', icon: Icons.analytics),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: _isLoading
                ? const LoadingState.fullScreen()
                : TabBarView(
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
    );
  }

  Widget _buildFleetStatistics() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: StatsSection(
        title: 'Fleet Overview',
        crossAxisCount: 2,
        stats: [
          StatItem(
            value: '${_fleetStats['total_vehicles'] ?? 0}',
            label: 'Total\\nVehicles',
            icon: Icons.directions_bus,
            color: context.colors.primary,
          ),
          StatItem(
            value: '${_fleetStats['active_vehicles'] ?? 0}',
            label: 'Active\\nVehicles',
            icon: Icons.check_circle,
            color: context.successColor,
          ),
          StatItem(
            value: '${_fleetStats['total_drivers'] ?? 0}',
            label: 'Total\\nDrivers',
            icon: Icons.person,
            color: context.infoColor,
          ),
          StatItem(
            value: '${_fleetStats['fleet_utilization'] ?? 0}%',
            label: 'Fleet\\nUtilization',
            icon: Icons.analytics,
            color: context.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      child: Row(
        children: [
          Expanded(
            child: AppInput(
              hint: 'Search vehicles, drivers, or plates...',
              prefixIcon: Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: DesignSystem.space8),
          AppButton.text(
            text: 'Filter',
            onPressed: _showFilterDialog,
            icon: Icons.filter_list,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesTab() {
    final filteredVehicles = _getFilteredVehicles();

    return Column(
      children: [
        // Vehicle Controls
        Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  text: 'Add Vehicle',
                  onPressed: _showAddVehicleDialog,
                  icon: Icons.add,
                ),
              ),
              const SizedBox(width: DesignSystem.space8),
              Expanded(
                child: AppButton.outlined(
                  text: 'Bulk Import',
                  onPressed: _showBulkImportDialog,
                  icon: Icons.upload_file,
                ),
              ),
            ],
          ),
        ),
        
        // Vehicle List
        Expanded(
          child: filteredVehicles.isEmpty
              ? const EmptyState(
                  title: 'No vehicles found',
                  message: 'No vehicles match your search criteria',
                  icon: Icons.directions_bus_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
                  itemCount: filteredVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = filteredVehicles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DesignSystem.space12),
                      child: _buildVehicleCard(vehicle),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Bus vehicle) {
    final statusColor = _getVehicleStatusColor(vehicle.status.value);
    final statusIcon = _getVehicleStatusIcon(vehicle.status.value);

    return AppCard(
      onTap: () => _showVehicleDetails(vehicle),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            Row(
              children: [
                // Vehicle Image/Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: DesignSystem.space12),
                
                // Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.plateNumber ?? 'Unknown',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${vehicle.make ?? 'Unknown'} ${vehicle.model ?? ''}',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.space4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: context.colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: DesignSystem.space4),
                          Text(
                            'Capacity: ${vehicle.capacity ?? 0}',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status and Actions
                Column(
                  children: [
                    StatusBadge(
                      status: vehicle.status.value.toUpperCase(),
                      color: _getVehicleBadgeStatusColor(vehicle.status.value),
                      
                    ),
                    const SizedBox(height: DesignSystem.space8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleVehicleAction(value, vehicle),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'view', child: Text('View Details')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'assign', child: Text('Assign Driver')),
                        const PopupMenuItem(value: 'maintenance', child: Text('Schedule Maintenance')),
                        const PopupMenuItem(value: 'disable', child: Text('Disable')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            // Vehicle Details Row
            Row(
              children: [
                Expanded(
                  child: _buildDetailChip(
                    'Driver',
                    vehicle.assignedDriverName ?? 'Unassigned',
                    Icons.person,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: _buildDetailChip(
                    'Route',
                    vehicle.assignedRoute ?? 'Not assigned',
                    Icons.route,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: _buildDetailChip(
                    'Mileage',
                    '${vehicle.mileage ?? 0} km',
                    Icons.speed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversTab() {
    final filteredDrivers = _getFilteredDrivers();

    return Column(
      children: [
        // Driver Controls
        Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  text: 'Add Driver',
                  onPressed: _showAddDriverDialog,
                  icon: Icons.person_add,
                ),
              ),
              const SizedBox(width: DesignSystem.space8),
              Expanded(
                child: AppButton.outlined(
                  text: 'Assign Routes',
                  onPressed: _showRouteAssignmentDialog,
                  icon: Icons.route,
                ),
              ),
            ],
          ),
        ),
        
        // Driver List
        Expanded(
          child: filteredDrivers.isEmpty
              ? const EmptyState(
                  title: 'No drivers found',
                  message: 'No drivers match your search criteria',
                  icon: Icons.person_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DesignSystem.space12),
                      child: _buildDriverCard(driver),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Driver driver) {
    final statusColor = _getDriverStatusColor(driver.status.value);

    return AppCard(
      onTap: () => _showDriverDetails(driver),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Row(
          children: [
            // Driver Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: context.colors.primaryContainer,
              backgroundImage: driver.profileImageUrl != null
                  ? NetworkImage(driver.profileImageUrl!)
                  : null,
              child: driver.profileImageUrl == null
                  ? Text(
                      _getInitials(driver.name ?? ''),
                      style: context.textStyles.titleMedium?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: DesignSystem.space12),
            
            // Driver Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name ?? 'Unknown Driver',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'License: ${driver.licenseNumber ?? 'N/A'}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.space4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: context.warningColor,
                      ),
                      const SizedBox(width: DesignSystem.space4),
                      Text(
                        '${driver.rating?.toStringAsFixed(1) ?? '0.0'}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      if (driver.assignedBusPlate != null) ...[
                        const SizedBox(width: DesignSystem.space16),
                        Icon(
                          Icons.directions_bus,
                          size: 16,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: DesignSystem.space4),
                        Text(
                          driver.assignedBusPlate!,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Status and Actions
            Column(
              children: [
                StatusBadge(
                  status: driver.status.value.toUpperCase(),
                  color: _getDriverBadgeStatusColor(driver.status.value),
                  
                ),
                const SizedBox(height: DesignSystem.space8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleDriverAction(value, driver),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Profile')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'assign_bus', child: Text('Assign Bus')),
                    const PopupMenuItem(value: 'assign_route', child: Text('Assign Route')),
                    const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return Column(
      children: [
        // Maintenance Controls
        Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  text: 'Schedule Maintenance',
                  onPressed: _showScheduleMaintenanceDialog,
                  icon: Icons.schedule,
                ),
              ),
              const SizedBox(width: DesignSystem.space8),
              Expanded(
                child: AppButton.outlined(
                  text: 'View Log',
                  onPressed: _showMaintenanceLogDialog,
                  icon: Icons.history,
                ),
              ),
            ],
          ),
        ),
        
        // Maintenance Records
        Expanded(
          child: _maintenanceRecords.isEmpty
              ? const EmptyState(
                  title: 'No maintenance records',
                  message: 'No maintenance activities scheduled or completed',
                  icon: Icons.build_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
                  itemCount: _maintenanceRecords.length,
                  itemBuilder: (context, index) {
                    final maintenance = _maintenanceRecords[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DesignSystem.space12),
                      child: _buildMaintenanceCard(maintenance),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> maintenance) {
    final priority = maintenance['priority'] ?? 'medium';
    final priorityColor = _getMaintenancePriorityColor(priority);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build,
                  color: priorityColor,
                  size: 20,
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: Text(
                    maintenance['type'] ?? 'Maintenance',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  status: priority.toUpperCase(),
                  color: _getMaintenanceBadgeStatusColor(priority),
                  
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            Text(
              'Vehicle: ${maintenance['vehicle_plate'] ?? 'Unknown'}',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              'Scheduled: ${_formatMaintenanceDate(maintenance['scheduled_date'])}',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            
            if (maintenance['description'] != null) ...[
              const SizedBox(height: DesignSystem.space8),
              Text(
                maintenance['description'],
                style: context.textStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          // Fleet Performance Metrics
          SectionLayout(
            title: 'Fleet Performance',
            child: StatsSection(
              crossAxisCount: 2,
              stats: [
                StatItem(
                  value: '${_fleetStats['avg_efficiency'] ?? 0}%',
                  label: 'Average\\nEfficiency',
                  icon: Icons.speed,
                  color: context.successColor,
                ),
                StatItem(
                  value: '${_fleetStats['uptime_percentage'] ?? 0}%',
                  label: 'Fleet\\nUptime',
                  icon: Icons.access_time,
                  color: context.infoColor,
                ),
                StatItem(
                  value: '${_fleetStats['maintenance_cost'] ?? 0}',
                  label: 'Monthly\\nMaintenance',
                  icon: Icons.attach_money,
                  color: context.warningColor,
                ),
                StatItem(
                  value: '${_fleetStats['fuel_efficiency'] ?? 0}',
                  label: 'Fuel\\nEfficiency',
                  icon: Icons.local_gas_station,
                  color: context.colors.primary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Vehicle Status Distribution
          SectionLayout(
            title: 'Vehicle Status Distribution',
            child: AppCard(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart,
                        size: 48,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: DesignSystem.space8),
                      Text(
                        'Fleet Distribution Chart',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vehicle status breakdown visualization',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Utilization Trends
          SectionLayout(
            title: 'Utilization Trends',
            child: AppCard(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 48,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: DesignSystem.space8),
                      Text(
                        'Utilization Trends',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fleet utilization over time',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.space8,
        vertical: DesignSystem.space4,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: DesignSystem.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Bus> _getFilteredVehicles() {
    var filtered = _vehicles.where((vehicle) {
      if (_selectedFilter != 'all' && vehicle.status != _selectedFilter) {
        return false;
      }
      
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return (vehicle.plateNumber?.toLowerCase().contains(query) ?? false) ||
               (vehicle.make?.toLowerCase().contains(query) ?? false) ||
               (vehicle.model?.toLowerCase().contains(query) ?? false);
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  List<Driver> _getFilteredDrivers() {
    if (_searchQuery.isEmpty) return _drivers;
    
    final query = _searchQuery.toLowerCase();
    return _drivers.where((driver) {
      return (driver.name?.toLowerCase().contains(query) ?? false) ||
             (driver.licenseNumber?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getVehicleStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return context.successColor;
      case 'maintenance':
        return context.warningColor;
      case 'offline':
        return context.colors.error;
      default:
        return context.colors.primary;
    }
  }

  IconData _getVehicleStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'maintenance':
        return Icons.build;
      case 'offline':
        return Icons.offline_bolt;
      default:
        return Icons.directions_bus;
    }
  }

  Color _getVehicleBadgeStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DesignSystem.busActive;
      case 'maintenance':
        return DesignSystem.warning;
      case 'offline':
        return DesignSystem.error;
      default:
        return DesignSystem.busInactive;
    }
  }

  Color _getDriverStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
      case 'on_duty':
        return context.successColor;
      case 'break':
        return context.warningColor;
      case 'offline':
        return context.colors.error;
      default:
        return context.colors.primary;
    }
  }

  Color _getDriverBadgeStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
      case 'on_duty':
        return DesignSystem.busActive;
      case 'break':
        return DesignSystem.warning;
      case 'offline':
        return DesignSystem.error;
      default:
        return DesignSystem.busInactive;
    }
  }

  Color _getMaintenancePriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return context.colors.error;
      case 'medium':
        return context.warningColor;
      case 'low':
        return context.infoColor;
      default:
        return context.colors.primary;
    }
  }

  Color _getMaintenanceBadgeStatusColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return DesignSystem.error;
      case 'medium':
        return DesignSystem.warning;
      case 'low':
        return DesignSystem.info;
      default:
        return DesignSystem.busInactive;
    }
  }

  String _formatMaintenanceDate(dynamic date) {
    if (date == null) return 'Not scheduled';
    try {
      final dateTime = date is String ? DateTime.parse(date) : date as DateTime;
      final now = DateTime.now();
      final difference = dateTime.difference(now);
      
      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Tomorrow';
      if (difference.inDays > 0) return 'In ${difference.inDays} days';
      if (difference.inDays == -1) return 'Yesterday';
      return '${difference.inDays.abs()} days ago';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Dialog methods
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignSystem.space16),
            // Filter options would be implemented here
            AppButton(
              text: 'Apply Filters',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVehicleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add vehicle form coming soon')),
    );
  }

  void _showBulkImportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk import feature coming soon')),
    );
  }

  void _showVehicleDetails(Bus vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle details for ${vehicle.plateNumber}')),
    );
  }

  void _showAddDriverDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add driver form coming soon')),
    );
  }

  void _showRouteAssignmentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route assignment feature coming soon')),
    );
  }

  void _showDriverDetails(Driver driver) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Driver details for ${driver.name}')),
    );
  }

  void _showScheduleMaintenanceDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule maintenance form coming soon')),
    );
  }

  void _showMaintenanceLogDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maintenance log viewer coming soon')),
    );
  }

  void _handleVehicleAction(String action, Bus vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for ${vehicle.plateNumber}')),
    );
  }

  void _handleDriverAction(String action, Driver driver) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for ${driver.name}')),
    );
  }
}