/// lib/presentation/pages/settings/user_profile_edit_page.dart

import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/mixins/validation_mixin.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/user_profile_edit/user_profile_edit_cubit.dart'; // Import Cubit
import '../../widgets/common/profile_picture_widget.dart'; // Use profile picture widget
import '../../widgets/common/themed_button.dart';

/// Page for users (non-drivers) to edit their basic profile information.
class UserProfileEditPage extends StatelessWidget {
  final UserEntity userProfile;

  const UserProfileEditPage({super.key, required this.userProfile});

   @override
  Widget build(BuildContext context) {
    // Provide the Cubit scoped to this page
    return BlocProvider(
      create: (context) => UserProfileEditCubit(updateUserProfileUseCase: sl()),
      child: _UserProfileEditView(initialProfile: userProfile),
    );
  }
}


class _UserProfileEditView extends StatefulWidget {
   final UserEntity initialProfile;
  const _UserProfileEditView({required this.initialProfile});

  @override
  State<_UserProfileEditView> createState() => __UserProfileEditViewState();
}

class __UserProfileEditViewState extends State<_UserProfileEditView> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  bool _isLoading = false; // Local loading state managed by Cubit listener

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _firstNameController = TextEditingController(text: widget.initialProfile.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.initialProfile.lastName ?? '');
    _phoneController = TextEditingController(text: widget.initialProfile.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Validates the form and submits the updated profile details.
  Future<void> _submitUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.w('Edit User Profile form validation failed.');
      return;
    }
    Helpers.hideKeyboard(context);

    // Collect changes
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    // Check if anything actually changed
    bool changed = false;
    if (firstName != (widget.initialProfile.firstName ?? '')) changed = true;
    if (lastName != (widget.initialProfile.lastName ?? '')) changed = true;
    if (phone != (widget.initialProfile.phoneNumber ?? '')) changed = true;
    // Note: Language is handled on Settings page in this design

    if (!changed) {
      Log.i("No changes detected in user profile.");
      Helpers.showSnackBar(context, message: 'No changes were made.'); // TODO: Localize
      return;
    }

    // Dispatch update event to Cubit with only changed fields
    context.read<UserProfileEditCubit>().updateProfile(
      firstName: firstName != (widget.initialProfile.firstName ?? '') ? firstName : null,
      lastName: lastName != (widget.initialProfile.lastName ?? '') ? lastName : null,
      // Send empty string to clear phone number if applicable
      phoneNumber: phone != (widget.initialProfile.phoneNumber ?? '') ? (phone.isEmpty ? '' : phone) : null,
    );
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
    final String appBarTitle = tr('edit_profile'); // TODO: Localize

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         backgroundColor: Colors.white.withOpacity(0.1),
         elevation: 0,
         flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(color: Colors.transparent))),
         leading: BackButton(color: Colors.white, onPressed: () => context.pop()),
         title: Text(appBarTitle, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
         centerTitle: true,
      ),
      body: BlocListener<UserProfileEditCubit, UserProfileEditState>(
         listener: (context, state) {
            final isLoading = state is UserProfileEditLoading;
            if (_isLoading != isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() { _isLoading = isLoading; });
                });
            }

            if (state is UserProfileEditFailure) {
               WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Helpers.showSnackBar(context, message: state.message, isError: true);
               });
            } else if (state is UserProfileEditSuccess) {
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                        Helpers.showSnackBar(context, message: tr('profile_updated_success')); // TODO: Localize
                        // TODO: Update AuthBloc's user state if necessary or rely on next full refresh
                        context.pop(); // Go back after success
                    }
                 });
            }
         },
         child: Stack(
           children: [
              // Background Image
              Positioned.fill(child: Image.asset(AssetsConstants.authBackground, fit: BoxFit.cover, color: Colors.black.withOpacity(0.6), colorBlendMode: BlendMode.darken)),
               // Main Content
              SafeArea(
                 child: Center(
                   child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: _buildGlassyForm(context, tr),
                      ),
                   ),
                 ),
              ),
               // Loading overlay during submission
               if (_isLoading)
                   Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator())
                   ),
           ],
         ),
      ),
    );
  }

   /// Builds the main form within the glassy container.
  Widget _buildGlassyForm(BuildContext context, String Function(String) tr) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          decoration: BoxDecoration( color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 // Profile Picture (Non-editable here, just display)
                 Center(
                    child: ProfilePictureWidget(
                       // imageUrl: widget.initialProfile.profilePictureUrl, // Add if UserEntity has it
                       fullName: widget.initialProfile.fullName,
                       radius: 50,
                       backgroundColor: theme.colorScheme.primaryContainer,
                       foregroundColor: theme.colorScheme.onPrimaryContainer,
                     )
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Center(
                     child: Text(
                       widget.initialProfile.email, // Display email (usually not editable)
                       style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                     ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge * 1.5),

                  // First Name
                   TextFormField(
                      controller: _firstNameController,
                      decoration: _buildInputDecoration(labelText: tr('first_name'), prefixIcon: Icons.person_outline), // TODO: Localize
                      validator: (value) => validateRequiredField(value, tr('first_name')),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // Last Name
                   TextFormField(
                      controller: _lastNameController,
                      decoration: _buildInputDecoration(labelText: tr('last_name'), prefixIcon: Icons.person_outline), // TODO: Localize
                      validator: (value) => validateRequiredField(value, tr('last_name')),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // Phone Number (Optional)
                    TextFormField(
                      controller: _phoneController,
                      decoration: _buildInputDecoration(labelText: tr('phone_number_optional'), prefixIcon: Icons.phone_outlined), // TODO: Localize 'Phone Number (Optional)'
                      // Optional validation: validatePhoneNumber from mixin if needed
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                       onFieldSubmitted: (_) => _isLoading ? null : _submitUpdate(),
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
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
                        textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
  InputDecoration _buildInputDecoration({ required String labelText, String? hintText, required IconData prefixIcon,}) { return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: AppTheme.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500), ); }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil { static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; } }

