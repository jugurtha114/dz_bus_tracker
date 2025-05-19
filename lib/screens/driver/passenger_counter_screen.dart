// lib/screens/driver/passenger_counter_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glassy_container.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/error_handler.dart';

class PassengerCounterScreen extends StatefulWidget {
  const PassengerCounterScreen({Key? key}) : super(key: key);

  @override
  State<PassengerCounterScreen> createState() => _PassengerCounterScreenState();
}

class _PassengerCounterScreenState extends State<PassengerCounterScreen> {
  int _passengerCount = 0;
  int _capacity = 0;
  bool _isLoading = false;
  final _stopNameController = TextEditingController();
  String? _selectedStopId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _stopNameController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
      final busProvider = Provider.of<BusProvider>(context, listen: false);

      // Get current passenger count if tracking
      if (trackingProvider.isTracking && trackingProvider.currentTrip != null) {
        _passengerCount = trackingProvider.currentTrip!['passenger_count'] != null
            ? int.tryParse(trackingProvider.currentTrip!['passenger_count'].toString()) ?? 0
            : 0;
      }

      // Get bus capacity
      if (busProvider.selectedBus != null) {
        _capacity = busProvider.selectedBus!['capacity'] != null
            ? int.tryParse(busProvider.selectedBus!['capacity'].toString()) ?? 0
            : 0;
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

  void _increment(int value) {
    if (_passengerCount + value <= _capacity) {
      setState(() {
        _passengerCount += value;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum capacity reached'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _decrement(int value) {
    if (_passengerCount - value >= 0) {
      setState(() {
        _passengerCount -= value;
      });
    } else {
      setState(() {
        _passengerCount = 0;
      });
    }
  }

  Future<void> _updateCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
      final busProvider = Provider.of<BusProvider>(context, listen: false);

      if (busProvider.selectedBus == null) {
        _showNoBusSelectedDialog();
        return;
      }

      await trackingProvider.updatePassengers(
        busId: busProvider.selectedBus!['id'],
        count: _passengerCount,
        stopId: _selectedStopId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passenger count updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
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

  void _showNoBusSelectedDialog() {
    DialogHelper.showInfoDialog(
      context,
      title: 'No Bus Selected',
      message: 'Please select a bus on the home screen first.',
    );
  }

  void _showStopSelectionDialog() {
    // In a real app, you would fetch stops from the API
    final stops = [
      {'id': 'stop1', 'name': 'Central Station'},
      {'id': 'stop2', 'name': 'Market Square'},
      {'id': 'stop3', 'name': 'University'},
      {'id': 'stop4', 'name': 'Hospital'},
      {'id': 'stop5', 'name': 'Airport'},
    ];

    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Stop',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Stop search field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search stops',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return ListTile(
                  title: Text(
                    stop['name']!,
                    style: TextStyle(color: AppColors.white),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedStopId = stop['id'];
                      _stopNameController.text = stop['name']!;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);
    final busProvider = Provider.of<BusProvider>(context);

    // Calculate occupancy percentage
    final occupancyPercent = _capacity > 0 ? (_passengerCount / _capacity * 100).round() : 0;

    // Determine color based on occupancy
    Color occupancyColor;
    if (occupancyPercent < 50) {
      occupancyColor = AppColors.success;
    } else if (occupancyPercent < 85) {
      occupancyColor = AppColors.warning;
    } else {
      occupancyColor = AppColors.error;
    }

    return Scaffold(
      appBar: const DzAppBar(
        title: 'Passenger Counter',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bus info card
            if (busProvider.selectedBus != null)
              GlassyContainer(
                color: AppColors.primary.withOpacity(0.1),
                child: Column(
                  children: [
                    // Bus details
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bus ${busProvider.selectedBus!['license_plate']}',
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Capacity: $_capacity passengers',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tracking status
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: trackingProvider.isTracking
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trackingProvider.isTracking
                                ? Icons.gps_fixed
                                : Icons.gps_off,
                            color: AppColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trackingProvider.isTracking
                                ? 'Tracking Active'
                                : 'Tracking Inactive',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              GlassyContainer(
                color: AppColors.warning.withOpacity(0.1),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Bus Selected',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please select a bus on the home screen first.',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Passenger count display
            GlassyContainer(
              child: Column(
                children: [
                  Text(
                    'Current Passengers',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Counter display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: occupancyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: occupancyColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_passengerCount',
                          style: AppTextStyles.h1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: occupancyColor,
                            fontSize: 64,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ $_capacity',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Occupancy percentage
                  Text(
                    'Occupancy: $occupancyPercent%',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: occupancyColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Counter buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCounterButton(
                        icon: Icons.exposure_minus_2,
                        onPressed: () => _decrement(2),
                        color: AppColors.error,
                      ),
                      _buildCounterButton(
                        icon: Icons.exposure_neg_1,
                        onPressed: () => _decrement(1),
                        color: AppColors.error,
                      ),
                      _buildCounterButton(
                        icon: Icons.exposure_plus_1,
                        onPressed: () => _increment(1),
                        color: AppColors.success,
                      ),
                      _buildCounterButton(
                        icon: Icons.exposure_plus_2,
                        onPressed: () => _increment(2),
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stop selection
            GlassyContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Stop',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stop selection field
                  TextField(
                    controller: _stopNameController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select a stop',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: _showStopSelectionDialog,
                      ),
                    ),
                    onTap: _showStopSelectionDialog,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Optional: Select the stop where you are counting passengers',
                    style: AppTextStyles.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Update button
            CustomButton(
              text: 'Update Passenger Count',
              onPressed: busProvider.selectedBus != null
                  ? _updateCount
                  : _showNoBusSelectedDialog,
              isLoading: _isLoading,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}