/// lib/presentation/pages/passenger/passenger_home_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Assuming GoRouter

import '../../../config/themes/app_theme.dart'; // For colors and styling constants
import '../../../core/utils/logger.dart';
import '../../routes/route_names.dart'; // For navigation constants
// Import tab pages later when created:
// import 'line_list_tab.dart';
// import 'map_tracking_tab.dart';
// import 'favorites_tab.dart';

/// Main container page for the Passenger role, hosting the primary navigation tabs.
class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  int _currentIndex = 0; // Index for the currently selected tab

  // Placeholder widgets for tab content - Replace with actual Tab widgets later
  // TODO: Replace placeholders with actual tab widgets (LineListTab, MapTrackingTab, FavoritesTab)
  final List<Widget> _tabs = [
    const _PlaceholderTabWidget(label: 'Lines List Tab', color: Colors.blueGrey),
    const _PlaceholderTabWidget(label: 'Map Tracking Tab', color: Colors.teal),
    const _PlaceholderTabWidget(label: 'Favorites Tab', color: Colors.pinkAccent),
  ];

  // TODO: Replace with localized strings using context.tr('key') or AppLocalizations.of(context)!
  final List<String> _tabTitles = ['Bus Lines', 'Live Map', 'Favorites'];

  /// Handles tapping on a bottom navigation bar item.
  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      Log.d("Passenger tab changed to index: $index (${_tabTitles[index]})");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _tabTitles[_currentIndex]), // Dynamically set title based on tab
        // Apply consistent AppBar styling from the theme
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings', // TODO: Localize
            onPressed: () {
              Log.i("Settings button pressed from Passenger Home.");
              context.pushNamed(RouteNames.settings); // Navigate using GoRouter
            },
          ),
        ],
      ),
      // Use IndexedStack to keep the state of inactive tabs alive
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      // Apply themed BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt), // Use filled icon when active
            label: 'Lines', // TODO: Localize
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map', // TODO: Localize
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites', // TODO: Localize
          ),
        ],
        // Use theme settings for colors, type, etc.
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        type: theme.bottomNavigationBarTheme.type,
        elevation: theme.bottomNavigationBarTheme.elevation,
        selectedFontSize: 12, // Explicitly set font sizes if needed
        unselectedFontSize: 12,
        showSelectedLabels: true, // Ensure labels are always visible
        showUnselectedLabels: true,
      ),
    );
  }
}

/// Placeholder widget for tab content during development.
class _PlaceholderTabWidget extends StatelessWidget {
  final String label;
  final Color color;
  const _PlaceholderTabWidget({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Text(
          'Placeholder for\n$label',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }
}
