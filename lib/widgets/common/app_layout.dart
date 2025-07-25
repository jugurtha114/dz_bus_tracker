// lib/widgets/common/app_layout.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/navigation_service.dart';
import '../../localization/app_localizations.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;
  final bool showBottomNav;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final int? currentIndex;
  final ValueChanged<int>? onNavItemTapped;

  const AppLayout({
    Key? key,
    required this.child,
    this.title,
    this.showBackButton = true,
    this.showBottomNav = true,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.currentIndex,
    this.onNavItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final userType = authProvider.user?.userType.value ?? AppConstants.userTypePassenger;

    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: child,
      bottomNavigationBar: showBottomNav ? _buildBottomNav(context, localizations, userType) : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, AppLocalizations localizations) {
    // Don't show app bar if no title, no back button needed, and no actions
    if (title == null && !showBackButton && (actions == null || actions!.isEmpty)) {
      return null;
    }

    // Check if we should show back button (only if explicitly requested AND can go back)
    final shouldShowBackButton = showBackButton && NavigationService.canGoBack();

    return AppBar(
      automaticallyImplyLeading: false,
      leading: shouldShowBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => NavigationService.goBack(),
            )
          : null,
      title: title != null 
          ? Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ) 
          : null,
      actions: actions,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
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

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (onNavItemTapped != null) {
          onNavItemTapped!(index);
        } else {
          NavigationService.navigateTo(routes[index]);
        }
      },
      type: BottomNavigationBarType.fixed,
      items: items,
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