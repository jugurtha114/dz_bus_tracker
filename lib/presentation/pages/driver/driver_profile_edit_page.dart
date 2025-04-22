/// lib/presentation/pages/driver/driver_profile_edit_page.dart

import 'dart:io'; // For File type
import 'dart:ui'; // For ImageFilter

import 'package:flutter/foundation.dart'; // For kIsWeb, Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting/parsing

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/di/service_locator.dart'; // Needed to get UseCase if BLoC doesn't load initial
import '../../../core/mixins/validation_mixin.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/driver_entity.dart';
import '../../../domain/usecases/bus/get_bus_details_usecase.dart'; // Incorrect use case, should be driver
import '../../../domain/usecases/driver/get_driver_profile_usecase.dart'; // Correct use case
import '../../blocs/driver_profile/driver_profile_bloc.dart'; // Import BLoC
import '../../widgets/common/image_picker_input.dart'; // Import enhanced picker
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/themed_button.dart';

/// Page for the driver to edit their specific profile details.
class DriverProfileEditPage extends StatefulWidget {
  /// The current driver profile data used to pre-fill the form.
  /// Passed via router's 'extra' parameter.
  final DriverEntity driverProfile;

  const DriverProfileEditPage({super.key, required this.driverProfile});

  @override
  State<DriverProfileEditPage> createState() => _DriverProfileEditPageState();
}

