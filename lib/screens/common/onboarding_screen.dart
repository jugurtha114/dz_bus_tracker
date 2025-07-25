// lib/screens/common/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../widgets/common/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingPage> _getPages(BuildContext context) => [
    OnboardingPage(
      title: 'Welcome to DZ Bus Tracker',
      description: 'Smart, real-time bus tracking for Algeria – connecting passengers and drivers like never before.',
      image: Icons.directions_bus_rounded,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
    OnboardingPage(
      title: 'For Bus Drivers',
      description: 'Register your bus, get approved, and start tracking your route. Help passengers know exactly when you\'ll arrive.',
      image: Icons.person,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
    OnboardingPage(
      title: 'For Passengers',
      description: 'Search routes, view live bus locations, and see estimated arrival times. No more waiting in the dark!',
      image: Icons.people_alt_rounded,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
    OnboardingPage(
      title: 'Smart Features',
      description: 'Get info about waiting passengers, bus occupancy, and smart predictions for a smoother journey.',
      image: Icons.lightbulb_outline,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    final pages = _getPages(context);
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
    final pages = _getPages(context);
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return pages[index];
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _finish,
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.1),
                  ),
                ),

                const SizedBox(height: 16),

                // Next/Get Started button
                CustomButton(
        text: _currentPage == pages.length - 1 ? 'Get Started' : 'Next',
        onPressed: _nextPage,
        color: Colors.white,
        icon: _currentPage == pages.length - 1
        ? Icons.check_circle_outline
        : Icons.arrow_forward
      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData image;
  final Color backgroundColor;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon
          Icon(
            image,
            size: 150,
            color: Colors.white,
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}