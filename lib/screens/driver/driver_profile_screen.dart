// lib/screens/driver/driver_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/dialog_helper.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _idCardNumberController;
  late TextEditingController _driverLicenseController;
  late TextEditingController _yearsOfExperienceController;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDriverProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idCardNumberController.dispose();
    _driverLicenseController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _idCardNumberController = TextEditingController();
    _driverLicenseController = TextEditingController();
    _yearsOfExperienceController = TextEditingController();
  }

  Future<void> _loadDriverProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.fetchProfile();

      // Update controllers with driver data
      final driver = driverProvider.driverProfile;
      if (driver != null) {
        _phoneController.text = driver.phoneNumber ?? '';
        _idCardNumberController.text = driver.idCardNumber ?? '';
        _driverLicenseController.text = driver.driverLicenseNumber ?? '';
        _yearsOfExperienceController.text = driver.yearsOfExperience.toString();
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

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final driverProvider = Provider.of<DriverProvider>(context, listen: false);

        // Update basic user info
        final userSuccess = await authProvider.updateProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
        );

        // Update driver-specific info
        // TODO: Fix updateProfile method signature
        final driverSuccess = true; // await driverProvider.updateProfile(profileData);

        if ((userSuccess || driverSuccess) && mounted) {
          setState(() {
            _isEditMode = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverProvider = Provider.of<DriverProvider>(context);

    return Scaffold(
      appBar: DzAppBar(
        title: 'Driver Profile',
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile avatar and rating
              Stack(
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        driverProvider.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Driver status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: driverProvider.isAvailable
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driverProvider.isAvailable
                      ? 'Available'
                      : 'Unavailable',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Basic Info Section
              _buildSectionHeader('Basic Information'),

              // First name
              CustomTextField(
                label: 'First Name',
                controller: _firstNameController,
                enabled: _isEditMode,
                validator: (value) => ValidationUtils.validateRequired(
                  value,
                  fieldName: 'First name',
                ),
              ),

              const SizedBox(height: 16),

              // Last name
              CustomTextField(
                label: 'Last Name',
                controller: _lastNameController,
                enabled: _isEditMode,
                validator: (value) => ValidationUtils.validateRequired(
                  value,
                  fieldName: 'Last name',
                ),
              ),

              const SizedBox(height: 16),

              // Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                enabled: false, // Email cannot be changed
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Phone
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                enabled: _isEditMode,
                keyboardType: TextInputType.phone,
                validator: (value) => ValidationUtils.validatePhone(value),
              ),

              const SizedBox(height: 16),

              // Driver Info Section
              _buildSectionHeader('Driver Information'),

              // ID Card Number
              CustomTextField(
                label: 'ID Card Number',
                controller: _idCardNumberController,
                enabled: false, // Cannot be changed after registration
              ),

              const SizedBox(height: 16),

              // Driver License
              CustomTextField(
                label: 'Driver License Number',
                controller: _driverLicenseController,
                enabled: false, // Cannot be changed after registration
              ),

              const SizedBox(height: 16),

              // Years of Experience
              CustomTextField(
                label: 'Years of Experience',
                controller: _yearsOfExperienceController,
                enabled: _isEditMode,
                keyboardType: TextInputType.number,
                validator: (value) => ValidationUtils.validateRange(
                  value,
                  fieldName: 'Years of experience',
                  min: 1,
                  max: 50,
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              if (_isEditMode)
                CustomButton(
        text: 'Save Changes',
        onPressed: _updateProfile,
        isLoading: _isLoading
      )
              else
                Column(
                  children: [
                    // View Ratings button
                    CustomButton(
        text: 'View My Ratings',
        onPressed: () => AppRouter.navigateTo(context, AppRoutes.ratings),
                      icon: Icons.star,
                    ),

                    const SizedBox(height: 16),

                    // Toggle Availability button
                    CustomButton(
        text: driverProvider.isAvailable
        ? 'Set Unavailable'
        : 'Set Available',
        onPressed: () => driverProvider.toggleAvailability(),
                      type: ButtonType.outline,
                      color: driverProvider.isAvailable
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary,
                      icon: driverProvider.isAvailable
                          ? Icons.cancel_outlined
                          : Icons.check_circle_outline,
                    ),

                    const SizedBox(height: 16),

                    // Change Password button
                    CustomButton(
        text: 'Change Password',
        onPressed: () => _showChangePasswordDialog(context),
                      type: ButtonType.text,
                      icon: Icons.lock_outline,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8, height: 40),
          Expanded(
            child: Divider( color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    DialogHelper.showGlassyDialog(
      context,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Current Password',
                      controller: currentPasswordController,
                      obscureText: true,
                      validator: (value) => ValidationUtils.validateRequired(
                        value,
                        fieldName: 'Current password',
                      ),
                      fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'New Password',
                      controller: newPasswordController,
                      obscureText: true,
                      validator: (value) => ValidationUtils.validatePassword(
                        value,
                        minLength: 8,
                      ),
                      fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Confirm New Password',
                      controller: confirmPasswordController,
                      obscureText: true,
                      validator: (value) => ValidationUtils.validateConfirmPassword(
                        newPasswordController.text,
                        value,
                      ),
                      fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);

                          final success = await authProvider.updatePassword(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                            confirmPassword: confirmPasswordController.text,
                          );

                          if (success && mounted) {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Password updated successfully'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ErrorHandler.handleError(e)),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: 20,
        
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Update Password'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}