// lib/screens/driver/bus_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/bus_provider.dart';
import '../../providers/driver_provider.dart';
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
      await busProvider.fetchBuses(driverId: driverProvider.driverId);
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
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
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

      await busProvider.registerBus(
        licensePlate: busData['license_plate'],
        driverId: driverProvider.driverId,
        model: busData['model'],
        manufacturer: busData['manufacturer'],
        year: int.parse(busData['year']),
        capacity: int.parse(busData['capacity']),
        isAirConditioned: busData['is_air_conditioned'] ?? false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus added successfully'),
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

  void _showEditBusDialog(Map<String, dynamic> bus) {
    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Bus',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BusForm(
            driverId: bus['driver'],
            initialData: bus,
            isEditing: true,
            onSaved: (busData) async {
              Navigator.pop(context);
              await _updateBus(bus['id'], busData);
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

      await busProvider.updateBus(
        busId: busId,
        licensePlate: busData['license_plate'],
        model: busData['model'],
        manufacturer: busData['manufacturer'],
        year: int.parse(busData['year']),
        capacity: int.parse(busData['capacity']),
        isAirConditioned: busData['is_air_conditioned'] ?? false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus updated successfully'),
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

  void _selectBus(Map<String, dynamic> bus) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    busProvider.selectBus(bus);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bus ${bus['license_plate']} selected'),
        backgroundColor: AppColors.success,
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
        backgroundColor: AppColors.primary,
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
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No buses registered yet',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first bus to start tracking',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Bus',
            onPressed: _showAddBusDialog,
            icon: Icons.add,
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
        final isSelected = selectedBus != null && selectedBus['id'] == bus['id'];

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