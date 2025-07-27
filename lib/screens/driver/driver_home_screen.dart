// lib/screens/driver/driver_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../models/api_response_models.dart';
import '../../providers/driver_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/widgets.dart';
import '../../services/navigation_service.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/permission_helper.dart';


class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check and request location permission
      final permissionGranted = await PermissionHelper.requestLocation(context);

      if (!permissionGranted) {
        // Show dialog explaining why location is needed
        if (mounted) {
          await DialogHelper.showInfoDialog(
            context,
            title: 'Location Required',
            message: 'Location permission is required to track your bus and share location with passengers.',
          );
          return;
        }
      }

      // Get current location
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.getCurrentLocation();

      // Get driver profile
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.fetchProfile();

      // Get driver's buses
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      final queryParams = BusQueryParameters(driverId: driverProvider.driverId);
      await busProvider.fetchBuses(queryParams: queryParams);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Show error
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() {
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

  void _toggleAvailability() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    driverProvider.toggleAvailability();
  }

  void _goToBusManagement() {
    NavigationService.navigateTo(AppRoutes.busManagement);
  }

  void _goToLineSelection() {
    NavigationService.navigateTo(AppRoutes.lineSelection);
  }

  void _startTracking() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Check if a bus is selected
    if (busProvider.selectedBus == null) {
      // Show select bus dialog
      _selectBusDialog();
      return;
    }

    // Start tracking
    setState(() {
      _isLoading = true;
    });

    try {
      // Start location tracking
      await locationProvider.startTracking();

      // Start tracking on server
      final success = await trackingProvider.startTracking(
        busProvider.selectedBus!.id,
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tracking started successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      // Show error
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

  void _stopTracking() async {
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Confirm stop tracking
    final confirm = await DialogHelper.showConfirmDialog(
      context,
      title: 'Stop Tracking',
      message: 'Are you sure you want to stop tracking? Passengers will no longer see your location.',
      confirmText: 'Stop Tracking',
      cancelText: 'Cancel',
    );

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Stop tracking on server
      final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      
      bool success = false;
      if (busProvider.selectedBus != null) {
        success = await trackingProvider.stopBusTracking(busProvider.selectedBus!.id);
      }

      if (success) {
        // Stop location tracking
        await locationProvider.stopTracking();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tracking stopped successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      // Show error
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

  void _updatePassengerCount(int count) async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);

    // Check if a bus is selected
    if (busProvider.selectedBus == null) {
      // Show select bus dialog
      _selectBusDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update passenger count
      final success = await trackingProvider.updatePassengers(
        busId: busProvider.selectedBus!.id,
        count: count,
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Passenger count updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update passenger count'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      // Show error
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

  void _selectBusDialog() {
    final busProvider = Provider.of<BusProvider>(context, listen: false);

    if (busProvider.buses.isEmpty) {
      DialogHelper.showInfoDialog(
        context,
        title: 'No Buses Available',
        message: 'You don\'t have any registered buses. Please add a bus first.',
      ).then((_) {
        _goToBusManagement();
      });
      return;
    }

    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Bus',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...busProvider.buses.map((bus) {
            return ListTile(
              title: Text(
                'Bus ${bus.licensePlate}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              subtitle: Text(
                '${bus.model} - ${bus.manufacturer}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
              ),
              onTap: () {
                // Select bus
                busProvider.selectBus(bus);
                Navigator.pop(context);
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToBusManagement();
            },
            child: Text(
              'Manage Buses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final busProvider = Provider.of<BusProvider>(context);
    final trackingProvider = Provider.of<TrackingProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return PageLayout(
      title: 'Driver Dashboard',
      showAppBar: true,
      appBarActions: [
        // Notification icon with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                NavigationService.navigateTo(AppRoutes.notifications);
              },
            ),
            if (notificationProvider.unreadCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '${notificationProvider.unreadCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
      body: _isLoading && !_isInitialized
          ? const LoadingState.fullScreen(message: 'Initializing...')
          : Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: locationProvider.currentLocation != null
                        ? LatLng(
                            locationProvider.latitude,
                            locationProvider.longitude,
                          )
                        : const LatLng(36.7538, 3.0588), // Default to Algiers
                    zoom: AppConfig.defaultZoomLevel,
                  ),
                  markers: _buildMarkers(locationProvider),
                  polylines: _buildPolylines(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

                // Current Location Button
                Positioned(
                  bottom: 250,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // Driver Status and Controls
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: AppCard(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Driver Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver Status',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  driverProvider.isAvailable ? 'Available' : 'Unavailable',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: driverProvider.isAvailable
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: driverProvider.isAvailable,
                              onChanged: (_) => _toggleAvailability(),
                              activeThumbColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Bus Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Bus',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  busProvider.selectedBus != null
                                      ? 'Bus ${busProvider.selectedBus!.licensePlate}'
                                      : 'No Bus Selected',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: busProvider.selectedBus != null
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: busProvider.selectedBus != null
                                  ? _selectBusDialog
                                  : _goToBusManagement,
                              child: Text(
                                busProvider.selectedBus != null
                                    ? 'Change'
                                    : 'Select',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Controls Panel
                Positioned(
                  bottom: 80, // Adjusted to account for bottom navigation
                  left: 0,
                  right: 0,
                  child: AppCard(
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tracking controls
                        TrackingControls(
                          isTracking: trackingProvider.isTracking,
                          onStartTracking: _startTracking,
                          onStopTracking: _stopTracking,
                        ),

                        const SizedBox(height: 16),

                        // Passenger counter
                        PassengerCounter(
                          onCountChanged: _updatePassengerCount,
                          isEnabled: trackingProvider.isTracking,
                          initialCount: trackingProvider.currentTrip?.maxPassengers ?? 0,
                          maxCapacity: busProvider.selectedBus?.capacity ?? 50,
                        ),

                        const SizedBox(height: 16),

                        // Line selection button
                        AppButton.outlined(
                          text: 'Select Line',
                          onPressed: _goToLineSelection,
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (_isLoading && _isInitialized)
                  LoadingOverlay(
                    isLoading: true,
                    child: Container(),
                  ),
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
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    // For demonstration. In a real app, you would get this data from the API
    return {};
  }

}