// lib/screens/common/splash_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_utils.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _rippleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textFade;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _initialize();
  }

  void _initializeAnimations() {
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _startAnimations() {
    _primaryController.forward();
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;

    final isFirstLaunch = await StorageUtils.getFromStorage<bool>(AppConstants.firstLaunchKey) ?? true;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();

    if (!mounted) return;

    if (isFirstLaunch) {
      await StorageUtils.saveToStorage(AppConstants.firstLaunchKey, false);
      await AppRouter.navigateToAndClearStack(context, AppRoutes.onboarding);
    } else if (authProvider.isAuthenticated && authProvider.user != null) {
      final userType = authProvider.user?.userType;
      
      if (userType == UserType.driver) {
        await AppRouter.navigateToAndClearStack(context, AppRoutes.driverHome);
      } else if (userType == UserType.admin) {
        await AppRouter.navigateToAndClearStack(context, AppRoutes.adminDashboard);
      } else {
        await AppRouter.navigateToAndClearStack(context, AppRoutes.passengerHome);
      }
    } else {
      await AppRouter.navigateToAndClearStack(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primaryLight,
              AppTheme.secondary,
              AppTheme.tertiary,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated ripples background
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: ModernRipplePainter(_rippleAnimation.value),
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with modern glass effect
                    AnimatedBuilder(
                      animation: _primaryController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.9),
                                    Colors.white.withValues(alpha: 0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.directions_bus_rounded,
                                size: 70,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    // App name with elegant fade
                    AnimatedBuilder(
                      animation: _textFade,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFade.value,
                          child: Column(
                            children: [
                              Text(
                                AppConfig.appName,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      offset: const Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                'Track • Navigate • Arrive',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 3.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80),

                    // Modern loading indicator
                    AnimatedBuilder(
                      animation: _textFade,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFade.value,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  return AnimatedBuilder(
                                    animation: _rippleController,
                                    builder: (context, child) {
                                      final delay = index * 0.3;
                                      final animValue = (_rippleAnimation.value + delay) % 1.0;
                                      final scale = 0.5 + (math.sin(animValue * 2 * math.pi) * 0.5);
                                      
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white.withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              Text(
                                'Loading your journey...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Version at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value * 0.6,
                    child: Text(
                      'Version ${AppConfig.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernRipplePainter extends CustomPainter {
  final double animationValue;

  ModernRipplePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.6;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Create elegant ripple effects
    for (int i = 0; i < 4; i++) {
      final progress = (animationValue + (i * 0.25)) % 1.0;
      final radius = progress * maxRadius;
      final alpha = (1.0 - progress) * 0.4;
      
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}