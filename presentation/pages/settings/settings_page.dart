/// lib/presentation/pages/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/language.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/user_entity.dart'; // To check user type
import '../../blocs/app_settings/app_settings_cubit.dart';
import '../../blocs/auth/auth_bloc.dart'; // To get user type and logout
import '../../routes/route_names.dart';
// Import ThemedButton if needed
// import '../../widgets/common/themed_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings')), // TODO: Localize
        leading: const BackButton(),
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settingsState) {
          return ListView(
            children: [
              // --- Appearance Section ---
              _buildSectionHeader(context, tr('appearance')), // TODO: Localize
              _buildThemeSelector(context, settingsState.themeMode),
              const Divider(height: 1),
              _buildLanguageSelector(context, settingsState.locale),
              const Divider(height: 1),

              // --- Account Section ---
               _buildSectionHeader(context, tr('account')), // TODO: Localize
               // Conditionally show Edit Profile based on user type
               BlocBuilder<AuthBloc, AuthState>(
                 builder: (context, authState) {
                   if (authState is AuthAuthenticated) {
                      return _buildAccountLinkTile(
                         context,
                         icon: Icons.person_outline,
                         title: tr('edit_profile'), // TODO: Localize
                         onTap: () {
                            if (authState.user.isDriver) {
                               Log.i("Navigating to Driver Profile edit.");
                               // TODO: Define and push RouteNames.driverProfileEdit
                               // context.pushNamed(RouteNames.driverProfileEdit);
                            } else {
                               Log.i("Navigating to User Profile edit.");
                               // TODO: Define and push RouteNames.userProfileEdit
                                // context.pushNamed(RouteNames.userProfileEdit);
                            }
                            Helpers.showSnackBar(context, message: 'Edit Profile page not implemented yet.');
                         }
                      );
                   }
                   return const SizedBox.shrink(); // Hide if not authenticated
                 },
               ),
               const Divider(height: 1, indent: 16, endIndent: 16), // Slightly inset divider
                _buildAccountLinkTile(
                   context,
                   icon: Icons.lock_outline,
                   title: tr('change_password'), // TODO: Localize
                   onTap: () {
                      Log.i("Navigating to Change Password.");
                       // TODO: Define and push RouteNames.changePassword
                      // context.pushNamed(RouteNames.changePassword);
                       Helpers.showSnackBar(context, message: 'Change Password page not implemented yet.');
                   }
               ),
               const Divider(height: 1, indent: 16, endIndent: 16),
               // --- Logout Button ---
               Padding(
                 padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingLarge,
                    horizontal: AppTheme.spacingMedium),
                 child: OutlinedButton.icon(
                   icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                   label: Text(tr('logout'), style: const TextStyle(color: AppTheme.errorColor)), // TODO: Localize
                   style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
                   ),
                   onPressed: () async {
                      final bool confirm = await Helpers.showConfirmationDialog(
                         context,
                         title: tr('confirm_logout_title'), // TODO: Localize 'Confirm Logout'
                         content: tr('confirm_logout_message'), // TODO: Localize 'Are you sure you want to log out?'
                         confirmText: tr('logout'), // TODO: Localize
                         cancelText: tr('cancel') // TODO: Localize
                      ) ?? false; // Default to false if dialog dismissed

                      if (confirm && context.mounted) {
                          Log.i("User confirmed logout.");
                          context.read<AuthBloc>().add(const LoggedOut());
                          // Global listener on AuthBloc state should handle navigation
                      }
                   },
                 ),
               ),
               // Optional: App Version
                Padding(
                   padding: const EdgeInsets.only(top: AppTheme.spacingMedium, bottom: AppTheme.spacingLarge),
                   child: Text(
                      'Version ${AppConstants.appVersion}', // TODO: Localize 'Version'
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
                   ),
                 ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a styled section header.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingMedium,
        right: AppTheme.spacingMedium,
        top: AppTheme.spacingLarge,
        bottom: AppTheme.spacingSmall,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
      ),
    );
  }

  /// Builds the theme selection control.
  Widget _buildThemeSelector(BuildContext context, ThemeMode currentMode) {
     String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
     final theme = Theme.of(context);

    return Padding(
       padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall), // Reduce padding for segmented button edge alignment
      child: ListTile(
         leading: Icon(Icons.palette_outlined, color: theme.listTileTheme.iconColor),
         title: Text(tr('theme')), // TODO: Localize
         subtitle: Text(tr(currentMode.name)), // TODO: Localize 'Light', 'Dark', 'System'
         trailing: SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined, size: 18), label: Text(tr('light'))), // TODO: Localize
              ButtonSegment<ThemeMode>(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined, size: 18), label: Text(tr('dark'))), // TODO: Localize
              ButtonSegment<ThemeMode>(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined, size: 18), label: Text(tr('system'))), // TODO: Localize
            ],
             showSelectedIcon: false, // Don't show selected icon by default
             style: SegmentedButton.styleFrom(
                // Adjust styling for better fit and appearance
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                 padding: const EdgeInsets.symmetric(horizontal: 8),
                 side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                 selectedBackgroundColor: theme.colorScheme.primaryContainer,
                 selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
             ),
            selected: <ThemeMode>{currentMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
               context.read<AppSettingsCubit>().updateThemeMode(newSelection.first);
            },
         ),
      ),
    );
  }

  /// Builds the language selection list tile.
  Widget _buildLanguageSelector(BuildContext context, Locale currentLocale) {
     String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
     final currentLanguage = Language.fromLocale(currentLocale);
      final theme = Theme.of(context);

     return ListTile(
       leading: Icon(Icons.language_outlined, color: theme.listTileTheme.iconColor),
       title: Text(tr('language')), // TODO: Localize
       subtitle: Text(currentLanguage.nativeName), // Show native name
       trailing: const Icon(Icons.chevron_right),
       onTap: () {
           Log.d("Navigating to Language Selection page from Settings.");
           // Navigate to the dedicated language selection page
           context.pushNamed(RouteNames.languageSelection);
       },
     );
  }

   /// Builds a generic list tile for account-related navigation links.
  Widget _buildAccountLinkTile(BuildContext context, {
     required IconData icon,
     required String title,
     required VoidCallback onTap,
  }) {
     final theme = Theme.of(context);
     return ListTile(
       leading: Icon(icon, color: theme.listTileTheme.iconColor),
       title: Text(title),
       trailing: const Icon(Icons.chevron_right),
       onTap: onTap,
     );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
