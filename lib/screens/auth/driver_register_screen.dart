// lib/screens/auth/driver_register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/glassy_container.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/permission_helper.dart';
import '../../widgets/auth/register_form.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({Key? key}) : super(key: key);

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic user info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Driver-specific info
  final _idCardNumberController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();

  // Image files
  File? _idCardPhoto;
  File? _driverLicensePhoto;

  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idCardNumberController.dispose();
    _driverLicenseNumberController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isIdCard) async {
    // Request permission
    final hasPermission = await PermissionHelper.requestCamera(context);

    if (!hasPermission) {
      return;
    }

    // Pick image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        if (isIdCard) {
          _idCardPhoto = File(pickedFile.path);
        } else {
          _driverLicensePhoto = File(pickedFile.path);
        }
      });
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      // Validate basic info
      return _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          ValidationUtils.isValidEmail(_emailController.text) &&
          ValidationUtils.isValidPhone(_phoneController.text) &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    } else {
      // Validate driver info
      return _idCardNumberController.text.isNotEmpty &&
          _driverLicenseNumberController.text.isNotEmpty &&
          _yearsOfExperienceController.text.isNotEmpty &&
          _idCardPhoto != null &&
          _driverLicensePhoto != null;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep = 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_idCardPhoto == null || _driverLicensePhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload both ID card and driver license photos.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // TODO: In a real app, we would upload the images to a server
        // and get back URLs to use for registration
        final idCardPhotoUrl = 'https://example.com/id_card.jpg';
        final driverLicensePhotoUrl = 'https://example.com/driver_license.jpg';

        final success = await authProvider.registerDriver(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
          idCardNumber: _idCardNumberController.text,
          idCardPhoto: idCardPhotoUrl,
          driverLicenseNumber: _driverLicenseNumberController.text,
          driverLicensePhoto: driverLicensePhotoUrl,
          yearsOfExperience: int.tryParse(_yearsOfExperienceController.text) ?? 0,
        );

        if (success && mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration submitted! Your application will be reviewed.'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to login screen
          AppRouter.navigateToReplacement(context, AppRoutes.login);
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Registration failed. Please try again.'),
              backgroundColor: AppColors.error,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Register as Driver',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Complete your profile to start driving',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Progress indicators
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _currentStep == 1
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Step labels
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Account Info',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: _currentStep == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Driver Details',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: _currentStep == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Registration form in a glass container
                  GlassyContainer(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: _currentStep == 0
                          ? _buildAccountInfoForm()
                          : _buildDriverDetailsForm(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRouter.navigateToReplacement(context, AppRoutes.login),
                        child: Text(
                          'Login',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // First and last name
        Row(
          children: [
            // First name
            Expanded(
              child: CustomTextField(
                label: 'First Name',
                controller: _firstNameController,
                validator: (value) => ValidationUtils.validateRequired(
                  value,
                  fieldName: 'First name',
                ),
                textInputAction: TextInputAction.next,
                fillColor: AppColors.white.withOpacity(0.8),
                borderColor: AppColors.white.withOpacity(0.5),
              ),
            ),

            const SizedBox(width: 16),

            // Last name
            Expanded(
              child: CustomTextField(
                label: 'Last Name',
                controller: _lastNameController,
                validator: (value) => ValidationUtils.validateRequired(
                  value,
                  fieldName: 'Last name',
                ),
                textInputAction: TextInputAction.next,
                fillColor: AppColors.white.withOpacity(0.8),
                borderColor: AppColors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Email
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator: ValidationUtils.validateEmail,
          textInputAction: TextInputAction.next,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 16),

        // Phone
        CustomTextField(
          label: 'Phone Number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
          validator: ValidationUtils.validatePhone,
          textInputAction: TextInputAction.next,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 16),

        // Password
        CustomTextField(
          label: 'Password',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: ValidationUtils.validatePassword,
          textInputAction: TextInputAction.next,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 16),

        // Confirm Password
        CustomTextField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: (value) => ValidationUtils.validateConfirmPassword(
            _passwordController.text,
            value,
          ),
          textInputAction: TextInputAction.done,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 24),

        // Next button
        CustomButton(
          text: 'Next',
          onPressed: _nextStep,
          icon: Icons.arrow_forward,
          iconOnRight: true,
          color: AppColors.primary,
          textColor: AppColors.white,
        ),
      ],
    );
  }

  Widget _buildDriverDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ID Card Number
        CustomTextField(
          label: 'ID Card Number',
          controller: _idCardNumberController,
          validator: (value) => ValidationUtils.validateRequired(
            value,
            fieldName: 'ID card number',
          ),
          textInputAction: TextInputAction.next,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 16),

        // ID Card Photo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID Card Photo',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickImage(true),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
                child: _idCardPhoto != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _idCardPhoto!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take a photo',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Driver License Number
        CustomTextField(
          label: 'Driver License Number',
          controller: _driverLicenseNumberController,
          validator: (value) => ValidationUtils.validateRequired(
            value,
            fieldName: 'Driver license number',
          ),
          textInputAction: TextInputAction.next,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 16),

        // Driver License Photo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver License Photo',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickImage(false),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
                child: _driverLicensePhoto != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _driverLicensePhoto!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take a photo',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Years of Experience
        CustomTextField(
          label: 'Years of Experience',
          controller: _yearsOfExperienceController,
          keyboardType: TextInputType.number,
          validator: (value) => ValidationUtils.validateRange(
            value,
            fieldName: 'Years of experience',
            min: 1,
            max: 50,
          ),
          textInputAction: TextInputAction.done,
          fillColor: AppColors.white.withOpacity(0.8),
          borderColor: AppColors.white.withOpacity(0.5),
        ),

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            // Back button
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
              ),
            ),

            const SizedBox(width: 16),

            // Register button
            Expanded(
              child: CustomButton(
                text: 'Register',
                onPressed: _register,
                isLoading: _isLoading,
                color: AppColors.primary,
                textColor: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}