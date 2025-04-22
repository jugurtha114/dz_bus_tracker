/// lib/presentation/widgets/map/bus_map_view.dart

/// lib/presentation/widgets/map/bus_map_view.dart

import 'dart:async';
import 'dart:convert'; // For jsonDecode (GeoJSON)
import 'dart:ui' as ui; // For image loading for markers

// CORRECTED: Ensure collection is imported
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'; // listEquals, mapEquals
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData, Uint8List;
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:Maps_flutter/Maps_flutter.dart';

// CORRECTED: Import ThemeConstants
import '../../../core/constants/theme_constants.dart';
// import '../../../config/themes/app_theme.dart'; // Only needed if using AppTheme directly
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/location_entity.dart';
import '../../../domain/entities/stop_entity.dart';
import '../common/loading_indicator.dart';

/// A widget that displays a Google Map focused on a specific bus line,
/// showing its route, stops, and the real-time locations of active buses.
class BusMapView extends StatefulWidget {
  final LineEntity line;
  final List<StopEntity> stops; // Use the full list of stops for markers
  final List<BusEntity> activeBuses; // Use BusEntity list
  final Map<String, LocationEntity> busLocations; // Separate map for latest locations

  const BusMapView({
    super.key,
    required this.line,
    required this.stops,
    required this.activeBuses, // Accept list of BusEntity
    required this.busLocations,
  });

  @override
  State<BusMapView> createState() => _BusMapViewState();
}

