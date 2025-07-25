// lib/screens/common/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/utils/validation_utils.dart';
import '../../services/navigation_service.dart';
import '../../helpers/error_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _emailController.text = user.email;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

        if (success) {
          setState(() {
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            message: authProvider.error ?? 'Failed to update profile',
          );
        }
      } catch (e) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset form if canceling
        _initializeForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return AppLayout(
      title: 'Profile',
      currentIndex: 3, // Profile tab
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: _toggleEdit,
        ),
      ],
      child: user == null
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            CustomCard(type: CardType.elevated, 
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(user),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: Text(
                      authProvider.userType?.name.toUpperCase() ?? 'USER',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile form
            CustomCard(type: CardType.elevated, 
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // First Name
                    CustomTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                      enabled: _isEditing,
                      validator: (value) => ValidationUtils.validateRequired(
                        value,
                        fieldName: 'First name',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Last Name
                    CustomTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      enabled: _isEditing,
                      validator: (value) => ValidationUtils.validateRequired(
                        value,
                        fieldName: 'Last name',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phone Number
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                      validator: ValidationUtils.validatePhone,
                    ),

                    const SizedBox(height: 16),

                    // Email (read-only)
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),

                      // Save button
                      CustomButton(
        text: 'Save Changes',
        onPressed: _saveProfile,
        isLoading: _isLoading,
        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Additional options
            CustomCard(type: CardType.elevated, 
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: _showChangePasswordDialog,
                  ),

                  const Divider(),

                  _buildOptionTile(
                    icon: Icons.notifications,
                    title: 'Notification Preferences',
                    subtitle: 'Manage your notification settings',
                    onTap: _showNotificationSettings,
                  ),

                  const Divider(),

                  _buildOptionTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'Change app language',
                    onTap: _showLanguageSelection,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(User? user) {
    if (user == null) return 'U';
    
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    
    return initials.isEmpty ? 'U' : initials;
  }

  void _showChangePasswordDialog() {
    // Implementation for change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Change password feature coming soon'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showNotificationSettings() {
    // Implementation for notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification settings feature coming soon'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showLanguageSelection() {
    // Implementation for language selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language selection feature coming soon'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}