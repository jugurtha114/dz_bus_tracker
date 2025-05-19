// lib/screens/passenger/bus_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../providers/passenger_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/map/map_widget.dart';
import '../../widgets/passenger/occupancy_indicator.dart';
import '../../helpers/error_handler.dart';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({Key? key}) : super(key: key);

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  GoogleMapController? _mapController;
  Timer? _refreshTimer;
  bool _isLoading = false;
  bool _isFollowingBus = true;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initTracking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

      // Make sure we have a selected bus
      if (passengerProvider.selectedBus == null) {
        Navigator.pop(context);
        return;
      }

      // Set up refresh timer to update bus location
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _refreshBusLocation();
      });
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        message: ErrorHandler.handleError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBusLocation() async {
    final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

    if (passengerProvider.selectedBus == null) return;

    try {
      await passengerProvider.trackBus(passengerProvider.selectedBus!['id']);

      // If following the bus, move camera to its position
      if (_isFollowingBus && _mapController != null && passengerProvider.selectedBus != null) {
        final busLocation = passengerProvider.selectedBus!['current_location'];

        if (busLocation != null &&
            busLocation['latitude'] != null &&
            busLocation['longitude'] != null) {
          final latitude = double.tryParse(busLocation['latitude'].toString()) ?? 0;
          final longitude = double.tryParse(busLocation['longitude'].toString()) ?? 0;

          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: AppConfig.defaultZoomLevel,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Silently handle error during background refresh
      debugPrint('Error refreshing bus location: ${e.toString()}');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _centerOnBus();
  }

  void _centerOnBus() {
    final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

    if (passengerProvider.selectedBus == null || _mapController == null) return;

    final busLocation = passengerProvider.selectedBus!['current_location'];

    if (busLocation != null &&
        busLocation['latitude'] != null &&
        busLocation['longitude'] != null) {
      final latitude = double.tryParse(busLocation['latitude'].toString()) ?? 0;
      final longitude = double.tryParse(busLocation['longitude'].toString()) ?? 0;

      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: AppConfig.defaultZoomLevel,
          ),
        ),
      );
    }
  }

  void _toggleFollowBus() {
    setState(() {
      _isFollowingBus = !_isFollowingBus;
    });

    if (_isFollowingBus) {
      _centerOnBus();
    }
  }

  void _rateDriver() {
    final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

    if (passengerProvider.selectedBus == null) return;

    // Extract driver ID
    final driverId = passengerProvider.selectedBus!['driver'];

    // Show rating dialog
    _showRatingDialog(driverId);
  }

  void _showRatingDialog(String driverId) {
    int rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How would you rate your experience?'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: index < rating ? AppColors.warning : AppColors.mediumGrey,
                        size: 36,
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (rating > 0) {
                final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

                try {
                  await passengerProvider.rateDriver(
                    driverId: driverId,
                    rating: rating,
                    comment: commentController.text.isNotEmpty ? commentController.text : null,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your rating!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ErrorHandler.showErrorSnackBar(
                    context,
                    message: ErrorHandler.handleError(e),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a rating'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passengerProvider = Provider.of<PassengerProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    final bus = passengerProvider.selectedBus;

    if (bus == null) {
      // Return early if no bus is selected
      return Scaffold(
        appBar: const DzAppBar(
          title: 'Bus Tracking',
        ),
        body: const Center(
          child: Text('No bus selected'),
        ),
      );
    }

    // Extract bus details
    final licensePlate = bus['license_plate'] ?? 'Unknown';
    final model = bus['model'] ?? '';
    final manufacturer = bus['manufacturer'] ?? '';
    final capacity = int.tryParse(bus['capacity']?.toString() ?? '0') ?? 0;

    // Get current passengers if available
    int currentPassengers = 0;
    if (bus.containsKey('current_location') &&
        bus['current_location'] != null &&
        bus['current_location'].containsKey('passenger_count')) {
      currentPassengers = int.tryParse(bus['current_location']['passenger_count']?.toString() ?? '0') ?? 0;
    }

    // Calculate occupancy percentage
    final occupancyPercent = capacity > 0 ? (currentPassengers / capacity * 100).round() : 0;

    // Get line info if available
    String lineName = '';
    String lineCode = '';
    if (bus.containsKey('line') && bus['line'] != null) {
      lineName = bus['line']['name'] ?? '';
      lineCode = bus['line']['code'] ?? '';
    }

    return Scaffold(
      appBar: DzAppBar(
        title: 'Bus Tracking',
        actions: [
          // Rate driver button
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: _rateDriver,
            tooltip: 'Rate Driver',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          MapWidget(
            initialPosition: _getBusPosition(bus),
            onMapCreated: _onMapCreated,
            markers: _buildMarkers(bus, locationProvider),
            polylines: _buildPolylines(),
            onCameraMove: (_) {
              // Disable follow mode when user moves the map
              if (_isFollowingBus) {
                setState(() {
                  _isFollowingBus = false;
                });
              }
            },
          ),

          // Follow bus button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: _isFollowingBus ? AppColors.primary : AppColors.white,
              foregroundColor: _isFollowingBus ? AppColors.white : AppColors.primary,
              child: const Icon(Icons.location_searching),
              onPressed: _toggleFollowBus,
              tooltip: _isFollowingBus ? 'Stop Following Bus' : 'Follow Bus',
            ),
          ),

          // Refresh button
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.refresh),
              onPressed: _refreshBusLocation,
              tooltip: 'Refresh Bus Location',
            ),
          ),

          // Bus info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassyContainer(
              borderRadius: 24,
              color: AppColors.glassDark,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bus info and line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bus license and model
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bus $licensePlate',
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          if (model.isNotEmpty || manufacturer.isNotEmpty)
                            Text(
                              '$manufacturer $model',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),

                      // Line info
                      if (lineCode.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Line $lineCode',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Occupancy indicator
                  if (capacity > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Occupancy: $currentPassengers / $capacity passengers',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        OccupancyIndicator(
                          occupancyPercent: occupancyPercent,
                          height: 12,
                          showText: true,
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // ETA if available
                  if (passengerProvider.estimatedArrival.isNotEmpty)
                    Text(
                      'Estimated arrival: ${_getEstimatedArrival(passengerProvider)}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const FullScreenLoading(),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(Map<String, dynamic> bus, LocationProvider locationProvider) {
    final Set<Marker> markers = {};

    // Add marker for current location
    if (locationProvider.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            locationProvider.latitude,
            locationProvider.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add marker for bus location
    if (bus.containsKey('current_location') &&
        bus['current_location'] != null &&
        bus['current_location']['latitude'] != null &&
        bus['current_location']['longitude'] != null) {
      final latitude = double.tryParse(bus['current_location']['latitude'].toString()) ?? 0;
      final longitude = double.tryParse(bus['current_location']['longitude'].toString()) ?? 0;

      markers.add(
        Marker(
          markerId: MarkerId('bus_${bus['id']}'),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Bus ${bus['license_plate']}',
            snippet: bus.containsKey('line') ? 'Line: ${bus['line']['code']}' : null,
          ),
        ),
      );
    }

    // Add markers for stops if available
    if (bus.containsKey('line') &&
        bus['line'] != null &&
        bus['line'].containsKey('stops')) {
      final stops = bus['line']['stops'] as List<dynamic>? ?? [];

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
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    // For demonstration. In a real app, you would get this data from the API
    return {};
  }

  LatLng? _getBusPosition(Map<String, dynamic> bus) {
    if (bus.containsKey('current_location') &&
        bus['current_location'] != null &&
        bus['current_location']['latitude'] != null &&
        bus['current_location']['longitude'] != null) {
      final latitude = double.tryParse(bus['current_location']['latitude'].toString()) ?? 0;
      final longitude = double.tryParse(bus['current_location']['longitude'].toString()) ?? 0;

      return LatLng(latitude, longitude);
    }

    return null;
  }

  String _getEstimatedArrival(PassengerProvider passengerProvider) {
    if (passengerProvider.estimatedArrival.isEmpty) {
      return 'Calculating...';
    }

    final stopId = passengerProvider.estimatedArrival.keys.first;
    final minutes = passengerProvider.estimatedArrival[stopId] ?? 0;

    if (minutes <= 0) {
      return 'Arriving now';
    } else if (minutes == 1) {
      return '1 minute';
    } else {
      return '$minutes minutes';
    }
  }
}