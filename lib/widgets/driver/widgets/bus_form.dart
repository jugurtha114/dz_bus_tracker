// lib/widgets/driver/widgets/bus_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme_config.dart';
import '../../../core/utils/validation_utils.dart';
import '../../common/custom_button.dart';
import '../../common/custom_text_field.dart';

class BusForm extends StatefulWidget {
  final String driverId;
  final Map<String, dynamic>? initialData;
  final bool isEditing;
  final Function(Map<String, dynamic>) onSaved;
  final VoidCallback onCancel;

  const BusForm({
    Key? key,
    required this.driverId,
    this.initialData,
    this.isEditing = false,
    required this.onSaved,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<BusForm> createState() => _BusFormState();
}

class _BusFormState extends State<BusForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licensePlateController;
  late TextEditingController _manufacturerController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _capacityController;
  bool _isAirConditioned = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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

  void _initializeControllers() {
    final data = widget.initialData ?? {};

    _licensePlateController = TextEditingController(text: data['license_plate'] ?? '');
    _manufacturerController = TextEditingController(text: data['manufacturer'] ?? '');
    _modelController = TextEditingController(text: data['model'] ?? '');
    _yearController = TextEditingController(text: data['year']?.toString() ?? '');
    _capacityController = TextEditingController(text: data['capacity']?.toString() ?? '');
    _isAirConditioned = data['is_air_conditioned'] == true;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final busData = {
        'driver': widget.driverId,
        'license_plate': _licensePlateController.text,
        'manufacturer': _manufacturerController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'capacity': _capacityController.text,
        'is_air_conditioned': _isAirConditioned,
      };

      widget.onSaved(busData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // License plate
          CustomTextField(
            label: 'License Plate',
            controller: _licensePlateController,
            validator: (value) => ValidationUtils.validateRequired(
              value,
              fieldName: 'License plate',
            ),
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),

          const SizedBox(height: 16),

          // Manufacturer
          CustomTextField(
            label: 'Manufacturer',
            controller: _manufacturerController,
            validator: (value) => ValidationUtils.validateRequired(
              value,
              fieldName: 'Manufacturer',
            ),
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),

          const SizedBox(height: 16),

          // Model
          CustomTextField(
            label: 'Model',
            controller: _modelController,
            validator: (value) => ValidationUtils.validateRequired(
              value,
              fieldName: 'Model',
            ),
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),

          const SizedBox(height: 16),

          // Year and Capacity (side by side)
          Row(
            children: [
              // Year
              Expanded(
                child: CustomTextField(
                  label: 'Year',
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) => ValidationUtils.validateRange(
                    value,
                    fieldName: 'Year',
                    min: 1990,
                    max: DateTime.now().year + 1,
                  ),
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),

              const SizedBox(width: 16, height: 40),

              // Capacity
              Expanded(
                child: CustomTextField(
                  label: 'Capacity',
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) => ValidationUtils.validateRange(
                    value,
                    fieldName: 'Capacity',
                    min: 1,
                    max: 200,
                  ),
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Air conditioned checkbox
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
            child: CheckboxListTile(
              title: const Text('Air Conditioned'),
              value: _isAirConditioned,
              onChanged: (value) {
                setState(() {
                  _isAirConditioned = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel button
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Save button
              CustomButton(
        text: widget.isEditing ? 'Update' : 'Save',
        onPressed: _submitForm,
        color: Theme.of(context).colorScheme.primary
      ),
            ],
          ),
        ],
      ),
    );
  }
}