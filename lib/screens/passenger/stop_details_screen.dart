// lib/screens/passenger/stop_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/stop_provider.dart';
import '../../providers/line_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/map/map_widget.dart';
import '../../helpers/error_handler.dart';

class StopDetailsScreen extends StatefulWidget {
  const StopDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StopDetailsScreen> createState() => _StopDetailsScreenState();
}

class _StopDetailsScreenState extends State<StopDetailsScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _lines = [];

  @override
  void initState() {
    super.initState();
    _loadStopDetails();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadStopDetails() async {
    final stopProvider = Provider.of<StopProvider>(context, listen: false);

    if (stopProvider.selectedStop == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Load lines that pass through this stop
      final stopId = stopProvider.selectedStop!['id'];
      final lineProvider = Provider.of<LineProvider>(context, listen: false);
      await lineProvider.fetchLines(stopId: stopId);

      setState(() {
        _lines = lineProvider.lines;
      });
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _reportWaitingPassengers() {
    final passengerCount = TextEditingController();
    String? selectedLineId;

    // Show dialog to report waiting passengers
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Report Waiting Passengers'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Passenger count input
                TextField(
                  controller: passengerCount,
                  decoration: const InputDecoration(
                    labelText: 'Number of passengers',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // Line selection (optional)
                if (_lines.isNotEmpty) ...[
                  const Text('Select Line (Optional)'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Select a line'),
                    value: selectedLineId,
                    items: _lines.map((line) {
                      return DropdownMenuItem<String>(
                        value: line['id'],
                        child: Text(
                          'Line ${line['code']}',
                          style: TextStyle(
                            color: line['color'] != null
                                ? Color(int.parse('0xFF${line['color'].toString().replaceAll('#', '')}'))
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLineId = value;
                      });
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate input
                  final count = int.tryParse(passengerCount.text);
                  if (count == null || count <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid number'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }

                  // Submit report
                  _submitWaitingReport(count, selectedLineId);
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitWaitingReport(int count, String? lineId) async {
    final stopProvider = Provider.of<StopProvider>(context, listen: false);
    final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

    if (stopProvider.selectedStop == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await passengerProvider.reportWaitingPassengers(
        stopId: stopProvider.selectedStop!['id'],
        count: count,
        lineId: lineId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
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

  void _viewLine(Map<String, dynamic> line) {
    final lineProvider = Provider.of<LineProvider>(context, listen: false);
    lineProvider.setSelectedLine(line);
    AppRouter.navigateTo(context, AppRoutes.lineDetails);
  }

  @override
  Widget build(BuildContext context) {
    final stopProvider = Provider.of<StopProvider>(context);
    final stop = stopProvider.selectedStop;

    if (stop == null) {
      // Return early if no stop is selected
      return Scaffold(
        appBar: const DzAppBar(
          title: 'Stop Details',
        ),
        body: const Center(
          child: Text('No stop selected'),
        ),
      );
    }

    // Extract stop details
    final name = stop['name'] ?? 'Unknown Stop';
    final address = stop['address'] ?? '';
    final description = stop['description'] ?? '';
    double? latitude = 0;
    double? longitude = 0;

    if (stop['latitude'] != null) {
      latitude = double.tryParse(stop['latitude'].toString()) ?? 0;
    }

    if (stop['longitude'] != null) {
      longitude = double.tryParse(stop['longitude'].toString()) ?? 0;
    }

    return Scaffold(
      appBar: DzAppBar(
        title: 'Stop Details',
      ),
      body: Stack(
        children: [
          // Map with stop marker
          MapWidget(
            initialPosition: LatLng(latitude, longitude),
            onMapCreated: _onMapCreated,
            markers: {
              Marker(
                markerId: MarkerId('stop_${stop['id']}'),
                position: LatLng(latitude, longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(
                  title: name,
                  snippet: address,
                ),
              ),
            },
          ),

          // Bottom panel with stop info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassyContainer(
              borderRadius: 24,
              color: AppColors.glassDark,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stop name
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Address
                  if (address.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 4),
                      child: Text(
                        address,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                    ),

                  // Description
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 8),
                      child: Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Lines that pass through this stop
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LoadingIndicator(
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    )
                  else if (_lines.isEmpty)
                    Text(
                      'No lines pass through this stop',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lines:',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _lines.length,
                            itemBuilder: (context, index) {
                              final line = _lines[index];
                              final code = line['code'] ?? '';
                              final color = line['color'] != null
                                  ? Color(int.parse('0xFF${line['color'].toString().replaceAll('#', '')}'))
                                  : AppColors.primary;

                              return GestureDetector(
                                onTap: () => _viewLine(line),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Line $code',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Report waiting passengers button
                  CustomButton(
                    text: 'Report Waiting Passengers',
                    onPressed: _reportWaitingPassengers,
                    icon: Icons.people,
                    color: AppColors.white,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            const FullScreenLoading(),
        ],
      ),
    );
  }
}