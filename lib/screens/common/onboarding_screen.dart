// lib/screens/common/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../widgets/widgets.dart';

/// Modern onboarding screen introducing app features
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to DZ Bus Tracker',
      description: 'Smart, real-time bus tracking for Algeria. Connect passengers and drivers with precision and reliability.',
      icon: Icons.directions_bus_rounded,
      color: DesignSystem.primary,
    ),
    OnboardingData(
      title: 'For Passengers',
      description: 'Track buses in real-time, find routes, check schedules, and plan your journey with ease.',
      icon: Icons.person_outline,
      color: DesignSystem.success,
    ),
    OnboardingData(
      title: 'For Drivers',
      description: 'Manage your routes, track passengers, share location, and provide excellent service.',
      icon: Icons.drive_eta_outlined,
      color: DesignSystem.warning,
    ),
    OnboardingData(
      title: 'Smart Features',
      description: 'Real-time tracking, payment integration, ratings, and comprehensive analytics.',
      icon: Icons.smartphone_outlined,
      color: DesignSystem.tertiary,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            Padding(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress indicator
                  Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  // Skip button
                  AppButton.text(
                    text: 'Skip',
                    onPressed: _skipOnboarding,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),

            // Bottom section with indicators and navigation
            Padding(
              padding: const EdgeInsets.all(DesignSystem.space24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.space4,
                        ),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? context.colors.primary
                              : context.colors.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: DesignSystem.space32),

                  // Navigation buttons
                  Row(
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        Expanded(
                          child: AppButton.outlined(
                            text: 'Previous',
                            onPressed: _previousPage,
                          ),
                        ),
                      
                      if (_currentPage > 0)
                        const SizedBox(width: DesignSystem.space16),

                      // Next/Get Started button
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: AppButton(
                          text: _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: _nextPage,
                          icon: _currentPage == _pages.length - 1
                              ? Icons.arrow_forward
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.color,
            ),
          ),

          const SizedBox(height: DesignSystem.space40),

          // Title
          Text(
            data.title,
            style: context.textStyles.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: DesignSystem.space16),

          // Description
          Text(
            data.description,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: DesignSystem.space64),
        ],
      ),
    );
  }
}

/// Onboarding page data model
class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}