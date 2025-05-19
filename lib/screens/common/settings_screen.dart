// lib/screens/common/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../localization/localization_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../helpers/dialog_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile ?? {};

    // Get notification settings from profile
    final pushNotificationsEnabled = profile['push_notifications_enabled'] ?? true;
    final emailNotificationsEnabled = profile['email_notifications_enabled'] ?? true;
    final smsNotificationsEnabled = profile['sms_notifications_enabled'] ?? false;

    return Scaffold(
      appBar: const DzAppBar(
        title: 'Settings',
      ),
      body: ListView(
        children: [
          // Language section
          _buildSectionHeader(context, 'Language'),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(localizationProvider.currentLanguageName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context),
          ),

          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: pushNotificationsEnabled,
            onChanged: (value) => _updateNotificationSetting(
              context,
              'push_notifications_enabled',
              value,
            ),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: emailNotificationsEnabled,
            onChanged: (value) => _updateNotificationSetting(
              context,
              'email_notifications_enabled',
              value,
            ),
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive notifications via SMS'),
            value: smsNotificationsEnabled,
            onChanged: (value) => _updateNotificationSetting(
              context,
              'sms_notifications_enabled',
              value,
            ),
          ),

          const Divider(),

          // App info section
          _buildSectionHeader(context, 'About'),
          ListTile(
            title: const Text('App Version'),
            subtitle: Text('${AppConfig.appVersion} (${AppConfig.appBuildNumber})'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show terms of service
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);

    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Language',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...AppConstants.supportedLanguages.map((language) {
            final languageName = AppConstants.languageNames[language] ?? language.toUpperCase();
            final isSelected = localizationProvider.locale.languageCode == language;

            return ListTile(
              title: Text(
                languageName,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                Icons.check_circle,
                color: AppColors.white,
              )
                  : null,
              onTap: () {
                localizationProvider.changeLocale(language);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _updateNotificationSetting(
      BuildContext context,
      String setting,
      bool value,
      ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Prepare settings to update
    final Map<String, dynamic> settings = {};
    settings[setting] = value;

    // TODO: Implement this when UserService is extended with updateProfileSettings method
    // await authProvider.updateProfileSettings(settings);
  }
}