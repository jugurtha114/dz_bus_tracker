// lib/screens/driver/passenger_counter_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
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
        _passengerCount = trackingProvider.currentTrip!.maxPassengers;
      }

      // Get bus capacity
      if (busProvider.selectedBus != null) {
        _capacity = busProvider.selectedBus!.capacity;
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
        SnackBar(
          content: Text('Maximum capacity reached'),
          backgroundColor: Theme.of(context).colorScheme.primary,
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
        busId: busProvider.selectedBus!.id,
        count: _passengerCount,
        // stopId: _selectedStopId, // stopId parameter not supported
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passenger count updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
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
              fillColor: Theme.of(context).colorScheme.primary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            child: ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return ListTile(
                  title: Text(
                    stop['name']!,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
      occupancyColor = Theme.of(context).colorScheme.primary;
    } else if (occupancyPercent < 85) {
      occupancyColor = Theme.of(context).colorScheme.primary;
    } else {
      occupancyColor = Theme.of(context).colorScheme.primary;
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
              CustomCard(type: CardType.elevated, 
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Column(
                  children: [
                    // Bus details
                    Row(
                      children: [
                        Icon(
                          Icons.directions_bus,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16, height: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bus ${busProvider.selectedBus!.licensePlate}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Capacity: $_capacity passengers',
                                style: Theme.of(context).textTheme.bodyLarge,
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trackingProvider.isTracking
                                ? Icons.gps_fixed
                                : Icons.gps_off,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8, height: 40),
                          Text(
                            trackingProvider.isTracking
                                ? 'Tracking Active'
                                : 'Tracking Inactive',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
              CustomCard(type: CardType.elevated, 
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Bus Selected',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please select a bus on the home screen first.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Passenger count display
            CustomCard(type: CardType.elevated, 
              child: Column(
                children: [
                  Text(
                    'Current Passengers',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: occupancyColor,
                            fontSize: 64,
                          ),
                        ),
                        const SizedBox(width: 8, height: 40),
                        Text(
                          '/ $_capacity',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Occupancy percentage
                  Text(
                    'Occupancy: $occupancyPercent%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _buildCounterButton(
                        icon: Icons.exposure_neg_1,
                        onPressed: () => _decrement(1),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _buildCounterButton(
                        icon: Icons.exposure_plus_1,
                        onPressed: () => _increment(1),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _buildCounterButton(
                        icon: Icons.exposure_plus_2,
                        onPressed: () => _increment(2),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stop selection
            CustomCard(type: CardType.elevated, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Stop',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

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
                      fillColor: Theme.of(context).colorScheme.primary,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: _showStopSelectionDialog,
                      ),
                    ),
                    onTap: _showStopSelectionDialog,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Optional: Select the stop where you are counting passengers',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Update button
            CustomButton(
              text: 'Update Passenger Count',
              onPressed: busProvider.selectedBus != null
                  ? _updateCount
                  : _showNoBusSelectedDialog,
              isLoading: _isLoading,
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
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}