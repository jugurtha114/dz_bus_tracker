// lib/screens/passenger/line_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme_config.dart';
import '../../config/route_config.dart';
import '../../providers/line_provider.dart';
import '../../providers/stop_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/map/map_widget.dart';
import '../../helpers/error_handler.dart';

class LineDetailsScreen extends StatefulWidget {
  const LineDetailsScreen({Key? key}) : super(key: key);

  @override
  State<LineDetailsScreen> createState() => _LineDetailsScreenState();
}

class _LineDetailsScreenState extends State<LineDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLineDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadLineDetails() async {
    final lineProvider = Provider.of<LineProvider>(context, listen: false);

    if (lineProvider.selectedLine == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Load stops and schedule for the selected line
      await lineProvider.fetchLineStops();
      await lineProvider.fetchLineSchedule();

      // Build map markers and polyline for the route
      _buildMapElements();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
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

  void _buildMapElements() {
    final lineProvider = Provider.of<LineProvider>(context, listen: false);
    final line = lineProvider.selectedLine;
    final stops = lineProvider.lineStops;

    if (line == null || stops.isEmpty) {
      return;
    }

    final Set<Marker> markers = {};
    final List<LatLng> points = [];

    // Create markers for each stop
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];

      if (stop['latitude'] != null && stop['longitude'] != null) {
        final latitude = double.tryParse(stop['latitude'].toString()) ?? 0;
        final longitude = double.tryParse(stop['longitude'].toString()) ?? 0;

        markers.add(
          Marker(
            markerId: MarkerId('stop_${stop['id']}'),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: stop['name'] ?? 'Stop ${i + 1}',
              snippet: stop['address'] ?? '',
            ),
          ),
        );

        points.add(LatLng(latitude, longitude));
      }
    }

    // Create polyline for the route
    final color = line['color'] != null
        ? Color(int.parse('0xFF${line['color'].toString().replaceAll('#', '')}'))
        : AppColors.primary;

    final polylines = <Polyline>{
      Polyline(
        polylineId: PolylineId('line_${line['id']}'),
        points: points,
        color: color,
        width: 5,
      ),
    };

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Fit map to show all stops
    if (_markers.isNotEmpty) {
      _fitMapToBounds();
    }
  }

  void _fitMapToBounds() {
    if (_mapController == null || _markers.isEmpty) {
      return;
    }

    // Calculate bounds
    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    // Add padding to bounds
    final padding = 0.01;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    // Animate camera to fit bounds
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  void _viewStop(Map<String, dynamic> stop) {
    final stopProvider = Provider.of<StopProvider>(context, listen: false);
    stopProvider.selectStop(stop);
    AppRouter.navigateTo(context, AppRoutes.stopDetails);
  }

  @override
  Widget build(BuildContext context) {
    final lineProvider = Provider.of<LineProvider>(context);
    final line = lineProvider.selectedLine;

    if (line == null) {
      // Return early if no line is selected
      return Scaffold(
        appBar: const DzAppBar(
          title: 'Line Details',
        ),
        body: const Center(
          child: Text('No line selected'),
        ),
      );
    }

    // Extract line details
    final name = line['name'] ?? 'Unknown Line';
    final code = line['code'] ?? '';
    final description = line['description'] ?? '';
    final color = line['color'] != null
        ? Color(int.parse('0xFF${line['color'].toString().replaceAll('#', '')}'))
        : AppColors.primary;
    final frequency = line['frequency'];
    final stops = lineProvider.lineStops;
    final schedule = lineProvider.lineSchedule;

    return Scaffold(
      appBar: DzAppBar(
        title: 'Line $code',
        backgroundColor: color,
      ),
      body: _isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : Column(
        children: [
          // Line info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: color.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line name and code
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        code,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Description
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.darkGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                // Frequency
                if (frequency != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Every $frequency minutes',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Stops',
                icon: Icon(Icons.location_on),
              ),
              Tab(
                text: 'Schedule',
                icon: Icon(Icons.schedule),
              ),
              Tab(
                text: 'Map',
                icon: Icon(Icons.map),
              ),
            ],
            labelColor: color,
            indicatorColor: color,
          ),

          // Tab contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Stops tab
                _buildStopsTab(stops),

                // Schedule tab
                _buildScheduleTab(schedule),

                // Map tab
                _buildMapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsTab(List<Map<String, dynamic>> stops) {
    if (stops.isEmpty) {
      return Center(
        child: Text(
          'No stops available for this line',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mediumGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: stops.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final stop = stops[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stop number indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Stop details
              Expanded(
                child: GestureDetector(
                  onTap: () => _viewStop(stop),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop['name'] ?? 'Unknown Stop',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      if (stop['address'] != null && stop['address'].toString().isNotEmpty)
                        Text(
                          stop['address'],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.mediumGrey,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab(List<Map<String, dynamic>> schedule) {
    if (schedule.isEmpty) {
      return Center(
        child: Text(
          'No schedule available for this line',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mediumGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Group schedules by day of week
    final Map<int, List<Map<String, dynamic>>> scheduleByDay = {};

    for (final item in schedule) {
      final dayOfWeek = item['day_of_week'] as int? ?? 0;

      if (!scheduleByDay.containsKey(dayOfWeek)) {
        scheduleByDay[dayOfWeek] = [];
      }

      scheduleByDay[dayOfWeek]!.add(item);
    }

    return ListView.builder(
      itemCount: scheduleByDay.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final dayOfWeek = scheduleByDay.keys.elementAt(index);
        final daySchedules = scheduleByDay[dayOfWeek]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day of week header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.lightGrey,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                _getDayOfWeekName(dayOfWeek),
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Schedules for this day
            ...daySchedules.map((schedule) {
              final startTime = schedule['start_time'] ?? '';
              final endTime = schedule['end_time'] ?? '';
              final frequencyMinutes = schedule['frequency_minutes'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$startTime - $endTime',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Every $frequencyMinutes minutes',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildMapTab() {
    return MapWidget(
      onMapCreated: _onMapCreated,
      markers: _markers,
      polylines: _polylines,
    );
  }

  String _getDayOfWeekName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}