// lib/screens/common/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/dialog_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _firstNameController = TextEditingController(text: user?['first_name'] ?? '');
    _lastNameController = TextEditingController(text: user?['last_name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phone_number'] ?? '');
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

        final success = await authProvider.updateProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
        );

        if (success && mounted) {
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

  void _showChangePasswordDialog() {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: DzAppBar(
        title: 'My Profile',
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

              const SizedBox(height: 24),

              // User type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  authProvider.userType?.toUpperCase() ?? 'USER',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Profile fields
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

              CustomTextField(
                label: 'Email',
                controller: _emailController,
                enabled: false, // Email cannot be changed
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                enabled: _isEditMode,
                keyboardType: TextInputType.phone,
                validator: (value) => ValidationUtils.validatePhone(value),
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
                CustomButton(
                  text: 'Change Password',
                  onPressed: _showChangePasswordDialog,
                  type: ButtonType.outlined,
                  icon: Icons.lock,
                ),
            ],
          ),
        ),
      ),
    );
  }
}