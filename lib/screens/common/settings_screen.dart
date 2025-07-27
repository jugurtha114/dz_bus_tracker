// lib/screens/common/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

/// Modern settings screen with comprehensive app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Settings',
      child: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return _buildUserProfileSection(context, authProvider);
              },
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            // Appearance Settings - use individual consumers
            _buildAppearanceSection(context),
            
            const SizedBox(height: DesignSystem.space16),
            
            // Notification Settings
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return _buildNotificationSection(context, authProvider);
              },
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            // App Settings
            _buildAppSection(context),
            
            const SizedBox(height: DesignSystem.space16),
            
            // Account Settings
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return _buildAccountSection(context, authProvider);
              },
            ),
            
            const SizedBox(height: DesignSystem.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    
    return SectionLayout(
      title: 'Profile',
      child: AppCard(
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: context.colors.primaryContainer,
            child: user?.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      user!.profileImage!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: context.colors.onPrimaryContainer,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: context.colors.onPrimaryContainer,
                  ),
          ),
          title: Text(
            user?.name ?? 'User',
            style: context.textStyles.titleMedium,
          ),
          subtitle: Text(
            user?.email ?? 'No email',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.profile);
          },
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return SectionLayout(
      title: 'Appearance',
      child: Column(
        children: [
          // Theme Mode - hardcoded to light mode since we're using light only
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: Icon(
                Icons.light_mode,
                color: context.colors.primary,
              ),
              title: const Text('Theme'),
              subtitle: const Text('Light Mode (Fixed)'),
              trailing: const Switch(
                value: false, // Always light mode
                onChanged: null, // Disabled
              ),
            ),
          ),
          
          // Language
          Consumer<LocalizationProvider>(
            builder: (context, localizationProvider, child) {
              return AppCard(
                child: ListTile(
                  leading: Icon(
                    Icons.language,
                    color: context.colors.primary,
                  ),
                  title: const Text('Language'),
                  subtitle: Text(localizationProvider.currentLanguageName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, localizationProvider),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, AuthProvider authProvider) {
    // Mock notification settings - replace with actual provider
    return SectionLayout(
      title: 'Notifications',
      child: Column(
        children: [
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: SwitchListTile(
              secondary: Icon(
                Icons.notifications,
                color: context.colors.primary,
              ),
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on your device'),
              value: true, // Replace with actual state
              onChanged: (value) {
                // Handle notification toggle
                _updateNotificationSetting('push', value);
              },
            ),
          ),
          
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: SwitchListTile(
              secondary: Icon(
                Icons.email,
                color: context.colors.primary,
              ),
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive updates via email'),
              value: false, // Replace with actual state
              onChanged: (value) {
                _updateNotificationSetting('email', value);
              },
            ),
          ),
          
          AppCard(
            child: ListTile(
              leading: Icon(
                Icons.tune,
                color: context.colors.primary,
              ),
              title: const Text('Notification Preferences'),
              subtitle: const Text('Customize notification types'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to detailed notification settings
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return SectionLayout(
      title: 'App',
      child: Column(
        children: [
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: Icon(
                Icons.help_outline,
                color: context.colors.primary,
              ),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help and contact support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.about);
              },
            ),
          ),
          
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: context.colors.primary,
              ),
              title: const Text('About'),
              subtitle: const Text('App version and information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.about);
              },
            ),
          ),
          
          AppCard(
            child: ListTile(
              leading: Icon(
                Icons.privacy_tip_outlined,
                color: context.colors.primary,
              ),
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our privacy policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Open privacy policy
                _showPrivacyPolicy(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider) {
    return SectionLayout(
      title: 'Account',
      child: Column(
        children: [
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: Icon(
                Icons.lock_outline,
                color: context.colors.primary,
              ),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
          ),
          
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space8),
            child: ListTile(
              leading: Icon(
                Icons.backup,
                color: context.colors.primary,
              ),
              title: const Text('Backup Data'),
              subtitle: const Text('Backup your app data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showBackupDialog(context);
              },
            ),
          ),
          
          AppCard(
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: context.colors.error,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(color: context.colors.error),
              ),
              subtitle: const Text('Sign out of your account'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showSignOutDialog(context, authProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocalizationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: provider.currentLocale.languageCode,
                onChanged: (value) {
                  provider.setLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Français'),
              leading: Radio<String>(
                value: 'fr',
                groupValue: provider.currentLocale.languageCode,
                onChanged: (value) {
                  provider.setLanguage('fr');
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('العربية'),
              leading: Radio<String>(
                value: 'ar',
                groupValue: provider.currentLocale.languageCode,
                onChanged: (value) {
                  provider.setLanguage('ar');
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _updateNotificationSetting(String type, bool value) {
    // Handle notification setting updates
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type notifications ${value ? 'enabled' : 'disabled'}'),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Show privacy policy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy content would go here...'),
        actions: [
          AppButton.text(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change functionality would go here...'),
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

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Are you sure you want to backup your data?'),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Backup',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data backup started...')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Sign Out',
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}