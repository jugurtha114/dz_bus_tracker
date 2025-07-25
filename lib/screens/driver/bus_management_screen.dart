// lib/screens/driver/bus_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/bus_provider.dart';
import '../../providers/driver_provider.dart';
import '../../models/api_response_models.dart';
import '../../models/bus_model.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/error_handler.dart';
import '../../widgets/driver/bus_card.dart';
import '../../widgets/driver/widgets/bus_form.dart';


class BusManagementScreen extends StatefulWidget {
  const BusManagementScreen({Key? key}) : super(key: key);

  @override
  State<BusManagementScreen> createState() => _BusManagementScreenState();
}

class _BusManagementScreenState extends State<BusManagementScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final busProvider = Provider.of<BusProvider>(context, listen: false);

      await driverProvider.fetchProfile();
      final queryParams = BusQueryParameters(driverId: driverProvider.driverId);
      await busProvider.fetchBuses(queryParams: queryParams);
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

  void _showAddBusDialog() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add New Bus',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BusForm(
            driverId: driverProvider.driverId,
            onSaved: (busData) async {
              Navigator.pop(context);
              await _addBus(busData);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addBus(Map<String, dynamic> busData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final busProvider = Provider.of<BusProvider>(context, listen: false);
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);

      final request = BusCreateRequest(
        licensePlate: busData['license_plate'],
        driver: driverProvider.driverId,
        model: busData['model'],
        manufacturer: busData['manufacturer'],
        year: int.parse(busData['year']),
        capacity: int.parse(busData['capacity']),
        isAirConditioned: busData['is_air_conditioned'] ?? false,
      );
      
      await busProvider.registerBus(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bus added successfully'),
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

  void _showEditBusDialog(Bus bus) {
    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Bus',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BusForm(
            driverId: bus.driver,
            initialData: bus.toMap(),  // Convert bus model to map for the form
            isEditing: true,
            onSaved: (busData) async {
              Navigator.pop(context);
              await _updateBus(bus.id, busData);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateBus(String busId, Map<String, dynamic> busData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final busProvider = Provider.of<BusProvider>(context, listen: false);

      final request = BusUpdateRequest(
        licensePlate: busData['license_plate'],
        model: busData['model'],
        manufacturer: busData['manufacturer'],
        year: int.parse(busData['year']),
        capacity: int.parse(busData['capacity']),
        isAirConditioned: busData['is_air_conditioned'] ?? false,
      );
      
      await busProvider.updateBus(busId, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bus updated successfully'),
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

  void _selectBus(Bus bus) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    busProvider.selectBus(bus);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bus ${bus.licensePlate} selected'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: const DzAppBar(
        title: 'Bus Management',
      ),
      body: _isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : busProvider.buses.isEmpty
          ? _buildEmptyState()
          : _buildBusList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBusDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No buses registered yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add your first bus to start tracking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
        text: 'Add Bus',
        onPressed: _showAddBusDialog,
        ),
        ],
      ),
    );
  }

  Widget _buildBusList() {
    final busProvider = Provider.of<BusProvider>(context);
    final buses = busProvider.buses;
    final selectedBus = busProvider.selectedBus;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buses.length,
      itemBuilder: (context, index) {
        final bus = buses[index];
        final isSelected = selectedBus != null && selectedBus.id == bus.id;

        return BusCard(
          bus: bus,
          isSelected: isSelected,
          onTap: () => _selectBus(bus),
          onEdit: () => _showEditBusDialog(bus),
        );
      },
    );
  }
}