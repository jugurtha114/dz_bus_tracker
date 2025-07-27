// lib/screens/common/about_screen.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../../widgets/widgets.dart';

/// About screen showing app information and credits
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'About DZ Bus Tracker',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            // App Logo and Info
            _buildAppHeader(context),
            
            const SizedBox(height: DesignSystem.space24),
            
            // App Description
            _buildAppDescription(context),
            
            const SizedBox(height: DesignSystem.space24),
            
            // Features
            _buildFeatures(context),
            
            const SizedBox(height: DesignSystem.space24),
            
            // Team Credits
            _buildTeamCredits(context),
            
            const SizedBox(height: DesignSystem.space24),
            
            // Legal Info
            _buildLegalInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space24),
        child: Column(
          children: [
            // App Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            // App Name
            Text(
              'DZ Bus Tracker',
              style: context.textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            // Version
            StatusBadge(
              status: 'Version 1.0.0',
              color: DesignSystem.info,
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            // Tagline
            Text(
              'Smart Bus Tracking for Algeria',
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDescription(BuildContext context) {
    return SectionLayout(
      title: 'About This App',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Text(
            'DZ Bus Tracker is a comprehensive public transportation solution designed specifically for Algeria. '
            'Our app connects passengers, drivers, and administrators to create a seamless and efficient bus tracking experience. '
            'With real-time GPS tracking, route optimization, and user-friendly interfaces, we\'re revolutionizing public transportation in Algeria.',
            style: context.textStyles.bodyLarge,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      {
        'icon': Icons.location_on,
        'title': 'Real-time Tracking',
        'description': 'Track buses in real-time with accurate GPS positioning',
      },
      {
        'icon': Icons.route,
        'title': 'Route Planning',
        'description': 'Optimized routes and schedules for efficient transportation',
      },
      {
        'icon': Icons.people,
        'title': 'Multi-user Support',
        'description': 'Separate interfaces for passengers, drivers, and administrators',
      },
      {
        'icon': Icons.notifications,
        'title': 'Smart Notifications',
        'description': 'Get notified about bus arrivals, delays, and updates',
      },
      {
        'icon': Icons.star,
        'title': 'Rating System',
        'description': 'Rate drivers and provide feedback to improve service quality',
      },
      {
        'icon': Icons.analytics,
        'title': 'Performance Analytics',
        'description': 'Detailed analytics and insights for better decision making',
      },
    ];

    return SectionLayout(
      title: 'Key Features',
      child: Column(
        children: features.map((feature) => 
          Padding(
            padding: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: AppCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(DesignSystem.space8),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  feature['title'] as String,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(feature['description'] as String),
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildTeamCredits(BuildContext context) {
    return SectionLayout(
      title: 'Development Team',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'Developed with ❤️ by the DZ Bus Tracker Team',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: DesignSystem.space16),
              
              Text(
                'Special thanks to all contributors who made this project possible. '
                'This app was built using Flutter and follows modern Material You design principles.',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalInfo(BuildContext context) {
    return SectionLayout(
      title: 'Legal Information',
      child: Column(
        children: [
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              subtitle: const Text('Read our terms and conditions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTermsOfService(context),
            ),
          ),
          
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              subtitle: const Text('How we handle your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPrivacyPolicy(context),
            ),
          ),
          
          AppCard(
            margin: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Open Source Licenses'),
              subtitle: const Text('Third-party libraries and licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showOpenSourceLicenses(context),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Column(
                children: [
                  Text(
                    '© 2024 DZ Bus Tracker',
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.space4),
                  Text(
                    'All rights reserved. Made in Algeria 🇩🇿',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'Terms of Service',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSystem.space16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    'Terms of Service content would be displayed here...\n\n'
                    'This section would contain the complete terms and conditions for using the DZ Bus Tracker application.',
                    style: context.textStyles.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'Privacy Policy',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSystem.space16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    'Privacy Policy content would be displayed here...\n\n'
                    'This section would contain information about how user data is collected, stored, and used.',
                    style: context.textStyles.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOpenSourceLicenses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'Open Source Licenses',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSystem.space16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    'Open Source Licenses would be listed here...\n\n'
                    'This section would contain all third-party libraries and their respective licenses used in the application.',
                    style: context.textStyles.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}