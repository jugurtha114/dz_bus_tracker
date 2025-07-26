// lib/widgets/common/modern_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/route_config.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/navigation_service.dart';
import 'mobile_optimized_background.dart';

class ModernDrawer extends StatelessWidget {
  const ModernDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userType = authProvider.user?.userType.value ?? AppConstants.userTypePassenger;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: MobileOptimizedBackground(
        blurIntensity: 1.0,
        opacity: 0.2,
        enableEffects: true,
        gradientColors: [
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          isDark ? const Color(0xFF1E293B) : AppTheme.primary.withValues(alpha: 0.03),
          isDark ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.secondary.withValues(alpha: 0.03),
        ],
        child: Column(
          children: [
            // Header
            _buildHeader(context, authProvider, isDark),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuSection(
                    context,
                    'Navigation',
                    _getNavigationItems(userType),
                    isDark,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMenuSection(
                    context,
                    'Settings',
                    _getSettingsItems(themeProvider, isDark),
                    isDark,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMenuSection(
                    context,
                    'Account',
                    _getAccountItems(context, authProvider, isDark),
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider, bool isDark) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.8),
            AppTheme.secondary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getUserIcon(authProvider.user?.userType.value),
              size: 30,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // User info
          Text(
            authProvider.user?.fullName ?? 'User',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          Text(
            _getUserTypeLabel(authProvider.user?.userType.value),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<DrawerItem> items,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item, isDark)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, DrawerItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: item.isActive 
          ? AppTheme.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: item.isActive
              ? AppTheme.primary.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Icon(
            item.icon,
            size: 20,
            color: item.isActive
              ? AppTheme.primary
              : (isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7)),
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: item.isActive
              ? AppTheme.primary
              : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8)),
            fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: item.onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  List<DrawerItem> _getNavigationItems(String userType) {
    if (userType == AppConstants.userTypeDriver) {
      return [
        DrawerItem(
          icon: Icons.home_rounded,
          title: 'Dashboard',
          onTap: () => NavigationService.navigateTo(AppRoutes.driverHome),
          isActive: NavigationService.getCurrentRoute() == AppRoutes.driverHome,
        ),
        DrawerItem(
          icon: Icons.directions_bus_rounded,
          title: 'My Buses',
          onTap: () => NavigationService.navigateTo(AppRoutes.busManagement),
        ),
        DrawerItem(
          icon: Icons.route_rounded,
          title: 'Lines',
          onTap: () => NavigationService.navigateTo(AppRoutes.lineSelection),
        ),
        DrawerItem(
          icon: Icons.gps_fixed_rounded,
          title: 'Tracking',
          onTap: () => NavigationService.navigateTo(AppRoutes.tracking),
        ),
        DrawerItem(
          icon: Icons.schedule_rounded,
          title: 'Schedules',
          onTap: () => NavigationService.navigateTo(AppRoutes.driverSchedules),
        ),
        DrawerItem(
          icon: Icons.history_rounded,
          title: 'Trip History',
          onTap: () => NavigationService.navigateTo(AppRoutes.tripHistory),
        ),
      ];
    } else if (userType == AppConstants.userTypeAdmin) {
      return [
        DrawerItem(
          icon: Icons.dashboard_rounded,
          title: 'Dashboard',
          onTap: () => NavigationService.navigateTo(AppRoutes.adminDashboard),
          isActive: NavigationService.getCurrentRoute() == AppRoutes.adminDashboard,
        ),
        DrawerItem(
          icon: Icons.people_rounded,
          title: 'User Management',
          onTap: () => NavigationService.navigateTo(AppRoutes.userManagement),
        ),
        DrawerItem(
          icon: Icons.directions_bus_rounded,
          title: 'Fleet Management',
          onTap: () => NavigationService.navigateTo(AppRoutes.fleetManagement),
        ),
        DrawerItem(
          icon: Icons.route_rounded,
          title: 'Line Management',
          onTap: () => NavigationService.navigateTo(AppRoutes.lineManagement),
        ),
        DrawerItem(
          icon: Icons.analytics_rounded,
          title: 'Fleet Management',
          onTap: () => NavigationService.navigateTo(AppRoutes.fleetManagement),
        ),
      ];
    } else {
      // Passenger
      return [
        DrawerItem(
          icon: Icons.home_rounded,
          title: 'Home',
          onTap: () => NavigationService.navigateTo(AppRoutes.passengerHome),
          isActive: NavigationService.getCurrentRoute() == AppRoutes.passengerHome,
        ),
        DrawerItem(
          icon: Icons.search_rounded,
          title: 'Search Lines',
          onTap: () => NavigationService.navigateTo(AppRoutes.lineSearch),
        ),
        DrawerItem(
          icon: Icons.near_me_rounded,
          title: 'Bus Tracking',
          onTap: () => NavigationService.navigateTo(AppRoutes.busTracking),
        ),
        DrawerItem(
          icon: Icons.history_rounded,
          title: 'Trip History',
          onTap: () => NavigationService.navigateTo(AppRoutes.tripHistory),
        ),
        DrawerItem(
          icon: Icons.star_rounded,
          title: 'Rate Driver',
          onTap: () => NavigationService.navigateTo(AppRoutes.ratings),
        ),
      ];
    }
  }

  List<DrawerItem> _getSettingsItems(ThemeProvider themeProvider, bool isDark) {
    return [
      DrawerItem(
        icon: themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        title: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
        onTap: () => themeProvider.toggleTheme(),
      ),
      DrawerItem(
        icon: Icons.notifications_rounded,
        title: 'Notifications',
        onTap: () => NavigationService.navigateTo(AppRoutes.notifications),
      ),
      DrawerItem(
        icon: Icons.language_rounded,
        title: 'Language',
        onTap: () => NavigationService.navigateTo(AppRoutes.settings),
      ),
      DrawerItem(
        icon: Icons.settings_rounded,
        title: 'Settings',
        onTap: () => NavigationService.navigateTo(AppRoutes.settings),
      ),
    ];
  }

  List<DrawerItem> _getAccountItems(BuildContext context, AuthProvider authProvider, bool isDark) {
    return [
      DrawerItem(
        icon: Icons.person_rounded,
        title: 'Profile',
        onTap: () => NavigationService.navigateTo(AppRoutes.profile),
      ),
      DrawerItem(
        icon: Icons.help_rounded,
        title: 'Help & Support',
        onTap: () => NavigationService.navigateTo(AppRoutes.about),
      ),
      DrawerItem(
        icon: Icons.info_rounded,
        title: 'About',
        onTap: () => NavigationService.navigateTo(AppRoutes.about),
      ),
      DrawerItem(
        icon: Icons.logout_rounded,
        title: 'Logout',
        onTap: () => _showLogoutDialog(context, authProvider),
        isDestructive: true,
      ),
    ];
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              await authProvider.logout();
              NavigationService.navigateToAndClearStack(AppRoutes.login);
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getUserIcon(String? userType) {
    switch (userType) {
      case AppConstants.userTypeDriver:
        return Icons.drive_eta_rounded;
      case AppConstants.userTypeAdmin:
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getUserTypeLabel(String? userType) {
    switch (userType) {
      case AppConstants.userTypeDriver:
        return 'Bus Driver';
      case AppConstants.userTypeAdmin:
        return 'Administrator';
      default:
        return 'Passenger';
    }
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDestructive;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });
}