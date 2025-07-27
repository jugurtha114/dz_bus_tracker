// lib/screens/passenger/bus_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/bus_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/bus_model.dart';

/// Modern bus details screen showing comprehensive bus information
class BusDetailsScreen extends StatefulWidget {
  final String busId;

  const BusDetailsScreen({
    super.key,
    required this.busId,
  });

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  bool _isLoading = true;
  Bus? _busData;

  @override
  void initState() {
    super.initState();
    _loadBusDetails();
  }

  Future<void> _loadBusDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final busProvider = context.read<BusProvider>();
      await busProvider.fetchBusById(widget.busId);
      
      setState(() {
        _busData = busProvider.selectedBus;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bus details: $error')),
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
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Bus Details',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadBusDetails,
        ),
      ],
      child: _isLoading
          ? const LoadingState.fullScreen()
          : _busData == null
              ? const EmptyState(
                  title: 'Bus not found',
                  message: 'The requested bus could not be found.',
                  icon: Icons.directions_bus_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadBusDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Bus Header
                        _buildBusHeader(context, _busData!),
                        
                        const SizedBox(height: DesignSystem.space16),
                        
                        // Quick Actions
                        _buildQuickActions(context, _busData!),
                        
                        const SizedBox(height: DesignSystem.space16),
                        
                        // Bus Information
                        _buildBusInformation(context, _busData!),
                        
                        const SizedBox(height: DesignSystem.space16),
                        
                        // Route Information
                        _buildRouteInformation(context, _busData!),
                        
                        const SizedBox(height: DesignSystem.space16),
                        
                        // Schedule Information
                        _buildScheduleInformation(context, _busData!),
                        
                        const SizedBox(height: DesignSystem.space16),
                        
                        // Real-time Status
                        _buildRealTimeStatus(context, _busData!),
                        
                        const SizedBox(height: DesignSystem.space24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBusHeader(BuildContext context, Bus bus) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Column(
        children: [
          // Bus icon and number
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colors.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bus,
                  size: 30,
                  color: context.colors.primary,
                ),
              ),
              
              const SizedBox(width: DesignSystem.space16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus ${bus.number}',
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      bus.licensePlate ?? 'License: N/A',
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: context.colors.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              StatusBadge(
                status: bus.status?.value.toUpperCase() ?? 'UNKNOWN',
                color: _getBusStatusColor(bus.status?.value),
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.space20),
          
          // Key metrics
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context,
                  'Capacity',
                  '${bus.capacity ?? 0}',
                  Icons.people,
                  context.colors.onPrimary,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  context,
                  'Occupancy',
                  _getOccupancyText(bus.occupancyLevel),
                  Icons.event_seat,
                  context.colors.onPrimary,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  context,
                  'Speed',
                  '${bus.currentSpeed?.toStringAsFixed(0) ?? '0'} km/h',
                  Icons.speed,
                  context.colors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.9), size: 20),
        const SizedBox(height: DesignSystem.space4),
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Bus bus) {
    return SectionLayout(
      title: 'Quick Actions',
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Track Live',
              onPressed: () => _trackBusLive(bus),
              icon: Icons.location_on,
            ),
          ),
          const SizedBox(width: DesignSystem.space12),
          Expanded(
            child: AppButton.outlined(
              text: 'Set Alert',
              onPressed: () => _setArrivalAlert(bus),
              icon: Icons.notifications,
            ),
          ),
          const SizedBox(width: DesignSystem.space12),
          Expanded(
            child: AppButton.outlined(
              text: 'Share',
              onPressed: () => _shareBus(bus),
              icon: Icons.share,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusInformation(BuildContext context, Bus bus) {
    return SectionLayout(
      title: 'Bus Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildInfoRow('Bus Number', bus.number ?? 'Unknown'),
              _buildInfoRow('License Plate', bus.licensePlate ?? 'N/A'),
              _buildInfoRow('Model', bus.model ?? 'N/A'),
              _buildInfoRow('Year', bus.year?.toString() ?? 'N/A'),
              _buildInfoRow('Capacity', '${bus.capacity ?? 0} passengers'),
              _buildInfoRow('Driver', bus.driverName ?? 'Not assigned'),
              _buildInfoRow('Status', bus.status?.value.toUpperCase() ?? 'UNKNOWN'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInformation(BuildContext context, Bus bus) {
    return SectionLayout(
      title: 'Route Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildInfoRow('Current Route', bus.currentRoute ?? 'No active route'),
              _buildInfoRow('Direction', bus.direction ?? 'N/A'),
              _buildInfoRow('Next Stop', bus.nextStop ?? 'Unknown'),
              _buildInfoRow('Distance to Next', '${(bus.distanceToNextStop is double ? (bus.distanceToNextStop as double).toStringAsFixed(1) : bus.distanceToNextStop?.toString() ?? '0.0')} km'),
              _buildInfoRow('ETA', bus.estimatedArrival ?? 'Calculating...'),
              
              const SizedBox(height: DesignSystem.space12),
              
              AppButton.text(
                text: 'View Full Route',
                onPressed: () => _viewFullRoute(bus),
                icon: Icons.route,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleInformation(BuildContext context, Bus bus) {
    return SectionLayout(
      title: 'Schedule Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildInfoRow('First Departure', bus.firstDeparture ?? 'N/A'),
              _buildInfoRow('Last Departure', bus.lastDeparture ?? 'N/A'),
              _buildInfoRow('Frequency', '${bus.frequency ?? 0} minutes'),
              _buildInfoRow('Service Days', bus.serviceDays ?? 'Daily'),
              
              const SizedBox(height: DesignSystem.space12),
              
              AppButton.text(
                text: 'View Schedule',
                onPressed: () => _viewSchedule(bus),
                icon: Icons.schedule,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeStatus(BuildContext context, Bus bus) {
    return SectionLayout(
      title: 'Real-time Status',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              // Current location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: context.colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: DesignSystem.space8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${bus.currentLocation?['latitude']?.toStringAsFixed(6) ?? '0.000000'}, '
                          '${bus.currentLocation?['longitude']?.toStringAsFixed(6) ?? '0.000000'}',
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton.text(
                    text: 'View on Map',
                    onPressed: () => _viewOnMap(bus),
                    size: AppButtonSize.small,
                  ),
                ],
              ),
              
              const SizedBox(height: DesignSystem.space16),
              
              // Last update
              _buildInfoRow('Last Update', _formatLastUpdate(bus.lastUpdate)),
              _buildInfoRow('Current Speed', '${bus.currentSpeed?.toStringAsFixed(1) ?? '0.0'} km/h'),
              _buildInfoRow('Passengers', '${bus.currentPassengers ?? 0}/${bus.capacity ?? 0}'),
              
              // Occupancy indicator
              const SizedBox(height: DesignSystem.space12),
              
              Container(
                padding: const EdgeInsets.all(DesignSystem.space12),
                decoration: BoxDecoration(
                  color: _getOccupancyColor(bus.occupancyLevel).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: _getOccupancyColor(bus.occupancyLevel),
                    ),
                    const SizedBox(width: DesignSystem.space8),
                    Expanded(
                      child: Text(
                        'Occupancy Level: ${_getOccupancyText(bus.occupancyLevel)}',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: _getOccupancyColor(bus.occupancyLevel),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBusStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DesignSystem.busActive;
      case 'delayed':
        return DesignSystem.warning;
      case 'offline':
        return DesignSystem.busInactive;
      default:
        return DesignSystem.onSurfaceVariant;
    }
  }

  String _getOccupancyText(String? occupancyLevel) {
    switch (occupancyLevel?.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return 'Unknown';
    }
  }

  Color _getOccupancyColor(String? occupancyLevel) {
    switch (occupancyLevel?.toLowerCase()) {
      case 'low':
        return context.successColor;
      case 'medium':
        return context.warningColor;
      case 'high':
        return context.colors.error;
      default:
        return context.colors.onSurfaceVariant;
    }
  }

  String _formatLastUpdate(DateTime? lastUpdate) {
    if (lastUpdate == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _trackBusLive(Bus bus) {
    Navigator.of(context).pushNamed(
      AppRoutes.busTracking,
      arguments: {'busId': bus.id},
    );
  }

  void _setArrivalAlert(Bus bus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Arrival Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Get notified when Bus ${bus.number} is approaching your location.'),
            const SizedBox(height: DesignSystem.space16),
            Text(
              'Select notification distance:',
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            // Add distance selection UI here
          ],
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Set Alert',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Alert set for Bus ${bus.number}')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _shareBus(Bus bus) {
    // Implement bus sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing Bus ${bus.number} information')),
    );
  }

  void _viewFullRoute(Bus bus) {
    // Navigate to route details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route details functionality coming soon')),
    );
  }

  void _viewSchedule(Bus bus) {
    // Navigate to schedule view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule view functionality coming soon')),
    );
  }

  void _viewOnMap(Bus bus) {
    Navigator.of(context).pushNamed(
      AppRoutes.busTracking,
      arguments: {'busId': bus.id},
    );
  }
}