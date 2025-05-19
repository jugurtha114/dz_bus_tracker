// lib/screens/driver/tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/map/map_widget.dart';
import '../../widgets/driver/passenger_counter.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/dialog_helper.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  Timer? _locationUpdateTimer;
  Timer? _busStatsUpdateTimer;
  bool _isLoading = false;
  int _passengerCount = 0;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _busStatsUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initTracking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
      final busProvider = Provider.of<BusProvider>(context, listen: false);

      // Check if tracking is active and bus is selected
      if (!trackingProvider.isTracking || busProvider.selectedBus == null) {
        if (mounted) {
          // Show message and go back
          DialogHelper.showInfoDialog(
            context,
            title: 'Not Tracking',
            message: 'You need to start tracking from the home screen first.',
          ).then((_) {
            Navigator.pop(context);
          });
        }
        return;
      }

      // Get initial passenger count
      _passengerCount = trackingProvider.currentTrip != null
          ? int.tryParse(trackingProvider.currentTrip!['passenger_count']?.toString() ?? '0') ?? 0
          : 0;

      // Set up location update timer
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: AppConfig.locationUpdateInterval),
            (_) => _sendLocationUpdate(),
      );

      // Set up bus stats update timer
      _busStatsUpdateTimer = Timer.periodic(
        const Duration(minutes: 1),
            (_) => _updateBusStats(),
      );
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

  Future<void> _sendLocationUpdate() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final busProvider = Provider.of<BusProvider>(context, listen: false);

    // Check if tracking is active and location is available
    if (!trackingProvider.isTracking ||
        busProvider.selectedBus == null ||
        locationProvider.currentLocation == null) {
      return;
    }

    try {
      await trackingProvider.sendLocation(
        busId: busProvider.selectedBus!['id'],
        latitude: locationProvider.latitude,
        longitude: locationProvider.longitude,
        altitude: locationProvider.currentLocation!.altitude,
        speed: locationProvider.currentLocation!.speed,
        heading: locationProvider.currentLocation!.heading,
        accuracy: locationProvider.currentLocation!.accuracy,
      );
    } catch (e) {
      // Silently handle error during background updates
      debugPrint('Error sending location update: ${e.toString()}');
    }
  }

  Future<void> _updateBusStats() async {
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final busProvider = Provider.of<BusProvider>(context, listen: false);

    // Check if tracking is active
    if (!trackingProvider.isTracking || busProvider.selectedBus == null) {
      return;
    }

    try {
      await trackingProvider.updatePassengers(
        busId: busProvider.selectedBus!['id'],
        count: _passengerCount,
      );
    } catch (e) {
      // Silently handle error during background updates
      debugPrint('Error updating bus stats: ${e.toString()}');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    // You can track camera movement if needed
  }

  void _centerOnCurrentLocation() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (locationProvider.currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              locationProvider.latitude,
              locationProvider.longitude,
            ),
            zoom: AppConfig.defaultZoomLevel,
          ),
        ),
      );
    }
  }

  void _updatePassengerCount(int count) {
    setState(() {
      _passengerCount = count;
    });
    _updateBusStats();
  }

  void _reportAnomaly() {
    // Add anomaly reporting functionality here
    final anomalyTypeController = TextEditingController();
    final anomalyDescriptionController = TextEditingController();
    String selectedSeverity = 'medium';

    DialogHelper.showGlassyDialog(
      context,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Report Anomaly',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Anomaly type dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select anomaly type'),
                    value: anomalyTypeController.text.isEmpty ? null : anomalyTypeController.text,
                    items: [
                      'speed',
                      'route',
                      'schedule',
                      'passengers',
                      'gap',
                      'bunching',
                      'other',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.substring(0, 1).toUpperCase() + value.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          anomalyTypeController.text = value;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Severity radio buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Severity',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Low'),
                          value: 'low',
                          groupValue: selectedSeverity,
                          onChanged: (value) {
                            setState(() {
                              selectedSeverity = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Medium'),
                          value: 'medium',
                          groupValue: selectedSeverity,
                          onChanged: (value) {
                            setState(() {
                              selectedSeverity = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('High'),
                          value: 'high',
                          groupValue: selectedSeverity,
                          onChanged: (value) {
                            setState(() {
                              selectedSeverity = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: anomalyDescriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (anomalyTypeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an anomaly type'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                        return;
                      }

                      if (anomalyDescriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a description'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                        return;
                      }

                      // Submit anomaly report
                      _submitAnomalyReport(
                        anomalyTypeController.text,
                        anomalyDescriptionController.text,
                        selectedSeverity,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitAnomalyReport(
      String type,
      String description,
      String severity,
      ) async {
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!trackingProvider.isTracking || busProvider.selectedBus == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final success = await trackingProvider.reportAnomaly(
        busId: busProvider.selectedBus!['id'],
        type: type,
        description: description,
        severity: severity,
        latitude: locationProvider.latitude,
        longitude: locationProvider.longitude,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anomaly reported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
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

  void _showTripInfo() {
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final trip = trackingProvider.currentTrip;

    if (trip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active trip information available'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Format trip data for display
    final startTime = trip['start_time'] != null
        ? DateTime.parse(trip['start_time'].toString())
        : null;
    final formattedStartTime = startTime != null
        ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
        : 'Unknown';
    final tripId = trip['id'] ?? 'Unknown';
    final lineId = trip['line'] ?? 'Unknown';
    final busId = trip['bus'] ?? 'Unknown';
    final notes = trip['notes'] ?? '';

    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Trip Information',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(
              'Start Time',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
            subtitle: Text(
              formattedStartTime,
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Current Passengers',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
            subtitle: Text(
              _passengerCount.toString(),
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (notes.isNotEmpty)
            ListTile(
              title: Text(
                'Notes',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
              subtitle: Text(
                notes,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Close',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final trackingProvider = Provider.of<TrackingProvider>(context);
    final busProvider = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: DzAppBar(
        title: 'Active Tracking',
        actions: [
          // Trip info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTripInfo,
            tooltip: 'Trip Info',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          MapWidget(
            initialPosition: locationProvider.currentLocation != null
                ? LatLng(
              locationProvider.latitude,
              locationProvider.longitude,
            )
                : null,
            onMapCreated: _onMapCreated,
            markers: _buildMarkers(locationProvider),
            polylines: _buildPolylines(),
            onCameraMove: _onCameraMove,
          ),

          // Location and anomaly buttons
          Positioned(
            bottom: 220,
            right: 16,
            child: Column(
              children: [
                // Current location button
                FloatingActionButton(
                  heroTag: 'location_btn',
                  mini: true,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  child: const Icon(Icons.my_location),
                  onPressed: _centerOnCurrentLocation,
                  tooltip: 'My Location',
                ),

                const SizedBox(height: 8),

                // Report anomaly button
                FloatingActionButton(
                  heroTag: 'anomaly_btn',
                  mini: true,
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                  child: const Icon(Icons.warning_amber_rounded),
                  onPressed: _reportAnomaly,
                  tooltip: 'Report Anomaly',
                ),
              ],
            ),
          ),

          // Bottom tracking panel
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
                  // Tracking status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Active tracking indicator
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: trackingProvider.isTracking ? AppColors.success : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tracking: ${trackingProvider.isTracking ? 'Active' : 'Inactive'}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Bus info
                      if (busProvider.selectedBus != null)
                        Text(
                          'Bus ${busProvider.selectedBus!['license_plate']}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Passenger counter
                  PassengerCounter(
                    onCountChanged: _updatePassengerCount,
                    isEnabled: trackingProvider.isTracking,
                    initialCount: _passengerCount,
                  ),

                  const SizedBox(height: 16),

                  // End trip button
                  CustomButton(
                    text: 'End Trip',
                    onPressed: () {
                      // Confirm end trip
                      DialogHelper.showConfirmDialog(
                        context,
                        title: 'End Trip',
                        message: 'Are you sure you want to end this trip?',
                        confirmText: 'End Trip',
                        cancelText: 'Cancel',
                      ).then((confirm) {
                        if (confirm) {
                          // End trip and go back
                          final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
                          trackingProvider.stopTracking().then((_) {
                            Navigator.pop(context);
                          });
                        }
                      });
                    },
                    type: ButtonType.outlined,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            const FullScreenLoading(),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(LocationProvider locationProvider) {
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
          infoWindow: const InfoWindow(title: 'Your Location (Bus)'),
        ),
      );
    }

    // Add markers for location history
    for (int i = 0; i < locationProvider.locationHistory.length; i++) {
      final position = locationProvider.locationHistory[i];
      markers.add(
        Marker(
          markerId: MarkerId('history_$i'),
          position: LatLng(
            position.latitude,
            position.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          alpha: 0.5, // Make historical markers semi-transparent
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final Set<Polyline> polylines = {};

    // Add polyline for location history
    if (locationProvider.locationHistory.length > 1) {
      final List<LatLng> points = locationProvider.locationHistory.map((position) {
        return LatLng(position.latitude, position.longitude);
      }).toList();

      // Add current location to the end of the list
      if (locationProvider.currentLocation != null) {
        points.add(LatLng(
          locationProvider.latitude,
          locationProvider.longitude,
        ));
      }

      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: AppColors.primary,
          width: 5,
        ),
      );
    }

    return polylines;
  }
}