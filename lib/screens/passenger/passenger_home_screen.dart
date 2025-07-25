// lib/screens/passenger/passenger_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/permission_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/line_provider.dart';
import '../../models/api_response_models.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/nav_drawer.dart';
import '../../widgets/map/map_widget.dart';
import '../../widgets/passenger/nearby_buses_list.dart';
import '../../widgets/passenger/search_bar_widget.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({Key? key}) : super(key: key);

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  bool _isLoading = false;
  bool _isMapReady = false;
  GoogleMapController? _mapController;
  int _selectedBottomIndex = 0;
  bool _showMapView = true;

  // Dashboard stats
  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
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

        // Fetch nearby buses if location is available
        if (locationProvider.currentLocation != null) {
          final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
          await passengerProvider.fetchNearbyBuses(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
          );
        }

        // Fetch lines for quick access
        final lineProvider = Provider.of<LineProvider>(context, listen: false);
        await lineProvider.fetchLines(queryParams: LineQueryParameters(isActive: true));

        // Load dashboard stats
        await _loadDashboardStats();
      }

      // Start animation
      _animationController.forward();
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

  Future<void> _loadDashboardStats() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
    final lineProvider = Provider.of<LineProvider>(context, listen: false);

    setState(() {
      _dashboardStats = {
        'nearby_buses': passengerProvider.nearbyBuses.length,
        'total_lines': lineProvider.lines.length,
        'active_lines': lineProvider.lines.where((line) => line.isActive == true).length,
        'location_status': locationProvider.currentLocation != null ? 'Available' : 'Unavailable',
        'last_updated': DateTime.now(),
      };
    });
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

  Future<void> _onRefresh() async {
    await _initialize();
  }

  void _toggleMapView() {
    setState(() {
      _showMapView = !_showMapView;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });

    switch (index) {
      case 0:
      // Home - already here
        break;
      case 1:
        AppRouter.navigateTo(context, AppRoutes.lineSearch);
        break;
      case 2:
        AppRouter.navigateTo(context, AppRoutes.notifications);
        break;
      case 3:
        AppRouter.navigateTo(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final passengerProvider = Provider.of<PassengerProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final lineProvider = Provider.of<LineProvider>(context);

    return Scaffold(
      appBar: DzAppBar(
        title: 'DZ Bus Tracker',
        actions: [
          // Map/List toggle
          IconButton(
            icon: Icon(_showMapView ? Icons.list : Icons.map),
            onPressed: _toggleMapView,
            tooltip: _showMapView ? 'List View' : 'Map View',
          ),
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
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: DzNavDrawer(
        selectedRoute: AppRoutes.passengerHome,
        notificationCount: notificationProvider.unreadCount,
        isDriver: false,
        userData: authProvider.user?.toJson(),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Welcome Section
              _buildWelcomeSection(authProvider),

              // Dashboard Stats
              _buildDashboardStats(),

              // Quick Actions
              _buildQuickActions(),

              // Search Bar
              _buildSearchSection(),

              // Map or List View
              _showMapView
                  ? _buildMapSection(locationProvider, passengerProvider)
                  : _buildListSection(passengerProvider),

              // Nearby Buses Section
              _buildNearbyBusesSection(passengerProvider),

              // Popular Lines Section
              _buildPopularLinesSection(lineProvider),

              // Add some bottom padding
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(notificationProvider),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final user = authProvider.user;
    final firstName = user?.firstName ?? 'Passenger';
    final currentTime = DateTime.now();
    String greeting = 'Good Morning';

    if (currentTime.hour >= 12 && currentTime.hour < 17) {
      greeting = 'Good Afternoon';
    } else if (currentTime.hour >= 17) {
      greeting = 'Good Evening';
    }

    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: GlassyContainer(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      firstName[0].toUpperCase(),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        Text(
                          firstName,
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Ready to track your bus?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Weather icon (placeholder)
                  Icon(
                    Icons.wb_sunny,
                    color: AppColors.warning,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassyContainer(
              color: AppColors.glassDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _dashboardStats['last_updated'] != null
                            ? 'Updated ${DzDateUtils.getTimeAgo(_dashboardStats['last_updated'])}'
                            : 'Not updated',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Nearby Buses',
                          '${_dashboardStats['nearby_buses'] ?? 0}',
                          Icons.directions_bus,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Active Lines',
                          '${_dashboardStats['active_lines'] ?? 0}',
                          Icons.route,
                          AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Lines',
                          '${_dashboardStats['total_lines'] ?? 0}',
                          Icons.list,
                          AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Location',
                          _dashboardStats['location_status'] ?? 'Unknown',
                          Icons.location_on,
                          _dashboardStats['location_status'] == 'Available'
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: GlassyContainer(
              color: AppColors.glassWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          'Search Lines',
                          Icons.search,
                          AppColors.primary,
                              () => AppRouter.navigateTo(context, AppRoutes.lineSearch),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          'Find Stops',
                          Icons.location_on,
                          AppColors.accent,
                              () => AppRouter.navigateTo(context, AppRoutes.stopSearch),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          'Track Bus',
                          Icons.directions_bus,
                          AppColors.success,
                              () => AppRouter.navigateTo(context, AppRoutes.busTracking),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          'Rate Driver',
                          Icons.star,
                          AppColors.warning,
                              () => AppRouter.navigateTo(context, AppRoutes.rateDriver),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBarWidget(
              onSearchTap: _onSearchTap,
              onStopSearchTap: _onStopSearchTap,
              hint: 'Search for lines, stops, or destinations...',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(LocationProvider locationProvider, PassengerProvider passengerProvider) {
    return AnimationConfiguration.staggeredList(
      position: 4,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            height: 300,
            child: GlassyContainer(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    MapWidget(
                      initialPosition: locationProvider.currentLocation != null
                          ? LatLng(
                        locationProvider.latitude,
                        locationProvider.longitude,
                      )
                          : null,
                      onMapCreated: _onMapCreated,
                      markers: _buildMarkers(locationProvider, passengerProvider),
                      polylines: _buildPolylines(),
                    ),

                    // Map controls
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            mini: true,
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.primary,
                            heroTag: "location_btn",
                            child: const Icon(Icons.my_location),
                            onPressed: _goToCurrentLocation,
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            mini: true,
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.primary,
                            heroTag: "refresh_btn",
                            child: const Icon(Icons.refresh),
                            onPressed: _onRefresh,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(PassengerProvider passengerProvider) {
    return AnimationConfiguration.staggeredList(
      position: 4,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            height: 300,
            child: GlassyContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby Activity',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _onRefresh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: passengerProvider.nearbyBuses.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bus_filled,
                            size: 48,
                            color: AppColors.mediumGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No buses found nearby',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching for a specific line',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: passengerProvider.nearbyBuses.length.clamp(0, 3),
                      itemBuilder: (context, index) {
                        final bus = passengerProvider.nearbyBuses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.directions_bus,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text('Bus ${bus.licensePlate}'),
                            subtitle: Text(
                              'Status: ${bus.status.value}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Track this bus
                              passengerProvider.trackBus(bus.id);
                              AppRouter.navigateTo(context, AppRoutes.busTracking);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyBusesSection(PassengerProvider passengerProvider) {
    return AnimationConfiguration.staggeredList(
      position: 5,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: GlassyContainer(
              color: AppColors.glassDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby Buses',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${passengerProvider.nearbyBuses.length} found',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.white),
                            onPressed: _onRefresh,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Buses list
                  if (passengerProvider.nearbyBuses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_bus_filled_outlined,
                              size: 48,
                              color: AppColors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No buses found nearby',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching for a specific line or check back later',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    NearbyBusesList(
                      buses: passengerProvider.nearbyBuses.map((bus) => bus.toJson()).toList(),
                      maxHeight: 250,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularLinesSection(LineProvider lineProvider) {
    final popularLines = lineProvider.lines.take(5).toList();

    return AnimationConfiguration.staggeredList(
      position: 6,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: GlassyContainer(
              color: AppColors.glassWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Lines',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRouter.navigateTo(context, AppRoutes.lineSearch),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (popularLines.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No lines available',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularLines.length,
                        itemBuilder: (context, index) {
                          final line = popularLines[index];

                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 16),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  AppRouter.navigateTo(context, AppRoutes.lineDetails, arguments: line);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: line.color != null
                                                  ? Color(int.parse(line.color!.toString().replaceFirst('#', '0xFF')))
                                                  : AppColors.primary,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  line.code ?? 'Line',
                                                  style: AppTextStyles.body.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  line.name ?? 'Unknown',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.mediumGrey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: AppColors.mediumGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            line.frequency != null
                                                ? 'Every ${line.frequency}min'
                                                : 'Schedule varies',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.mediumGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(NotificationProvider notificationProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mediumGrey,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: AppTextStyles.caption,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${notificationProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Quick SOS or Emergency button
        DialogHelper.showConfirmDialog(
          context,
          title: 'Emergency',
          message: 'Do you need emergency assistance?',
          confirmText: 'Call Emergency',
          cancelText: 'Cancel',
        ).then((confirm) {
          if (confirm) {
            // Handle emergency call
            // You can implement emergency services integration here
          }
        });
      },
      icon: const Icon(Icons.emergency),
      label: const Text('SOS'),
      backgroundColor: AppColors.error,
    );
  }

  Set<Marker> _buildMarkers(LocationProvider locationProvider, PassengerProvider passengerProvider) {
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

    // Add markers for nearby buses
    for (final bus in passengerProvider.nearbyBuses) {
      if (bus.currentLocation != null &&
          bus.currentLocation!['latitude'] != null &&
          bus.currentLocation!['longitude'] != null) {
        final latitude = double.tryParse(bus.currentLocation!['latitude'].toString()) ?? 0;
        final longitude = double.tryParse(bus.currentLocation!['longitude'].toString()) ?? 0;

        markers.add(
          Marker(
            markerId: MarkerId('bus_${bus.id}'),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: 'Bus ${bus.licensePlate}',
              snippet: 'Status: ${bus.status.value}',
            ),
            onTap: () {
              passengerProvider.trackBus(bus.id);
              AppRouter.navigateTo(context, AppRoutes.busTracking);
            },
          ),
        );
      }
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    // For demonstration. In a real app, you would get this data from the API
    return {};
  }
}

// // lib/screens/passenger/passenger_home_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../config/api_config.dart';
// import '../../config/app_config.dart';
// import '../../config/route_config.dart';
// import '../../config/theme_config.dart';
// import '../../helpers/dialog_helper.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/location_provider.dart';
// import '../../providers/passenger_provider.dart';
// import '../../providers/notification_provider.dart';
// import '../../widgets/common/app_bar.dart';
// import '../../widgets/common/glassy_container.dart';
// import '../../widgets/common/loading_indicator.dart';
// import '../../widgets/map/map_widget.dart';
// import '../../helpers/permission_helper.dart';
// import '../../widgets/passenger/nearby_buses_list.dart';
// import '../../widgets/passenger/search_bar_widget.dart';
//
//
// class PassengerHomeScreen extends StatefulWidget {
//   const PassengerHomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
// }
//
// class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
//   bool _isLoading = false;
//   bool _isMapReady = false;
//   GoogleMapController? _mapController;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Check and request location permission
//       final permissionGranted = await PermissionHelper.requestLocation(context);
//
//       if (permissionGranted) {
//         // Get current location
//         final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//         await locationProvider.getCurrentLocation();
//
//         // Fetch nearby buses
//         if (locationProvider.currentLocation != null) {
//           final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
//           await passengerProvider.fetchNearbyBuses(
//             latitude: locationProvider.latitude,
//             longitude: locationProvider.longitude,
//           );
//         }
//       }
//     } catch (e) {
//       // Error will be handled by provider
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     setState(() {
//       _isMapReady = true;
//     });
//   }
//
//   void _goToCurrentLocation() {
//     final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//
//     if (locationProvider.currentLocation != null && _mapController != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(
//               locationProvider.latitude,
//               locationProvider.longitude,
//             ),
//             zoom: AppConfig.defaultZoomLevel,
//           ),
//         ),
//       );
//     }
//   }
//
//   void _onSearchTap() {
//     AppRouter.navigateTo(context, AppRoutes.lineSearch);
//   }
//
//   void _onStopSearchTap() {
//     AppRouter.navigateTo(context, AppRoutes.stopSearch);
//   }
//
//   void _onRefresh() {
//     _initialize();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final locationProvider = Provider.of<LocationProvider>(context);
//     final passengerProvider = Provider.of<PassengerProvider>(context);
//     final notificationProvider = Provider.of<NotificationProvider>(context);
//
//     return Scaffold(
//       appBar: DzAppBar(
//         title: 'DZ Bus Tracker',
//         actions: [
//           // Notification icon with badge
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications),
//                 onPressed: () {
//                   AppRouter.navigateTo(context, AppRoutes.notifications);
//                 },
//               ),
//               if (notificationProvider.unreadCount > 0)
//                 Positioned(
//                   right: 10,
//                   top: 10,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: AppColors.error,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 14,
//                       minHeight: 14,
//                     ),
//                     child: Text(
//                       '${notificationProvider.unreadCount}',
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppColors.white,
//                         fontSize: 8,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: Stack(
//         children: [
//           // Map
//           MapWidget(
//             initialPosition: locationProvider.currentLocation != null
//                 ? LatLng(
//               locationProvider.latitude,
//               locationProvider.longitude,
//             )
//                 : null,
//             onMapCreated: _onMapCreated,
//             markers: _buildMarkers(passengerProvider),
//             polylines: _buildPolylines(),
//           ),
//
//           // Search Bar
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: SearchBarWidget(
//               onSearchTap: _onSearchTap,
//               onStopSearchTap: _onStopSearchTap,
//             ),
//           ),
//
//           // Current Location Button
//           Positioned(
//             bottom: 250,
//             right: 16,
//             child: FloatingActionButton(
//               mini: true,
//               backgroundColor: AppColors.white,
//               foregroundColor: AppColors.primary,
//               child: const Icon(Icons.my_location),
//               onPressed: _goToCurrentLocation,
//             ),
//           ),
//
//           // Nearby Buses Panel
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: GlassyContainer(
//               borderRadius: 24,
//               color: AppColors.glassDark,
//               border: Border.all(color: Colors.white.withOpacity(0.1)),
//               margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Nearby Buses',
//                           style: AppTextStyles.h3.copyWith(
//                             color: AppColors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.refresh, color: AppColors.white),
//                           onPressed: _onRefresh,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Nearby buses list
//                   _isLoading
//                       ? const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: LoadingIndicator(
//                         color: AppColors.white,
//                         size: 30,
//                       ),
//                     ),
//                   )
//                       : passengerProvider.nearbyBuses.isEmpty
//                       ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         'No buses found nearby. Try searching for a specific line.',
//                         style: AppTextStyles.body.copyWith(
//                           color: AppColors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   )
//                       : NearbyBusesList(
//                     buses: passengerProvider.nearbyBuses,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Set<Marker> _buildMarkers(PassengerProvider passengerProvider) {
//     final Set<Marker> markers = {};
//
//     // Add marker for current location
//     final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//     if (locationProvider.currentLocation != null) {
//       markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: LatLng(
//             locationProvider.latitude,
//             locationProvider.longitude,
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//           infoWindow: const InfoWindow(title: 'Your Location'),
//         ),
//       );
//     }
//
//     // Add markers for nearby buses
//     for (final bus in passengerProvider.nearbyBuses) {
//       if (bus.containsKey('current_location')) {
//         final location = bus['current_location'];
//         if (location != null &&
//             location['latitude'] != null &&
//             location['longitude'] != null) {
//           final latitude = double.tryParse(location['latitude'].toString()) ?? 0;
//           final longitude = double.tryParse(location['longitude'].toString()) ?? 0;
//
//           markers.add(
//             Marker(
//               markerId: MarkerId('bus_${bus['id']}'),
//               position: LatLng(latitude, longitude),
//               icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//               infoWindow: InfoWindow(
//                 title: 'Bus ${bus['license_plate']}',
//                 snippet: bus.containsKey('line') ? 'Line: ${bus['line']['code']}' : null,
//               ),
//               onTap: () {
//                 passengerProvider.trackBus(bus['id']);
//                 AppRouter.navigateTo(context, AppRoutes.busTracking);
//               },
//             ),
//           );
//         }
//       }
//     }
//
//     return markers;
//   }
//
//   Set<Polyline> _buildPolylines() {
//     // For demonstration. In a real app, you would get this data from the API
//     return {};
//   }
//
//   Widget _buildDrawer() {
//     final authProvider = Provider.of<AuthProvider>(context);
//
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // Drawer Header with user info
//           UserAccountsDrawerHeader(
//             accountName: Text(
//               authProvider.user != null
//                   ? '${authProvider.user!['first_name']} ${authProvider.user!['last_name']}'
//                   : 'Passenger',
//               style: AppTextStyles.body.copyWith(
//                 color: AppColors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             accountEmail: Text(
//               authProvider.user != null
//                   ? authProvider.user!['email']
//                   : '',
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: AppColors.white,
//               ),
//             ),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: AppColors.white,
//               child: Icon(
//                 Icons.person,
//                 color: AppColors.primary,
//                 size: 40,
//               ),
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//             ),
//           ),
//
//           // Menu Items
//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text('Home'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.search),
//             title: const Text('Search Lines'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               AppRouter.navigateTo(context, AppRoutes.lineSearch);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.location_on),
//             title: const Text('Find Stops'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               AppRouter.navigateTo(context, AppRoutes.stopSearch);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.notifications),
//             title: const Text('Notifications'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               AppRouter.navigateTo(context, AppRoutes.notifications);
//             },
//           ),
//
//           const Divider(),
//
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Profile'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               AppRouter.navigateTo(context, AppRoutes.profile);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               AppRouter.navigateTo(context, AppRoutes.settings);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.info),
//             title: const Text('About'),
//             onTap: () {
//               Navigator.pop(context); // Close the drawer
//               AppRouter.navigateTo(context, AppRoutes.about);
//             },
//           ),
//
//           const Divider(),
//
//           ListTile(
//             leading: const Icon(Icons.logout, color: AppColors.error),
//             title: Text(
//               'Logout',
//               style: TextStyle(color: AppColors.error),
//             ),
//             onTap: () {
//               // Show confirmation dialog
//               DialogHelper.showConfirmDialog(
//                 context,
//                 title: 'Logout',
//                 message: 'Are you sure you want to logout?',
//                 confirmText: 'Logout',
//                 cancelText: 'Cancel',
//               ).then((confirm) {
//                 if (confirm) {
//                   // Logout and navigate to login screen
//                   authProvider.logout().then((_) {
//                     AppRouter.navigateToAndClearStack(context, AppRoutes.login);
//                   });
//                 } else {
//                   Navigator.pop(context); // Close the drawer
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }