// lib/widgets/bus/bus_form.dart

import 'package:flutter/material.dart';
import '../../models/bus_model.dart';
import '../common/enhanced_text_field.dart';
import '../common/enhanced_custom_button.dart';
import '../common/enhanced_card.dart';

/// Modular bus form component for creating and editing buses
class BusForm extends StatefulWidget {
  final Bus? initialBus;
  final List<Map<String, dynamic>> availableDrivers;
  final Function(BusCreateRequest) onSubmit;
  final Function(String, BusUpdateRequest)? onUpdate;
  final VoidCallback? onCancel;
  final bool isEditing;
  final bool isLoading;

  const BusForm({
    Key? key,
    this.initialBus,
    required this.availableDrivers,
    required this.onSubmit,
    this.onUpdate,
    this.onCancel,
    this.isEditing = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<BusForm> createState() => _BusFormState();
}

class _BusFormState extends State<BusForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _licensePlateController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _capacityController;
  
  String? _selectedDriverId;
  bool _isAirConditioned = false;
  BusStatus _selectedStatus = BusStatus.inactive;

  @override
  void initState() {
    super.initState();
    
    _licensePlateController = TextEditingController(
      text: widget.initialBus?.licensePlate ?? '',
    );
    _manufacturerController = TextEditingController(
      text: widget.initialBus?.manufacturer ?? '',
    );
    _modelController = TextEditingController(
      text: widget.initialBus?.model ?? '',
    );
    _yearController = TextEditingController(
      text: widget.initialBus?.year.toString() ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.initialBus?.capacity.toString() ?? '',
    );
    
    if (widget.initialBus != null) {
      _selectedDriverId = widget.initialBus!.driverId;
      _isAirConditioned = widget.initialBus!.isAirConditioned;
      _selectedStatus = widget.initialBus!.status;
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return EnhancedCard.elevated(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.isEditing ? 'Edit Bus' : 'Add New Bus',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 24),
            
            // License Plate
            EnhancedTextField(
              label: 'License Plate',
              controller: _licensePlateController,
              required: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'License plate is required';
                }
                if (value!.length < 3) {
                  return 'License plate must be at least 3 characters';
                }
                return null;
              },
              prefixIcon: Icon(Icons.confirmation_number),
            ),
            
            SizedBox(height: 16),
            
            // Manufacturer and Model
            Row(
              children: [
                Expanded(
                  child: EnhancedTextField(
                    label: 'Manufacturer',
                    controller: _manufacturerController,
                    required: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Manufacturer is required';
                      }
                      return null;
                    },
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: EnhancedTextField(
                    label: 'Model',
                    controller: _modelController,
                    required: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Model is required';
                      }
                      return null;
                    },
                    prefixIcon: Icon(Icons.directions_bus),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Year and Capacity
            Row(
              children: [
                Expanded(
                  child: EnhancedTextField(
                    label: 'Year',
                    controller: _yearController,
                    type: TextFieldType.number,
                    required: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Year is required';
                      }
                      final year = int.tryParse(value!);
                      if (year == null) {
                        return 'Please enter a valid year';
                      }
                      final currentYear = DateTime.now().year;
                      if (year < 1990 || year > currentYear + 1) {
                        return 'Year must be between 1990 and ${currentYear + 1}';
                      }
                      return null;
                    },
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: EnhancedTextField(
                    label: 'Capacity',
                    controller: _capacityController,
                    type: TextFieldType.number,
                    required: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Capacity is required';
                      }
                      final capacity = int.tryParse(value!);
                      if (capacity == null) {
                        return 'Please enter a valid capacity';
                      }
                      if (capacity < 1 || capacity > 100) {
                        return 'Capacity must be between 1 and 100';
                      }
                      return null;
                    },
                    prefixIcon: Icon(Icons.airline_seat_recline_normal),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Driver Selection
            _buildDriverDropdown(theme),
            
            SizedBox(height: 16),
            
            // Air Conditioning
            Row(
              children: [
                Checkbox(
                  value: _isAirConditioned,
                  onChanged: (value) {
                    setState(() {
                      _isAirConditioned = value ?? false;
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Air Conditioned',
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(width: 8),
                Icon(
                  _isAirConditioned ? Icons.ac_unit : Icons.air,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            
            // Status (only for editing)
            if (widget.isEditing) ...[
              SizedBox(height: 16),
              _buildStatusDropdown(theme),
            ],
            
            SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                if (widget.onCancel != null) ...[
                  Expanded(
                    child: EnhancedCustomButton.outline(
                      text: 'Cancel',
                      onPressed: widget.isLoading ? null : widget.onCancel,
                    ),
                  ),
                  SizedBox(width: 16),
                ],
                Expanded(
                  child: EnhancedCustomButton.primary(
                    text: widget.isEditing ? 'Update Bus' : 'Add Bus',
                    icon: widget.isEditing ? Icons.update : Icons.add,
                    onPressed: widget.isLoading ? null : _handleSubmit,
                    isLoading: widget.isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Driver *',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDriverId,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Driver is required';
            }
            return null;
          },
          onChanged: (String? newValue) {
            setState(() {
              _selectedDriverId = newValue;
            });
          },
          items: widget.availableDrivers.map<DropdownMenuItem<String>>((driver) {
            return DropdownMenuItem<String>(
              value: driver['id'],
              child: Text(
                '${driver['firstName']} ${driver['lastName']} - ${driver['licenseNumber']}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<BusStatus>(
          value: _selectedStatus,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.info),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          onChanged: (BusStatus? newValue) {
            setState(() {
              _selectedStatus = newValue ?? BusStatus.inactive;
            });
          },
          items: BusStatus.values.map<DropdownMenuItem<BusStatus>>((status) {
            return DropdownMenuItem<BusStatus>(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Bus.getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(status.name.toUpperCase()),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final year = int.parse(_yearController.text);
    final capacity = int.parse(_capacityController.text);

    if (widget.isEditing && widget.onUpdate != null && widget.initialBus != null) {
      final updateRequest = BusUpdateRequest(
        licensePlate: _licensePlateController.text != widget.initialBus!.licensePlate 
            ? _licensePlateController.text : null,
        manufacturer: _manufacturerController.text != widget.initialBus!.manufacturer 
            ? _manufacturerController.text : null,
        model: _modelController.text != widget.initialBus!.model 
            ? _modelController.text : null,
        year: year != widget.initialBus!.year ? year : null,
        capacity: capacity != widget.initialBus!.capacity ? capacity : null,
        isAirConditioned: _isAirConditioned != widget.initialBus!.isAirConditioned 
            ? _isAirConditioned : null,
        status: _selectedStatus != widget.initialBus!.status ? _selectedStatus : null,
      );

      widget.onUpdate!(widget.initialBus!.id, updateRequest);
    } else {
      final createRequest = BusCreateRequest(
        licensePlate: _licensePlateController.text,
        driver: _selectedDriverId!,
        manufacturer: _manufacturerController.text,
        model: _modelController.text,
        year: year,
        capacity: capacity,
        isAirConditioned: _isAirConditioned,
      );

      widget.onSubmit(createRequest);
    }
  }
}