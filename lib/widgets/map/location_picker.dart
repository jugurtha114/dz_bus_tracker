// lib/widgets/map/location_picker.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../core/constants/app_constants.dart';
import '../../helpers/permission_helper.dart';

class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final void Function(LatLng) onLocationPicked;
  final String title;
  final String confirmButtonText;
  final bool showSearchBar;
  final String searchHint;

  const LocationPickerWidget({
    Key? key,
    this.initialPosition,
    required this.onLocationPicked,
    this.title = 'Select Location',
    this.confirmButtonText = 'Confirm Location',
    this.showSearchBar = true,
    this.searchHint = 'Search for a location',
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late GoogleMapController _mapController;
  LatLng _selectedPosition = LatLng(
    AppConstants.defaultLatitude,
    AppConstants.defaultLongitude,
  );
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedPosition = widget.initialPosition!;
      _updateMarker();
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarker();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permissionGranted = await PermissionHelper.requestLocation(context);

      if (permissionGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _selectedPosition = LatLng(position.latitude, position.longitude);
        });

        _updateMarker();
        _animateToPosition(_selectedPosition);
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _updateMarker();
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedPosition = newPosition;
            });
          },
        ),
      };
    });
  }

  void _animateToPosition(LatLng position) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: AppConfig.defaultZoomLevel,
        ),
      ),
    );
  }

  void _search() {
    // In a real app, you would use a geocoding service to search for locations
    // For now, we'll just show a message
    if (_searchQuery.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for "$_searchQuery"...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmLocation() {
    widget.onLocationPicked(_selectedPosition);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: AppConfig.defaultZoomLevel,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Search bar
          if (widget.showSearchBar)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _search(),
                ),
              ),
            ),

          // Current location button
          Positioned(
            top: widget.showSearchBar ? 80 : 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
            ),
          ),

          // Selected location info
          Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Latitude: ${_selectedPosition.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Longitude: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap on the map to change the location',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.confirmButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}