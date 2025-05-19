// lib/screens/passenger/bus_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/bus_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/error_handler.dart';

class BusDetailsScreen extends StatefulWidget {
  final String busId;

  const BusDetailsScreen({
    Key? key,
    required this.busId,
  }) : super(key: key);

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _busData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBusDetails();
  }

  Future<void> _loadBusDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      await busProvider.fetchBusById(widget.busId);

      setState(() {
        _busData = busProvider.selectedBus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandler.handleError(e);
        _isLoading = false;
      });
    }
  }

  void _trackBus() {
    if (_busData != null) {
      final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
      passengerProvider.trackBus(_busData!['id']);
      AppRouter.navigateTo(context, AppRoutes.busTracking);
    }
  }

  void _rateDriver() {
    if (_busData != null && _busData!.containsKey('driver')) {
      AppRouter.navigateTo(
        context,
        AppRoutes.rateDriver,
        arguments: {
          'driverId': _busData!['driver'],
          'busId': _busData!['id'],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DzAppBar(
        title: 'Bus Details',
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading bus details',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Try Again',
              onPressed: _loadBusDetails,
              icon: Icons.refresh,
            ),
          ],
        ),
      )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_busData == null) {
      return const Center(
        child: Text('No bus details available'),
      );
    }

    // Extract bus data
    final licensePlate = _busData!['license_plate'] ?? 'N/A';
    final model = _busData!['model'] ?? 'N/A';
    final manufacturer = _busData!['manufacturer'] ?? 'N/A';
    final year = _busData!['year']?.toString() ?? 'N/A';
    final capacity = _busData!['capacity']?.toString() ?? 'N/A';
    final isAirConditioned = _busData!['is_air_conditioned'] == true;
    final status = _busData!['status'] ?? 'N/A';
    final isActive = _busData!['is_active'] == true;

    // Extract occupancy data
    int? occupancy;
    if (_busData!.containsKey('current_location') &&
        _busData!['current_location'] != null &&
        _busData!['current_location'].containsKey('passenger_count')) {
      occupancy = _busData!['current_location']['passenger_count'];
    }

    // Calculate occupancy percentage
    final occupancyPercentage = occupancy != null && int.tryParse(capacity) != null
        ? (occupancy / int.parse(capacity) * 100).round()
        : null;

    // Check if the bus is being tracked
    final isTracking = _busData!.containsKey('current_location') &&
        _busData!['current_location'] != null;

    // Get last update time
    String lastUpdateText = 'Not tracking';
    if (isTracking &&
        _busData!['current_location'].containsKey('timestamp')) {
      final timestamp = DateTime.tryParse(_busData!['current_location']['timestamp']);
      if (timestamp != null) {
        lastUpdateText = 'Updated ${timeago.format(timestamp)}';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bus Image (placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              color: AppColors.lightGrey,
              child: Center(
                child: Icon(
                  Icons.directions_bus,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bus basic info
          GlassyContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // License plate & status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'License Plate',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        Text(
                          licensePlate,
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Model & manufacturer
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Model', model),
                    ),
                    Expanded(
                      child: _buildInfoItem('Manufacturer', manufacturer),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Year & capacity
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Year', year),
                    ),
                    Expanded(
                      child: _buildInfoItem('Capacity', '$capacity passengers'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Air conditioning & status
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Air Conditioning',
                        isAirConditioned ? 'Available' : 'Not available',
                        icon: isAirConditioned ? Icons.ac_unit : Icons.highlight_off,
                        iconColor: isAirConditioned ? AppColors.info : AppColors.mediumGrey,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Status',
                        status.toString().toUpperCase(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Current tracking info
          GlassyContainer(
            color: isTracking ? AppColors.glassWhite : AppColors.glassDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Tracking',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isTracking ? AppColors.darkGrey : AppColors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isTracking
                      ? 'This bus is currently being tracked.'
                      : 'This bus is not currently being tracked.',
                  style: AppTextStyles.body.copyWith(
                    color: isTracking ? AppColors.darkGrey : AppColors.white,
                  ),
                ),

                const SizedBox(height: 16),

                if (isTracking) ...[
                  // Last update time
                  _buildInfoItem(
                    'Last Update',
                    lastUpdateText,
                    textColor: AppColors.darkGrey,
                  ),

                  const SizedBox(height: 16),

                  // Current location - in a real app, you'd show a small map here
                  Text(
                    'Current Location',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 40,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Occupancy information
                if (occupancy != null && occupancyPercentage != null) ...[
                  Text(
                    'Current Occupancy',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isTracking ? AppColors.mediumGrey : AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Occupancy number
                      Text(
                        '$occupancy / $capacity',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTracking ? AppColors.darkGrey : AppColors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: occupancyPercentage / 100,
                            backgroundColor: isTracking
                                ? AppColors.lightGrey
                                : AppColors.white.withOpacity(0.3),
                            color: _getOccupancyColor(occupancyPercentage),
                            minHeight: 8,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Percentage
                      Text(
                        '$occupancyPercentage%',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTracking
                              ? _getOccupancyColor(occupancyPercentage)
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Track button
                Center(
                  child: CustomButton(
                    text: isTracking ? 'View Live Tracking' : 'Track This Bus',
                    onPressed: _trackBus,
                    color: isTracking ? AppColors.success : AppColors.primary,
                    icon: Icons.location_on,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rate driver
          GlassyContainer(
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate the Driver',
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Share your experience with this bus driver',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomButton(
                  text: 'Rate Driver',
                  onPressed: _rateDriver,
                  type: ButtonType.outlined,
                  icon: Icons.star,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label,
      String value, {
        IconData? icon,
        Color? iconColor,
        Color? textColor,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor != null ? textColor.withOpacity(0.6) : AppColors.mediumGrey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: iconColor ?? AppColors.primary,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.darkGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getOccupancyColor(int percentage) {
    if (percentage < 50) {
      return AppColors.success;
    } else if (percentage < 80) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}