// lib/widgets/passenger/bus_tracker_map.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';

class BusTrackerMap extends StatefulWidget {
  final LatLng? initialPosition;
  final List<Map<String, dynamic>> buses;
  final List<Map<String, dynamic>> stops;
  final Function(String busId)? onBusSelected;
  final Function(String stopId)? onStopSelected;
  final String? selectedBusId;
  final String? selectedRouteId;
  final bool showStops;
  final bool showUserLocation;
  final LatLng? userLocation;
  final void Function(GoogleMapController)? onMapCreated;
  final Set<Polyline>? polylines;

  const BusTrackerMap({
    Key? key,
    this.initialPosition,
    this.buses = const [],
    this.stops = const [],
    this.onBusSelected,
    this.onStopSelected,
    this.selectedBusId,
    this.selectedRouteId,
    this.showStops = true,
    this.showUserLocation = true,
    this.userLocation,
    this.onMapCreated,
    this.polylines,
  }) : super(key: key);

  @override
  State<BusTrackerMap> createState() => _BusTrackerMapState();
}

class _BusTrackerMapState extends State<BusTrackerMap> {
  GoogleMapController? _mapController;
  final Map<String, BitmapDescriptor> _markerIcons = {};
  bool _markersLoaded = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();

    // Set up auto-refresh timer
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updateBusPositions();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    try {
      // Load bus marker
      final busMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/bus_marker.png',
      );

      // Load stop marker
      final stopMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        'assets/images/stop_marker.png',
      );

      // Load selected bus marker
      final selectedBusMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(56, 56)),
        'assets/images/selected_bus_marker.png',
      );

      // Load user location marker
      final userLocationMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        'assets/images/user_location.png',
      );

      setState(() {
        _markerIcons['bus'] = busMarker;
        _markerIcons['stop'] = stopMarker;
        _markerIcons['selectedBus'] = selectedBusMarker;
        _markerIcons['userLocation'] = userLocationMarker;
        _markersLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading marker icons: $e');

      // Fallback to default markers if assets fail to load
      setState(() {
        _markerIcons['bus'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        _markerIcons['stop'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        _markerIcons['selectedBus'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
        _markerIcons['userLocation'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
        _markersLoaded = true;
      });
    }
  }

  void _updateBusPositions() {
    // This would be implemented to fetch updated bus positions
    // For now, we'll just rebuild the widget with existing data
    if (mounted) {
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (widget.onMapCreated != null) {
      widget.onMapCreated!(controller);
    }

    // Apply custom map style if needed
    _setMapStyle();
  }

  Future<void> _setMapStyle() async {
    // You can load a custom map style JSON
    // String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
    // _mapController?.setMapStyle(style);
  }

  void _centerMap() {
    if (_mapController == null) return;

    // Center on user location if available
    if (widget.userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.userLocation!,
            zoom: AppConfig.defaultZoomLevel,
          ),
        ),
      );
      return;
    }

    // Center on selected bus if available
    if (widget.selectedBusId != null) {
      final selectedBus = widget.buses.firstWhere(
            (bus) => bus['id'] == widget.selectedBusId,
        orElse: () => {},
      );

      if (selectedBus.isNotEmpty &&
          selectedBus.containsKey('current_location') &&
          selectedBus['current_location'] != null) {
        final location = selectedBus['current_location'];

        if (location['latitude'] != null && location['longitude'] != null) {
          final latitude = double.tryParse(location['latitude'].toString()) ?? 0;
          final longitude = double.tryParse(location['longitude'].toString()) ?? 0;

          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: AppConfig.defaultZoomLevel,
              ),
            ),
          );
          return;
        }
      }
    }

    // Fall back to initial position
    if (widget.initialPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.initialPosition!,
            zoom: AppConfig.defaultZoomLevel,
          ),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    // Add user location marker
    if (widget.showUserLocation && widget.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: widget.userLocation!,
          icon: _markerIcons['userLocation'] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add bus markers
    for (final bus in widget.buses) {
      if (bus.containsKey('current_location') &&
          bus['current_location'] != null &&
          bus['current_location']['latitude'] != null &&
          bus['current_location']['longitude'] != null) {
        final latitude = double.tryParse(bus['current_location']['latitude'].toString()) ?? 0;
        final longitude = double.tryParse(bus['current_location']['longitude'].toString()) ?? 0;
        final busId = bus['id']?.toString() ?? '';
        final licensePlate = bus['license_plate'] ?? 'Unknown';
        final lineCode = bus.containsKey('line') && bus['line'] != null
            ? bus['line']['code']
            : '';

        // Skip if invalid location
        if (latitude == 0 && longitude == 0) continue;

        // Determine if this is the selected bus
        final isSelected = widget.selectedBusId == busId;

        markers.add(
          Marker(
            markerId: MarkerId('bus_$busId'),
            position: LatLng(latitude, longitude),
            icon: isSelected
                ? (_markerIcons['selectedBus'] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure))
                : (_markerIcons['bus'] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
            infoWindow: InfoWindow(
              title: 'Bus $licensePlate',
              snippet: lineCode.isNotEmpty ? 'Line: $lineCode' : null,
            ),
            onTap: () {
              if (widget.onBusSelected != null) {
                widget.onBusSelected!(busId);
              }
            },
          ),
        );
      }
    }

    // Add stop markers
    if (widget.showStops) {
      for (final stop in widget.stops) {
        if (stop['latitude'] != null && stop['longitude'] != null) {
          final latitude = double.tryParse(stop['latitude'].toString()) ?? 0;
          final longitude = double.tryParse(stop['longitude'].toString()) ?? 0;
          final stopId = stop['id']?.toString() ?? '';
          final name = stop['name'] ?? 'Bus Stop';

          // Skip if invalid location
          if (latitude == 0 && longitude == 0) continue;

          markers.add(
            Marker(
              markerId: MarkerId('stop_$stopId'),
              position: LatLng(latitude, longitude),
              icon: _markerIcons['stop'] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: name,
              ),
              onTap: () {
                if (widget.onStopSelected != null) {
                  widget.onStopSelected!(stopId);
                }
              },
            ),
          );
        }
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition ?? const LatLng(0, 0),
            zoom: AppConfig.defaultZoomLevel,
          ),
          onMapCreated: _onMapCreated,
          markers: _markersLoaded ? _buildMarkers() : {},
          polylines: widget.polylines ?? {},
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapType: MapType.normal,
        ),

        // Center button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.white,
            child: Icon(
              Icons.my_location,
              color: AppColors.primary,
            ),
            onPressed: _centerMap,
          ),
        ),
      ],
    );
  }
}