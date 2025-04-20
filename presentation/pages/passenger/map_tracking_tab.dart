/// lib/presentation/widgets/map/bus_map_view.dart

import 'dart:async';
import 'dart:convert'; // For jsonDecode (GeoJSON)
import 'dart:ui' as ui; // For image loading for markers

// CORRECTED: Ensure collection is imported for mapNotNull
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'; // listEquals, mapEquals
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData, Uint8List;
import 'package:google_maps_flutter/google_maps_flutter.dart';

// CORRECTED: Import ThemeConstants
import '../../../core/constants/theme_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/location_entity.dart';
import '../../../domain/entities/stop_entity.dart';
import '../../widgets/common/loading_indicator.dart';


/// A widget that displays a Google Map focused on a specific bus line,
/// showing its route, stops, and the real-time locations of active buses.
class BusMapView extends StatefulWidget {
  final LineEntity line;
  final List<StopEntity> stops;
  final List<BusEntity> activeBuses;
  final Map<String, LocationEntity> busLocations;

  const BusMapView({
    super.key,
    required this.line,
    required this.stops,
    required this.activeBuses,
    required this.busLocations,
  });

  @override
  State<BusMapView> createState() => _BusMapViewState();
}

class _BusMapViewState extends State<BusMapView> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLngBounds? _lineBounds;

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
    if (widget.line != oldWidget.line ||
        !listEquals(widget.stops, oldWidget.stops) ||
        !listEquals(widget.activeBuses, oldWidget.activeBuses) ||
        !mapEquals(widget.busLocations, oldWidget.busLocations)) {
      Log.d('BusMapView: Input data changed, updating map elements.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) _updateMapElements();
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapAssetsAndInitialize() async {
    await _loadMapAssets();
    if(mounted) _updateMapElements();
  }

  Future<void> _loadMapAssets() async {
    if (_assetsLoaded) return;
    try {
      _busMarkerIcon = await _bitmapDescriptorFromAssetBytes(AssetsConstants.mapPinBus, 100);
      _stopMarkerIcon = await _bitmapDescriptorFromAssetBytes(AssetsConstants.mapPinStop, 60);
      _lightMapStyle = await rootBundle.loadString(AssetsConstants.mapStyleLight);
      _darkMapStyle = await rootBundle.loadString(AssetsConstants.mapStyleDark);
      Log.i('BusMapView assets loaded.');
      if(mounted) setState(() => _assetsLoaded = true);
    } catch (e, stackTrace) {
      Log.e('Error loading BusMapView assets', error: e, stackTrace: stackTrace);
      if(mounted) setState(() => _assetsLoaded = true);
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromAssetBytes(String path, int width) async {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    final ByteData? resizedByteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (resizedByteData == null) throw Exception('Failed to convert image to ByteData');
    final Uint8List resizedBytes = resizedByteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  void _setMapStyle() {
    if (!_assetsLoaded || _mapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styleJson = isDark ? _darkMapStyle : _lightMapStyle;
    try {
      _mapController!.setMapStyle(styleJson);
      Log.d('Map style set for ${Theme.of(context).brightness}.');
    } catch (e) {
      Log.w('Failed to set custom map style.', error: e);
      _mapController!.setMapStyle(null);
    }
  }

  void _updateMapElements() {
    if (!_assetsLoaded || !mounted) return;
    final newMarkers = <Marker>{};
    final newPolylines = <Polyline>{};
    final List<LatLng> allPoints = [];

    for (final stop in widget.stops) {
      final position = LatLng(stop.latitude, stop.longitude);
      allPoints.add(position);
      newMarkers.add(Marker( markerId: MarkerId('stop_${stop.id}'), position: position, icon: _stopMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), infoWindow: InfoWindow( title: stop.name, snippet: stop.code ?? 'Stop', onTap: () => _onStopMarkerTapped(stop), ), anchor: const Offset(0.5, 0.5), ));
    }

    widget.busLocations.forEach((busId, location) {
      final busDetails = widget.activeBuses.firstWhereOrNull((b) => b.id == busId);
      if (busDetails != null) {
        final position = LatLng(location.latitude, location.longitude);
        allPoints.add(position);
        newMarkers.add(Marker(
          markerId: MarkerId('bus_$busId'),
          position: position,
          icon: _busMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Bus ${busDetails.matricule}',
            // CORRECTED: Use widget.line.name
            snippet: 'Line: ${widget.line.name}',
            onTap: () => _onBusMarkerTapped(busDetails),
          ),
          rotation: location.heading ?? 0.0, anchor: const Offset(0.5, 0.5), flat: true, zIndex: 1.0,
        ));
      }
    });

    if (widget.line.path != null) {
      final points = _parseGeoJsonPath(widget.line.path);
      if (points.isNotEmpty) {
        allPoints.addAll(points);
        newPolylines.add(Polyline( polylineId: PolylineId('line_${widget.line.id}'), points: points, color: _parseLineColor(context, widget.line.color), width: 5, startCap: Cap.roundCap, endCap: Cap.roundCap, jointType: JointType.round, ));
      } else if (widget.stops.length > 1) {
        final stopPoints = widget.stops.map((s) => LatLng(s.latitude, s.longitude)).toList(); allPoints.addAll(stopPoints); newPolylines.add(Polyline( polylineId: PolylineId('line_${widget.line.id}_fallback'), points: stopPoints, color: _parseLineColor(context, widget.line.color).withOpacity(0.7), width: 4, patterns: [PatternItem.dot, PatternItem.gap(10)], ));
      }
    } else if (widget.stops.length > 1) {
      final stopPoints = widget.stops.map((s) => LatLng(s.latitude, s.longitude)).toList(); allPoints.addAll(stopPoints); newPolylines.add(Polyline( polylineId: PolylineId('line_${widget.line.id}_fallback'), points: stopPoints, color: _parseLineColor(context, widget.line.color).withOpacity(0.7), width: 4, patterns: [PatternItem.dot, PatternItem.gap(10)], ));
    }

    _lineBounds = allPoints.isNotEmpty ? _boundsFromLatLngList(allPoints) : null;

    if (!setEquals(_markers, newMarkers) || !setEquals(_polylines, newPolylines)) {
      setState(() { _markers = newMarkers; _polylines = newPolylines; });
      Log.d('BusMapView: Map elements updated.');
    } else { Log.d('BusMapView: Map elements unchanged.'); }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapControllerCompleter.isCompleted) { _mapControllerCompleter.complete(controller); }
    _mapController = controller;
    _setMapStyle();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds(true));
    Log.i("GoogleMap created for BusMapView.");
  }

  void _onStopMarkerTapped(StopEntity stop) { Log.i('BusMapView: Tapped stop marker: ${stop.name}'); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped stop: ${stop.name}'), duration: const Duration(seconds: 2))); }
  void _onBusMarkerTapped(BusEntity bus) { Log.i('BusMapView: Tapped bus marker: ${bus.matricule}'); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped bus: ${bus.matricule} on Line ${widget.line.name}'), duration: const Duration(seconds: 2))); }

  // --------------------------------------------------------------------------
  // Converts a GeoJSON LineString to a list of LatLngs.
  // Falls back to an empty list on any parse error – never returns null.
  // --------------------------------------------------------------------------
  List<LatLng> _parseGeoJsonPath(Map<String, dynamic>? pathData) {
    if (pathData == null) return [];

    try {
      if (pathData['type'] != 'LineString') return [];

      final coords = pathData['coordinates'] as List?;
      if (coords == null) return [];

      // Filter out invalid entries, then map each valid pair to LatLng.
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
    } catch (e, s) {
      Log.e('Error parsing GeoJSON', error: e, stackTrace: s);
      return [];
    }
  }


  Color _parseLineColor(BuildContext context, String? colorHex) { if (colorHex == null || colorHex.isEmpty) return Theme.of(context).colorScheme.primary.withOpacity(0.8); try { String hex = colorHex.toUpperCase().replaceAll("#", ""); if (hex.length == 6) hex = "FF$hex"; if (hex.length == 8) return Color(int.parse("0x$hex")); } catch (e) { Log.e("Parsing color failed", error: e); } return Theme.of(context).colorScheme.primary.withOpacity(0.8); }

  LatLngBounds _boundsFromLatLngList(List<LatLng> points) { if (points.isEmpty) return LatLngBounds(southwest: AppConstants.initialMapCenter, northeast: AppConstants.initialMapCenter); double? minLat, maxLat, minLng, maxLng; for (final p in points) { minLat = (minLat == null || p.latitude < minLat) ? p.latitude : minLat; maxLat = (maxLat == null || p.latitude > maxLat) ? p.latitude : maxLat; minLng = (minLng == null || p.longitude < minLng) ? p.longitude : minLng; maxLng = (maxLng == null || p.longitude > maxLng) ? p.longitude : maxLng; } if (points.length == 1 || (maxLat! - minLat!).abs() < 0.0001 || (maxLng! - minLng!).abs() < 0.0001 ) { const padding = 0.005; minLat = minLat! - padding; maxLat = maxLat! + padding; minLng = minLng! - padding; maxLng = maxLng! + padding; } return LatLngBounds(southwest: LatLng(minLat!, minLng!), northeast: LatLng(maxLat!, maxLng!)); }

  void _fitBounds([bool initialFit = false]) { if (_mapController != null && _lineBounds != null) { try { final update = CameraUpdate.newLatLngBounds(_lineBounds!, 60.0); if (initialFit) { _mapController!.moveCamera(update); } else { _mapController!.animateCamera(update); } Log.d('BusMapView: Camera adjusted to bounds.'); } catch (e) { Log.e('Error adjusting map bounds', error: e); } } }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), // Use ThemeConstants
        child: _assetsLoaded
            ? GoogleMap(
          initialCameraPosition: const CameraPosition( target: AppConstants.initialMapCenter, zoom: 12, ), // Use AppConstants
          markers: _markers, polylines: _polylines, mapType: MapType.normal,
          myLocationButtonEnabled: false, myLocationEnabled: false,
          zoomControlsEnabled: false, zoomGesturesEnabled: true,
          scrollGesturesEnabled: true, tiltGesturesEnabled: false,
          rotateGesturesEnabled: true, compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: _onMapCreated,
        )
            : Container( color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), child: const Center(child: LoadingIndicator(message: 'Loading Map...'))),
      ),
    );
  }
}

// REMOVED Extension on AppConstants as it was defined locally within this file
// Define initialMapCenter directly in app_constants.dart