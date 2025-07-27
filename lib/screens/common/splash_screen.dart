// lib/screens/common/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

/// Modern splash screen with optimized animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  Future<void> _startInitialization() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (!mounted) return;

    try {
      // Initialize app services
      await _initializeServices();
      
      // Check authentication status and navigate
      await _checkAuthAndNavigate();
    } catch (error) {
      // Handle initialization errors
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<void> _initializeServices() async {
    // Initialize core services
    final authProvider = context.read<AuthProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    // Load saved settings
    await themeProvider.loadThemeMode();
    
    // Check for saved authentication
    await authProvider.checkExistingAuth();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    
    // Add a minimum display time for better UX
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    if (authProvider.isAuthenticated && authProvider.user != null) {
      _navigateBasedOnUserRole(authProvider.user!);
    } else {
      _navigateToLogin();
    }
  }

  void _navigateBasedOnUserRole(dynamic user) {
    final userRole = user.role?.toLowerCase() ?? 'passenger';
    
    switch (userRole) {
      case 'admin':
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
        break;
      case 'driver':
        Navigator.of(context).pushReplacementNamed(AppRoutes.driverHome);
        break;
      case 'passenger':
      default:
        Navigator.of(context).pushReplacementNamed(AppRoutes.passengerHome);
        break;
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: context.colors.onPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.onPrimary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        size: 60,
                        color: context.colors.primary,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: DesignSystem.space32),
              
              // Animated App Name
              AnimatedBuilder(
                animation: _textOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          'DZ Bus Tracker',
                          style: context.textStyles.headlineLarge?.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignSystem.space8),
                        Text(
                          'Smart Transportation Solution',
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: context.colors.onPrimary.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: DesignSystem.space64),
              
              // Loading indicator
              AnimatedBuilder(
                animation: _textOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}