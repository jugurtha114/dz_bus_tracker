// lib/screens/passenger/bus_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../models/bus_model.dart';
import '../../providers/bus_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/error_handler.dart';
import '../../widgets/common/custom_card.dart';

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
  Bus? _busData;
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
      passengerProvider.trackBus(_busData!.id);
      AppRouter.navigateTo(context, AppRoutes.busTracking);
    }
  }

  void _rateDriver() {
    if (_busData != null && _busData!.driver != null) {
      AppRouter.navigateTo(
        context,
        AppRoutes.rateDriver,
        arguments: {
          'driverId': _busData!.driver,
          'busId': _busData!.id,
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
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading bus details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
        text: 'Try Again',
        onPressed: _loadBusDetails,
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
    final licensePlate = _busData!.licensePlate ?? 'N/A';
    final model = _busData!.model ?? 'N/A';
    final manufacturer = _busData!.manufacturer ?? 'N/A';
    final year = _busData!.year?.toString() ?? 'N/A';
    final capacity = _busData!.capacity?.toString() ?? 'N/A';
    final isAirConditioned = _busData!.isAirConditioned == true;
    final status = _busData!.status.toString();
    final isActive = _busData!.isActive == true;

    // Extract occupancy data
    int? occupancy;
    // Note: Real-time occupancy would come from tracking service
    // For now using placeholder data
    occupancy = null;

    // Calculate occupancy percentage
    final occupancyPercentage = occupancy != null && int.tryParse(capacity) != null
        ? (occupancy / int.parse(capacity) * 100).round()
        : null;

    // Check if the bus is being tracked
    final isTracking = _busData!.isActive;
    // Note: Real tracking status would come from tracking service

    // Get last update time
    String lastUpdateText = 'Not tracking';
    if (isTracking &&
        _busData!.currentLocation != null &&
        _busData!.currentLocation!.containsKey('timestamp')) {
      final timestamp = DateTime.tryParse(_busData!.currentLocation!['timestamp']);
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
              color: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Icon(
                  Icons.directions_bus,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bus basic info
          CustomCard(type: CardType.elevated, 
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          licensePlate,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
                        iconColor: isAirConditioned ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
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

          const SizedBox(height: 16),

          // Current tracking info
          CustomCard(type: CardType.elevated, 
            backgroundColor: isTracking ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Tracking',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isTracking ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  isTracking
                      ? 'This bus is currently being tracked.'
                      : 'This bus is not currently being tracked.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isTracking ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                if (isTracking) ...[
                  // Last update time
                  _buildInfoItem(
                    'Last Update',
                    lastUpdateText,
                    textColor: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 16),

                  // Current location - in a real app, you'd show a small map here
                  Text(
                    'Current Location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Occupancy information
                if (occupancy != null && occupancyPercentage != null) ...[
                  Text(
                    'Current Occupancy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isTracking ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Occupancy number
                      Text(
                        '$occupancy / $capacity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTracking ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 16, height: 40),

                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: occupancyPercentage / 100,
                            backgroundColor: isTracking
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            color: _getOccupancyColor(occupancyPercentage),
                            minHeight: 8,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8, height: 40),

                      // Percentage
                      Text(
                        '$occupancyPercentage%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTracking
                              ? _getOccupancyColor(occupancyPercentage)
                              : Theme.of(context).colorScheme.primary,
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
        color: isTracking ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Rate driver
          CustomCard(type: CardType.elevated, 
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16, height: 40),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate the Driver',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Share your experience with this bus driver',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
        type: ButtonType.outline,
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor != null ? textColor.withOpacity(0.1) : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8, height: 40),
            ],
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Theme.of(context).colorScheme.primary,
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
      return Theme.of(context).colorScheme.primary;
    } else if (percentage < 80) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}