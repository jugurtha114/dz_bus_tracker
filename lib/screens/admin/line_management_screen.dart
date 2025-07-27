// lib/screens/admin/line_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/line_model.dart';

/// Comprehensive line management screen for admins to manage bus routes and lines
class LineManagementScreen extends StatefulWidget {
  const LineManagementScreen({super.key});

  @override
  State<LineManagementScreen> createState() => _LineManagementScreenState();
}

class _LineManagementScreenState extends State<LineManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Line> _allLines = [];
  List<Line> _activeLines = [];
  List<Line> _inactiveLines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLines();
  }

  Future<void> _loadLines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadAllLines();
      
      setState(() {
        _allLines = adminProvider.allLines;
        _activeLines = adminProvider.activeLines;
        _inactiveLines = adminProvider.inactiveLines;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lines: $error')),
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
      title: 'Line Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddLineDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadLines,
        ),
      ],
      child: Column(
        children: [
          // Line Statistics Header
          _buildLineStatistics(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Tab Bar
          AppTabBar(
            controller: _tabController,
            tabs: [
              AppTab(
                label: 'All (${_allLines.length})',
                icon: Icons.route,
              ),
              AppTab(
                label: 'Active (${_activeLines.length})',
                icon: Icons.check_circle,
              ),
              AppTab(
                label: 'Inactive (${_inactiveLines.length})',
                icon: Icons.pause_circle,
              ),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: _isLoading
                ? const LoadingState.fullScreen()
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

  Widget _buildLineStatistics() {
    final totalBuses = _allLines.fold<int>(0, (sum, line) => sum + (line.totalBuses ?? 0));
    final activeBuses = _allLines.fold<int>(0, (sum, line) => sum + (line.activeBuses ?? 0));
    final totalTrips = _allLines.fold<int>(0, (sum, line) => sum + (line.dailyTrips ?? 0));

    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: StatsSection(
        title: 'Line Overview',
        crossAxisCount: 2,
        stats: [
          StatItem(
            value: '${_allLines.length}',
            label: 'Total\\nLines',
            icon: Icons.route,
            color: context.colors.primary,
          ),
          StatItem(
            value: '${_activeLines.length}',
            label: 'Active\\nLines',
            icon: Icons.check_circle,
            color: context.successColor,
          ),
          StatItem(
            value: '$activeBuses/$totalBuses',
            label: 'Active\\nBuses',
            icon: Icons.directions_bus,
            color: context.infoColor,
          ),
          StatItem(
            value: '$totalTrips',
            label: 'Daily\\nTrips',
            icon: Icons.trip_origin,
            color: context.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      child: AppInput(
        hint: 'Search lines by name, code, or description...',
        prefixIcon: const Icon(Icons.search),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildLinesList(List<Line> lines) {
    if (lines.isEmpty) {
      return EmptyState(
        title: 'No lines found',
        message: _searchQuery.isNotEmpty 
            ? 'No lines match your search criteria'
            : 'No lines in this category',
        icon: Icons.route_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLines,
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignSystem.space16),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: _buildLineCard(line),
          );
        },
      ),
    );
  }

  Widget _buildLineCard(Line line) {
    final lineColor = _getLineColor(line.color);

    return AppCard(
      onTap: () => _showLineDetails(line),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Line Color Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(width: DesignSystem.space12),
                
                // Line Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            line.code ?? 'Unknown',
                            style: context.textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: lineColor,
                            ),
                          ),
                          const SizedBox(width: DesignSystem.space8),
                          StatusBadge(
                            status: line.isActive ? 'ACTIVE' : 'INACTIVE',
                            color: line.isActive ? DesignSystem.busActive : DesignSystem.busInactive,
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.space4),
                      Text(
                        line.name ?? 'Unnamed Line',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions Menu
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
                    const PopupMenuItem(
                      value: 'buses',
                      child: Row(
                        children: [
                          Icon(Icons.directions_bus),
                          SizedBox(width: 8),
                          Text('Assign Buses'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: line.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(line.isActive ? Icons.pause : Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(line.isActive ? 'Deactivate' : 'Activate'),
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
            
            const SizedBox(height: DesignSystem.space8),
            
            // Description
            if (line.description != null && line.description!.isNotEmpty)
              Text(
                line.description!,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: DesignSystem.space12),
            
            // Line Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    'Stops',
                    '${line.totalStops ?? 0}',
                    Icons.location_on,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: _buildStatChip(
                    'Distance',
                    '${line.distance?.toStringAsFixed(1) ?? '0.0'} km',
                    Icons.straighten,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: _buildStatChip(
                    'Duration',
                    '${line.estimatedDuration ?? 0} min',
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            // Additional Info
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    'Buses',
                    '${line.activeBuses ?? 0}/${line.totalBuses ?? 0}',
                    Icons.directions_bus,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: _buildStatChip(
                    'Trips/Day',
                    '${line.dailyTrips ?? 0}',
                    Icons.trip_origin,
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${line.fare?.toStringAsFixed(0) ?? '0'} DA',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
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
  List<Line> _getFilteredLines(List<Line> lines) {
    if (_searchQuery.isEmpty) return lines;
    
    final query = _searchQuery.toLowerCase();
    return lines.where((line) {
      final name = line.name?.toLowerCase() ?? '';
      final code = line.code?.toLowerCase() ?? '';
      final description = line.description?.toLowerCase() ?? '';
      return name.contains(query) || code.contains(query) || description.contains(query);
    }).toList();
  }

  Color _getLineColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return context.colors.primary;
    }
    
    try {
      final color = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (e) {
      return context.colors.primary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays < 30) return '${difference.inDays}d ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).round()}m ago';
    return '${(difference.inDays / 365).round()}y ago';
  }

  // Action handlers
  void _handleLineAction(String action, Line line) {
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
      case 'buses':
        _assignBusesToLine(line);
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

  void _showLineDetails(Line line) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'Line Details',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSystem.space16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _buildLineInfoSection(line),
                      const SizedBox(height: DesignSystem.space16),
                      _buildLineStatsSection(line),
                      const SizedBox(height: DesignSystem.space16),
                      _buildLineOperationsSection(line),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineInfoSection(Line line) {
    return SectionLayout(
      title: 'Line Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildDetailRow('Code', line.code ?? 'Not provided'),
              _buildDetailRow('Name', line.name ?? 'Not provided'),
              _buildDetailRow('Description', line.description ?? 'Not provided'),
              _buildDetailRow('Status', line.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Fare', '${line.fare?.toStringAsFixed(0) ?? '0'} DA'),
              _buildDetailRow('Color', line.color ?? 'Default'),
              _buildDetailRow('Created', _formatDate(line.createdAt)),
              _buildDetailRow('Last Updated', _formatDate(line.updatedAt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineStatsSection(Line line) {
    return SectionLayout(
      title: 'Line Statistics',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildDetailRow('Total Stops', '${line.totalStops ?? 0}'),
              _buildDetailRow('Distance', '${line.distance?.toStringAsFixed(1) ?? '0.0'} km'),
              _buildDetailRow('Estimated Duration', '${line.estimatedDuration ?? 0} minutes'),
              _buildDetailRow('Total Buses', '${line.totalBuses ?? 0}'),
              _buildDetailRow('Active Buses', '${line.activeBuses ?? 0}'),
              _buildDetailRow('Daily Trips', '${line.dailyTrips ?? 0}'),
              _buildDetailRow('Average Rating', line.averageRating != null 
                  ? '${line.averageRating!.toStringAsFixed(1)} ⭐'
                  : 'Not rated'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineOperationsSection(Line line) {
    return SectionLayout(
      title: 'Operations',
      child: Column(
        children: [
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Manage Stops'),
              subtitle: Text('${line.totalStops ?? 0} stops on this line'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _manageLineStops(line),
            ),
          ),
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Assign Buses'),
              subtitle: Text('${line.activeBuses ?? 0}/${line.totalBuses ?? 0} buses assigned'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _assignBusesToLine(line),
            ),
          ),
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Manage Schedule'),
              subtitle: Text('${line.dailyTrips ?? 0} trips per day'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _manageLineSchedule(line),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddLineDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add line form coming soon')),
    );
  }

  void _showEditLineDialog(Line line) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit line form for ${line.name} coming soon')),
    );
  }

  void _manageLineStops(Line line) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stop management for ${line.name} coming soon')),
    );
  }

  void _assignBusesToLine(Line line) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bus assignment for ${line.name} coming soon')),
    );
  }

  void _manageLineSchedule(Line line) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule management for ${line.name} coming soon')),
    );
  }

  void _toggleLineStatus(Line line) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(line.isActive ? 'Deactivate Line' : 'Activate Line'),
        content: Text(
          'Are you sure you want to ${line.isActive ? 'deactivate' : 'activate'} ${line.name}?'
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: line.isActive ? 'Deactivate' : 'Activate',
            onPressed: () {
              Navigator.of(context).pop();
              _processLineStatusToggle(line);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processLineStatusToggle(Line line) async {
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.toggleLineStatus(line.id!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Line ${line.isActive ? 'deactivated' : 'activated'} successfully'),
          backgroundColor: context.successColor,
        ),
      );
      
      _loadLines();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update line status: $error')),
      );
    }
  }

  void _deleteLine(Line line) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Line'),
        content: Text(
          'Are you sure you want to delete ${line.name}? This action cannot be undone and will affect all associated buses, stops, and schedules.'
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Delete',
            onPressed: () {
              Navigator.of(context).pop();
              _processLineDeletion(line);
            },
            ),
        ],
      ),
    );
  }

  Future<void> _processLineDeletion(Line line) async {
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.deleteLine(line.id!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${line.name} deleted successfully'),
          backgroundColor: context.colors.error,
        ),
      );
      
      _loadLines();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete line: $error')),
      );
    }
  }
}