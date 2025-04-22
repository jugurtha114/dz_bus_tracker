/// lib/presentation/pages/driver/driver_add_edit_bus_page.dart

import 'dart:io'; // For File type
import 'dart:ui'; // For ImageFilter

import 'package:flutter/foundation.dart'; // For kIsWeb, Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/mixins/validation_mixin.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/usecases/bus/get_bus_details_usecase.dart';
import '../../blocs/auth/auth_bloc.dart'; // To get current driver ID
import '../../blocs/driver_bus/driver_bus_bloc.dart';
import '../../widgets/common/image_picker_input.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/themed_button.dart';


/// Page for adding a new bus or editing an existing one (Driver role).
class DriverAddEditBusPage extends StatefulWidget {
  /// Optional ID of the bus to edit. If null, the page is in "Add" mode.
  final String? busId;

  const DriverAddEditBusPage({super.key, this.busId});

  /// Convenience getter to check if the page is in edit mode.
  bool get isEditMode => busId != null;

  @override
  State<DriverAddEditBusPage> createState() => _DriverAddEditBusPageState();
}

class _DriverAddEditBusPageState extends State<DriverAddEditBusPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State for image files (replace File with dynamic if supporting web/bytes)
  // For simplicity, currently allowing only adding new photos, not editing existing ones easily.
  final List<File> _newPhotos = [];

  bool _isPageLoading = false; // Loading initial data in edit mode
  bool _isSubmitting = false; // Submitting add/update request
  BusEntity? _editingBus; // Stores fetched bus data in edit mode

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _fetchBusDetails();
    }
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fetches bus details when in edit mode.
  Future<void> _fetchBusDetails() async {
    setState(() => _isPageLoading = true);
    Log.d("Fetching details for bus ID: ${widget.busId}");
    final getBusDetailsUseCase = sl<GetBusDetailsUseCase>(); // Get from service locator
    final result = await getBusDetailsUseCase(GetBusDetailsParams(busId: widget.busId!));

    if (mounted) {
      result.fold(
        (failure) {
          Log.e("Failed to fetch bus details", error: failure);
          setState(() => _isPageLoading = false);
          Helpers.showSnackBar(context, message: failure.message ?? 'Failed to load bus details.', isError: true); // TODO: Localize
          // Optionally pop if loading fails critically
          // context.pop();
        },
        (bus) {
           Log.d("Bus details fetched: ${bus.matricule}");
          setState(() {
            _editingBus = bus;
            _matriculeController.text = bus.matricule;
            _brandController.text = bus.brand;
            _modelController.text = bus.model;
            _yearController.text = bus.year?.toString() ?? '';
            _capacityController.text = bus.capacity?.toString() ?? '';
            _descriptionController.text = bus.description ?? '';
            // TODO: Handle loading/displaying existing photos if needed
            _isPageLoading = false;
          });
        },
      );
    }
  }

  /// Handles form submission for both adding and editing.
  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.w('Add/Edit Bus form validation failed.');
      return;
    }
    Helpers.hideKeyboard(context);

    // Get current driver ID (assuming user is authenticated as driver)
    final authState = context.read<AuthBloc>().state;
    String? driverId;
    if (authState is AuthAuthenticated && authState.user.isDriver) {
       driverId = authState.user.id;
    }

    if (driverId == null && !widget.isEditMode) {
       Log.e('Cannot add bus: Driver ID not available.');
       Helpers.showSnackBar(context, message: 'Authentication error. Cannot identify driver.', isError: true); // TODO: Localize
       return;
    }

    final matricule = _matriculeController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final capacity = int.tryParse(_capacityController.text.trim());
    final description = _descriptionController.text.trim();

    if (widget.isEditMode) {
      // Dispatch Update Event
      context.read<DriverBusBloc>().add(UpdateBusSubmitted(
            busId: widget.busId!,
            brand: brand == _editingBus?.brand ? null : brand, // Send only changed fields
            model: model == _editingBus?.model ? null : model,
            year: year == _editingBus?.year ? null : year,
            capacity: capacity == _editingBus?.capacity ? null : capacity,
            description: description == _editingBus?.description ? null : (description.isEmpty ? null : description),
            // TODO: Add isActive, nextMaintenance if editable here
          ));
       // TODO: Handle photo updates/additions separately if needed for edit mode
    } else {
      // Dispatch Add Event
      context.read<DriverBusBloc>().add(AddBusSubmitted(
            driverId: driverId!,
            matricule: matricule,
            brand: brand,
            model: model,
            year: year,
            capacity: capacity,
            description: description.isEmpty ? null : description,
            photos: _newPhotos.isNotEmpty ? _newPhotos : null,
          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
     // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
    final String appBarTitle = widget.isEditMode ? tr('edit_bus') : tr('add_new_bus'); // TODO: Localize


    return Scaffold(
      resizeToAvoidBottomInset: true,
       extendBodyBehindAppBar: true,
        appBar: AppBar(
         backgroundColor: Colors.white.withOpacity(0.1),
         elevation: 0,
         flexibleSpace: ClipRect(
           child: BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
             child: Container(color: Colors.transparent),
           ),
         ),
         leading: BackButton(color: Colors.white),
         title: Text(appBarTitle, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
         centerTitle: true,
      ),
      body: BlocListener<DriverBusBloc, DriverBusState>(
        listener: (context, state) {
           setState(() {
              _isSubmitting = (state is DriverBusLoading);
           });

           if (state is DriverBusError) {
              Helpers.showSnackBar(context, message: state.message, isError: true);
           } else if (state is DriverBusLoaded && _isSubmitting) {
              // Success feedback: If previous state was loading (submitting),
              // and now it's loaded again, assume success.
              Helpers.showSnackBar(context, message: widget.isEditMode ? tr('bus_updated_success') : tr('bus_added_success')); // TODO: Localize
              context.pop(); // Go back after successful add/edit
           }
        },
        child: Stack(
           children: [
               // Background Image
                Positioned.fill(
                  child: Image.asset(
                    AssetsConstants.authBackground, // Reuse auth background or use a different one
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6), // Darken more
                    colorBlendMode: BlendMode.darken,
                  ),
                ),

                 // Main Content
                 SafeArea(
                    child: SingleChildScrollView(
                       padding: const EdgeInsets.all(AppTheme.spacingLarge),
                       child: _isPageLoading
                          ? SizedBox(height: MediaQuery.of(context).size.height * 0.7, child: const Center(child: LoadingIndicator()))
                          : ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: _buildGlassyForm(context),
                            ),
                    ),
                 )
           ],
        ),
      ),
    );
  }


  /// Builds the main form within the glassy container.
  Widget _buildGlassyForm(BuildContext context) {
     // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Matricule (License Plate) - Read-only in edit mode usually
                  TextFormField(
                    controller: _matriculeController,
                    decoration: _buildInputDecoration(labelText: tr('matricule'), prefixIcon: Icons.pin_outlined), // TODO: Localize
                    validator: (value) => validateRequiredField(value, tr('matricule')),
                    textInputAction: TextInputAction.next,
                    enabled: !_isSubmitting && !widget.isEditMode, // Disable editing matricule
                    style: TextStyle(color: widget.isEditMode ? Colors.white54 : Colors.white),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // Brand
                  TextFormField(
                    controller: _brandController,
                    decoration: _buildInputDecoration(labelText: tr('brand'), prefixIcon: Icons.business_outlined), // TODO: Localize
                    validator: (value) => validateRequiredField(value, tr('brand')),
                    textInputAction: TextInputAction.next,
                     enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.white),
                  ),
                   const SizedBox(height: AppTheme.spacingMedium),

                  // Model
                  TextFormField(
                    controller: _modelController,
                    decoration: _buildInputDecoration(labelText: tr('model'), prefixIcon: Icons.directions_bus_filled_outlined), // TODO: Localize
                     validator: (value) => validateRequiredField(value, tr('model')),
                    textInputAction: TextInputAction.next,
                     enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.white),
                  ),
                   const SizedBox(height: AppTheme.spacingMedium),

                  // Year
                  TextFormField(
                    controller: _yearController,
                    decoration: _buildInputDecoration(labelText: tr('year_optional'), prefixIcon: Icons.calendar_today_outlined), // TODO: Localize
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                     enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.white),
                  ),
                   const SizedBox(height: AppTheme.spacingMedium),

                  // Capacity
                  TextFormField(
                    controller: _capacityController,
                    decoration: _buildInputDecoration(labelText: tr('capacity_optional'), prefixIcon: Icons.people_outline), // TODO: Localize
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.white),
                  ),
                   const SizedBox(height: AppTheme.spacingMedium),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _buildInputDecoration(labelText: tr('description_optional'), prefixIcon: Icons.description_outlined), // TODO: Localize
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // Photo Pickers (Only show in Add mode for simplicity now)
                  // TODO: Enhance to show/manage existing photos in Edit mode
                  if (!widget.isEditMode) ...[
                      Text('Add Photos (Optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)), // TODO: Localize
                       const SizedBox(height: AppTheme.spacingMedium),
                       // Example for one photo - repeat or use a builder for multiple
                      ImagePickerInput(
                        label: tr('photo') + ' 1', // TODO: Localize
                        onImagePicked: (file) {
                           // Basic handling for one photo
                           _newPhotos.clear(); // Clear previous if only one allowed
                           if (file != null) {
                              _newPhotos.add(file);
                           }
                        },
                      ),
                      // Add more ImagePickerInput widgets or a dynamic list builder here
                       const SizedBox(height: AppTheme.spacingLarge),
                  ],


                  // Submit Button
                  ThemedButton(
                    text: widget.isEditMode ? tr('save_changes') : tr('add_bus'), // TODO: Localize
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? () {} : _submitForm,
                    isFullWidth: true,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                      foregroundColor: Colors.white,
                      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  /// Helper to build consistent InputDecoration for TextFormFields (copied/adapted)
  InputDecoration _buildInputDecoration({
      required String labelText, String? hintText, required IconData prefixIcon,}) {
      return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: AppTheme.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500), );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
