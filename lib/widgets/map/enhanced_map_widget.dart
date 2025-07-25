// lib/widgets/map/enhanced_map_widget.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../common/custom_button.dart';
import '../common/custom_card.dart';
import '../common/loading_states.dart';

enum MapDisplayType { normal, satellite, hybrid, terrain }
enum MapViewMode { bus, passenger, admin }

class EnhancedMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Set<Polygon>? polygons;
  final Set<Circle>? circles;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final Function(CameraPosition)? onCameraMove;
  final VoidCallback? onCameraIdle;
  final MapViewMode viewMode;
  final bool showMapControls;
  final bool showLocationButton;
  final bool showZoomControls;
  final bool showMapTypeSelector;
  final bool showTrafficLayer;
  final bool showCompass;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const EnhancedMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14,
    this.markers,
    this.polylines,
    this.polygons,
    this.circles,
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
    this.onCameraMove,
    this.onCameraIdle,
    this.viewMode = MapViewMode.passenger,
    this.showMapControls = true,
    this.showLocationButton = true,
    this.showZoomControls = true,
    this.showMapTypeSelector = true,
    this.showTrafficLayer = false,
    this.showCompass = true,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry});

  @override
  State<EnhancedMapWidget> createState() => _EnhancedMapWidgetState();
}

