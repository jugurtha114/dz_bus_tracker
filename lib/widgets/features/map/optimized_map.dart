// lib/widgets/features/map/optimized_map.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../config/design_system.dart';
import '../../foundation/foundation.dart';
import '../../common/common.dart';

/// Optimized map widget for bus tracking with performance improvements
class OptimizedMapWidget extends StatefulWidget {
  const OptimizedMapWidget({
    super.key,
    required this.initialPosition,
    this.buses = const [],
    this.stops = const [],
    this.routes = const [],
    this.onMapCreated,
    this.onCameraMove,
    this.onBusTap,
    this.onStopTap,
    this.userLocation,
    this.followUser = false,
    this.showTraffic = false,
    this.mapType = MapType.normal,
    this.minZoom = 8.0,
    this.maxZoom = 20.0,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  final LatLng initialPosition;
  final List<BusMapData> buses;
  final List<StopMapData> stops;
  final List<RouteMapData> routes;
  final Function(GoogleMapController)? onMapCreated;
  final Function(CameraPosition)? onCameraMove;
  final Function(BusMapData)? onBusTap;
  final Function(StopMapData)? onStopTap;
  final LatLng? userLocation;
  final bool followUser;
  final bool showTraffic;
  final MapType mapType;
  final double minZoom;
  final double maxZoom;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  State<OptimizedMapWidget> createState() => _OptimizedMapWidgetState();
}

class _OptimizedMapWidgetState extends State<OptimizedMapWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _updateMapData();
  }

  @override
  void didUpdateWidget(OptimizedMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buses != widget.buses ||
        oldWidget.stops != widget.stops ||
        oldWidget.routes != widget.routes ||
        oldWidget.userLocation != widget.userLocation) {
      _updateMapData();
    }
    
    if (widget.followUser && 
        widget.userLocation != null && 
        widget.userLocation != oldWidget.userLocation) {
      _animateToPosition(widget.userLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const LoadingState(message: 'Loading map...');
    }

    if (widget.errorMessage != null) {
      return ErrorState(
        message: widget.errorMessage!,
        onRetry: widget.onRetry,
        type: ErrorType.general,
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: 14.0,
          ),
          onMapCreated: _onMapCreated,
          onCameraMove: widget.onCameraMove,
          markers: _markers,
          polylines: _polylines,
          trafficEnabled: widget.showTraffic,
          mapType: widget.mapType,
          minMaxZoomPreference: MinMaxZoomPreference(
            widget.minZoom,
            widget.maxZoom,
          ),
          myLocationEnabled: widget.userLocation != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
        ),
        _buildMapControls(),
        if (widget.buses.isNotEmpty) _buildBusLegend(),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: DesignSystem.space16,
      right: DesignSystem.space16,
      child: Column(
        children: [
          _buildMapTypeToggle(),
          const SizedBox(height: DesignSystem.space8),
          if (widget.userLocation != null) _buildMyLocationButton(),
          const SizedBox(height: DesignSystem.space8),
          _buildZoomControls(),
        ],
      ),
    );
  }

  Widget _buildMapTypeToggle() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: IconButton(
        icon: Icon(
          widget.mapType == MapType.normal 
              ? Icons.satellite_alt
              : Icons.map,
        ),
        onPressed: () {
          // Toggle map type - this would be handled by parent
        },
        tooltip: 'Toggle map type',
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: IconButton(
        icon: const Icon(Icons.my_location),
        onPressed: () {
          if (widget.userLocation != null) {
            _animateToPosition(widget.userLocation!);
          }
        },
        tooltip: 'My location',
      ),
    );
  }

  Widget _buildZoomControls() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _zoomIn,
            tooltip: 'Zoom in',
          ),
          const Divider(height: 1),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _zoomOut,
            tooltip: 'Zoom out',
          ),
        ],
      ),
    );
  }

  Widget _buildBusLegend() {
    return Positioned(
      bottom: DesignSystem.space16,
      left: DesignSystem.space16,
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bus Status',
              style: context.textStyles.titleSmall,
            ),
            const SizedBox(height: DesignSystem.space8),
            _buildLegendItem(
              color: DesignSystem.busActive,
              label: 'Active',
              count: widget.buses.where((b) => b.isActive).length,
            ),
            _buildLegendItem(
              color: DesignSystem.busInactive,
              label: 'Inactive',
              count: widget.buses.where((b) => !b.isActive).length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: DesignSystem.space8),
          Text(
            '$label ($count)',
            style: context.textStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  void _updateMapData() {
    final markers = <Marker>{};
    final polylines = <Polyline>{};

    // Add bus markers
    for (final bus in widget.buses) {
      markers.add(
        Marker(
          markerId: MarkerId('bus_${bus.id}'),
          position: bus.position,
          icon: bus.isActive 
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => widget.onBusTap?.call(bus),
          infoWindow: InfoWindow(
            title: bus.busNumber,
            snippet: bus.isActive ? 'Active' : 'Inactive',
          ),
        ),
      );
    }

    // Add stop markers
    for (final stop in widget.stops) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: stop.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () => widget.onStopTap?.call(stop),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Bus Stop',
          ),
        ),
      );
    }

    // Add user location marker
    if (widget.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: widget.userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
    }

    // Add route polylines
    for (final route in widget.routes) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route_${route.id}'),
          points: route.points,
          color: route.color,
          width: route.width,
          patterns: route.isDashed ? [PatternItem.dash(10), PatternItem.gap(5)] : [],
        ),
      );
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    widget.onMapCreated?.call(controller);
  }

  void _animateToPosition(LatLng position) {
    _controller?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _zoomIn() {
    _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _controller?.animateCamera(CameraUpdate.zoomOut());
  }
}

/// Map location picker for selecting coordinates
class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({
    super.key,
    required this.initialPosition,
    this.onLocationSelected,
    this.title = 'Select Location',
  });

  final LatLng initialPosition;
  final Function(LatLng)? onLocationSelected;
  final String title;

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late LatLng _selectedPosition;
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: widget.title,
      actions: [
        AppButton.text(
          text: 'Confirm',
          onPressed: () {
            widget.onLocationSelected?.call(_selectedPosition);
            Navigator.of(context).pop(_selectedPosition);
          },
        ),
      ],
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 15.0,
        ),
        onMapCreated: (controller) {
          _controller = controller;
        },
        onTap: (position) {
          setState(() {
            _selectedPosition = position;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedPosition,
            draggable: true,
            onDragEnd: (position) {
              setState(() {
                _selectedPosition = position;
              });
            },
          ),
        },
      ),
    );
  }
}

/// Data classes for map components
class BusMapData {
  const BusMapData({
    required this.id,
    required this.busNumber,
    required this.position,
    required this.isActive,
    this.lineId,
    this.passengerCount,
    this.capacity,
  });

  final String id;
  final String busNumber;
  final LatLng position;
  final bool isActive;
  final String? lineId;
  final int? passengerCount;
  final int? capacity;
}

class StopMapData {
  const StopMapData({
    required this.id,
    required this.name,
    required this.position,
    this.waitingPassengers,
  });

  final String id;
  final String name;
  final LatLng position;
  final int? waitingPassengers;
}

class RouteMapData {
  const RouteMapData({
    required this.id,
    required this.points,
    this.color = Colors.blue,
    this.width = 3,
    this.isDashed = false,
  });

  final String id;
  final List<LatLng> points;
  final Color color;
  final int width;
  final bool isDashed;
}