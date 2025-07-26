// lib/widgets/common/app_layout.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/route_config.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/navigation_service.dart';
import '../../localization/app_localizations.dart';
import 'mobile_optimized_background.dart';
import 'modern_drawer.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;
  final bool showBottomNav;
  final bool showDrawer;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final int? currentIndex;
  final ValueChanged<int>? onNavItemTapped;
  final String? backgroundImage;
  final Color? backgroundColor;

  const AppLayout({
    Key? key,
    required this.child,
    this.title,
    this.showBackButton = true,
    this.showBottomNav = true,
    this.showDrawer = true,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.currentIndex,
    this.onNavItemTapped,
    this.backgroundImage,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final userType = authProvider.user?.userType.value ?? AppConstants.userTypePassenger;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget bodyContent = child;
    
    // Add background if specified
    if (backgroundImage != null || backgroundColor != null) {
      bodyContent = MobileOptimizedBackground(
        imagePath: backgroundImage,
        blurIntensity: 1.5,
        opacity: 0.2,
        enableEffects: backgroundImage != null,
        gradientColors: backgroundColor != null ? [
          backgroundColor!,
          backgroundColor!.withValues(alpha: 0.8),
        ] : [
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          isDark ? const Color(0xFF1E293B) : AppTheme.primary.withValues(alpha: 0.02),
          isDark ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.secondary.withValues(alpha: 0.02),
        ],
        child: child,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, localizations),
      drawer: showDrawer ? const ModernDrawer() : null,
      body: bodyContent,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context, localizations, userType) : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, AppLocalizations localizations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canGoBack = NavigationService.canGoBack();
    
    // Always show app bar for proper navigation
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      
      // Leading: Back button or menu
      leading: showBackButton && canGoBack
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => NavigationService.goBack(),
              ),
            )
          : showDrawer
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
      
      // Title
      title: title != null 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ) 
          : null,
      
      // Actions
      actions: actions?.map((action) => Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          ),
        ),
        child: action,
      )).toList(),
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) => Stack(
        children: [
          const Icon(Icons.notifications),
          if (notificationProvider.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${notificationProvider.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildBottomNav(BuildContext context, AppLocalizations localizations, String userType) {
    final currentRoute = NavigationService.getCurrentRoute();

    // Define navigation items based on user type
    List<BottomNavigationBarItem> items;
    List<String> routes;

    if (userType == AppConstants.userTypeDriver) {
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.gps_fixed),
          label: localizations.translate('tracking'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications),
          label: localizations.translate('notifications'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: localizations.translate('profile'),
        ),
      ];
      routes = [
        AppRoutes.driverHome,
        AppRoutes.tracking,
        AppRoutes.notifications,
        AppRoutes.driverProfile,
      ];
    } else if (userType == AppConstants.userTypeAdmin) {
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: localizations.translate('dashboard'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: localizations.translate('users'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications),
          label: localizations.translate('notifications'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: localizations.translate('profile'),
        ),
      ];
      routes = [
        AppRoutes.adminDashboard,
        AppRoutes.userManagement,
        AppRoutes.notifications,
        AppRoutes.adminProfile,
      ];
    } else {
      // Passenger
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: localizations.translate('search'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications),
          label: localizations.translate('notifications'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: localizations.translate('profile'),
        ),
      ];
      routes = [
        AppRoutes.passengerHome,
        AppRoutes.lineSearch,
        AppRoutes.notifications,
        AppRoutes.profile,
      ];
    }

    // Determine current index based on route
    int selectedIndex = currentIndex ?? 0;
    if (currentIndex == null && currentRoute != null) {
      final index = routes.indexOf(currentRoute);
      if (index != -1) {
        selectedIndex = index;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;
              
              return GestureDetector(
                onTap: () {
                  if (onNavItemTapped != null) {
                    onNavItemTapped!(index);
                  } else {
                    NavigationService.navigateTo(routes[index]);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (item.icon as Icon).icon!,
                        color: isSelected 
                          ? AppTheme.primary
                          : (isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6)),
                        size: 22,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.label!,
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Extension to use AppLayout easily
extension AppLayoutExtension on Widget {
  Widget withAppLayout({
    String? title,
    bool showBackButton = true,
    bool showBottomNav = true,
    List<Widget>? actions,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    int? currentIndex,
    ValueChanged<int>? onNavItemTapped,
  }) {
    return AppLayout(
      title: title,
      showBackButton: showBackButton,
      showBottomNav: showBottomNav,
      actions: actions,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      currentIndex: currentIndex,
      onNavItemTapped: onNavItemTapped,
      child: this,
    );
  }
}