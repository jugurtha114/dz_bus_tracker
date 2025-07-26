// lib/widgets/common/glass_app_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'glassy_container.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final TextStyle? titleTextStyle;
  final IconThemeData? iconTheme;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final GlassAppBarVariant variant;
  final bool showBorder;
  final bool showGlow;

  const GlassAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.backgroundColor,
    this.centerTitle = false,
    this.titleTextStyle,
    this.iconTheme,
    this.showBackButton = true,
    this.onBackPressed,
    this.variant = GlassAppBarVariant.primary,
    this.showBorder = true,
    this.showGlow = false,
  }) : super(key: key);

  Color _getVariantColor() {
    switch (variant) {
      case GlassAppBarVariant.primary:
        return AppTheme.primary;
      case GlassAppBarVariant.secondary:
        return AppTheme.secondary;
      case GlassAppBarVariant.tertiary:
        return AppTheme.tertiary;
      case GlassAppBarVariant.neutral:
        return AppTheme.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final variantColor = _getVariantColor();
    
    return Container(
      height: preferredSize.height,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: backgroundColor == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.glass,
                        AppTheme.glassMedium,
                        variantColor.withValues(alpha: 0.05),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    )
                  : null,
              border: showBorder
                  ? Border(
                      bottom: BorderSide(
                        color: variantColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.glassShadow,
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
                if (showGlow)
                  BoxShadow(
                    color: variantColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: Row(
                  children: [
                    // Leading widget or back button
                    _buildLeading(context, canPop, variantColor),

                    // Title
                    Expanded(
                      child: Text(
                        title,
                        style: titleTextStyle ??
                            theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                        textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Actions
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context, bool canPop, Color variantColor) {
    if (leading != null) {
      return leading!;
    }
    
    if ((automaticallyImplyLeading && canPop) || showBackButton) {
      return Container(
        margin: const EdgeInsets.only(right: AppTheme.spacing12),
        child: GlassyContainer(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          borderRadius: AppTheme.radiusLg,
          variant: GlassVariant.primary,
          showGlow: showGlow,
          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: variantColor,
          ),
        ),
      );
    }
    
    return const SizedBox(width: AppTheme.spacing16);
  }

  Widget _buildActions() {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox(width: AppTheme.spacing16);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: AppTheme.spacing16),
        ...actions!.map((action) {
          return Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacing8),
            child: action,
          );
        }).toList(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

enum GlassAppBarVariant {
  primary,
  secondary,
  tertiary,
  neutral,
}

class GlassTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final Color? indicatorColor;
  final EdgeInsetsGeometry? padding;
  final GlassAppBarVariant variant;
  final bool showBorder;

  const GlassTabBar({
    Key? key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.indicatorColor,
    this.padding,
    this.variant = GlassAppBarVariant.primary,
    this.showBorder = true,
  }) : super(key: key);

  Color _getVariantColor() {
    switch (variant) {
      case GlassAppBarVariant.primary:
        return AppTheme.primary;
      case GlassAppBarVariant.secondary:
        return AppTheme.secondary;
      case GlassAppBarVariant.tertiary:
        return AppTheme.tertiary;
      case GlassAppBarVariant.neutral:
        return AppTheme.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variantColor = _getVariantColor();
    
    return Container(
      height: preferredSize.height,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.glass,
                  AppTheme.glassMedium,
                  variantColor.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              border: showBorder
                  ? Border(
                      bottom: BorderSide(
                        color: variantColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.glassShadow,
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: TabBar(
                controller: controller,
                tabs: tabs,
                onTap: onTap,
                indicatorColor: indicatorColor ?? variantColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppTheme.onSurface,
                unselectedLabelColor: AppTheme.onSurfaceVariant,
                labelStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.1,
                ),
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(
                  variantColor.withValues(alpha: 0.1),
                ),
                splashBorderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

// Convenience constructors
extension GlassAppBarVariants on GlassAppBar {
  static GlassAppBar primary({
    Key? key,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    bool centerTitle = false,
    TextStyle? titleTextStyle,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    bool showBorder = true,
    bool showGlow = false,
  }) {
    return GlassAppBar(
      key: key,
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      titleTextStyle: titleTextStyle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      variant: GlassAppBarVariant.primary,
      showBorder: showBorder,
      showGlow: showGlow,
    );
  }

  static GlassAppBar secondary({
    Key? key,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    bool centerTitle = false,
    TextStyle? titleTextStyle,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    bool showBorder = true,
    bool showGlow = false,
  }) {
    return GlassAppBar(
      key: key,
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      titleTextStyle: titleTextStyle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      variant: GlassAppBarVariant.secondary,
      showBorder: showBorder,
      showGlow: showGlow,
    );
  }
}