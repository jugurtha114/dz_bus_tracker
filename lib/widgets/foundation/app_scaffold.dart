// lib/widgets/foundation/app_scaffold.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Modern, optimized scaffold component following Material You design
/// Provides consistent page structure across the app
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.showAppBar = true,
    this.centerTitle = false,
    this.actions,
    this.leading,
    this.elevation,
  });

  final String? title;
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool showAppBar;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: _buildAppBar(context),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (appBar != null) return appBar;
    if (!showAppBar) return null;
    if (title == null) return null;

    return AppBar(
      title: Text(title!),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      elevation: elevation ?? 0,
      scrolledUnderElevation: elevation ?? DesignSystem.elevation1,
      backgroundColor: context.colors.surface,
      foregroundColor: context.colors.onSurface,
    );
  }
}

/// Page scaffold with consistent padding and safe area
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showAppBar = true,
    this.showBackButton = false,
    this.centerTitle = false,
    this.backgroundColor,
    this.safeArea = true,
    this.scrollable = false,
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool safeArea;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    Widget body = Padding(
      padding: padding ?? const EdgeInsets.all(DesignSystem.space16),
      child: child,
    );

    if (scrollable) {
      body = SingleChildScrollView(child: body);
    }

    if (safeArea) {
      body = SafeArea(child: body);
    }

    return AppScaffold(
      title: title,
      body: body,
      actions: actions,
      leading: showBackButton && Navigator.of(context).canPop() 
          ? BackButton(
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      showAppBar: showAppBar,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
    );
  }
}

/// Loading scaffold for async operations
class AppLoadingScaffold extends StatelessWidget {
  const AppLoadingScaffold({
    super.key,
    this.title,
    this.message,
    this.showAppBar = true,
  });

  final String? title;
  final String? message;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showAppBar: showAppBar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: context.colors.primary,
            ),
            if (message != null) ...[
              const SizedBox(height: DesignSystem.space16),
              Text(
                message!,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error scaffold for error states
class AppErrorScaffold extends StatelessWidget {
  const AppErrorScaffold({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryText = 'Retry',
    this.showAppBar = true,
  });

  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showAppBar: showAppBar,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colors.error,
              ),
              const SizedBox(height: DesignSystem.space16),
              Text(
                message,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: DesignSystem.space24),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(retryText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}