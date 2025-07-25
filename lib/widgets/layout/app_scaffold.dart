// lib/widgets/layout/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/custom_app_bar.dart';
import '../common/loading_states.dart';
import '../common/error_states.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive_utils.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showBackButton;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final AppBarType appBarType;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showAppBar;
  final Widget? bottomSheet;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final bool useResponsiveLayout;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.showBackButton = true,
    this.showThemeToggle = false,
    this.onBackPressed,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.appBarType = AppBarType.primary,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.showAppBar = true,
    this.bottomSheet,
    this.safeArea = true,
    this.padding,
    this.useResponsiveLayout = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = body;

    // Add error handling
    if (errorMessage != null) {
      content = ErrorStateWidget(
        errorType: ErrorType.unknown,
        message: errorMessage,
        onRetry: onRetry,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    // Add loading overlay
    if (isLoading) {
      content = LoadingOverlay(
        isLoading: true,
        child: content,
      );
    }

    // Add responsive layout wrapper
    if (useResponsiveLayout) {
      content = ResponsiveContainer(
        maxWidth: ResponsiveUtils.isDesktop(context) ? 1200 : null,
        child: content,
      );
    }

    // Add padding if specified
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // Add safe area if specified
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: showAppBar
          ? CustomAppBar(
              title: title,
              type: appBarType,
              actions: actions,
              leading: leading,
              showBackButton: showBackButton,
              showThemeToggle: showThemeToggle,
              onBackPressed: onBackPressed,
              backgroundColor: backgroundColor,
            )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? colorScheme.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomSheet: bottomSheet,
    );
  }
}

class ResponsiveAppScaffold extends StatelessWidget {
  final String title;
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showBackButton;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final AppBarType appBarType;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ResponsiveAppScaffold({
    super.key,
    required this.title,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.showBackButton = true,
    this.showThemeToggle = false,
    this.onBackPressed,
    this.backgroundColor,
    this.appBarType = AppBarType.primary,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: ResponsiveWidget(
        mobile: mobileBody,
        tablet: tabletBody,
        desktop: desktopBody,
      ),
      actions: actions,
      leading: leading,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      showBackButton: showBackButton,
      showThemeToggle: showThemeToggle,
      onBackPressed: onBackPressed,
      backgroundColor: backgroundColor,
      appBarType: appBarType,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
    );
  }
}

class DashboardScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showThemeToggle;
  final Color? backgroundColor;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final List<DashboardTab>? tabs;
  final int? initialTabIndex;
  final Function(int)? onTabChanged;

  const DashboardScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showThemeToggle = true,
    this.backgroundColor,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.tabs,
    this.initialTabIndex,
    this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = body;

    if (tabs != null && tabs!.isNotEmpty) {
      content = DefaultTabController(
        length: tabs!.length,
        initialIndex: initialTabIndex ?? 0,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: TabBar(
                tabs: tabs!.map((tab) => Tab(
                  text: tab.title,
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                )).toList(),
                onTap: onTabChanged,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: tabs!.map((tab) => tab.content).toList(),
              ),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      title: title,
      body: content,
      actions: actions,
      floatingActionButton: floatingActionButton,
      showBackButton: false,
      showThemeToggle: showThemeToggle,
      backgroundColor: backgroundColor,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
      safeArea: false,
      useResponsiveLayout: true,
    );
  }
}

class DashboardTab {
  final String title;
  final IconData? icon;
  final Widget content;

  const DashboardTab({
    required this.title,
    this.icon,
    required this.content});
}

class BottomNavScaffold extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final String title;
  final List<Widget>? actions;
  final bool showThemeToggle;
  final Color? backgroundColor;

  const BottomNavScaffold({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.title,
    this.actions,
    this.showThemeToggle = false,
    this.backgroundColor});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppScaffold(
      title: widget.title,
      body: IndexedStack(
        index: widget.currentIndex,
        children: widget.items.map((item) => item.body).toList(),
      ),
      actions: widget.actions,
      showBackButton: false,
      showThemeToggle: widget.showThemeToggle,
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        items: widget.items.map((item) => BottomNavigationBarItem(

          activeIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label, icon: Icon(item.activeIcon ?? item.icon),
        )).toList(),
      ),
      safeArea: false,
    );
  }
}

class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Widget body;

  const BottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.body});
}