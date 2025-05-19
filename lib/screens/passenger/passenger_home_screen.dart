// lib/screens/passenger/passenger_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../helpers/dialog_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/map/map_widget.dart';
import '../../helpers/permission_helper.dart';
import '../../widgets/passenger/nearby_buses_list.dart';
import '../../widgets/passenger/search_bar_widget.dart';


class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({Key? key}) : super(key: key);

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  bool _isLoading = false;
  bool _isMapReady = false;
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

      if (permissionGranted) {
        // Get current location
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        await locationProvider.getCurrentLocation();

        // Fetch nearby buses
        if (locationProvider.currentLocation != null) {
          final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
          await passengerProvider.fetchNearbyBuses(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
          );
        }
      }
    } catch (e) {
      // Error will be handled by provider
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
    setState(() {
      _isMapReady = true;
    });
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

  void _onSearchTap() {
    AppRouter.navigateTo(context, AppRoutes.lineSearch);
  }

  void _onStopSearchTap() {
    AppRouter.navigateTo(context, AppRoutes.stopSearch);
  }

  void _onRefresh() {
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final passengerProvider = Provider.of<PassengerProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: DzAppBar(
        title: 'DZ Bus Tracker',
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
            markers: _buildMarkers(passengerProvider),
            polylines: _buildPolylines(),
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SearchBarWidget(
              onSearchTap: _onSearchTap,
              onStopSearchTap: _onStopSearchTap,
            ),
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

          // Nearby Buses Panel
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Buses',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.white),
                          onPressed: _onRefresh,
                        ),
                      ],
                    ),
                  ),

                  // Nearby buses list
                  _isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingIndicator(
                        color: AppColors.white,
                        size: 30,
                      ),
                    ),
                  )
                      : passengerProvider.nearbyBuses.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No buses found nearby. Try searching for a specific line.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : NearbyBusesList(
                    buses: passengerProvider.nearbyBuses,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(PassengerProvider passengerProvider) {
    final Set<Marker> markers = {};

    // Add marker for current location
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
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

    // Add markers for nearby buses
    for (final bus in passengerProvider.nearbyBuses) {
      if (bus.containsKey('current_location')) {
        final location = bus['current_location'];
        if (location != null &&
            location['latitude'] != null &&
            location['longitude'] != null) {
          final latitude = double.tryParse(location['latitude'].toString()) ?? 0;
          final longitude = double.tryParse(location['longitude'].toString()) ?? 0;

          markers.add(
            Marker(
              markerId: MarkerId('bus_${bus['id']}'),
              position: LatLng(latitude, longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                title: 'Bus ${bus['license_plate']}',
                snippet: bus.containsKey('line') ? 'Line: ${bus['line']['code']}' : null,
              ),
              onTap: () {
                passengerProvider.trackBus(bus['id']);
                AppRouter.navigateTo(context, AppRoutes.busTracking);
              },
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

  Widget _buildDrawer() {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with user info
          UserAccountsDrawerHeader(
            accountName: Text(
              authProvider.user != null
                  ? '${authProvider.user!['first_name']} ${authProvider.user!['last_name']}'
                  : 'Passenger',
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
            leading: const Icon(Icons.search),
            title: const Text('Search Lines'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.lineSearch);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Find Stops'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              AppRouter.navigateTo(context, AppRoutes.stopSearch);
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
              AppRouter.navigateTo(context, AppRoutes.profile);
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