// lib/screens/passenger/bus_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../models/bus_model.dart';
import '../../providers/passenger_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/map/map_widget.dart';
import '../../widgets/passenger/occupancy_indicator.dart';
import '../../services/navigation_service.dart';
import '../../helpers/error_handler.dart';
import '../../widgets/common/custom_card.dart';

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
        NavigationService.goBack();
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
      await passengerProvider.trackBus(passengerProvider.selectedBus!.id);

      // If following the bus, move camera to its position
      if (_isFollowingBus && _mapController != null && passengerProvider.selectedBus != null) {
        // For now, use default location (would need to get from GPS tracking service)
        final busLocation = {'latitude': 36.7538, 'longitude': 3.0588}; // Default Algiers location

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

    // For now, use default location (would need to get from GPS tracking service)
    final busLocation = {'latitude': 36.7538, 'longitude': 3.0588}; // Default Algiers location

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
    final driverId = passengerProvider.selectedBus!.driver;

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
                        color: index < rating ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
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
              NavigationService.goBack();
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
                    NavigationService.goBack();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Thank you for your rating!'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                } catch (e) {
                  NavigationService.goBack();
                  ErrorHandler.showErrorSnackBar(
                    context,
                    message: ErrorHandler.handleError(e),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please select a rating'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
      return AppLayout(
        title: 'Bus Tracking',
        showBottomNav: false, // No bottom nav for tracking screen
        child: const Center(
          child: Text('No bus selected'),
        ),
      );
    }

    // Extract bus details
    final licensePlate = bus.licensePlate;
    final model = bus.model ?? '';
    final manufacturer = bus.manufacturer ?? '';
    final capacity = bus.capacity;

    // Get current passengers (would need to be updated via real-time tracking)
    int currentPassengers = 0; // Placeholder - would come from real-time data

    // Calculate occupancy percentage
    final occupancyPercent = capacity > 0 ? (currentPassengers / capacity * 100).round() : 0;

    // Get line info if available
    String lineName = '';
    String lineCode = '';
    // Note: Line info would come from a separate API call
    // For now using placeholder values

    return AppLayout(
      title: 'Bus Tracking',
      showBottomNav: false, // No bottom nav for tracking screen
      actions: [
        // Rate driver button
        IconButton(
          icon: const Icon(Icons.star),
          onPressed: _rateDriver,
          tooltip: 'Rate Driver',
        ),
      ],
      child: Stack(
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
              backgroundColor: _isFollowingBus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
              foregroundColor: _isFollowingBus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
            child: CustomCard(type: CardType.elevated, 
              borderRadius: BorderRadius.circular(24),
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderColor: Colors.white.withOpacity(0.1),
              borderWidth: 1,
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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (model.isNotEmpty || manufacturer.isNotEmpty)
                            Text(
                              '$manufacturer $model',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),

                      // Line info
                      if (lineCode.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Line $lineCode',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Occupancy indicator
                  if (capacity > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Occupancy: $currentPassengers / $capacity passengers',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OccupancyIndicator(
                          occupancyPercent: occupancyPercent,
                          showText: true,
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // ETA if available
                  if (passengerProvider.estimatedArrival.isNotEmpty)
                    Text(
                      'Estimated arrival: ${_getEstimatedArrival(passengerProvider)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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

  Set<Marker> _buildMarkers(Bus bus, LocationProvider locationProvider) {
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
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add marker for bus location (using default location for now)
    // In a real implementation, this would come from real-time tracking data
    const defaultLat = 36.7538;
    const defaultLng = 3.0588;
    
    markers.add(
      Marker(
        markerId: MarkerId('bus_${bus.id}'),
        position: const LatLng(defaultLat, defaultLng),
        infoWindow: InfoWindow(
          title: 'Bus ${bus.licensePlate}',
          snippet: 'Current location',
        ),
      ),
    );

    // Add markers for stops if available
    // Note: Stop information would be fetched separately via Line API
    // For now, this is commented out until proper Line-Stop relationship is implemented

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    // For demonstration. In a real app, you would get this data from the API
    return {};
  }

  LatLng? _getBusPosition(Bus bus) {
    // For now, return default position (would need real-time GPS data)
    return const LatLng(36.7538, 3.0588); // Default Algiers location
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