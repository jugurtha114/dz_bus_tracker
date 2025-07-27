// lib/screens/admin/stop_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/stop_model.dart';

/// Stop management screen for admins to manage bus stops
class StopManagementScreen extends StatefulWidget {
  const StopManagementScreen({super.key});

  @override
  State<StopManagementScreen> createState() => _StopManagementScreenState();
}

class _StopManagementScreenState extends State<StopManagementScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  List<Stop> _stops = [];

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  Future<void> _loadStops() async {
    setState(() => _isLoading = true);
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadAllStops();
      setState(() => _stops = adminProvider.allStops);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stops: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Stop Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_location),
          onPressed: _showAddStopDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStops,
        ),
      ],
      child: Column(
        children: [
          // Statistics
          Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: StatsSection(
              crossAxisCount: 2,
              stats: [
                StatItem(
                  value: '${_stops.length}',
                  label: 'Total\\nStops',
                  icon: Icons.location_on,
                  color: context.colors.primary,
                ),
                StatItem(
                  value: '${_stops.where((s) => s.isActive).length}',
                  label: 'Active\\nStops',
                  icon: Icons.check_circle,
                  color: context.successColor,
                ),
              ],
            ),
          ),
          
          // Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
            child: AppInput(
              hint: 'Search stops...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Stop List
          Expanded(
            child: _isLoading
                ? const LoadingState.fullScreen()
                : _buildStopsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsList() {
    final filteredStops = _getFilteredStops();
    
    if (filteredStops.isEmpty) {
      return const EmptyState(
        title: 'No stops found',
        message: 'No stops match your search criteria',
        icon: Icons.location_on_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.space16),
      itemCount: filteredStops.length,
      itemBuilder: (context, index) {
        final stop = filteredStops[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSystem.space12),
          child: AppCard(
            onTap: () => _showStopDetails(stop),
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: stop.isActive ? context.successColor : context.colors.error,
                    size: 24,
                  ),
                  const SizedBox(width: DesignSystem.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name ?? 'Unknown Stop',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (stop.address != null)
                          Text(
                            stop.address!,
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    status: stop.isActive ? 'ACTIVE' : 'INACTIVE',
                    color: stop.isActive ? DesignSystem.success : DesignSystem.info,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Stop> _getFilteredStops() {
    if (_searchQuery.isEmpty) return _stops;
    
    final query = _searchQuery.toLowerCase();
    return _stops.where((stop) {
      final name = stop.name?.toLowerCase() ?? '';
      final address = stop.address?.toLowerCase() ?? '';
      return name.contains(query) || address.contains(query);
    }).toList();
  }

  void _showStopDetails(Stop stop) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stop details for ${stop.name}')),
    );
  }

  void _showAddStopDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add stop form coming soon')),
    );
  }
}