class _DriverProfileEditPageState extends State<DriverProfileEditPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  // Controllers for editable fields
  late final TextEditingController _experienceController;
  late final TextEditingController _dobController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyContactController;
  late final TextEditingController _notesController; // If editable by driver

  // State for newly picked image files
  File? _newIdPhotoFile;
  File? _newLicensePhotoFile;
  DateTime? _selectedDateOfBirth;

  bool _isLoading = false; // Local loading state managed by BLoC listener
  // No _isPageLoading needed if profile passed via constructor

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data from widget.driverProfile
    _experienceController = TextEditingController(text: widget.driverProfile.experienceYears?.toString() ?? '');
    _selectedDateOfBirth = widget.driverProfile.dateOfBirth;
    _dobController = TextEditingController(
        text: _selectedDateOfBirth != null ? DateFormat.yMd().format(_selectedDateOfBirth!) : '');
    _addressController = TextEditingController(text: widget.driverProfile.address ?? '');
    _emergencyContactController = TextEditingController(text: widget.driverProfile.emergencyContact ?? '');
    _notesController = TextEditingController(text: widget.driverProfile.notes ?? '');
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Handles selecting the Date of Birth.
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final initialDate = _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20));
    final firstDate = DateTime(1940);
    final lastDate = DateTime.now().subtract(const Duration(days: 365 * 18)); // Must be at least 18

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : (initialDate.isBefore(firstDate) ? firstDate : initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) { // Optional: Theme the Date Picker
        return Theme(
          data: Theme.of(context).copyWith(
             colorScheme: Theme.of(context).colorScheme.copyWith(
               primary: Theme.of(context).colorScheme.primary,
               onPrimary: Theme.of(context).colorScheme.onPrimary,
               onSurface: Theme.of(context).colorScheme.onSurface,
             ),
             textButtonTheme: TextButtonThemeData(
               style: TextButton.styleFrom(
                 foregroundColor: Theme.of(context).colorScheme.primary,
               ),
             ),
           ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat.yMd().format(picked);
      });
    }
  }

  /// Validates the form and submits the updated profile details.
  Future<void> _submitUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.w('Edit Driver Profile form validation failed.');
      return;
    }
    Helpers.hideKeyboard(context);

    // Collect potential changes
    final experienceYearsText = _experienceController.text.trim();
    final address = _addressController.text.trim();
    final emergencyContact = _emergencyContactController.text.trim();
    final notes = _notesController.text.trim();
    final int? experienceYears = experienceYearsText.isNotEmpty ? int.tryParse(experienceYearsText) : null;

    // Check if anything actually changed
    bool changed = false;
    if (_newIdPhotoFile != null) changed = true;
    if (_newLicensePhotoFile != null) changed = true;
    if (experienceYears != widget.driverProfile.experienceYears) changed = true;
    if (_selectedDateOfBirth != widget.driverProfile.dateOfBirth) changed = true;
    if (address != (widget.driverProfile.address ?? '')) changed = true;
    if (emergencyContact != (widget.driverProfile.emergencyContact ?? '')) changed = true;
    if (notes != (widget.driverProfile.notes ?? '')) changed = true;

    if (!changed) {
      Log.i("No changes detected in driver profile.");
      Helpers.showSnackBar(context, message: 'No changes were made.'); // TODO: Localize
      return;
    }

    // Create params only with changed values (usecase expects nullable fields)
    final params = UpdateDriverDetailsSubmitted(
      idPhoto: _newIdPhotoFile,
      licensePhoto: _newLicensePhotoFile,
      experienceYears: experienceYears != widget.driverProfile.experienceYears ? experienceYears : null,
      dateOfBirth: _selectedDateOfBirth != widget.driverProfile.dateOfBirth ? _selectedDateOfBirth : null,
      address: address != (widget.driverProfile.address ?? '') ? (address.isEmpty ? '' : address) : null,
      emergencyContact: emergencyContact != (widget.driverProfile.emergencyContact ?? '') ? (emergencyContact.isEmpty ? '' : emergencyContact) : null,
      notes: notes != (widget.driverProfile.notes ?? '') ? (notes.isEmpty ? '' : notes) : null,
    );

    // Dispatch update event to BLoC (assuming DriverProfileBloc is provided)
    context.read<DriverProfileBloc>().add(params);
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
    final String appBarTitle = tr('edit_driver_profile'); // TODO: Localize

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
         leading: BackButton(color: Colors.white, onPressed: () => context.pop()),
         title: Text(appBarTitle, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
         centerTitle: true,
      ),
      body: BlocListener<DriverProfileBloc, DriverProfileState>(
         // Assuming DriverProfileBloc is provided by the route or parent
         listener: (context, state) {
           // Keep local loading state in sync with BLoC state
            final bool currentlySubmitting = state is DriverProfileUpdating;
           if (_isLoading != currentlySubmitting) {
               // Use WidgetsBinding to avoid calling setState during build
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) setState(() { _isLoading = currentlySubmitting; });
               });
           }

           if (state is DriverProfileError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) Helpers.showSnackBar(context, message: state.message, isError: true);
              });
           } else if (state is DriverProfileLoaded && _isLoading) {
              // If state becomes Loaded AND we were previously loading, it means success
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) {
                    Helpers.showSnackBar(context, message: tr('profile_updated_success')); // TODO: Localize
                    context.pop(); // Go back to profile view after success
                 }
              });
           }
         },
         child: Stack(
           children: [
              // Background Image
                Positioned.fill(
                  child: Image.asset(
                    AssetsConstants.authBackground, // Reuse background
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                 // Main Content
                 SafeArea(
                    child: Center( // Center the form horizontally
                       child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500), // Max form width
                              child: _buildGlassyForm(context),
                          ),
                       ),
                    ),
                 ),
                 // Loading overlay only during submission
                 if (_isLoading)
                    Container(
                       color: Colors.black.withOpacity(0.5),
                       child: const Center(child: LoadingIndicator(message: 'Saving...')) // TODO: Localize
                    ),
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
                 Text(
                     tr('update_your_driver_details'), // TODO: Localize
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // Experience Years
                  TextFormField(
                      controller: _experienceController,
                      decoration: _buildInputDecoration(labelText: tr('experience_years_optional'), prefixIcon: Icons.star_outline), // TODO: Localize
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) { // Optional: Add validation for number range
                         if (value == null || value.isEmpty) return null; // Optional field
                         final years = int.tryParse(value);
                         if (years == null || years < 0 || years > 60) {
                            return 'Please enter a valid number of years (0-60).'; // TODO: Localize
                         }
                         return null;
                      },
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // Date of Birth
                   TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: _buildInputDecoration(labelText: tr('date_of_birth_optional'), prefixIcon: Icons.cake_outlined).copyWith( // TODO: Localize
                         suffixIcon: Icon(Icons.calendar_month_outlined, color: Colors.white.withOpacity(0.7)),
                      ),
                      onTap: _isLoading ? null : () => _selectDateOfBirth(context),
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // Address
                   TextFormField(
                      controller: _addressController,
                      decoration: _buildInputDecoration(labelText: tr('address_optional'), prefixIcon: Icons.home_outlined), // TODO: Localize
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // Emergency Contact
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: _buildInputDecoration(labelText: tr('emergency_contact_optional'), prefixIcon: Icons.contact_emergency_outlined), // TODO: Localize
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // Notes (If editable by driver)
                    TextFormField(
                      controller: _notesController,
                      decoration: _buildInputDecoration(labelText: tr('notes_optional'), prefixIcon: Icons.notes_outlined), // TODO: Localize
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      onFieldSubmitted: (_) => _isLoading ? null : _submitUpdate(), // Submit on done
                   ),
                   const SizedBox(height: AppTheme.spacingLarge),

                  // ID Photo Picker
                   ImagePickerInput(
                       label: tr('id_photo') + ' (' + tr('tap_to_change') + ')', // TODO: Localize
                       initialImageUrl: widget.driverProfile.idPhotoUrl, // Show current photo
                       onImagePicked: (file) => setState(() => _newIdPhotoFile = file),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // License Photo Picker
                   ImagePickerInput(
                       label: tr('license_photo') + ' (' + tr('tap_to_change') + ')', // TODO: Localize
                       initialImageUrl: widget.driverProfile.licensePhotoUrl, // Show current photo
                       onImagePicked: (file) => setState(() => _newLicensePhotoFile = file),
                   ),
                   const SizedBox(height: AppTheme.spacingLarge * 1.5),

                  // Save Button
                  ThemedButton(
                    text: tr('save_changes'), // TODO: Localize
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _submitUpdate,
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

  /// Helper to build consistent InputDecoration (copied/adapted)
  InputDecoration _buildInputDecoration({
      required String labelText, String? hintText, required IconData prefixIcon,}) {
      return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: AppTheme.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500), );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
