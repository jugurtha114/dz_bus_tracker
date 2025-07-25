// lib/screens/auth/driver_register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:convert';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
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

  // Image files and web image data
  File? _idCardPhoto;
  File? _driverLicensePhoto;
  Uint8List? _webIdCardImage;
  Uint8List? _webDriverLicenseImage;
  XFile? _idCardXFile;
  XFile? _driverLicenseXFile;

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

// lib/screens/auth/driver_register_screen.dart

  Future<void> _pickImage(bool isIdCard) async {
    // Request permission
    final hasPermission = await PermissionHelper.requestCamera(context);

    if (!hasPermission) {
      return;
    }

    // Pick image
    final picker = ImagePicker();
    final ImageSource source = kIsWeb ? ImageSource.gallery : ImageSource.camera;

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        if (isIdCard) {
          _idCardXFile = pickedFile;
          if (kIsWeb) {
            // For web, read the XFile as bytes
            pickedFile.readAsBytes().then((value) {
              setState(() {
                _webIdCardImage = value;
              });
            });
          } else {
            // For mobile, create a File object
            _idCardPhoto = File(pickedFile.path);
          }
        } else {
          _driverLicenseXFile = pickedFile;
          if (kIsWeb) {
            // For web, read the XFile as bytes
            pickedFile.readAsBytes().then((value) {
              setState(() {
                _webDriverLicenseImage = value;
              });
            });
          } else {
            // For mobile, create a File object
            _driverLicensePhoto = File(pickedFile.path);
          }
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
      // Validate driver info - include all possible photo variables in the check
      return _idCardNumberController.text.isNotEmpty &&
          _driverLicenseNumberController.text.isNotEmpty &&
          _yearsOfExperienceController.text.isNotEmpty &&
          (_idCardPhoto != null || _webIdCardImage != null || _idCardXFile != null) &&
          (_driverLicensePhoto != null || _webDriverLicenseImage != null || _driverLicenseXFile != null);
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep = 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields correctly.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

// lib/screens/auth/driver_register_screen.dart
// lib/screens/auth/driver_register_screen.dart - just the _register method

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if photos are available - more comprehensive check
      bool hasIdCardPhoto = _idCardPhoto != null || _webIdCardImage != null || _idCardXFile != null;
      bool hasDriverLicensePhoto = _driverLicensePhoto != null || _webDriverLicenseImage != null || _driverLicenseXFile != null;

      if (!hasIdCardPhoto || !hasDriverLicensePhoto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please upload both ID card and driver license photos.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Determine which photo object to use based on platform
        dynamic idCardPhoto;
        dynamic driverLicensePhoto;

        if (kIsWeb) {
          // On web, prefer using the Uint8List for actual binary data
          idCardPhoto = _webIdCardImage ?? _idCardXFile;
          driverLicensePhoto = _webDriverLicenseImage ?? _driverLicenseXFile;
        } else {
          // On mobile, prefer File objects
          idCardPhoto = _idCardPhoto ?? _idCardXFile;
          driverLicensePhoto = _driverLicensePhoto ?? _driverLicenseXFile;
        }

        final success = await authProvider.registerDriver(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          idCardNumber: _idCardNumberController.text.trim(),
          idCardPhoto: idCardPhoto,
          driverLicenseNumber: _driverLicenseNumberController.text.trim(),
          driverLicensePhoto: driverLicensePhoto,
          yearsOfExperience: int.tryParse(_yearsOfExperienceController.text) ?? 0,
        );

        if (mounted) {
          if (success) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Registration submitted! Your application will be reviewed.'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );

            // Navigate to login screen
            AppRouter.navigateToReplacement(context, AppRoutes.login);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Registration failed. Please try again.'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary,
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Register as Driver',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Complete your profile to start driving',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Progress indicators
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8, height: 40),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentStep == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Step labels
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Account Info',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: _currentStep == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8, height: 40),
                      Expanded(
                        child: Text(
                          'Driver Details',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: _currentStep == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Registration form in a glass container
                  CustomCard(type: CardType.elevated, 
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: _currentStep == 0
                          ? _buildAccountInfoForm()
                          : _buildDriverDetailsForm(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRouter.navigateToReplacement(context, AppRoutes.login),
                        child: Text(
                          'Login',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),

            const SizedBox(width: 16, height: 40),

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
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),

        const SizedBox(height: 16),

        // Next button
        CustomButton(
        text: 'Next',
        onPressed: _nextStep,
        icon: Icons.arrow_forward,
        color: Theme.of(context).colorScheme.primary,
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),

        const SizedBox(height: 16),

        // ID Card Photo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID Card Photo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickImage(true),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: _buildPhotoPreview(
                  isIdCard: true,
                  photo: _idCardPhoto,
                  webImage: _webIdCardImage,
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),

        const SizedBox(height: 16),

        // Driver License Photo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver License Photo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickImage(false),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: _buildPhotoPreview(
                  isIdCard: false,
                  photo: _driverLicensePhoto,
                  webImage: _webDriverLicenseImage,
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
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            // Back button
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(width: 16, height: 40),

            // Register button
            Expanded(
              child: CustomButton(
        text: 'Register',
        onPressed: _register,
        isLoading: _isLoading,
        color: Theme.of(context).colorScheme.primary,
      ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build the photo preview widget for both web and mobile
  Widget _buildPhotoPreview({
    required bool isIdCard,
    required File? photo,
    required Uint8List? webImage,
  }) {
    if (kIsWeb) {
      // Web version
      if (webImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            webImage,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }
    } else {
      // Mobile version
      if (photo != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            photo,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }
    }

    // No image selected yet
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to take a photo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}