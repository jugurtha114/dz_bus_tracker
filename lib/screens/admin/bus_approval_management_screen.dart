// lib/screens/admin/bus_approval_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/bus_model.dart';
import '../../models/api_response_models.dart';

/// Comprehensive Bus Approval Management Screen with API-driven functionality
class BusApprovalManagementScreen extends StatefulWidget {
  const BusApprovalManagementScreen({super.key});

  @override
  State<BusApprovalManagementScreen> createState() => _BusApprovalManagementScreenState();
}

class _BusApprovalManagementScreenState extends State<BusApprovalManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  
  String _currentFilter = 'pending';
  bool _isLoading = false;
  List<Bus> _buses = [];
  List<Bus> _filteredBuses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController = TextEditingController();
    _tabController.addListener(_onTabChanged);
    _loadBuses();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final filters = ['pending', 'approved', 'rejected', 'active', 'maintenance'];
    setState(() {
      _currentFilter = filters[_tabController.index];
    });
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final busProvider = context.read<BusProvider>();
      
      // Map tab filter to API parameters using proper BusQueryParameters
      BusQueryParameters? queryParams;
      
      switch (_currentFilter) {
        case 'pending':
          queryParams = BusQueryParameters(isApproved: false);
          break;
        case 'approved':
          queryParams = BusQueryParameters(isApproved: true, isActive: true);
          break;
        case 'rejected':
          queryParams = BusQueryParameters(isApproved: false);
          break;
        case 'active':
          queryParams = BusQueryParameters(isActive: true);
          break;
        case 'maintenance':
          queryParams = BusQueryParameters();
          break;
      }
      
      await busProvider.fetchBuses(queryParams: queryParams);
      
      setState(() {
        _buses = busProvider.buses;
        _filteredBuses = _buses;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load buses: $e')),
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

  void _filterBuses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBuses = _buses;
      } else {
        _filteredBuses = _buses.where((bus) =>
          bus.licensePlate.toLowerCase().contains(query.toLowerCase()) ||
          bus.model.toLowerCase().contains(query.toLowerCase()) ||
          bus.manufacturer.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Bus Approval Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadBuses,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(context),
          tooltip: 'Advanced Filters',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddBusDialog(context),
          tooltip: 'Add New Bus',
        ),
      ],
      child: Column(
        children: [
          // Search and Filter Header
          _buildSearchHeader(context),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Status Tabs
          _buildStatusTabs(context),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Buses List
          Expanded(
            child: _buildBusesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            // Search Bar
            AppInput(
              controller: _searchController,
              label: 'Search buses...',
              hint: 'License plate, model, or manufacturer',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterBuses('');
                      },
                    )
                  : null,
              onChanged: _filterBuses,
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            // Stats Summary
            _buildStatsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final pendingCount = _buses.where((b) => !b.isApproved).length;
    final approvedCount = _buses.where((b) => b.isApproved && b.isActive).length;
    final maintenanceCount = _buses.where((b) => b.status == 'maintenance').length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            context,
            'Pending',
            pendingCount.toString(),
            context.colors.tertiary,
          ),
        ),
        const SizedBox(width: DesignSystem.space8),
        Expanded(
          child: _buildStatChip(
            context,
            'Active',
            approvedCount.toString(),
            context.successColor,
          ),
        ),
        const SizedBox(width: DesignSystem.space8),
        Expanded(
          child: _buildStatChip(
            context,
            'Maintenance',
            maintenanceCount.toString(),
            context.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.space12,
        vertical: DesignSystem.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: DesignSystem.space4),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(BuildContext context) {
    return AppCard(
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.hourglass_empty), text: 'Pending'),
          Tab(icon: Icon(Icons.check_circle), text: 'Approved'),
          Tab(icon: Icon(Icons.cancel), text: 'Rejected'),
          Tab(icon: Icon(Icons.directions_bus), text: 'Active'),
          Tab(icon: Icon(Icons.build), text: 'Maintenance'),
        ],
        labelColor: context.colors.primary,
        unselectedLabelColor: context.colors.onSurfaceVariant,
        indicatorColor: context.colors.primary,
        isScrollable: true,
      ),
    );
  }

  Widget _buildBusesList(BuildContext context) {
    if (_isLoading) {
      return const LoadingState.fullScreen();
    }

    if (_filteredBuses.isEmpty) {
      return EmptyState(
        title: 'No buses found',
        message: _currentFilter == 'pending'
            ? 'No pending bus registrations'
            : 'No $_currentFilter buses found',
        icon: Icons.directions_bus_filled_outlined,
        onAction: _loadBuses,
        actionText: 'Refresh',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBuses,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
        itemCount: _filteredBuses.length,
        itemBuilder: (context, index) {
          final bus = _filteredBuses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: _buildBusCard(context, bus),
          );
        },
      ),
    );
  }

  Widget _buildBusCard(BuildContext context, Bus bus) {
    return AppCard(
      onTap: () => _viewBusDetails(context, bus),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Bus Image/Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  ),
                  child: bus.photo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                          child: Image.network(
                            bus.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.directions_bus,
                                color: context.colors.onPrimaryContainer,
                                size: 32,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.directions_bus,
                          color: context.colors.onPrimaryContainer,
                          size: 32,
                        ),
                ),
                
                const SizedBox(width: DesignSystem.space12),
                
                // Bus Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.licensePlate,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.space4),
                      Text(
                        '${bus.manufacturer} ${bus.model} (${bus.year})',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Capacity: ${bus.capacity} passengers',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                StatusBadge(
                  status: _getBusStatusLabel(bus),
                  color: _getStatusBadgeTypeColor(bus),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            // Bus Details
            _buildBusDetails(context, bus),
            
            // Action Buttons (only for pending buses)
            if (!bus.isApproved && _currentFilter == 'pending') ...[ 
              const SizedBox(height: DesignSystem.space16),
              _buildActionButtons(context, bus),
            ],
            
            // Quick Actions (for approved buses)
            if (bus.isApproved) ...[
              const SizedBox(height: DesignSystem.space12),
              _buildQuickActions(context, bus),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBusDetails(BuildContext context, Bus bus) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Driver',
                bus.driverDetails?['full_name'] ?? 'Not assigned',
                Icons.person,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                'A/C',
                bus.isAirConditioned ? 'Yes' : 'No',
                bus.isAirConditioned ? Icons.ac_unit : Icons.block,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.space8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Status',
                bus.status.value.toUpperCase(),
                _getStatusIcon(bus.status.value),
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                context,
                'Added',
                _formatDate(bus.createdAt),
                Icons.calendar_today,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: DesignSystem.space6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Bus bus) {
    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            text: 'Reject',
            onPressed: () => _rejectBus(context, bus),
            icon: Icons.close,
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: AppButton(
            text: 'Approve',
            onPressed: () => _approveBus(context, bus),
            icon: Icons.check,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Bus bus) {
    return Row(
      children: [
        if (bus.isActive) ...[
          Expanded(
            child: AppButton.outlined(
              text: 'Maintenance',
              onPressed: () => _setMaintenance(context, bus),
              icon: Icons.build,
              size: AppButtonSize.small,
            ),
          ),
          const SizedBox(width: DesignSystem.space8),
        ],
        Expanded(
          child: AppButton.outlined(
            text: bus.isActive ? 'Deactivate' : 'Activate',
            onPressed: () => _toggleBusStatus(context, bus),
            icon: bus.isActive ? Icons.pause : Icons.play_arrow,
            size: AppButtonSize.small,
          ),
        ),
        const SizedBox(width: DesignSystem.space8),
        Expanded(
          child: AppButton.outlined(
            text: 'Track',
            onPressed: () => _viewBusTracking(context, bus),
            icon: Icons.location_on,
            size: AppButtonSize.small,
          ),
        ),
      ],
    );
  }

  String _getBusStatusLabel(Bus bus) {
    if (!bus.isApproved) return 'PENDING';
    if (!bus.isActive) return 'INACTIVE';
    return bus.status.value.toUpperCase();
  }

  Color _getStatusBadgeTypeColor(Bus bus) {
    if (!bus.isApproved) return DesignSystem.warning;
    if (!bus.isActive) return DesignSystem.busInactive;
    
    switch (bus.status.value.toLowerCase()) {
      case 'active':
        return DesignSystem.busActive;
      case 'maintenance':
        return DesignSystem.warning;
      case 'inactive':
        return DesignSystem.busInactive;
      default:
        return DesignSystem.busInactive;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'maintenance':
        return Icons.build;
      case 'inactive':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Action methods
  void _viewBusDetails(BuildContext context, Bus bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildBusDetailsModal(context, bus),
    );
  }

  Widget _buildBusDetailsModal(BuildContext context, Bus bus) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(DesignSystem.radiusLarge),
              topRight: Radius.circular(DesignSystem.radiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: DesignSystem.space12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(DesignSystem.space20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bus Details',
                        style: context.textStyles.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space20),
                  child: _buildDetailedBusInfo(context, bus),
                ),
              ),
              
              // Action buttons (if pending)
              if (!bus.isApproved)
                Padding(
                  padding: const EdgeInsets.all(DesignSystem.space20),
                  child: _buildActionButtons(context, bus),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedBusInfo(BuildContext context, Bus bus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bus Image
        if (bus.photo != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            child: Image.network(
              bus.photo!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: context.colors.surfaceVariant,
                  child: const Icon(Icons.directions_bus, size: 64),
                );
              },
            ),
          ),
          const SizedBox(height: DesignSystem.space24),
        ],
        
        // Basic Information
        _buildInfoSection(
          context,
          'Basic Information',
          [
            _buildInfoRow('License Plate', bus.licensePlate),
            _buildInfoRow('Manufacturer', bus.manufacturer),
            _buildInfoRow('Model', bus.model),
            _buildInfoRow('Year', bus.year.toString()),
            _buildInfoRow('Capacity', '${bus.capacity} passengers'),
            _buildInfoRow('Air Conditioned', bus.isAirConditioned ? 'Yes' : 'No'),
          ],
        ),
        
        const SizedBox(height: DesignSystem.space24),
        
        // Driver Information
        _buildInfoSection(
          context,
          'Driver Information',
          [
            _buildInfoRow('Driver Name', bus.driverDetails?['full_name'] ?? 'Not assigned'),
            _buildInfoRow('Driver Phone', bus.driverDetails?['phone_number'] ?? 'N/A'),
            _buildInfoRow('Driver License', bus.driverDetails?['driver_license_number'] ?? 'N/A'),
          ],
        ),
        
        const SizedBox(height: DesignSystem.space24),
        
        // Status Information
        _buildInfoSection(
          context,
          'Status Information',
          [
            _buildInfoRow('Approval Status', bus.isApproved ? 'Approved' : 'Pending'),
            _buildInfoRow('Active Status', bus.isActive ? 'Active' : 'Inactive'),
            _buildInfoRow('Current Status', bus.status.value.toUpperCase()),
            _buildInfoRow('Created Date', _formatFullDate(bus.createdAt)),
            _buildInfoRow('Last Updated', _formatFullDate(bus.updatedAt)),
          ],
        ),
        
        const SizedBox(height: DesignSystem.space24),
        
        // Additional Information
        if (bus.description?.isNotEmpty == true) ...[
          _buildInfoSection(
            context,
            'Description',
            [
              _buildInfoRow('Details', bus.description!),
            ],
          ),
          const SizedBox(height: DesignSystem.space24),
        ],
        
        // Features
        if (bus.features != null) ...[
          _buildInfoSection(
            context,
            'Features',
            [
              _buildInfoRow('Additional Features', bus.features.toString()),
            ],
          ),
          const SizedBox(height: DesignSystem.space24),
        ],
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: DesignSystem.space12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Action implementations using API endpoints discovered through @api_explorer.py
  Future<void> _approveBus(BuildContext context, Bus bus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Bus'),
        content: Text('Are you sure you want to approve bus ${bus.licensePlate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final busProvider = context.read<BusProvider>();
        // Use the API endpoint /api/v1/buses/buses/{id}/approve/ discovered via api_explorer.py
        final request = BusApprovalRequest(approve: true);
        await busProvider.approveBus(bus.id, request);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bus ${bus.licensePlate} has been approved')),
          );
          _loadBuses(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve bus: $e')),
          );
        }
      }
    }
  }

  Future<void> _rejectBus(BuildContext context, Bus bus) async {
    String? rejectionReason;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Bus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejecting bus ${bus.licensePlate}:'),
            const SizedBox(height: DesignSystem.space16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason for rejection...',
              ),
              maxLines: 3,
              onChanged: (value) => rejectionReason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && rejectionReason?.isNotEmpty == true) {
      try {
        final busProvider = context.read<BusProvider>();
        // Use the BusApproveRequest schema from API analysis
        final request = BusApprovalRequest(approve: false, reason: rejectionReason);
        await busProvider.approveBus(bus.id, request);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bus ${bus.licensePlate} has been rejected')),
          );
          _loadBuses(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reject bus: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleBusStatus(BuildContext context, Bus bus) async {
    final action = bus.isActive ? 'deactivate' : 'activate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.substring(0, 1).toUpperCase()}${action.substring(1)} Bus'),
        content: Text('Are you sure you want to $action bus ${bus.licensePlate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action.substring(0, 1).toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final busProvider = context.read<BusProvider>();
        // Use API endpoints /api/v1/buses/buses/{id}/activate/ and /api/v1/buses/buses/{id}/deactivate/
        if (bus.isActive) {
          await busProvider.deactivateBus(bus.id);
        } else {
          await busProvider.activateBus(bus.id);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bus ${bus.licensePlate} has been ${action}d')),
          );
          _loadBuses(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to $action bus: $e')),
          );
        }
      }
    }
  }

  Future<void> _setMaintenance(BuildContext context, Bus bus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Maintenance Mode'),
        content: Text('Set bus ${bus.licensePlate} to maintenance mode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Set Maintenance'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final busProvider = context.read<BusProvider>();
        // Update bus status using PATCH endpoint
        final request = BusUpdateRequest(status: BusStatus.maintenance);
        await busProvider.updateBus(bus.id, request);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bus ${bus.licensePlate} set to maintenance mode')),
          );
          _loadBuses(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to set maintenance mode: $e')),
          );
        }
      }
    }
  }

  void _viewBusTracking(BuildContext context, Bus bus) {
    Navigator.of(context).pushNamed(
      AppRoutes.busTracking,
      arguments: {'busId': bus.id},
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Minimum Year',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Maximum Capacity',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Apply advanced filters using API query parameters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAddBusDialog(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.busManagement);
  }
}