class _BusMapViewState extends State<BusMapView> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;

  // Map elements state
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLngBounds? _lineBounds; // Bounds calculated from line/stops

  // Preloaded map assets
  BitmapDescriptor? _busMarkerIcon;
  BitmapDescriptor? _stopMarkerIcon;
  String? _lightMapStyle;
  String? _darkMapStyle;
  bool _assetsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMapAssetsAndInitialize();
  }

  @override
  void didUpdateWidget(covariant BusMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the line, stops, buses, or locations change, update the map elements
    if (widget.line != oldWidget.line ||
        !listEquals(widget.stops, oldWidget.stops) || // Need deep equality check if StopEntity not Equatable
        !listEquals(widget.activeBuses, oldWidget.activeBuses) ||
        !mapEquals(widget.busLocations, oldWidget.busLocations)) {
      Log.d('BusMapView: Input data changed, updating map elements.');
      _updateMapElements();
      // Optionally re-animate camera if bounds changed significantly
      // _fitBounds(); // Re-fitting bounds might be jarring on frequent updates
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Load assets and then initialize map elements
  Future<void> _loadMapAssetsAndInitialize() async {
    await _loadMapAssets();
    _updateMapElements(); // Initial element setup
  }

  Future<void> _loadMapAssets() async {
    if (_assetsLoaded) return; // Don't reload if already done
    try {
      _busMarkerIcon = await _bitmapDescriptorFromAssetBytes(AssetsConstants.mapPinBus, 100);
      _stopMarkerIcon = await _bitmapDescriptorFromAssetBytes(AssetsConstants.mapPinStop, 60);
      _lightMapStyle = await rootBundle.loadString(AssetsConstants.mapStyleLight);
      _darkMapStyle = await rootBundle.loadString(AssetsConstants.mapStyleDark);
      Log.i('BusMapView assets loaded.');
      if(mounted) setState(() => _assetsLoaded = true);
    } catch (e, stackTrace) {
      Log.e('Error loading BusMapView assets', error: e, stackTrace: stackTrace);
       if(mounted) setState(() => _assetsLoaded = true); // Mark loaded even if error
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromAssetBytes(String path, int width) async {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    final ByteData? resizedByteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  void _setMapStyle() {
    if (!_assetsLoaded || _mapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styleJson = isDark ? _darkMapStyle : _lightMapStyle;
    _mapController!.setMapStyle(styleJson);
  }

  /// Updates the markers and polylines displayed on the map.
  void _updateMapElements() {
    if (!_assetsLoaded || !mounted) return;

    final newMarkers = <Marker>{};
    final newPolylines = <Polyline>{};
    final List<LatLng> allPoints = []; // To calculate bounds

    // --- Create Stop Markers ---
    for (final stop in widget.stops) {
      final position = LatLng(stop.latitude, stop.longitude);
      allPoints.add(position);
      newMarkers.add(Marker(
         markerId: MarkerId('stop_${stop.id}'),
         position: position,
         icon: _stopMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
         infoWindow: InfoWindow(
            title: stop.name,
            snippet: stop.code ?? 'Stop', // TODO: Localize 'Stop'
            onTap: () => _onStopMarkerTapped(stop),
         ),
         anchor: const Offset(0.5, 0.5),
      ));
    }

    // --- Create Bus Markers ---
    widget.busLocations.forEach((busId, location) {
      final busDetails = widget.activeBuses.firstWhereOrNull((b) => b.id == busId);
      if (busDetails != null) {
        final position = LatLng(location.latitude, location.longitude);
         allPoints.add(position); // Include bus position in bounds calculation
        newMarkers.add(Marker(
           markerId: MarkerId('bus_$busId'),
           position: position,
           icon: _busMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
           infoWindow: InfoWindow(
              title: 'Bus ${busDetails.matricule}', // TODO: Localize 'Bus'
              snippet: 'Line: ${widget.line.name}', // Display current line context
              onTap: () => _onBusMarkerTapped(busDetails),
           ),
           rotation: location.heading ?? 0.0,
           anchor: const Offset(0.5, 0.5),
           flat: true,
           zIndex: 1.0, // Ensure buses are drawn above lines/stops
        ));
      }
    });

    // --- Create Line Polyline ---
    if (widget.line.path != null) {
        final points = _parseGeoJsonPath(widget.line.path);
        if (points.isNotEmpty) {
            allPoints.addAll(points); // Add polyline points to bounds calculation
            newPolylines.add(Polyline(
              polylineId: PolylineId('line_${widget.line.id}'),
              points: points,
              color: _parseLineColor(context, widget.line.color),
              width: 5, // Make line slightly thicker
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            ));
        } else {
            // Fallback: Draw line connecting stops if path parsing fails
            if(widget.stops.length > 1) {
                final stopPoints = widget.stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
                allPoints.addAll(stopPoints);
                newPolylines.add(Polyline(
                  polylineId: PolylineId('line_${widget.line.id}_fallback'),
                  points: stopPoints,
                  color: _parseLineColor(context, widget.line.color).withOpacity(0.7),
                  width: 4,
                   patterns: [PatternItem.dot, PatternItem.gap(10)], // Indicate it's approx
                ));
            }
        }
    }

    // Calculate bounds
    _lineBounds = allPoints.isNotEmpty ? _boundsFromLatLngList(allPoints) : null;

    // Update state
    setState(() {
      _markers = newMarkers;
      _polylines = newPolylines;
    });
  }

  // --- Event Handlers ---
  void _onMapCreated(GoogleMapController controller) {
     if (!_mapControllerCompleter.isCompleted) {
         _mapControllerCompleter.complete(controller);
      }
     _mapController = controller;
     _setMapStyle(); // Apply style
     _fitBounds(true); // Fit bounds on initial creation
     Log.i("GoogleMap created for BusMapView.");
  }

  void _onStopMarkerTapped(StopEntity stop) {
      Log.i('BusMapView: Tapped stop marker: ${stop.name}');
      // TODO: Implement desired action (e.g., show bottom sheet with ETAs)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tapped stop: ${stop.name}'), // TODO: Localize
        duration: const Duration(seconds: 2),
      ));
  }

   void _onBusMarkerTapped(BusEntity bus) {
      Log.i('BusMapView: Tapped bus marker: ${bus.matricule}');
      // TODO: Implement desired action
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tapped bus: ${bus.matricule} on Line ${widget.line.name}'), // TODO: Localize
        duration: const Duration(seconds: 2),
      ));
  }

  // --- Utility Methods (Copied/Adapted) ---

  /// Convert a GeoJSON LineString to a list of LatLng. Returns an empty list on
  /// any error – never null.
  List<LatLng> _parseGeoJsonPath(Map<String, dynamic>? pathData) {
    if (pathData == null) return [];

    try {
      if (pathData['type'] != 'LineString') return [];

      final coords = pathData['coordinates'] as List?;
      if (coords == null) return [];

      // Filter + map in two passes to avoid mapNotNull (extension not available).
      return coords
          .where((p) =>
      p is List &&
          p.length >= 2 &&
          p[0] is num &&
          p[1] is num)
          .map((p) {
        final list = p as List;
        return LatLng(
          (list[1] as num).toDouble(), // latitude
          (list[0] as num).toDouble(), // longitude
        );
      })
          .toList();
    } catch (e, stack) {
      Log.e('Error parsing GeoJSON', error: e, stackTrace: stack);
      return [];
    }
  }

    Color _parseLineColor(BuildContext context, String? colorHex) {
      if (colorHex == null || colorHex.isEmpty) return Theme.of(context).colorScheme.primary.withOpacity(0.8);
      try { String hex = colorHex.toUpperCase().replaceAll("#", ""); if (hex.length == 6) hex = "FF$hex"; if (hex.length == 8) return Color(int.parse("0x$hex")); } catch (e) { Log.e("Parsing color failed", error: e); }
      return Theme.of(context).colorScheme.primary.withOpacity(0.8);
   }

   LatLngBounds _boundsFromLatLngList(List<LatLng> points) {
      if (points.isEmpty) return LatLngBounds(southwest: AppConstants.initialMapCenter, northeast: AppConstants.initialMapCenter); // Default
      double? minLat, maxLat, minLng, maxLng;
      for (final p in points) { minLat = (minLat == null || p.latitude < minLat) ? p.latitude : minLat; maxLat = (maxLat == null || p.latitude > maxLat) ? p.latitude : maxLat; minLng = (minLng == null || p.longitude < minLng) ? p.longitude : minLng; maxLng = (maxLng == null || p.longitude > maxLng) ? p.longitude : maxLng; }
      // Add padding if bounds are too small (single point)
      if (maxLat == minLat || maxLng == minLng) {
         const padding = 0.005; // Adjust padding as needed
         minLat = minLat! - padding; maxLat = maxLat! + padding; minLng = minLng! - padding; maxLng = maxLng! + padding;
      }
      return LatLngBounds(southwest: LatLng(minLat!, minLng!), northeast: LatLng(maxLat!, maxLng!));
   }

   void _fitBounds([bool initialFit = false]) {
      if (_mapController != null && _lineBounds != null) {
         if (initialFit) {
            // Use moveCamera for initial positioning without animation
            _mapController!.moveCamera(CameraUpdate.newLatLngBounds(_lineBounds!, 60.0));
         } else {
             _mapController!.animateCamera(CameraUpdate.newLatLngBounds(_lineBounds!, 60.0));
         }
         Log.d('BusMapView: Camera adjusted to bounds.');
      }
   }


  @override
  Widget build(BuildContext context) {
    // Use a fixed height container for the map within the details page
    return SizedBox(
       height: 280, // Adjust height as desired
       child: _assetsLoaded
          ? GoogleMap(
                initialCameraPosition: CameraPosition(
                   target: AppConstants.initialMapCenter, // Initial fallback center
                   zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                zoomControlsEnabled: false, // Keep UI clean, user can pinch zoom
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: true,
                compassEnabled: false, // Less clutter
                mapToolbarEnabled: false,
                onMapCreated: _onMapCreated,
             )
            : Container( // Placeholder while assets load
               color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
               child: const Center(child: LoadingIndicator(message: 'Loading Map...')) // TODO: Localize
             ),
    );
  }
}
