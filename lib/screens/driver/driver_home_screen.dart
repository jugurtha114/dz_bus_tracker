// lib/screens/driver/driver_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/driver/passenger_counter.dart';
import '../../widgets/driver/tracking_controls.dart';
import '../../widgets/map/map_widget.dart';
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
      await busProvider.fetchBuses(driverId: driverProvider.driverId);

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
    AppRouter.navigateTo(context, AppRoutes.busManagement);
  }

  void _goToLineSelection() {
    AppRouter.navigateTo(context, AppRoutes.lineSelection);
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
        busId: busProvider.selectedBus!['id'],
        driverId: driverProvider.driverId,
        lineId: busProvider.selectedBus!['line_id'],
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tracking started successfully'),
              backgroundColor: AppColors.success,
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
      final success = await trackingProvider.stopTracking();

      if (success) {
        // Stop location tracking
        await locationProvider.stopTracking();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tracking stopped successfully'),
              backgroundColor: AppColors.info,
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
      await trackingProvider.updatePassengers(
        busId: busProvider.selectedBus!['id'],
        count: count,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passenger count updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
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
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...busProvider.buses.map((bus) {
            return ListTile(
              title: Text(
                'Bus ${bus['license_plate']}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white,
                ),
              ),
              subtitle: Text(
                '${bus['model']} - ${bus['manufacturer']}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.7),
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
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
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

    return Scaffold(
      appBar: DzAppBar(
        title: 'Driver Dashboard',
        actions: [
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  AppRouter.navigateTo(context, AppRoutes.notifications);
                },
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading && !_isInitialized
          ? const Center(
        child: LoadingIndicator(),
      )
          : Stack(
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
          ),

          // Current Location Button
          Positioned(
            bottom: 250,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.my_location),
              onPressed: _goToCurrentLocation,
            ),
          ),

          // Driver Status and Controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: GlassyContainer(
              color: AppColors.glassDark,
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
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            driverProvider.isAvailable ? 'Available' : 'Unavailable',
                            style: AppTextStyles.h3.copyWith(
                              color: driverProvider.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: driverProvider.isAvailable,
                        onChanged: (_) => _toggleAvailability(),
                        activeColor: AppColors.success,
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
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            busProvider.selectedBus != null
                                ? 'Bus ${busProvider.selectedBus!['license_plate']}'
                                : 'No Bus Selected',
                            style: AppTextStyles.h3.copyWith(
                              color: busProvider.selectedBus != null
                                  ? AppColors.white
                                  : AppColors.warning,
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
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
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
                    initialCount: trackingProvider.currentTrip != null
                        ? int.tryParse(trackingProvider.currentTrip!['passenger_count']?.toString() ?? '0') ?? 0
                        : 0,
                  ),

                  const SizedBox(height: 16),

                  // Line selection button
                  CustomButton(
                    text: 'Select Line',
                    onPressed: _goToLineSelection,
                    type: ButtonType.outlined,
                    color: AppColors.white,
                    icon: Icons.route,
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading && _isInitialized)
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

  Widget _buildDrawer() {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverProvider = Provider.of<DriverProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with driver info
          UserAccountsDrawerHeader(
            accountName: Text(
              authProvider.user != null
                  ? '${authProvider.user!['first_name']} ${authProvider.user!['last_name']}'
                  : 'Driver',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              authProvider.user != null
                  ? authProvider.user!['email']
                  : '',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            otherAccountsPictures: [
              // Display driver rating
              CircleAvatar(
                backgroundColor: AppColors.white,
                child: Text(
                  driverProvider.rating.toStringAsFixed(1),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_bus),
            title: const Text('Bus Management'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _goToBusManagement();
            },
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Line Selection'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _goToLineSelection();
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Tracking'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.tracking);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Passenger Counter'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.passengerCounter);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Ratings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.ratings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.notifications);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.driverProfile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.about);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              // Show confirmation dialog
              DialogHelper.showConfirmDialog(
                context,
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Logout',
                cancelText: 'Cancel',
              ).then((confirm) {
                if (confirm) {
                  // Logout and navigate to login screen
                  authProvider.logout().then((_) {
                    AppRouter.navigateToAndClearStack(context, AppRoutes.login);
                  });
                } else {
                  Navigator.pop(context); // Close the drawer
                }
              });
            },
          ),
        ],
      ),
    );
  }
}