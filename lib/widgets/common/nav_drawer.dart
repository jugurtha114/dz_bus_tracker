// lib/widgets/common/nav_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../helpers/dialog_helper.dart';
import 'notification_badge.dart';

class DzNavDrawer extends StatelessWidget {
  final String? selectedRoute;
  final int notificationCount;
  final bool isDriver;
  final VoidCallback? onLogout;
  final String? avatarUrl;
  final Map<String, dynamic>? userData;
  final double? rating;

  const DzNavDrawer({
    Key? key,
    this.selectedRoute,
    this.notificationCount = 0,
    this.isDriver = false,
    this.onLogout,
    this.avatarUrl,
    this.userData,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = userData != null ? null : authProvider.user; // Use proper User object
    final _isDriver = isDriver || authProvider.isDriver;

    return Drawer(
      child: Column(
        children: [
          // User account header
          UserAccountsDrawerHeader(
            accountName: Text(
              user != null && user.firstName != null && user.lastName != null
                  ? '${user.firstName} ${user.lastName}'
                  : _isDriver ? 'Driver' : 'Passenger',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              )
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            otherAccountsPictures: _isDriver && rating != null
                ? [
              // Display driver rating
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  rating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
                : null,
          ),

          // Drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  route: _isDriver ? AppRoutes.driverHome : AppRoutes.passengerHome,
                ),

                // Driver-specific items
                if (_isDriver) ...[
                  _buildDrawerItem(
                    context,
                    icon: Icons.directions_bus,
                    title: 'Bus Management',
                    route: AppRoutes.busManagement,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.route,
                    title: 'Line Selection',
                    route: AppRoutes.lineSelection,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.location_on,
                    title: 'Tracking',
                    route: AppRoutes.tracking,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    title: 'Passenger Counter',
                    route: AppRoutes.passengerCounter,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star,
                    title: 'Ratings',
                    route: AppRoutes.ratings,
                  ),
                ]

                // Passenger-specific items
                else ...[
                  _buildDrawerItem(
                    context,
                    icon: Icons.search,
                    title: 'Search Lines',
                    route: AppRoutes.lineSearch,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.location_on,
                    title: 'Find Stops',
                    route: AppRoutes.stopSearch,
                  ),
                ],

                // Common items
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  route: AppRoutes.notifications,
                  badgeCount: notificationCount,
                ),

                const Divider(),

                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  route: _isDriver ? AppRoutes.driverProfile : AppRoutes.profile,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: AppRoutes.settings,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  route: AppRoutes.about,
                ),

                const Divider(),

                // Logout
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer

                    // Show confirmation dialog
                    DialogHelper.showConfirmDialog(
                      context,
                      title: 'Logout',
                      message: 'Are you sure you want to logout?',
                      confirmText: 'Logout',
                      cancelText: 'Cancel',
                    ).then((confirm) {
                      if (confirm) {
                        if (onLogout != null) {
                          onLogout!();
                        } else {
                          // Default logout behavior
                          authProvider.logout().then((_) {
                            AppRouter.navigateToAndClearStack(context, AppRoutes.login);
                          });
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // App version at bottom
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version 1.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
        int badgeCount = 0,
      }) {
    final isSelected = selectedRoute == route;

    return ListTile(
      leading: badgeCount > 0
          ? NotificationBadge(
        count: badgeCount,
        size: 16,
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      )
          : Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close the drawer

        if (selectedRoute != route) {
          AppRouter.navigateTo(context, route);
        }
      },
    );
  }
}