class _EnhancedMapWidgetState extends State<EnhancedMapWidget>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  MapDisplayType _currentMapDisplayType = MapDisplayType.normal;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );
    if (widget.showMapControls) {
      _controlsAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.errorMessage != null) {
      return _buildErrorState(colorScheme);
    }

    return Stack(
      children: [
        // Map
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.initialPosition,
                  zoom: widget.initialZoom,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  widget.onMapCreated?.call(controller);
                },
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                onCameraMove: widget.onCameraMove,
                onCameraIdle: widget.onCameraIdle,
                markers: widget.markers ?? {},
                polylines: widget.polylines ?? {},
                polygons: widget.polygons ?? {},
                circles: widget.circles ?? {},
                mapType: _getGoogleMapType(_currentMapDisplayType),
                trafficEnabled: widget.showTrafficLayer,
                compassEnabled: widget.showCompass,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                buildingsEnabled: true,
                indoorViewEnabled: true,
              ),
              
              // Loading overlay
              if (widget.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: LoadingWidget(
                      type: LoadingType.circular,
                      size: LoadingSize.large,
                      showMessage: true,
                      message: 'Loading map...',
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Map controls
        if (widget.showMapControls)
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _controlsAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - _controlsAnimation.value) * 20),
                  child: child,
                ),
              );
            },
            child: _buildMapControls(colorScheme),
          ),

        // View mode specific overlays
        _buildViewModeOverlay(colorScheme),
      ],
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 16),
            Text(
              'Map Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 16),
              CustomButton(
        text: 'Retry',
        onPressed: widget.onRetry,
        type: ButtonType.outline,
        size: ButtonSize.small,
        color: colorScheme.onErrorContainer
      ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls(ColorScheme colorScheme) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Map type selector
          if (widget.showMapTypeSelector)
            CustomCard(
              type: CardType.elevated,
              size: CardSize.small,
              padding: const EdgeInsets.all(4),
              child: PopupMenuButton<MapDisplayType>(
                icon: Icon(
                  _getMapDisplayTypeIcon(_currentMapDisplayType),
                  color: colorScheme.onSurface,
                ),
                onSelected: (mapType) {
                  setState(() {
                    _currentMapDisplayType = mapType;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: MapDisplayType.normal,
                    child: Row(
                      children: [
                        Icon(Icons.map, color: colorScheme.onSurface),
                        const SizedBox(width: 8, height: 40),
                        const Text('Normal'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: MapDisplayType.satellite,
                    child: Row(
                      children: [
                        Icon(Icons.satellite_alt, color: colorScheme.onSurface),
                        const SizedBox(width: 8, height: 40),
                        const Text('Satellite'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: MapDisplayType.hybrid,
                    child: Row(
                      children: [
                        Icon(Icons.layers, color: colorScheme.onSurface),
                        const SizedBox(width: 8, height: 40),
                        const Text('Hybrid'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: MapDisplayType.terrain,
                    child: Row(
                      children: [
                        Icon(Icons.terrain, color: colorScheme.onSurface),
                        const SizedBox(width: 8, height: 40),
                        const Text('Terrain'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Zoom controls
          if (widget.showZoomControls) ...[
            CustomCard(
              type: CardType.elevated,
              size: CardSize.small,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _zoomIn(),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: Container(
                        width: 40,
        
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Divider( color: colorScheme.outline),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _zoomOut(),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                      child: Container(
                        width: 40,
        
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.remove,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],

          // My location button
          if (widget.showLocationButton)
            CustomButton(
              text: '',
              onPressed: () => _goToMyLocation(),
              type: ButtonType.primary,
              size: ButtonSize.small,
              icon: Icons.my_location,
            ),
        ],
      ),
    );
  }

  Widget _buildViewModeOverlay(ColorScheme colorScheme) {
    switch (widget.viewMode) {
      case MapViewMode.bus:
        return _buildBusOverlay(colorScheme);
      case MapViewMode.passenger:
        return _buildPassengerOverlay(colorScheme);
      case MapViewMode.admin:
        return _buildAdminOverlay(colorScheme);
    }
  }

  Widget _buildBusOverlay(ColorScheme colorScheme) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: CustomCard(
        type: CardType.elevated,
        size: CardSize.medium,
        child: Row(
          children: [
            Icon(
              Icons.directions_bus,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12, height: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Driver Mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tracking enabled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
        
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerOverlay(ColorScheme colorScheme) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: CustomCard(
        type: CardType.elevated,
        size: CardSize.medium,
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 12, height: 40),
            Expanded(
              child: Text(
                'Tap on buses for details',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
            ),
            CustomButton(
        text: 'Refresh',
        onPressed: () => widget.onRetry?.call(),
              type: ButtonType.text,
              size: ButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOverlay(ColorScheme colorScheme) {
    return Positioned(
      top: 16,
      left: 16,
      child: CustomCard(
        type: CardType.elevated,
        size: CardSize.small,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 8, height: 40),
            Text(
              'Admin View',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MapType _getGoogleMapType(MapDisplayType mapType) {
    switch (mapType) {
      case MapDisplayType.normal:
        return MapType.normal;
      case MapDisplayType.satellite:
        return MapType.satellite;
      case MapDisplayType.hybrid:
        return MapType.hybrid;
      case MapDisplayType.terrain:
        return MapType.terrain;
    }
  }

  IconData _getMapDisplayTypeIcon(MapDisplayType mapType) {
    switch (mapType) {
      case MapDisplayType.normal:
        return Icons.map;
      case MapDisplayType.satellite:
        return Icons.satellite_alt;
      case MapDisplayType.hybrid:
        return Icons.layers;
      case MapDisplayType.terrain:
        return Icons.terrain;
    }
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToMyLocation() {
    // This would typically get the user's current location and animate to it
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(widget.initialPosition),
    );
  }
}

class MapLegend extends StatelessWidget {
  final List<MapLegendItem> items;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const MapLegend({
    super.key,
    required this.items,
    this.isExpanded = false,
    this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomCard(
      type: CardType.elevated,
      size: CardSize.small,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 8, height: 40),
                Text(
                  'Legend',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onToggle != null) ...[
                  const SizedBox(width: 4, height: 40),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                ],
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
        
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: item.shape == MapLegendShape.circle
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                    ),
                  ),
                  const SizedBox(width: 8, height: 40),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }
}

enum MapLegendShape { circle, rectangle }

class MapLegendItem {
  final String label;
  final Color color;
  final MapLegendShape shape;

  const MapLegendItem({
    required this.label,
    required this.color,
    this.shape = MapLegendShape.circle});
}