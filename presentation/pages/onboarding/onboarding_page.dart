/// lib/presentation/pages/onboarding/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// CORRECTED: Import ThemeConstants
import '../../../core/constants/theme_constants.dart';
// REMOVED: AppTheme import not needed for constants
// import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/di/service_locator.dart'; // Import Service Locator (sl)
import '../../../core/utils/logger.dart';
import '../../routes/route_names.dart';
import '../../../core/utils/helpers.dart'; // For Helpers.showSnackBar

// Helper class (keep as before or move to separate file)
class _OnboardingInfo {
  final String imageAsset;
  final String titleKey;
  final String descriptionKey;
  const _OnboardingInfo({ required this.imageAsset, required this.titleKey, required this.descriptionKey, });
}

/// Onboarding Page that introduces the user to the app's features.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define onboarding content (use localization keys)
  static final List<_OnboardingInfo> _onboardingScreens = [
    const _OnboardingInfo( imageAsset: AssetsConstants.onboarding1, titleKey: 'onboarding_title_1', descriptionKey: 'onboarding_desc_1',),
    const _OnboardingInfo( imageAsset: AssetsConstants.onboarding2, titleKey: 'onboarding_title_2', descriptionKey: 'onboarding_desc_2',),
    const _OnboardingInfo( imageAsset: AssetsConstants.onboarding3, titleKey: 'onboarding_title_3', descriptionKey: 'onboarding_desc_3',),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Marks onboarding as complete in storage and navigates to the login screen.
  Future<void> _completeOnboarding() async {
    Log.i("Onboarding completed or skipped.");
    try {
      // CORRECTED: Use sl() to get StorageService
      final storageService = sl<StorageService>();
      final success = await storageService.saveData<bool>(StorageKeys.onboardingComplete, true);
      if (success) { Log.d("Onboarding complete flag saved successfully."); }
      else { Log.w("Failed to save onboarding complete flag."); }

      // Navigate to Login screen, replacing the onboarding stack
      if (mounted) { // mounted is valid in State class
        context.goNamed(RouteNames.login);
      }
    } catch (e, stackTrace) {
      Log.e("Error saving onboarding status or navigating.", error: e, stackTrace: stackTrace);
      if (mounted) { context.goNamed(RouteNames.login); } // Fallback navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _onboardingScreens.length - 1;
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                // CORRECTED: Use ThemeConstants
                padding: const EdgeInsets.only( top: ThemeConstants.spacingSmall, right: ThemeConstants.spacingSmall),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text( tr('skip'), style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary), ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingScreens.length,
                onPageChanged: (int page) { setState(() { _currentPage = page; }); }, // setState is valid here
                itemBuilder: (context, index) {
                  return _OnboardingScreenWidget( info: _onboardingScreens[index], );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              // CORRECTED: Use ThemeConstants
              padding: const EdgeInsets.symmetric( horizontal: ThemeConstants.spacingLarge, vertical: ThemeConstants.spacingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController, count: _onboardingScreens.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary,
                      // CORRECTED: Use ThemeConstants
                      dotColor: ThemeConstants.neutralLight,
                      dotHeight: 10, dotWidth: 10,
                      spacing: ThemeConstants.spacingSmall,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      // CORRECTED: Use ThemeConstants
                      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                      backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      if (isLastPage) { _completeOnboarding(); }
                      else { _pageController.nextPage(
                        // CORRECTED: Use ThemeConstants
                        duration: ThemeConstants.animationFast,
                        curve: Curves.easeInOut, );
                      }
                    },
                    child: Icon( isLastPage ? Icons.check_rounded : Icons.arrow_forward_ios_rounded, size: 24, ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium), // Use ThemeConstants
          ],
        ),
      ),
    );
  }
}

/// Widget to display the content of a single onboarding screen.
class _OnboardingScreenWidget extends StatefulWidget {
  final _OnboardingInfo info;
  const _OnboardingScreenWidget({required this.info});
  @override
  State<_OnboardingScreenWidget> createState() => _OnboardingScreenWidgetState();
}

class _OnboardingScreenWidgetState extends State<_OnboardingScreenWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // CORRECTED: Use ThemeConstants
    _animationController = AnimationController( vsync: this, duration: ThemeConstants.animationSlow, );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate( CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack), );
    _animationController.forward();
  }

  @override
  void dispose() { _animationController.dispose(); super.dispose(); }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        // CORRECTED: Use ThemeConstants
        padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingLarge * 1.5, vertical: ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: ThemeConstants.spacingLarge), // Use ThemeConstants
            ScaleTransition( scale: _scaleAnimation, child: AspectRatio( aspectRatio: 1.1, child: Image.asset( widget.info.imageAsset, fit: BoxFit.contain,),),),
            const SizedBox(height: ThemeConstants.spacingXLarge * 1.5), // Use ThemeConstants
            Text( tr(widget.info.titleKey), textAlign: TextAlign.center, style: textTheme.displaySmall?.copyWith( fontWeight: FontWeight.bold, color: colorScheme.onBackground, ), ),
            const SizedBox(height: ThemeConstants.spacingMedium), // Use ThemeConstants
            Text( tr(widget.info.descriptionKey), textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith( color: ThemeConstants.neutralMedium, height: 1.5, ), ), // Use ThemeConstants
            const SizedBox(height: ThemeConstants.spacingLarge), // Use ThemeConstants
          ],
        ),
      ),
    );
  }
}

/// Helper class for storage keys (move to constants file)
class StorageKeys { static const String onboardingComplete = 'onboarding_complete'; }
/// Helper class for capitalization (move to string_utils.dart)
class StringUtil { static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; } }