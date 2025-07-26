// lib/widgets/layout/app_layout.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/app_background.dart';
import '../common/glass_app_bar.dart';
import '../common/glass_drawer.dart';
import '../common/glass_bottom_nav.dart';
import '../../providers/theme_provider.dart';

class AppLayout extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;
  final List<GlassBottomNavItem>? bottomNavItems;
  final int? currentBottomNavIndex;
  final ValueChanged<int>? onBottomNavTap;
  final bool showAppBar;
  final bool showDrawer;
  final bool showBottomNav;
  final bool showBackground;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const AppLayout({
    Key? key,
    required this.body,
    this.title,
    this.appBarActions,
    this.floatingActionButton,
    this.bottomNavItems,
    this.currentBottomNavIndex = 0,
    this.onBottomNavTap,
    this.showAppBar = true,
    this.showDrawer = false,
    this.showBottomNav = false,
    this.showBackground = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.padding,
  }) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar && widget.title != null
          ? GlassAppBar(
              title: widget.title!,
              actions: widget.appBarActions,
              leading: widget.leading,
              showBackButton: widget.showBackButton,
              onBackPressed: widget.onBackPressed,
            )
          : null,
      drawer: widget.showDrawer ? const GlassDrawer() : null,
      body: SafeArea(
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: widget.body,
        ),
      ),
      bottomNavigationBar: widget.showBottomNav && widget.bottomNavItems != null
          ? GlassBottomNav(
              currentIndex: widget.currentBottomNavIndex ?? 0,
              items: widget.bottomNavItems!,
              onTap: widget.onBottomNavTap,
            )
          : null,
      floatingActionButton: widget.floatingActionButton,
    );

    if (widget.showBackground) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AppBackground(
            showAnimatedShapes: true,
            isDarkMode: themeProvider.isDarkMode,
            child: content,
          );
        },
      );
    }

    return content;
  }
}

class SimpleAppLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackground;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? padding;

  const SimpleAppLayout({
    Key? key,
    required this.child,
    this.title,
    this.showBackground = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: title != null
          ? GlassAppBar(
              title: title!,
              showBackButton: showBackButton,
              onBackPressed: onBackPressed,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (showBackground) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AppBackground(
            isDarkMode: themeProvider.isDarkMode,
            child: content,
          );
        },
      );
    }

    return content;
  }
}