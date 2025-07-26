// lib/screens/common/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/enhanced_text_field.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../core/utils/validation_utils.dart';
import '../../services/navigation_service.dart';
import '../../helpers/error_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeForm();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _animationController.dispose();
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
              content: const Text('Profile updated successfully'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
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
        _initializeForm();
      }
    });
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

  Color _getUserTypeColor(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        return AppTheme.secondary;
      case UserType.admin:
        return AppTheme.tertiary;
      case UserType.passenger:
      default:
        return AppTheme.primary;
    }
  }

  String _getUserTypeLabel(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        return 'DRIVER';
      case UserType.admin:
        return 'ADMIN';
      case UserType.passenger:
      default:
        return 'PASSENGER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return AppLayout(
      title: 'Profile',
      currentIndex: 3,
      backgroundColor: AppTheme.neutral50,
      actions: [
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _toggleEdit,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
      child: user == null
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Profile Header
                          _buildProfileHeader(user, authProvider),

                          const SizedBox(height: 24),

                          // Profile Form
                          _buildProfileForm(user),

                          const SizedBox(height: 24),

                          // Additional Options
                          _buildAdditionalOptions(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildProfileHeader(User user, AuthProvider authProvider) {
    final userTypeColor = _getUserTypeColor(authProvider.userType);
    
    return ModernCard(
      type: ModernCardType.glass,
      variant: ModernCardVariant.primary,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Avatar with elegant design
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  userTypeColor,
                  userTypeColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: userTypeColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(user),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // User Name
          Text(
            '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // User Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: userTypeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: userTypeColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getUserTypeLabel(authProvider.userType),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: userTypeColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(User user) {
    return ModernCard(
      type: ModernCardType.glass,
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),

            const SizedBox(height: 24),

            // First Name
            EnhancedTextField(
              label: 'First Name',
              controller: _firstNameController,
              enabled: _isEditing,
              required: true,
              validator: (value) => ValidationUtils.validateRequired(
                value,
                fieldName: 'First name',
              ),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),

            const SizedBox(height: 20),

            // Last Name
            EnhancedTextField(
              label: 'Last Name',
              controller: _lastNameController,
              enabled: _isEditing,
              required: true,
              validator: (value) => ValidationUtils.validateRequired(
                value,
                fieldName: 'Last name',
              ),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),

            const SizedBox(height: 20),

            // Phone Number
            EnhancedTextField.phone(
              label: 'Phone Number',
              controller: _phoneController,
              enabled: _isEditing,
              validator: ValidationUtils.validatePhone,
            ),

            const SizedBox(height: 20),

            // Email (read-only)
            EnhancedTextField.email(
              label: 'Email',
              controller: _emailController,
              enabled: false,
            ),

            if (_isEditing) ...[
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Cancel',
                      onPressed: _toggleEdit,
                      size: ModernButtonSize.large,
                      leadingIcon: Icons.close_rounded,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'Save Changes',
                      onPressed: _isLoading ? null : _saveProfile,
                      isLoading: _isLoading,
                      size: ModernButtonSize.large,
                      leadingIcon: Icons.save_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return ModernCard(
      type: ModernCardType.glass,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),

          const SizedBox(height: 20),

          _buildOptionTile(
            icon: Icons.lock_outline_rounded,
            iconColor: AppTheme.warning,
            title: 'Change Password',
            subtitle: 'Update your account security',
            onTap: _showChangePasswordDialog,
          ),

          const SizedBox(height: 4),

          _buildOptionTile(
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.info,
            title: 'Notification Settings',
            subtitle: 'Manage your notifications',
            onTap: _showNotificationSettings,
          ),

          const SizedBox(height: 4),

          _buildOptionTile(
            icon: Icons.language_rounded,
            iconColor: AppTheme.tertiary,
            title: 'Language & Region',
            subtitle: 'Change app language',
            onTap: _showLanguageSelection,
          ),

          const SizedBox(height: 4),

          _buildOptionTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppTheme.secondary,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: _showHelpSupport,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppTheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Change password feature coming soon'),
        backgroundColor: AppTheme.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification settings coming soon'),
        backgroundColor: AppTheme.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLanguageSelection() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Language selection coming soon'),
        backgroundColor: AppTheme.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Help & support coming soon'),
        backgroundColor: AppTheme.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}