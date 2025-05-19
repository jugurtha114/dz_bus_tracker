// lib/widgets/map/route_polyline.dart

import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme_config.dart';

class RoutePolyline {
  // Create a polyline from a list of coordinates
// Alternative implementation for createRoutePolyline
  static Polyline createRoutePolyline({
    required String id,
    required List<LatLng> points,
    Color color = AppColors.primary,
    int width = 5,
    bool geodesic = true,
    JointType jointType = JointType.round,
    bool visible = true,
    List<PatternItem>? patterns,
    int zIndex = 0,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      geodesic: geodesic,
      jointType: jointType,
      visible: visible,
      patterns: patterns ?? [], // Provide empty list if patterns is null
      zIndex: zIndex,
    );
  }

  // Create a dashed polyline
  static Polyline createDashedRoutePolyline({
    required String id,
    required List<LatLng> points,
    Color color = AppColors.primary,
    int width = 5,
    bool geodesic = true,
    JointType jointType = JointType.round,
    bool visible = true,
    int zIndex = 0,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      geodesic: geodesic,
      jointType: jointType,
      visible: visible,
      patterns: [
        PatternItem.dot,
        PatternItem.gap(10),
      ],
      zIndex: zIndex,
    );
  }

  // Create a polyline with custom pattern
  static Polyline createPatternedRoutePolyline({
    required String id,
    required List<LatLng> points,
    Color color = AppColors.primary,
    int width = 5,
    bool geodesic = true,
    JointType jointType = JointType.round,
    bool visible = true,
    required List<PatternItem> patterns,
    int zIndex = 0,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      geodesic: geodesic,
      jointType: jointType,
      visible: visible,
      patterns: patterns,
      zIndex: zIndex,
    );
  }

  // Create highlighted route with glow effect (using multiple polylines)
  static Set<Polyline> createHighlightedRoute({
    required String id,
    required List<LatLng> points,
    Color color = AppColors.primary,
    Color glowColor = Colors.white,
    int mainWidth = 5,
    int glowWidth = 9,
    bool geodesic = true,
    JointType jointType = JointType.round,
    bool visible = true,
  }) {
    return {
      // Glow effect (wider line in the back)
      Polyline(
        polylineId: PolylineId('${id}_glow'),
        points: points,
        color: glowColor,
        width: glowWidth,
        geodesic: geodesic,
        jointType: jointType,
        visible: visible,
        zIndex: 0,
      ),
      // Main route line on top
      Polyline(
        polylineId: PolylineId(id),
        points: points,
        color: color,
        width: mainWidth,
        geodesic: geodesic,
        jointType: jointType,
        visible: visible,
        zIndex: 1,
      ),
    };
  }

  // Create a gradient-like route using multiple polylines with different colors
  static Set<Polyline> createGradientRoute({
    required String id,
    required List<LatLng> points,
    required List<Color> colors,
    int width = 5,
    bool geodesic = true,
    JointType jointType = JointType.round,
    bool visible = true,
  }) {
    if (points.length <= 1 || colors.isEmpty) {
      return {};
    }

    final Set<Polyline> polylines = {};
    final segments = points.length - 1;
    final colorSegments = colors.length - 1;

    for (int i = 0; i < segments; i++) {
      // Calculate color index based on segment position
      final colorIndex = (i * colorSegments / segments).floor();
      final color = colors[colorIndex];

      polylines.add(
        Polyline(
          polylineId: PolylineId('${id}_segment_$i'),
          points: [points[i], points[i + 1]],
          color: color,
          width: width,
          geodesic: geodesic,
          jointType: jointType,
          visible: visible,
          zIndex: 0,
        ),
      );
    }

    return polylines;
  }

  // Create route with direction arrows
  static Set<Marker> createRouteArrows({
    required String id,
    required List<LatLng> points,
    Color color = AppColors.primary,
    int arrowCount = 3, // Number of arrows to show along the route
    double arrowSize = 20.0,
  }) {
    if (points.length <= 1 || arrowCount <= 0) {
      return {};
    }

    final Set<Marker> markers = {};

    // Calculate intervals for arrow placement
    final routeLength = points.length;
    final interval = (routeLength - 1) / (arrowCount + 1);

    for (int i = 1; i <= arrowCount; i++) {
      final index = (i * interval).round();
      if (index >= routeLength - 1) continue;

      // Get current and next point for direction
      final LatLng current = points[index];
      final LatLng next = points[index + 1];

      // Calculate bearing for arrow rotation
      final bearing = _calculateBearing(current.latitude, current.longitude,
          next.latitude, next.longitude);

      // Create custom arrow marker
      final marker = Marker(
        markerId: MarkerId('${id}_arrow_$i'),
        position: current,
        icon: BitmapDescriptor.defaultMarker, // In real app, use custom arrow icon
        rotation: bearing.toDouble(),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      );

      markers.add(marker);
    }

    return markers;
  }

  // Calculate bearing between two coordinates
  static double _calculateBearing(double startLat, double startLng, double endLat, double endLng) {
    startLat = _toRadians(startLat);
    startLng = _toRadians(startLng);
    endLat = _toRadians(endLat);
    endLng = _toRadians(endLng);

    final double y = Math.sin(endLng - startLng) * Math.cos(endLat);
    final double x = Math.cos(startLat) * Math.sin(endLat) -
        Math.sin(startLat) * Math.cos(endLat) * Math.cos(endLng - startLng);
    final double bearing = Math.atan2(y, x);

    return (_toDegrees(bearing) + 360) % 360;
  }

  // Convert degrees to radians
  static double _toRadians(double degree) {
    return degree * Math.pi / 180;
  }

  // Convert radians to degrees
  static double _toDegrees(double radian) {
    return radian * 180 / Math.pi;
  }
}