/// lib/presentation/pages/splash/splash_page.dart

import 'dart:async';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Assuming GoRouter for navigation

import '../../../config/themes/app_theme.dart'; // For colors and spacing
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_constants.dart'; // For logo
import '../../../core/utils/logger.dart';
import '../../blocs/auth/auth_bloc.dart'; // Import Auth BLoC and States
import '../../routes/route_names.dart'; // Import route names

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _minDisplayTimer;
  Timer? _authTimeoutTimer; // New timer to ensure we don't wait forever
  bool _canNavigate = false;
  bool _didNavigate = false; // Track if we've already navigated
  AuthState? _finalAuthState;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationMedium, // Use theme constant
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation
    _animationController.forward();

    // Trigger initial auth check (important!)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AppStarted());
    });

    // Set minimum display time (e.g., 1.5 seconds)
    _minDisplayTimer = Timer(const Duration(milliseconds: 1500), () {
      Log.d("Splash minimum display time elapsed.");
      if (mounted) {
        setState(() {
          _canNavigate = true;
        });
      }
      _attemptNavigation(); // Try navigation if auth state already received
    });

    // Set maximum wait time for auth (e.g., 5 seconds)
    _authTimeoutTimer = Timer(const Duration(seconds: 5), () {
      Log.w("Auth state timeout - forcing navigation to login");
      if (mounted && !_didNavigate) {
        _forceNavigateToFallback();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minDisplayTimer?.cancel();
    _authTimeoutTimer?.cancel();
    super.dispose();
  }

  // Force navigation to a fallback route if auth takes too long
  void _forceNavigateToFallback() {
    Log.w("Forcing fallback navigation after timeout");
    _didNavigate = true;
    try {
      context.goNamed(RouteNames.languageSelection);
    } catch (e, stackTrace) {
      Log.e("Error during fallback navigation", error: e, stackTrace: stackTrace);
      // Try a simpler navigation as last resort
      try {
        context.go('/language-selection');
      } catch (e) {
        Log.e("Critical navigation failure", error: e);
      }
    }
  }

  /// Attempts navigation if both min display time passed and auth state is determined.
  void _attemptNavigation() {
    if (_didNavigate) return; // Prevent multiple navigation attempts

    if (_canNavigate && _finalAuthState != null && mounted) {
      Log.i("Attempting navigation from Splash. Auth State: ${_finalAuthState.runtimeType}");
      final state = _finalAuthState!;
      _didNavigate = true; // Mark that we've navigated
      _authTimeoutTimer?.cancel(); // Cancel timeout timer

      // Navigate based on auth state
      try {
        if (state is AuthAuthenticated) {
          Log.i("Navigating to dashboard (User type: ${state.user.userType}).");
          if (state.user.isDriver) {
            context.goNamed(RouteNames.driverDashboard);
          } else {
            // Assume passenger/admin go to passenger home for now
            context.goNamed(RouteNames.passengerHome);
          }
        } else { // AuthUnauthenticated or AuthFailure
          Log.i("Navigating to language selection / login.");
          // Navigate to language selection first? Or onboarding? Or Login?
          // Let's assume language selection is the first step for unauthenticated users.
          context.goNamed(RouteNames.languageSelection);
          // Alternative: context.goNamed(RouteNames.login);
        }
      } catch (e, stackTrace) {
        Log.e("Error during navigation from Splash Page", error: e, stackTrace: stackTrace);
        // Fallback navigation
        _forceNavigateToFallback();
      }
    } else {
      Log.d("Navigation prerequisites not met (CanNavigate: $_canNavigate, FinalAuthState: ${_finalAuthState != null})");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      // Listener is crucial for navigation *after* the initial build
      listener: (context, state) {
        Log.d("Splash BlocListener received state: ${state.runtimeType}");
        // Ignore initial/loading states for navigation purposes
        if (state is AuthAuthenticated || state is AuthUnauthenticated || state is AuthFailure) {
          if (mounted) {
            setState(() {
              _finalAuthState = state; // Store the final state
            });
          }
          _attemptNavigation(); // Attempt navigation immediately if timer finished
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryColor, // Darker green top
                    AppTheme.primaryColor, // Lighter green bottom
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 2. Optional: Subtle Background Pattern/Image (Example)
            // Positioned.fill(
            //   child: Opacity(
            //     opacity: 0.1,
            //     child: Image.asset(
            //       AssetsConstants.some SubtleBackgroundPattern, // Use a relevant asset
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),


            // 3. Main Content Area (Centered) with potential Glass effect
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism Container (Optional)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge * 2),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                          width: screenSize.width * 0.7,
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge * 2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              )
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 4. Animated Logo
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Image.asset(
                                  AssetsConstants.logo, // Ensure this path is correct
                                  width: screenSize.width * 0.4, // Adjust size as needed
                                  // Consider adding semantic label:
                                  // semanticLabel: AppLocalizations.of(context).appName,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXLarge),

                              // 5. Loading Indicator
                              const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingMedium),

                              // 6. App Name / Tagline (Optional)
                              Text(
                                AppConstants.appName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600
                                ),
                              )
                            ],
                          )

                      ),
                    ),
                  )


                ],
              ),
            ),

            // 7. Version Number (Optional, bottom corner)
            Positioned(
              bottom: AppTheme.spacingMedium,
              right: AppTheme.spacingMedium,
              child: Text(
                'v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}