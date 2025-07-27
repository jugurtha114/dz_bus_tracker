// lib/screens/driver/driver_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../models/driver_model.dart';
import '../../widgets/widgets.dart';

/// Modern driver profile screen with comprehensive driver information
class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _experienceController;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDriverProfile();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseNumberController = TextEditingController();
    _experienceController = TextEditingController();
  }

  Future<void> _loadDriverProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = context.read<DriverProvider>();
      await driverProvider.loadDriverProfile();
      _populateFields();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $error')),
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

  void _populateFields() {
    final driverProvider = context.read<DriverProvider>();
    final driver = driverProvider.currentDriver;

    if (driver != null) {
      _firstNameController.text = driver.firstName ?? '';
      _lastNameController.text = driver.lastName ?? '';
      _emailController.text = driver.email ?? '';
      _phoneController.text = driver.phoneNumber ?? '';
      _licenseNumberController.text = driver.licenseNumber ?? '';
      _experienceController.text = driver.yearsOfExperience?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Driver Profile',
      actions: [
        IconButton(
          icon: Icon(_isEditMode ? Icons.save : Icons.edit),
          onPressed: _isEditMode ? _saveProfile : _toggleEditMode,
        ),
      ],
      child: Consumer2<DriverProvider, AuthProvider>(
        builder: (context, driverProvider, authProvider, child) {
          if (_isLoading) {
            return const LoadingState.fullScreen();
          }

          final driver = driverProvider.currentDriver;
          final user = authProvider.user;

          return RefreshIndicator(
            onRefresh: _loadDriverProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(context, driver, user),
                    
                    const SizedBox(height: DesignSystem.space24),
                    
                    // Personal Information
                    _buildPersonalInformation(context),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    // Driver Information
                    _buildDriverInformation(context, driver),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    // Statistics
                    _buildDriverStatistics(context, driver),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    // Documents
                    _buildDocumentsSection(context, driver),
                    
                    const SizedBox(height: DesignSystem.space24),
                    
                    // Action Buttons
                    if (!_isEditMode) ...[
                      _buildActionButtons(context),
                      const SizedBox(height: DesignSystem.space24),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic driver, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: context.colors.onPrimary,
                backgroundImage: user?.profileImage != null
                    ? NetworkImage(user!.profileImage!)
                    : null,
                child: user?.profileImage == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: context.colors.primary,
                      )
                    : null,
              ),
              if (_isEditMode)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.colors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.onPrimary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: context.colors.onSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // Name and Status
          Text(
            '${driver?.firstName ?? 'Driver'} ${driver?.lastName ?? ''}',
            style: context.textStyles.headlineSmall?.copyWith(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DesignSystem.space8),
          
          StatusBadge(
            status: driver?.status?.toUpperCase() ?? 'INACTIVE',
            color: _getDriverStatusColor(driver?.status),
          ),
          
          const SizedBox(height: DesignSystem.space8),
          
          Text(
            'Driver ID: ${driver?.id ?? 'N/A'}',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(BuildContext context) {
    return SectionLayout(
      title: 'Personal Information',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppInput(
                  label: 'First Name',
                  controller: _firstNameController,
                  enabled: _isEditMode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: DesignSystem.space16),
              Expanded(
                child: AppInput(
                  label: 'Last Name',
                  controller: _lastNameController,
                  enabled: _isEditMode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          AppInput(
            label: 'Email',
            controller: _emailController,
            enabled: _isEditMode,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          AppInput(
            label: 'Phone Number',
            controller: _phoneController,
            enabled: _isEditMode,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInformation(BuildContext context, dynamic driver) {
    return SectionLayout(
      title: 'Driver Information',
      child: Column(
        children: [
          AppInput(
            label: 'License Number',
            controller: _licenseNumberController,
            enabled: _isEditMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter license number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          AppInput(
            label: 'Years of Experience',
            controller: _experienceController,
            enabled: _isEditMode,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter years of experience';
              }
              final years = int.tryParse(value);
              if (years == null || years < 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          // License Expiry (Read-only)
          AppInput(
            label: 'License Expiry',
            controller: TextEditingController(
              text: driver?.licenseExpiryDate?.toString().substring(0, 10) ?? 'Not available'
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatistics(BuildContext context, dynamic driver) {
    return SectionLayout(
      title: 'Statistics',
      child: StatsSection(
        crossAxisCount: 2,
        stats: [
          StatItem(
            value: '${driver?.totalTrips ?? 0}',
            label: 'Total\\nTrips',
            icon: Icons.route,
            color: context.colors.primary,
          ),
          StatItem(
            value: '${driver?.rating?.toStringAsFixed(1) ?? '0.0'}',
            label: 'Average\\nRating',
            icon: Icons.star,
            color: context.warningColor,
          ),
          StatItem(
            value: '${driver?.totalDistance ?? 0} km',
            label: 'Total\\nDistance',
            icon: Icons.speed,
            color: context.infoColor,
          ),
          StatItem(
            value: '${driver?.totalHours ?? 0}h',
            label: 'Total\\nHours',
            icon: Icons.schedule,
            color: context.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context, dynamic driver) {
    return SectionLayout(
      title: 'Documents',
      child: Column(
        children: [
          _buildDocumentItem(
            context,
            title: 'Driver License',
            status: driver?.licenseVerified == true ? 'Verified' : 'Pending',
            onTap: () => _viewDocument('license'),
          ),
          const SizedBox(height: DesignSystem.space8),
          _buildDocumentItem(
            context,
            title: 'Identity Card',
            status: driver?.idVerified == true ? 'Verified' : 'Pending',
            onTap: () => _viewDocument('id'),
          ),
          const SizedBox(height: DesignSystem.space8),
          _buildDocumentItem(
            context,
            title: 'Medical Certificate',
            status: driver?.medicalCertVerified == true ? 'Verified' : 'Pending',
            onTap: () => _viewDocument('medical'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, {
    required String title,
    required String status,
    required VoidCallback onTap,
  }) {
    final isVerified = status == 'Verified';
    
    return AppCard(
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          isVerified ? Icons.verified : Icons.pending,
          color: isVerified ? context.successColor : context.warningColor,
        ),
        title: Text(title),
        subtitle: Text(status),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      child: Column(
        children: [
          AppButton(
            text: 'View Performance',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.driverPerformance);
            },
            icon: Icons.analytics,
          ),
          
          const SizedBox(height: DesignSystem.space12),
          
          AppButton.outlined(
            text: 'Change Password',
            onPressed: _changePassword,
            icon: Icons.lock,
          ),
        ],
      ),
    );
  }

  Color _getDriverStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DesignSystem.busActive;
      case 'busy':
        return DesignSystem.warning;
      case 'offline':
        return DesignSystem.busInactive;
      default:
        return DesignSystem.onSurfaceVariant;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = context.read<DriverProvider>();
      
      // Create updated driver data
      final updateRequest = DriverUpdateRequest(
        phoneNumber: _phoneController.text,
        yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
      );

      // For now, we'll update this to use a simplified approach
      // In a real implementation, this would call the driver service
      // await driverProvider.updateDriverProfile(currentDriver.copyWith(...));
      
      // Mock update for now
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isEditMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
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

  void _changeProfileImage() {
    // Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image change feature coming soon')),
    );
  }

  void _viewDocument(String type) {
    // Implement document viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing $type document')),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change functionality will be implemented here.'),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Change',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}