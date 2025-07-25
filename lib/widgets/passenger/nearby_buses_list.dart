// lib/widgets/passenger/nearby_buses_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../providers/passenger_provider.dart';
import 'bus_list_item.dart';

class NearbyBusesList extends StatelessWidget {
  final List<Map<String, dynamic>> buses;
  final bool showEmpty;
  final String emptyMessage;
  final double maxHeight;

  const NearbyBusesList({
    Key? key,
    required this.buses,
    this.showEmpty = true,
    this.emptyMessage = 'No buses found nearby.',
    this.maxHeight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (buses.isEmpty && showEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: buses.length,
        itemBuilder: (context, index) {
          final bus = buses[index];

          return BusListItem(
            bus: bus,
            onTap: () => _onBusTap(context, bus),
          );
        },
      ),
    );
  }

  void _onBusTap(BuildContext context, Map<String, dynamic> bus) {
    final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

    // Set selected bus
    passengerProvider.trackBus(bus['id']);

    // Navigate to bus tracking screen
    AppRouter.navigateTo(context, AppRoutes.busTracking);
  }
}