// lib/screens/passenger/stop_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/stop_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/passenger/stop_list_item.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/permission_helper.dart';

class StopSearchScreen extends StatefulWidget {
  const StopSearchScreen({Key? key}) : super(key: key);

  @override
  State<StopSearchScreen> createState() => _StopSearchScreenState();
}

class _StopSearchScreenState extends State<StopSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  bool _showNearbyOnly = false;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stopProvider = Provider.of<StopProvider>(context, listen: false);
      await stopProvider.fetchStops(isActive: true);
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

  Future<void> _findNearbyStops() async {
    final permissionGranted = await PermissionHelper.requestLocation(context);

    if (!permissionGranted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final stopProvider = Provider.of<StopProvider>(context, listen: false);

      // Get current location
      await locationProvider.getCurrentLocation();

      if (locationProvider.currentLocation != null) {
        // Find nearby stops
        await stopProvider.fetchNearbyStops(
          latitude: locationProvider.latitude,
          longitude: locationProvider.longitude,
        );

        setState(() {
          _showNearbyOnly = true;
        });
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, dynamic>> _getFilteredStops() {
    final stopProvider = Provider.of<StopProvider>(context);

    // Choose which list to filter (all stops or nearby stops)
    final stops = _showNearbyOnly ? stopProvider.nearbyStops : stopProvider.stops;

    if (_searchQuery.isEmpty) {
      return stops;
    }

    return stops.where((stop) {
      final name = stop['name']?.toString().toLowerCase() ?? '';
      final address = stop['address']?.toString().toLowerCase() ?? '';
      final description = stop['description']?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          address.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();
  }

  void _onStopSelected(Map<String, dynamic> stop) {
    final stopProvider = Provider.of<StopProvider>(context, listen: false);
    stopProvider.selectStop(stop);
    AppRouter.navigateTo(context, AppRoutes.stopDetails);
  }

  @override
  Widget build(BuildContext context) {
    final filteredStops = _getFilteredStops();

    return Scaffold(
      appBar: const DzAppBar(
        title: 'Find Stops',
      ),
      body: Column(
        children: [
          // Near me button and search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Near me button
                CustomButton(
                  text: 'Find Stops Near Me',
                  onPressed: _findNearbyStops,
                  icon: Icons.near_me,
                  type: _showNearbyOnly ? ButtonType.filled : ButtonType.outlined,
                ),

                const SizedBox(height: 16),

                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by stop name or address',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),

          // List type indicator
          if (_showNearbyOnly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Showing nearby stops',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showNearbyOnly = false;
                      });
                    },
                    child: const Text('Show All'),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
              child: LoadingIndicator(),
            )
                : filteredStops.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No stops available'
                        : 'No stops matching "$_searchQuery"',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredStops.length,
              itemBuilder: (context, index) {
                final stop = filteredStops[index];

                return StopListItem(
                  stop: stop,
                  onTap: () => _onStopSelected(stop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}