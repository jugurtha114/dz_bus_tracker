// lib/screens/driver/trips_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../models/tracking_model.dart';
import '../../providers/driver_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({Key? key}) : super(key: key);

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.fetchDriverTrips();
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final driverProvider = Provider.of<DriverProvider>(context);
    final trackingProvider = Provider.of<TrackingProvider>(context);

    return AppLayout(
      title: localizations.translate('trips'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ],
      child: Column(
        children: [
          // Stats overview
          _buildStatsOverview(localizations, driverProvider),
          
          // Tab bar
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              tabs: [
                Tab(text: localizations.translate('active')),
                Tab(text: localizations.translate('completed')),
                Tab(text: localizations.translate('scheduled')),
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
                      _buildTripsList(driverProvider.activeTrips, localizations, trackingProvider),
                      _buildTripsList(driverProvider.completedTrips, localizations, trackingProvider),
                      _buildTripsList(driverProvider.scheduledTrips, localizations, trackingProvider),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(AppLocalizations localizations, DriverProvider driverProvider) {
    final todayTrips = driverProvider.trips.where((trip) {
      return DzDateUtils.isToday(trip.startTime);
    }).toList();

    final totalDistance = todayTrips.fold<double>(
      0,
      (sum, trip) => sum + (trip.distance ?? 0.0),
    );

    final totalPassengers = todayTrips.fold<int>(
      0,
      (sum, trip) => sum + trip.maxPassengers,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              localizations.translate('today_trips'),
              todayTrips.length.toString(),
              Icons.directions_bus,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: _buildStatCard(
              localizations.translate('distance'),
              '${totalDistance.toStringAsFixed(1)} km',
              Icons.map,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: _buildStatCard(
              localizations.translate('passengers'),
              totalPassengers.toString(),
              Icons.people,
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(type: CardType.elevated, 
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Trip> trips, AppLocalizations localizations, TrackingProvider trackingProvider) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_filled,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_trips_found'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip, localizations, trackingProvider);
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip, AppLocalizations localizations, TrackingProvider trackingProvider) {
    final status = trip.isCompleted ? 'completed' : 'active';
    final startTime = trip.startTime;
    final endTime = trip.endTime;
    final line = trip.line;
    final bus = trip.bus;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'active':
      case 'in_progress':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.play_circle_filled;
        statusText = localizations.translate('active');
        break;
      case 'completed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        statusText = localizations.translate('completed');
        break;
      case 'scheduled':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.schedule;
        statusText = localizations.translate('scheduled');
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.help;
        statusText = localizations.translate('unknown');
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showTripDetails(trip, localizations),
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
                          '${localizations.translate('trip')} #${trip.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status == 'active')
                    ElevatedButton(
                      onPressed: () => _endTrip(trip, trackingProvider, localizations),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(localizations.translate('end_trip')),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Line and bus info
              if (line.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.route, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8, height: 40),
                    Text(
                      '${localizations.translate('line')}: ${trip.lineId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              
              if (bus.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.directions_bus, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8, height: 40),
                    Text(
                      '${localizations.translate('bus')}: ${trip.busId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Time info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('start_time'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          startTime != null
                              ? DzDateUtils.formatDateTime(startTime)
                              : '--',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('end_time'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          endTime != null
                              ? DzDateUtils.formatDateTime(endTime)
                              : '--',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTripStat(
                    Icons.map,
                    '${trip.distance?.toStringAsFixed(1) ?? '0.0'} km',
                    localizations.translate('distance'),
                  ),
                  _buildTripStat(
                    Icons.people,
                    '${trip.maxPassengers}',
                    localizations.translate('passengers'),
                  ),
                  _buildTripStat(
                    Icons.timer,
                    _calculateDuration(startTime, endTime),
                    localizations.translate('duration'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
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

  String _calculateDuration(DateTime? start, DateTime? end) {
    if (start == null) return '--';
    
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _showTripDetails(Trip trip, AppLocalizations localizations) {
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '${localizations.translate('trip_details')} #${trip.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Add trip details here
                    _buildDetailRow(localizations.translate('status'), trip.isCompleted ? 'completed' : 'active'),
                    _buildDetailRow(localizations.translate('total_distance'), '${trip.distance?.toStringAsFixed(1) ?? '0.0'} km'),
                    _buildDetailRow(localizations.translate('total_passengers'), '${trip.maxPassengers}'),
                    _buildDetailRow(localizations.translate('average_speed'), '${trip.averageSpeed?.toStringAsFixed(1) ?? '0.0'} km/h'),
                    
                    const SizedBox(height: 16),
                    
                    // Statistics button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(
                          AppRoutes.tripStatistics,
                          arguments: {'tripId': trip.id},
                        );
                      },
                      icon: const Icon(Icons.analytics),
                      label: Text(localizations.translate('view_statistics')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('filter_trips')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: Text(localizations.translate('all_trips')),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
                _loadTrips();
              },
            ),
            RadioListTile(
              title: Text(localizations.translate('today')),
              value: 'today',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
                _loadTrips();
              },
            ),
            RadioListTile(
              title: Text(localizations.translate('this_week')),
              value: 'week',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
                _loadTrips();
              },
            ),
            RadioListTile(
              title: Text(localizations.translate('this_month')),
              value: 'month',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
                _loadTrips();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _endTrip(Trip trip, TrackingProvider trackingProvider, AppLocalizations localizations) {
    DialogHelper.showConfirmDialog(
      context,
      title: localizations.translate('end_trip'),
      message: localizations.translate('end_trip_confirm'),
      confirmText: localizations.translate('end'),
      cancelText: localizations.translate('cancel'),
    ).then((confirmed) {
      if (confirmed) {
        _performEndTrip(trip.id, trackingProvider, localizations);
      }
    });
  }

  Future<void> _performEndTrip(String tripId, TrackingProvider trackingProvider, AppLocalizations localizations) async {
    try {
      final success = await trackingProvider.endTrip(tripId);
      
      if (success) {
        _loadTrips();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('trip_ended_successfully')),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('failed_to_end_trip')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}