// lib/screens/common/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../config/app_theme.dart';
import '../../config/route_config.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/modern_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<OnboardingData> get _pages => [
    OnboardingData(
      title: 'Welcome to DZ Bus Tracker',
      description: 'Smart, real-time bus tracking for Algeria. Connect passengers and drivers with precision and reliability.',
      icon: Icons.directions_bus_rounded,
      primaryColor: AppTheme.primary,
      secondaryColor: AppTheme.primaryLight,
    ),
    OnboardingData(
      title: 'For Bus Drivers',
      description: 'Register your bus, get approved, and start tracking your route. Help passengers know exactly when you\'ll arrive.',
      icon: Icons.drive_eta_rounded,
      primaryColor: AppTheme.secondary,
      secondaryColor: AppTheme.secondaryLight,
    ),
    OnboardingData(
      title: 'For Passengers',
      description: 'Search routes, view live bus locations, and see estimated arrival times. Never wait in uncertainty again!',
      icon: Icons.people_alt_rounded,
      primaryColor: AppTheme.tertiary,
      secondaryColor: AppTheme.tertiaryLight,
    ),
    OnboardingData(
      title: 'Smart & Reliable',
      description: 'Get real-time updates, smart predictions, and a seamless transportation experience throughout Algeria.',
      icon: Icons.smart_toy_rounded,
      primaryColor: AppTheme.primary,
      secondaryColor: AppTheme.secondary,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    AppRouter.navigateToReplacement(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].primaryColor,
              _pages[_currentPage].secondaryColor,
              _pages[_currentPage].primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: OnboardingPatternPainter(_currentPage),
              ),
            ),

            // Page View
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return OnboardingPageWidget(
                  data: _pages[index],
                  animation: _animationController,
                );
              },
            ),

            // Skip button
            Positioned(
              top: 60,
              right: 24,
              child: ModernCard(
                type: ModernCardType.glass,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                borderRadius: 25,
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: ModernCard(
                type: ModernCardType.glass,
                padding: const EdgeInsets.all(32),
                borderRadius: 28,
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 12,
                        dotWidth: 12,
                        spacing: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withValues(alpha: 0.4),
                        expansionFactor: 3,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Next/Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        onPressed: _nextPage,
                        size: ModernButtonSize.large,
                        trailingIcon: _currentPage == _pages.length - 1
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animation;

  const OnboardingPageWidget({
    Key? key,
    required this.data,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    ));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            
            // Animated Icon
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
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
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: data.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        size: 80,
                        color: data.primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // Animated Title
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Animated Description
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: ModernCard(
                      type: ModernCardType.glass,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        data.description,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class OnboardingPatternPainter extends CustomPainter {
  final int currentPage;

  OnboardingPatternPainter(this.currentPage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw subtle geometric patterns
    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 50.0;
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Draw grid lines
    paint.strokeWidth = 0.5;
    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}