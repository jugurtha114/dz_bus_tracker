/// lib/presentation/pages/onboarding/language_selection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Assuming GoRouter

import '../../../config/themes/app_theme.dart';
import '../../../core/enums/language.dart';
import '../../../core/utils/logger.dart';
import '../../blocs/app_settings/app_settings_cubit.dart';
import '../../routes/route_names.dart';
// Import localization extension if available for title/button text
// import '../../../i18n/app_localizations.dart';
// Import custom button if using ThemedButton
// import '../../widgets/common/themed_button.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // Placeholder for localization - replace with context.tr('key') later
    String tr(String key) => key;

    return Scaffold(
      body: Container(
        // Apply gradient background similar to splash
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryColor, // Darker green top
              AppTheme.primaryColor, // Lighter green bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  tr('select_language'), // TODO: Localize 'Select Your Language'
                  style: textTheme.displaySmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  tr('choose_preferred_language'), // TODO: Localize 'Choose your preferred language for the app.'
                  style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXLarge),

                // Language List
                Expanded(
                  child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
                    builder: (context, state) {
                      return ListView.separated(
                        itemCount: Language.values.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppTheme.spacingMedium),
                        itemBuilder: (context, index) {
                          final language = Language.values[index];
                          final bool isSelected = state.locale == language.locale;

                          return _LanguageTile(
                            language: language,
                            isSelected: isSelected,
                            onTap: () {
                              Log.i('Language selected: ${language.value}');
                              context
                                  .read<AppSettingsCubit>()
                                  .updateLanguage(language);
                              // Optional: Automatically navigate after selection
                              // context.goNamed(RouteNames.onboarding);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // Continue Button
                const SizedBox(height: AppTheme.spacingMedium),
                ElevatedButton(
                  // Use ThemedButton if implemented or style ElevatedButton
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium),
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                  ),
                  onPressed: () {
                    Log.i('Continue button pressed from Language Selection.');
                    // Navigate to the next step (Onboarding or Login/Register)
                    context.goNamed(RouteNames.onboarding);
                    // Alternative: context.goNamed(RouteNames.login);
                  },
                  child: Text(
                    tr('continue_button'), // TODO: Localize 'Continue'
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                // Example using ThemedButton (if you created it based on earlier example)
                // ThemedButton(
                //   text: tr('continue_button'), // TODO: Localize 'Continue'
                //   onPressed: () {
                //      Log.i('Continue button pressed from Language Selection.');
                //      context.goNamed(RouteNames.onboarding);
                //   },
                //   style: ElevatedButton.styleFrom(
                //      backgroundColor: Colors.white,
                //      foregroundColor: AppTheme.primaryColor,
                //   ),
                //   isFullWidth: true,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom widget for displaying a language option tile.
class _LanguageTile extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? AppTheme.elevationMedium : AppTheme.elevationSmall,
      margin: EdgeInsets.zero, // Margin handled by ListView separator
      color: isSelected
          ? Colors.white.withOpacity(0.3)
          : Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: BorderSide(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingLarge, // Make tiles taller
          ),
          child: Row(
            children: [
              // Optional: Flag Icon
              // Icon(getFlagIcon(language), size: 28, color: Colors.white),
              // const SizedBox(width: AppTheme.spacingMedium),

              // Language Name (Native)
              Expanded(
                child: Text(
                  language.nativeName, // Display native name (e.g., Français)
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),

              // Selection Indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                )
              else
                 Icon(
                  Icons.circle_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder for flag icons if you add them later
  // IconData getFlagIcon(Language language) { ... }
}
