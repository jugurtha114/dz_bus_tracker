// lib/screens/common/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_utils.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Add a slight delay for the animation
    await Future.delayed(const Duration(seconds: 2));

    // Check if this is the first launch
    final isFirstLaunch = await StorageUtils.getFromStorage<bool>(AppConstants.firstLaunchKey) ?? true;

    // Check authentication status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();

    if (isFirstLaunch) {
      // Save first launch status to prevent showing onboarding next time
      await StorageUtils.saveToStorage(AppConstants.firstLaunchKey, false);

      // Navigate to onboarding screen
      await AppRouter.navigateToAndClearStack(context, AppRoutes.onboarding);
    } else if (authProvider.isAuthenticated) {
      // Navigate to appropriate home screen based on user type
      final userType = authProvider.user?.userType;
      
      if (userType == UserType.driver) {
        await AppRouter.navigateToAndClearStack(context, AppRoutes.driverHome);
      } else if (userType == UserType.admin) {
        await AppRouter.navigateToAndClearStack(context, AppRoutes.adminDashboard);
      } else {
        await AppRouter.navigateToAndClearStack(context, AppRoutes.passengerHome);
      }
    } else {
      // Navigate to login screen
      await AppRouter.navigateToAndClearStack(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or App Icon - replace with your actual logo
              Container(
                width: 120,
        
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_bus_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(delay: 300.ms, duration: 700.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 16),

              // App Name
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fade(delay: 500.ms, duration: 700.ms)
                  .slideY(begin: 0, end: 0, curve: Curves.easeOutQuart),

              const SizedBox(height: 16),

              // Tagline
              Text(
                'Never Miss Your Bus Again!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              )
                  .animate()
                  .fade(delay: 800.ms, duration: 700.ms)
                  .slideY(delay: 800.ms, begin: 0, end: 0, curve: Curves.easeOutQuart),

              const SizedBox(height: 16),

              // Loading Indicator
              LoadingIndicator(
                color: Theme.of(context).colorScheme.primary,
                type: LoadingIndicatorType.wave,
              )
                  .animate()
                  .fade(delay: 1200.ms, duration: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}