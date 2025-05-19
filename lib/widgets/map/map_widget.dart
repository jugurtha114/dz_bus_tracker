// lib/widgets/map/map_widget.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../core/constants/app_constants.dart';

class MapWidget extends StatelessWidget {
  final LatLng? initialPosition;
  final void Function(GoogleMapController)? onMapCreated;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Set<Circle>? circles;
  final MapType mapType;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool trafficEnabled;
  final double initialZoom;
  final CameraTargetBounds? cameraTargetBounds;
  final MinMaxZoomPreference? minMaxZoomPreference;
  final EdgeInsets padding;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool tiltGesturesEnabled;
  final bool zoomGesturesEnabled;
  final bool indoorViewEnabled;
  final bool compassEnabled;
  final void Function(CameraPosition)? onCameraMove;
  final void Function(CameraPosition)? onCameraIdle;
  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;

  const MapWidget({
    Key? key,
    this.initialPosition,
    this.onMapCreated,
    this.markers,
    this.polylines,
    this.circles,
    this.mapType = MapType.normal,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.trafficEnabled = false,
    this.initialZoom = 14.0,
    this.cameraTargetBounds,
    this.minMaxZoomPreference,
    this.padding = EdgeInsets.zero,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.indoorViewEnabled = true,
    this.compassEnabled = true,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition ??
            LatLng(
              AppConstants.defaultLatitude,
              AppConstants.defaultLongitude,
            ),
        zoom: initialZoom,
      ),
      onMapCreated: onMapCreated,
      markers: markers ?? {},
      polylines: polylines ?? {},
      circles: circles ?? {},
      mapType: mapType,
      myLocationEnabled: myLocationEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
      trafficEnabled: trafficEnabled,
      cameraTargetBounds: cameraTargetBounds ?? CameraTargetBounds.unbounded,
      minMaxZoomPreference: minMaxZoomPreference ?? MinMaxZoomPreference.unbounded,
      padding: padding,
      rotateGesturesEnabled: rotateGesturesEnabled,
      scrollGesturesEnabled: scrollGesturesEnabled,
      tiltGesturesEnabled: tiltGesturesEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled,
      indoorViewEnabled: indoorViewEnabled,
      compassEnabled: compassEnabled,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}