// lib/screens/passenger/line_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/line_provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/line_model.dart';
import '../../models/bus_model.dart';
import '../../models/stop_model.dart';

/// Modern line details screen showing comprehensive line information
class LineDetailsScreen extends StatefulWidget {
  final String lineId;

  const LineDetailsScreen({
    super.key,
    required this.lineId,
  });

  @override
  State<LineDetailsScreen> createState() => _LineDetailsScreenState();
}

class _LineDetailsScreenState extends State<LineDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Line? _lineData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLineDetails();
  }

  Future<void> _loadLineDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lineProvider = context.read<LineProvider>();
      await lineProvider.fetchLineById(widget.lineId);
      
      setState(() {
        _lineData = lineProvider.selectedLine;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load line details: $error')),
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
      title: 'Line Details',
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () => _toggleFavorite(),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareLine(),
        ),
      ],
      child: _isLoading
          ? const LoadingState.fullScreen()
          : _lineData == null
              ? const EmptyState(
                  title: 'Line not found',
                  message: 'The requested line could not be found.',
                  icon: Icons.route_outlined,
                )
              : Column(
                  children: [
                    // Line Header
                    _buildLineHeader(context, _lineData!),
                    
                    // Tab Bar
                    AppTabBar(
                      controller: _tabController,
                      tabs: const [
                        AppTab(label: 'Overview', icon: Icons.info),
                        AppTab(label: 'Stops', icon: Icons.location_on),
                        AppTab(label: 'Buses', icon: Icons.directions_bus),
                        AppTab(label: 'Schedule', icon: Icons.schedule),
                      ],
                    ),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(context, _lineData!),
                          _buildStopsTab(context, _lineData!),
                          _buildBusesTab(context, _lineData!),
                          _buildScheduleTab(context, _lineData!),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLineHeader(BuildContext context, Line line) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: line.color != null
              ? [
                  Color(int.parse(line.color!.replaceFirst('#', '0xff'))),
                  Color(int.parse(line.color!.replaceFirst('#', '0xff'))).withValues(alpha: 0.8),
                ]
              : [
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
          // Line number and name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    line.code,
                    style: context.textStyles.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: DesignSystem.space16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name ?? 'Unnamed Line',
                      style: context.textStyles.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      line.description ?? 'No description available',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              StatusBadge(
                status: (line.isActive ? 'ACTIVE' : 'INACTIVE'),
                color: _getLineStatusColor(line.isActive),
                
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.space20),
          
          // Route overview
          Row(
            children: [
              Expanded(
                child: _buildRoutePoint(
                  context,
                  'From',
                  line.stops.isNotEmpty ? line.stops.first.stopName ?? 'Unknown' : 'Unknown',
                  Icons.radio_button_checked,
                ),
              ),
              
              Container(
                width: 40,
                height: 2,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              
              Expanded(
                child: _buildRoutePoint(
                  context,
                  'To',
                  line.stops.isNotEmpty ? line.stops.last.stopName ?? 'Unknown' : 'Unknown',
                  Icons.location_on,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Quick metrics
          Row(
            children: [
              Expanded(
                child: _buildQuickMetric(
                  context,
                  'Distance',
                  '${line.distance.toStringAsFixed(1)} km',
                  Icons.straighten,
                ),
              ),
              Expanded(
                child: _buildQuickMetric(
                  context,
                  'Frequency',
                  'Every ${line.frequency ?? 0}min',
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildQuickMetric(
                  context,
                  'Stops',
                  '${line.totalStops}',
                  Icons.location_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(BuildContext context, String label, String location, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: DesignSystem.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          location,
          style: context.textStyles.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickMetric(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 16,
        ),
        const SizedBox(height: DesignSystem.space4),
        Text(
          value,
          style: context.textStyles.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, Line line) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          // Line Information
          SectionLayout(
            title: 'Line Information',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    _buildInfoRow('Line Number', line.code),
                    _buildInfoRow('Line Name', line.name ?? 'N/A'),
                    _buildInfoRow('Type', 'Regular'), // Mock - Line model doesn't have type property
                    _buildInfoRow('Operator', 'DZ Bus Transit'), // Mock - Line model doesn't have operator property
                    _buildInfoRow('Service Days', line.serviceDays ?? 'Daily'),
                    _buildInfoRow('First Service', line.firstDeparture ?? 'N/A'),
                    _buildInfoRow('Last Service', line.lastDeparture ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Route Information
          SectionLayout(
            title: 'Route Information',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    _buildInfoRow('Start Location', line.startLocation ?? 'N/A'),
                    _buildInfoRow('End Location', line.endLocation ?? 'N/A'),
                    _buildInfoRow('Total Distance', '${line.totalDistance?.toStringAsFixed(1) ?? '0.0'} km'),
                    _buildInfoRow('Number of Stops', '${line.totalStops}'),
                    _buildInfoRow('Average Journey Time', '${line.averageJourneyTime ?? 0} minutes'),
                    
                    const SizedBox(height: DesignSystem.space12),
                    
                    AppButton.outlined(
                      text: 'View on Map',
                      onPressed: () => _viewRouteOnMap(line),
                      icon: Icons.map,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Service Statistics
          SectionLayout(
            title: 'Service Statistics',
            child: StatsSection(
              crossAxisCount: 2,
              stats: [
                StatItem(
                  value: '${line.dailyTrips ?? 0}',
                  label: 'Daily\\nTrips',
                  icon: Icons.route,
                  color: context.colors.primary,
                ),
                StatItem(
                  value: '${line.averagePassengers ?? 0}',
                  label: 'Avg\\nPassengers',
                  icon: Icons.people,
                  color: context.successColor,
                ),
                StatItem(
                  value: '${line.onTimePerformance?.toStringAsFixed(0) ?? '0'}%',
                  label: 'On-Time\\nPerformance',
                  icon: Icons.schedule,
                  color: context.infoColor,
                ),
                StatItem(
                  value: '${line.customerRating?.toStringAsFixed(1) ?? '0.0'}',
                  label: 'Customer\\nRating',
                  icon: Icons.star,
                  color: context.warningColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsTab(BuildContext context, Line line) {
    return Consumer<LineProvider>(
      builder: (context, lineProvider, child) {
        final stops = lineProvider.lineStops;
        
        if (stops.isEmpty) {
          return const EmptyState(
            title: 'No stops found',
            message: 'Stop information is not available for this line.',
            icon: Icons.location_off,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(DesignSystem.space16),
          itemCount: stops.length,
          itemBuilder: (context, index) {
            final stop = stops[index];
            final isFirst = index == 0;
            final isLast = index == stops.length - 1;
            
            return _buildStopItem(context, stop, isFirst, isLast, index + 1);
          },
        );
      },
    );
  }

  Widget _buildStopItem(BuildContext context, LineStop stop, bool isFirst, bool isLast, int position) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space12),
      child: Row(
        children: [
          // Stop indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: context.colors.outline,
                  ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isFirst || isLast 
                        ? context.colors.primary 
                        : context.colors.outline,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      position.toString(),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: isFirst || isLast 
                            ? context.colors.onPrimary
                            : context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 20,
                    color: context.colors.outline,
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: DesignSystem.space16),
          
          // Stop information
          Expanded(
            child: AppCard(
              onTap: () => _viewStopDetails(stop),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stop.name ?? 'Unnamed Stop',
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isFirst)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSystem.space8,
                              vertical: DesignSystem.space4,
                            ),
                            decoration: BoxDecoration(
                              color: context.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                            ),
                            child: Text(
                              'START',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isLast)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSystem.space8,
                              vertical: DesignSystem.space4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                            ),
                            child: Text(
                              'END',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    if (stop.address != null) ...[
                      const SizedBox(height: DesignSystem.space4),
                      Text(
                        stop.address!,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: DesignSystem.space8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: DesignSystem.space4),
                        Text(
                          'Next arrival: ${stop.nextArrival ?? 'N/A'}',
                          style: context.textStyles.bodySmall,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusesTab(BuildContext context, Line line) {
    return Consumer<BusProvider>(
      builder: (context, busProvider, child) {
        final buses = busProvider.getBusesForLine(line.id);
        
        if (buses.isEmpty) {
          return const EmptyState(
            title: 'No buses available',
            message: 'There are currently no buses operating on this line.',
            icon: Icons.directions_bus_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(DesignSystem.space16),
          itemCount: buses.length,
          itemBuilder: (context, index) {
            final bus = buses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignSystem.space12),
              child: BusCard(
                bus: bus,
                onTap: () => _viewBusDetails(bus),
                showETA: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleTab(BuildContext context, Line line) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          // Schedule overview
          SectionLayout(
            title: 'Schedule Overview',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    _buildInfoRow('First Departure', line.firstDeparture ?? 'N/A'),
                    _buildInfoRow('Last Departure', line.lastDeparture ?? 'N/A'),
                    _buildInfoRow('Frequency', 'Every ${line.frequency ?? 0} minutes'),
                    _buildInfoRow('Peak Frequency', 'Every ${line.peakFrequency ?? 0} minutes'),
                    _buildInfoRow('Service Days', line.serviceDays ?? 'Daily'),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Departure times
          SectionLayout(
            title: 'Departure Times',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    Text(
                      'Sample departure times (every ${line.frequency ?? 0} minutes)',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    // Generate sample times
                    Wrap(
                      spacing: DesignSystem.space8,
                      runSpacing: DesignSystem.space8,
                      children: _generateSampleTimes(line.frequency ?? 30)
                          .map((time) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignSystem.space12,
                                  vertical: DesignSystem.space8,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                                ),
                                child: Text(
                                  time,
                                  style: context.textStyles.bodySmall,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  List<String> _generateSampleTimes(int frequency) {
    final times = <String>[];
    const startHour = 6; // 6 AM
    const endHour = 22; // 10 PM
    
    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += frequency) {
        times.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      }
    }
    
    return times.take(20).toList(); // Show first 20 times
  }

  Color _getLineStatusColor(bool isActive) {
    return isActive ? DesignSystem.busActive : DesignSystem.busInactive;
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite functionality coming soon')),
    );
  }

  void _shareLine() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing line information')),
    );
  }

  void _viewRouteOnMap(Line line) {
    Navigator.of(context).pushNamed(
      AppRoutes.busTracking,
      arguments: {'lineId': line.id},
    );
  }

  void _viewStopDetails(LineStop stop) {
    Navigator.of(context).pushNamed(
      AppRoutes.stopDetails,
      arguments: {'stopId': stop.id},
    );
  }

  void _viewBusDetails(Bus bus) {
    Navigator.of(context).pushNamed(
      AppRoutes.busDetails,
      arguments: {'busId': bus.id},
    );
  }
}