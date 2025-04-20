/// lib/presentation/pages/auth/register_page.dart

import 'dart:io'; // For File type
import 'dart:ui'; // For ImageFilter

import 'package:flutter/foundation.dart'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/di/service_locator.dart'; // To potentially get use case for provider
import '../../../core/enums/language.dart';
import '../../../core/enums/user_type.dart';
import '../../../core/mixins/validation_mixin.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../blocs/registration/registration_cubit.dart'; // Import Cubit
import '../../routes/route_names.dart';
import '../../widgets/common/image_picker_input.dart'; // Import image picker
import '../../widgets/common/themed_button.dart'; // Import custom button

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit to the widget subtree
    return BlocProvider(
      create: (context) => RegistrationCubit(registerUseCase: sl()), // Get use case from service locator
      child: const _RegisterPageContent(),
    );
  }
}


class _RegisterPageContent extends StatefulWidget {
  const _RegisterPageContent();

  @override
  State<_RegisterPageContent> createState() => _RegisterPageContentState();
}

class _RegisterPageContentState extends State<_RegisterPageContent> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  // Add controllers for other driver fields if needed (experience, dob, etc.)

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  UserType _selectedUserType = UserType.passenger; // Default selection
  File? _idPhotoFile;
  File? _licensePhotoFile;

  bool _isLoading = false; // Local loading state managed by Cubit listener

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  /// Attempts to register the user.
  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
       Log.w('Registration form validation failed.');
      return; // Validation failed
    }
     // Additional check for driver photos if driver type is selected
    if (_selectedUserType == UserType.driver) {
      if (_idPhotoFile == null) {
         Helpers.showSnackBar(context, message: 'ID Photo is required for drivers.', isError: true); // TODO: Localize
         return;
      }
       if (_licensePhotoFile == null) {
         Helpers.showSnackBar(context, message: 'License Photo is required for drivers.', isError: true); // TODO: Localize
         return;
      }
    }

    Helpers.hideKeyboard(context);

    // Call the Cubit's register method
    context.read<RegistrationCubit>().registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          userType: _selectedUserType,
          language: Language.fr, // Or get from AppSettingsCubit? Defaulting for now.
          // Pass driver details only if selected
          idNumber: _selectedUserType == UserType.driver ? _idNumberController.text.trim() : null,
          idPhoto: _selectedUserType == UserType.driver ? _idPhotoFile : null,
          licenseNumber: _selectedUserType == UserType.driver ? _licenseNumberController.text.trim() : null,
          licensePhoto: _selectedUserType == UserType.driver ? _licensePhotoFile : null,
           // Add other driver fields here if implemented
           // experienceYears: ...,
           // dateOfBirth: ...,
           // address: ...,
           // emergencyContact: ...,
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
     // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow resizing for keyboard
      // Extend body behind AppBar to make AppBar transparent/blurry
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         // Transparent AppBar with blur effect
         backgroundColor: Colors.white.withOpacity(0.1),
         elevation: 0,
         flexibleSpace: ClipRect(
           child: BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
             child: Container(color: Colors.transparent), // Needs a color for filter to apply
           ),
         ),
         leading: BackButton(color: Colors.white),
         title: Text(
           tr('create_account'), // TODO: Localize 'Create Account'
           style: textTheme.titleLarge?.copyWith(color: Colors.white),
         ),
         centerTitle: true,
      ),
      body: BlocListener<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          setState(() {
             _isLoading = (state is RegistrationLoading);
          });

          if (state is RegistrationFailure) {
            Helpers.showSnackBar(context, message: state.message, isError: true);
          } else if (state is RegistrationSuccess) {
            Helpers.showSnackBar(context, message: tr('registration_successful_login')); // TODO: Localize 'Registration successful! Please login.'
            // Navigate back to Login page after successful registration
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.login); // Fallback if cannot pop
            }
          }
        },
        child: Stack(
          children: [
             // 1. Background Image
            Positioned.fill(
              child: Image.asset(
                AssetsConstants.authBackground,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5), // Darken more for register page?
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // 2. Scrollable Content Area
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingMedium), // Less top padding due to AppBar
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450), // Max width for form
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         const SizedBox(height: kToolbarHeight), // Space for AppBar
                         // Glassy Form Container
                         ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingLarge),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: _buildFormFields(context), // Build form fields dynamically
                                ),
                              ),
                            ),
                          ),
                         ), // End Glassy Container
                           SizedBox(height: AppTheme.spacingLarge),
                          // Login Link
                          _buildLoginLink(context),
                           SizedBox(height: AppTheme.spacingMedium),
                      ]
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of form field widgets based on selected user type.
  List<Widget> _buildFormFields(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;
     // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

     return [
        // First Name
        TextFormField(
          controller: _firstNameController,
          decoration: _buildInputDecoration(labelText: tr('first_name'), prefixIcon: Icons.person_outline, hintText: 'John'),
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
          decoration: _buildInputDecoration(labelText: tr('last_name'), prefixIcon: Icons.person_outline, hintText: 'Doe'),
           validator: (value) => validateRequiredField(value, tr('last_name')),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Email
        TextFormField(
          controller: _emailController,
          decoration: _buildInputDecoration(labelText: tr('email'), prefixIcon: Icons.alternate_email, hintText: 'jugu@example.com'),
          validator: validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: AppTheme.spacingMedium),

        // Phone Number (Optional)
        TextFormField(
          controller: _phoneController,
          decoration: _buildInputDecoration(labelText: tr('phone_number_optional'), prefixIcon: Icons.phone_outlined, hintText: '+213 123 456 789'), // TODO: Localize 'Phone Number (Optional)'
          // No validator needed if optional, or use validatePhoneNumber if format check desired
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: AppTheme.spacingMedium),

        // Password
        TextFormField(
          controller: _passwordController,
          decoration: _buildInputDecoration(labelText: tr('password'), prefixIcon: Icons.lock_outline, hintText: '*******').copyWith(
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              color: Colors.white.withOpacity(0.7),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          obscureText: !_isPasswordVisible,
          validator: validatePassword,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: AppTheme.spacingMedium),

        // Confirm Password
        TextFormField(
          controller: _confirmPasswordController,
          decoration: _buildInputDecoration(labelText: tr('confirm_password'), prefixIcon: Icons.lock_outline, hintText: '*******').copyWith(
             suffixIcon: IconButton(
              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              color: Colors.white.withOpacity(0.7),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
          obscureText: !_isConfirmPasswordVisible,
          validator: (value) => validateConfirmPassword(value, _passwordController.text),
          textInputAction: TextInputAction.next, // Go to next field (User Type or Driver fields)
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: AppTheme.spacingLarge),

        // User Type Selection
        Text(tr('register_as'), style: textTheme.labelLarge?.copyWith(color: Colors.white.withOpacity(0.9))), // TODO: Localize 'Register as:'
        SizedBox(height: AppTheme.spacingSmall),
        _buildUserTypeSelector(context),
        SizedBox(height: AppTheme.spacingLarge),

        // Conditional Driver Fields
        AnimatedSize( // Animate visibility change
           duration: AppTheme.animationMedium,
           curve: Curves.easeInOut,
           child: Visibility(
            visible: _selectedUserType == UserType.driver,
            child: Column(
              children: [
                // ID Number
                TextFormField(
                  controller: _idNumberController,
                  decoration: _buildInputDecoration(labelText: tr('id_number'), prefixIcon: Icons.badge_outlined, hintText: '1234567'), // TODO: Localize
                  validator: (value) => _selectedUserType == UserType.driver ? validateRequiredField(value, tr('id_number')) : null,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: AppTheme.spacingMedium),

                // License Number
                 TextFormField(
                  controller: _licenseNumberController,
                  decoration: _buildInputDecoration(labelText: tr('license_number'), prefixIcon: Icons.card_membership_outlined, hintText: 'XX-XXX-XXX'), // TODO: Localize
                  validator: (value) => _selectedUserType == UserType.driver ? validateRequiredField(value, tr('license_number')) : null,
                  textInputAction: TextInputAction.next, // Adjust if more fields added
                  enabled: !_isLoading,
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: AppTheme.spacingMedium),

                // ID Photo Picker
                ImagePickerInput(
                   label: tr('id_photo'), // TODO: Localize
                   onImagePicked: (file) => setState(() => _idPhotoFile = file),
                ),
                 SizedBox(height: AppTheme.spacingMedium),

                 // License Photo Picker
                ImagePickerInput(
                   label: tr('license_photo'), // TODO: Localize
                   onImagePicked: (file) => setState(() => _licensePhotoFile = file),
                ),
                 SizedBox(height: AppTheme.spacingLarge),
                 // Add more driver fields here (Experience, DoB, Address...)
              ],
            ),
           ),
        ),


        // Register Button
        ThemedButton(
          text: tr('register'), // TODO: Localize
          isLoading: _isLoading,
          onPressed: _isLoading ? () {} : _register,
          isFullWidth: true,
           style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.9), // Slightly transparent
              foregroundColor: Colors.white,
              textStyle: textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
               shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
            ),
        ),
     ];
  }

  /// Builds the selector for choosing between Passenger and Driver roles.
  Widget _buildUserTypeSelector(BuildContext context) {
      final theme = Theme.of(context);
     return ToggleButtons(
        isSelected: [_selectedUserType == UserType.passenger, _selectedUserType == UserType.driver],
        onPressed: (index) {
            setState(() {
                _selectedUserType = index == 0 ? UserType.passenger : UserType.driver;
            });
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        selectedColor: Colors.white,
        color: Colors.white.withOpacity(0.7),
        fillColor: AppTheme.primaryColor.withOpacity(0.5),
        selectedBorderColor: AppTheme.primaryColor,
        borderColor: Colors.white.withOpacity(0.3),
        constraints: BoxConstraints(minHeight: 45.0, minWidth: (MediaQuery.of(context).size.width - (AppTheme.spacingLarge * 3))/2), // Adjust width dynamically
        children: [
           Padding(
             padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.person_outline, size: 20),
                 SizedBox(width: AppTheme.spacingSmall),
                 Text('Passenger'), // TODO: Localize
               ],
             ),
           ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Icon(Icons.drive_eta_outlined, size: 20),
                 SizedBox(width: AppTheme.spacingSmall),
                 Text('Driver'), // TODO: Localize
               ],
             ),
            ),
        ],
     );
  }


  /// Builds the link to navigate back to the Login page.
  Widget _buildLoginLink(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;
     // Placeholder for localization
     String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('already_have_account'), // TODO: Localize "Already have an account?"
              style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
            ),
            TextButton(
              onPressed: _isLoading ? null : () {
                Log.i('Login link tapped.');
                // Navigate back to Login page
                 if (context.canPop()) {
                   context.pop();
                 } else {
                   context.goNamed(RouteNames.login); // Fallback if cannot pop
                 }
              },
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXSmall),
                   foregroundColor: Colors.white, // Make link white
                   textStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                       decorationColor: Colors.white,
                   ),
              ),
              child: Text(tr('login')), // TODO: Localize 'Login'
            ),
          ],
        );
  }

  /// Helper to build consistent InputDecoration for TextFormFields
  InputDecoration _buildInputDecoration({
      required String labelText,
      required String hintText,
      required IconData prefixIcon,
      }) {
     // Reusing the helper from LoginPage, potentially move to shared location
      return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Slightly more transparent fill
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide.none, // No border shown by default with fill
        ),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), // Subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: const BorderSide(color: Colors.white, width: 1.5), // Highlight border
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide(color: AppTheme.errorColor.withOpacity(0.8), width: 1.0),
        ),
         focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        errorStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500), // Lighter error text for contrast
      );
  }
}

/// Helper class for storage keys (move to a constants file if preferred)
class StorageKeys {
   static const String onboardingComplete = 'onboarding_complete';
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) {
    if (s.isEmpty) return '';
    return "${s[0].toUpperCase()}${s.substring(1)}";
  }
}
