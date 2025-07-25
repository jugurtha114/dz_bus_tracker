// lib/widgets/common/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

enum AppBarType { primary, secondary, transparent }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppBarType type;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final Widget? bottom;
  final double? bottomHeight;

  const CustomAppBar({
    super.key,
    required this.title,
    this.type = AppBarType.primary,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.showThemeToggle = false,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.bottom,
    this.bottomHeight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: foregroundColor ?? _getForegroundColor(colorScheme),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: elevation > 0 ? elevation + 1 : 1,
      backgroundColor: backgroundColor ?? _getBackgroundColor(colorScheme),
      foregroundColor: foregroundColor ?? _getForegroundColor(colorScheme),
      surfaceTintColor: type == AppBarType.transparent ? Colors.transparent : null,
      systemOverlayStyle: _getSystemOverlayStyle(colorScheme),
      leading: leading ?? (showBackButton && canPop 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null),
      actions: [
        ...?actions,
        if (showThemeToggle) _buildThemeToggle(context),
      ],
      bottom: bottom != null 
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 48),
              child: bottom!,
            )
          : null,
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeProvider.toggleTheme,
          tooltip: 'Switch to ${_getNextThemeName(themeProvider.currentThemeName)}',
        );
      },
    );
  }

  String _getNextThemeName(String currentTheme) {
    switch (currentTheme) {
      case 'Light':
        return 'Dark';
      case 'Dark':
        return 'System';
      case 'System':
        return 'Light';
      default:
        return 'Light';
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (type) {
      case AppBarType.primary:
        return colorScheme.surface;
      case AppBarType.secondary:
        return colorScheme.surfaceVariant;
      case AppBarType.transparent:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    switch (type) {
      case AppBarType.primary:
      case AppBarType.secondary:
        return colorScheme.onSurface;
      case AppBarType.transparent:
        return colorScheme.onSurface;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom != null ? (bottomHeight ?? 48) : 0),
  );
}

class SliverCustomAppBar extends StatelessWidget {
  final String title;
  final AppBarType type;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final Widget? bottom;
  final double? bottomHeight;

  const SliverCustomAppBar({
    super.key,
    required this.title,
    this.type = AppBarType.primary,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.showThemeToggle = false,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 200,
    this.flexibleSpace,
    this.bottom,
    this.bottomHeight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canPop = Navigator.of(context).canPop();

    return SliverAppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: foregroundColor ?? _getForegroundColor(colorScheme),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: backgroundColor ?? _getBackgroundColor(colorScheme),
      foregroundColor: foregroundColor ?? _getForegroundColor(colorScheme),
      surfaceTintColor: type == AppBarType.transparent ? Colors.transparent : null,
      systemOverlayStyle: _getSystemOverlayStyle(colorScheme),
      leading: leading ?? (showBackButton && canPop 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null),
      actions: [
        ...?actions,
        if (showThemeToggle) _buildThemeToggle(context),
      ],
      flexibleSpace: flexibleSpace,
      bottom: bottom != null 
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 48),
              child: bottom!,
            )
          : null,
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeProvider.toggleTheme,
          tooltip: 'Switch to ${_getNextThemeName(themeProvider.currentThemeName)}',
        );
      },
    );
  }

  String _getNextThemeName(String currentTheme) {
    switch (currentTheme) {
      case 'Light':
        return 'Dark';
      case 'Dark':
        return 'System';
      case 'System':
        return 'Light';
      default:
        return 'Light';
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (type) {
      case AppBarType.primary:
        return colorScheme.surface;
      case AppBarType.secondary:
        return colorScheme.surfaceVariant;
      case AppBarType.transparent:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    switch (type) {
      case AppBarType.primary:
      case AppBarType.secondary:
        return colorScheme.onSurface;
      case AppBarType.transparent:
        return colorScheme.onSurface;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }
}