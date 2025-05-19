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

    _firstNameController = TextEditingController(text: user?['first_name'] ?? '');
    _lastNameController = TextEditingController(text: user?['last_name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phone_number'] ?? '');
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
        _phoneController.text = driver['phone_number'] ?? '';
        _idCardNumberController.text = driver['id_card_number'] ?? '';
        _driverLicenseController.text = driver['driver_license_number'] ?? '';
        _yearsOfExperienceController.text = driver['years_of_experience']?.toString() ?? '';
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
        final driverSuccess = await driverProvider.updateProfile(
          phoneNumber: _phoneController.text,
          yearsOfExperience: int.tryParse(_yearsOfExperienceController.text),
        );

        if ((userSuccess || driverSuccess) && mounted) {
          setState(() {
            _isEditMode = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
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
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
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
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.white,
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
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        driverProvider.rating.toStringAsFixed(1),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
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
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driverProvider.isAvailable
                      ? 'Available'
                      : 'Unavailable',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              // Action buttons
              if (_isEditMode)
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _updateProfile,
                  isLoading: _isLoading,
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
                      type: ButtonType.outlined,
                      color: driverProvider.isAvailable
                          ? AppColors.error
                          : AppColors.success,
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
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: AppColors.primary.withOpacity(0.5),
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
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.white,
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
                      fillColor: AppColors.white.withOpacity(0.8),
                      borderColor: AppColors.white.withOpacity(0.5),
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
                      fillColor: AppColors.white.withOpacity(0.8),
                      borderColor: AppColors.white.withOpacity(0.5),
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
                      fillColor: AppColors.white.withOpacity(0.8),
                      borderColor: AppColors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
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
                              const SnackBar(
                                content: Text('Password updated successfully'),
                                backgroundColor: AppColors.success,
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
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
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