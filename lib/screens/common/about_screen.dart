// lib/screens/common/about_screen.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  Future<void> _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  void _openWebsite() async {
    final url = Uri.parse('https://dzbusttracker.dz');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openEmail() async {
    final url = Uri.parse('mailto:support@dzbusttracker.dz');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DzAppBar(
        title: 'About',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
        
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App name
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Version
            Text(
              'Version $_appVersion',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // App description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'DZ Bus Tracker is a real-time bus tracking application for Algeria, connecting passengers and drivers to make public transport more efficient and accessible.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Never miss your bus again!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Features
            _buildFeatureList(),

            const SizedBox(height: 16),

            // Contact buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
        text: 'Visit Website',
        onPressed: _openWebsite,
        icon: Icons.language,
        type: ButtonType.outline
      ),
                ),

                const SizedBox(width: 16, height: 40),

                Expanded(
                  child: CustomButton(
        text: 'Contact Support',
        onPressed: _openEmail,
        ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Copyright
            Text(
              '© ${DateTime.now().year} DZ Bus Tracker. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {
        'icon': Icons.location_on,
        'title': 'Real-time Tracking',
        'description': 'Track buses in real-time to see exactly when they\'ll arrive.',
      },
      {
        'icon': Icons.people,
        'title': 'Passenger Count',
        'description': 'See how crowded the bus is before it arrives.',
      },
      {
        'icon': Icons.access_time,
        'title': 'Arrival Estimates',
        'description': 'Get accurate estimates of bus arrival times.',
      },
      {
        'icon': Icons.map,
        'title': 'Interactive Maps',
        'description': 'View bus routes and stops on interactive maps.',
      },
      {
        'icon': Icons.directions_bus,
        'title': 'Driver Updates',
        'description': 'Drivers can update passenger counts and report issues.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        ...features.map((feature) => _buildFeatureItem(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
        )).toList(),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
        
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16, height: 40),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}