// lib/screens/common/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/user_model.dart';

/// User profile screen for viewing and editing profile information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) {
                _loadUserData(); // Reset data if canceling edit
              }
            });
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const EmptyState(
              title: 'No user data',
              message: 'Please log in to view your profile',
              icon: Icons.person_outline,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                
                const SizedBox(height: DesignSystem.space24),
                
                // Profile Information
                _buildProfileInfo(user),
                
                const SizedBox(height: DesignSystem.space24),
                
                // Statistics (for drivers)
                if (user.userType == UserType.driver)
                  _buildDriverStats(user),
                
                const SizedBox(height: DesignSystem.space24),
                
                // Action Buttons
                if (_isEditing)
                  _buildEditActions()
                else
                  _buildProfileActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space24),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: context.colors.primaryContainer,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: context.colors.onPrimaryContainer,
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _changeProfilePicture,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            // User Name
            Text(
              user.name ?? 'Unknown User',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: DesignSystem.space4),
            
            // User Type Badge
            StatusBadge(
              status: _getUserTypeLabel(user.userType),
              color: DesignSystem.info,
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            // Member Since
            Text(
              'Member since ${_formatDate(user.createdAt)}',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return SectionLayout(
      title: 'Profile Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              if (_isEditing) ...[
                AppInput(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                const SizedBox(height: DesignSystem.space16),
                AppInput(
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: DesignSystem.space16),
                AppInput(
                  label: 'Phone Number',
                  controller: _phoneController,
                  prefixIcon: Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                _buildInfoRow('Full Name', user.name ?? 'Not provided'),
                _buildInfoRow('Email', user.email ?? 'Not provided'),
                _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
                _buildInfoRow('User ID', user.id ?? 'Unknown'),
                _buildInfoRow('Account Status', user.isActive ? 'Active' : 'Inactive'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverStats(User user) {
    return SectionLayout(
      title: 'Driver Statistics',
      child: StatsSection(
        crossAxisCount: 2,
        stats: [
          StatItem(
            value: '${user.totalTrips ?? 0}',
            label: 'Total\\nTrips',
            icon: Icons.trip_origin,
            color: context.colors.primary,
          ),
          StatItem(
            value: user.rating?.toStringAsFixed(1) ?? '0.0',
            label: 'Average\\nRating',
            icon: Icons.star,
            color: context.warningColor,
          ),
          StatItem(
            value: '${user.totalDistanceDriven ?? 0} km',
            label: 'Distance\\nDriven',
            icon: Icons.straighten,
            color: context.successColor,
          ),
          StatItem(
            value: '${user.yearsExperience ?? 0}',
            label: 'Years\\nExperience',
            icon: Icons.work,
            color: context.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            text: 'Cancel',
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
              _loadUserData();
            },
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: AppButton(
            text: 'Save Changes',
            onPressed: _saveProfile,
            isLoading: _isLoading,
            icon: Icons.save,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        AppButton.outlined(
          text: 'Change Password',
          onPressed: _changePassword,
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: DesignSystem.space12),
        AppButton.outlined(
          text: 'Delete Account',
          onPressed: _deleteAccount,
          icon: Icons.delete_outline,
        ),
      ],
    );
  }

  String _getUserTypeLabel(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        return 'Driver';
      case UserType.admin:
        return 'Administrator';
      case UserType.passenger:
      default:
        return 'Passenger';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture change coming soon')),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.updateProfile(
        firstName: _nameController.text.trim().split(' ').first,
        lastName: _nameController.text.trim().split(' ').skip(1).join(' '),
        phoneNumber: _phoneController.text.trim(),
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: context.successColor,
          ),
        );
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update profile'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Delete',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}