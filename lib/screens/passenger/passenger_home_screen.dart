// lib/screens/passenger/passenger_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/app_theme.dart';
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
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/modern_button.dart' hide IconButton;
import '../../widgets/common/loading_indicator.dart';
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
  late AnimationController _fabAnimationController;

  bool _isLoading = false;
  bool _isMapReady = false;
  GoogleMapController? _mapController;
  int _selectedBottomIndex = 0;
  bool _showMapView = true;

  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initialize();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 4, vsync: this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permissionGranted = await PermissionHelper.requestLocation(context);

      if (permissionGranted) {
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        await locationProvider.getCurrentLocation();

        if (locationProvider.currentLocation != null) {
          final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
          await passengerProvider.fetchNearbyBuses(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
          );
        }

        final lineProvider = Provider.of<LineProvider>(context, listen: false);
        await lineProvider.fetchLines(queryParams: LineQueryParameters(isActive: true));

        await _loadDashboardStats();
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
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _toggleMapView() {
    setState(() {
      _showMapView = !_showMapView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final passengerProvider = Provider.of<PassengerProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final lineProvider = Provider.of<LineProvider>(context);

    return AppLayout(
      title: 'DZ Bus Tracker',
      currentIndex: 0,
      backgroundColor: AppTheme.neutral50,
      actions: [
        // Map/List toggle
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _toggleMapView,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _showMapView ? Icons.list_rounded : Icons.map_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
        
        // Notification icon with badge
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    AppRouter.navigateTo(context, AppRoutes.notifications);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      floatingActionButton: _buildFloatingActionButton(),
      child: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _initialize,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 600),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // Welcome Section
                        _buildWelcomeSection(authProvider),
                        
                        const SizedBox(height: 20),
                        
                        // Quick Stats
                        _buildQuickStats(),
                        
                        const SizedBox(height: 20),
                        
                        // Search Section
                        _buildSearchSection(),
                        
                        const SizedBox(height: 20),
                        
                        // Map or List View
                        _showMapView ? _buildMapSection() : _buildListSection(),
                        
                        const SizedBox(height: 20),
                        
                        // Quick Actions
                        _buildQuickActions(),
                        
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final user = authProvider.user;
    final firstName = user?.firstName ?? 'Passenger';
    
    return ModernCard(
      type: ModernCardType.gradient,
      variant: ModernCardVariant.primary,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 30,
              color: AppTheme.primary,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  firstName,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Location Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                
                const SizedBox(width: 4),
                
                Text(
                  _dashboardStats['location_status'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Nearby Buses',
            '${_dashboardStats['nearby_buses'] ?? 0}',
            Icons.directions_bus_rounded,
            AppTheme.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildStatCard(
            'Active Lines',
            '${_dashboardStats['active_lines'] ?? 0}',
            Icons.route_rounded,
            AppTheme.secondary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildStatCard(
            'Total Lines',
            '${_dashboardStats['total_lines'] ?? 0}',
            Icons.map_rounded,
            AppTheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return ModernCard(
      type: ModernCardType.glass,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return ModernCard(
      type: ModernCardType.glass,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          SearchBarWidget(
            onSearchTap: () {
              // Navigate to search screen
              AppRouter.navigateTo(context, AppRoutes.lineSearch);
            },
            onStopSearchTap: () {
              // Navigate to stop search
              AppRouter.navigateTo(context, AppRoutes.stopSearch);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return ModernCard(
      type: ModernCardType.glass,
      height: 300,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: MapWidget(
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }

  Widget _buildListSection() {
    return ModernCard(
      type: ModernCardType.glass,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Buses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Consumer<PassengerProvider>(
            builder: (context, passengerProvider, child) {
              return NearbyBusesList(
                buses: passengerProvider.nearbyBuses,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return ModernCard(
      type: ModernCardType.glass,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Search Lines',
                  Icons.search_rounded,
                  AppTheme.primary,
                  () => AppRouter.navigateTo(context, AppRoutes.lineSearch),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildActionButton(
                  'Bus Tracking',
                  Icons.gps_fixed_rounded,
                  AppTheme.secondary,
                  () => AppRouter.navigateTo(context, AppRoutes.busTracking),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Trip History',
                  Icons.history_rounded,
                  AppTheme.tertiary,
                  () => AppRouter.navigateTo(context, AppRoutes.tripHistory),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildActionButton(
                  'Rate Driver',
                  Icons.star_rounded,
                  AppTheme.warning,
                  () => AppRouter.navigateTo(context, AppRoutes.ratings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimationController.value,
          child: FloatingActionButton.extended(
            onPressed: _goToCurrentLocation,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text(
              'My Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}