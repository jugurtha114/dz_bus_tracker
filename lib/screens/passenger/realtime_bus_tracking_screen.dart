// lib/screens/passenger/realtime_bus_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/bus_tracking_service.dart';
import '../../services/location_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/common/custom_card.dart';

class RealTimeBusTrackingScreen extends StatefulWidget {
  final String busId;
  final String? lineId;
  final Map<String, dynamic>? selectedTrip;

  const RealTimeBusTrackingScreen({
    Key? key,
    required this.busId,
    this.lineId,
    this.selectedTrip,
  }) : super(key: key);

  @override
  State<RealTimeBusTrackingScreen> createState() => _RealTimeBusTrackingScreenState();
}

class _RealTimeBusTrackingScreenState extends State<RealTimeBusTrackingScreen> 
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final BusTrackingService _trackingService = BusTrackingService();
  final LocationService _locationService = LocationService();
  
  bool _isLoading = true;
  bool _isTracking = false;
  Timer? _trackingTimer;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Bus and tracking data
  Map<String, dynamic> _busData = {};
  Map<String, dynamic> _routeData = {};
  List<Map<String, dynamic>> _stops = [];
  LatLng? _currentBusLocation;
  LatLng? _userLocation;
  
  // Map markers and polylines
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // ETA and status
  String _estimatedArrival = 'Calculating...';
  int _stopsRemaining = 0;
  double _distanceToUser = 0;
  String _busStatus = 'unknown';
  int _passengerCount = 0;
  int _busCapacity = 40;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTracking();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _initializeTracking() async {
    setState(() => _isLoading = true);
    
    try {
      // Get user location
      _userLocation = await _locationService.getCurrentLocation();
      
      // Load bus and route data
      await _loadBusData();
      await _loadRouteData();
      
      // Start real-time tracking
      _startRealTimeTracking();
      
      // Animate the bottom sheet
      _slideController.forward();
      
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadBusData() async {
    final busData = await _trackingService.getBusInfo(widget.busId);
    setState(() {
      _busData = busData;
      _passengerCount = busData['current_passengers'] ?? 0;
      _busCapacity = busData['capacity'] ?? 40;
    });
  }

  Future<void> _loadRouteData() async {
    if (widget.lineId != null) {
      final routeData = await _trackingService.getRouteInfo(widget.lineId!);
      setState(() {
        _routeData = routeData;
        _stops = List<Map<String, dynamic>>.from(routeData['stops'] ?? []);
      });
    }
  }

  void _startRealTimeTracking() {
    setState(() => _isTracking = true);
    
    // Update every 5 seconds
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateBusLocation();
    });
    
    // Initial update
    _updateBusLocation();
  }

  Future<void> _updateBusLocation() async {
    try {
      final locationData = await _trackingService.getBusLocation(widget.busId);
      
      if (locationData['latitude'] != null && locationData['longitude'] != null) {
        final newLocation = LatLng(
          locationData['latitude'],
          locationData['longitude'],
        );
        
        setState(() {
          _currentBusLocation = newLocation;
          _busStatus = locationData['status'] ?? 'unknown';
          _passengerCount = locationData['passenger_count'] ?? _passengerCount;
        });
        
        // Update ETA and distance
        _calculateETA();
        _updateMapView();
        _updateMarkers();
      }
    } catch (e) {
      // Handle error
    }
  }

  void _calculateETA() {
    if (_currentBusLocation != null && _userLocation != null) {
      // Calculate distance to user
      _distanceToUser = _trackingService.calculateDistance(
        _currentBusLocation!,
        _userLocation!,
      );
      
      // Estimate arrival time based on current speed and route
      final estimatedMinutes = (_distanceToUser / 0).round(); // Rough estimation
      final arrivalTime = DateTime.now().add(Duration(minutes: estimatedMinutes));
      
      setState(() {
        _estimatedArrival = DzDateUtils.formatTime(arrivalTime);
        _stopsRemaining = _calculateRemainingStops();
      });
    }
  }

  int _calculateRemainingStops() {
    if (_currentBusLocation == null || _stops.isEmpty) return 0;
    
    // Find the nearest stop to the bus
    int nearestStopIndex = 0;
    double minDistance = double.infinity;
    
    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      if (stop['latitude'] != null && stop['longitude'] != null) {
        final stopLocation = LatLng(stop['latitude'], stop['longitude']);
        final distance = _trackingService.calculateDistance(_currentBusLocation!, stopLocation);
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestStopIndex = i;
        }
      }
    }
    
    return _stops.length - nearestStopIndex - 1;
  }

  void _updateMapView() {
    if (_mapController != null && _currentBusLocation != null) {
      // Calculate bounds to include both bus and user locations
      LatLngBounds bounds;
      
      if (_userLocation != null) {
        final southwest = LatLng(
          _currentBusLocation!.latitude < _userLocation!.latitude 
              ? _currentBusLocation!.latitude 
              : _userLocation!.latitude,
          _currentBusLocation!.longitude < _userLocation!.longitude 
              ? _currentBusLocation!.longitude 
              : _userLocation!.longitude,
        );
        
        final northeast = LatLng(
          _currentBusLocation!.latitude > _userLocation!.latitude 
              ? _currentBusLocation!.latitude 
              : _userLocation!.latitude,
          _currentBusLocation!.longitude > _userLocation!.longitude 
              ? _currentBusLocation!.longitude 
              : _userLocation!.longitude,
        );
        
        bounds = LatLngBounds(southwest: southwest, northeast: northeast);
        
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      } else {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentBusLocation!,
              zoom: AppConfig.defaultZoomLevel,
            ),
          ),
        );
      }
    }
  }

  void _updateMarkers() {
    final Set<Marker> markers = {};
    
    // Add bus marker
    if (_currentBusLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: _currentBusLocation!,
          infoWindow: InfoWindow(
            title: 'Bus ${_busData['license_plate'] ?? 'Unknown'}',
            snippet: 'Status: $_busStatus',
          ),
        ),
      );
    }
    
    // Add user location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
    }
    
    // Add stop markers
    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      if (stop['latitude'] != null && stop['longitude'] != null) {
        markers.add(
          Marker(
            markerId: MarkerId('stop_$i'),
            position: LatLng(stop['latitude'], stop['longitude']),
            infoWindow: InfoWindow(
              title: stop['name'] ?? 'Stop $i',
            ),
          ),
        );
      }
    }
    
    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Bus Tracking',
      child: _isLoading
          ? const Center(child: LoadingIndicator())
          : Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentBusLocation ?? const LatLng(36, 3),
                    zoom: AppConfig.defaultZoomLevel,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
                
                // Status indicator
                _buildStatusIndicator(),
                
                // Center on bus button
                _buildCenterButton(),
                
                // Bottom tracking panel
                _buildTrackingPanel(localizations),
              ],
            ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (_busStatus) {
      case 'active':
      case 'in_transit':
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = 'Bus is Active';
        statusIcon = Icons.directions_bus;
        break;
      case 'at_stop':
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = 'At Bus Stop';
        statusIcon = Icons.location_on;
        break;
      case 'delayed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = 'Bus Delayed';
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = 'Status Unknown';
        statusIcon = Icons.help;
    }

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: CustomCard(type: CardType.elevated, 
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                );
              },
            ),
            const SizedBox(width: 12, height: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isTracking)
                    Text(
                      'Live tracking active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LIVE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return Positioned(
      bottom: 200,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _updateMapView,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildTrackingPanel(AppLocalizations localizations) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomCard(type: CardType.elevated, 
          backgroundColor: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
        
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bus info header
              _buildBusInfoHeader(),
              const SizedBox(height: 16),
              
              // ETA and stats
              _buildETASection(),
              const SizedBox(height: 16),
              
              // Occupancy indicator
              _buildOccupancyIndicator(),
              const SizedBox(height: 16),
              
              // Action buttons
              _buildActionButtons(localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusInfoHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.directions_bus,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12, height: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bus ${_busData['license_plate'] ?? 'Unknown'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_routeData['name'] != null)
                Text(
                  _routeData['name'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                  ),
                ),
            ],
          ),
        ),
        if (_distanceToUser > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_distanceToUser.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'away',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildETASection() {
    return Row(
      children: [
        Expanded(
          child: _buildETACard(
            'ETA',
            _estimatedArrival,
            Icons.schedule,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12, height: 40),
        Expanded(
          child: _buildETACard(
            'Stops Remaining',
            '$_stopsRemaining',
            Icons.location_on,
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildETACard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyIndicator() {
    final occupancyRatio = _passengerCount / _busCapacity;
    Color occupancyColor;
    String occupancyText;
    
    if (occupancyRatio < 0) {
      occupancyColor = Theme.of(context).colorScheme.primary;
      occupancyText = 'Available';
    } else if (occupancyRatio < 0) {
      occupancyColor = Theme.of(context).colorScheme.primary;
      occupancyText = 'Moderate';
    } else {
      occupancyColor = Theme.of(context).colorScheme.primary;
      occupancyText = 'Crowded';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bus Occupancy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                occupancyText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: occupancyColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: occupancyRatio,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                  valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                ),
              ),
              const SizedBox(width: 12, height: 40),
              Text(
                '$_passengerCount/$_busCapacity',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Show route details
            },
            icon: const Icon(Icons.route),
            label: const Text('Route Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Share location or set reminder
            },
            icon: const Icon(Icons.notifications),
            label: const Text('Notify Me'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}