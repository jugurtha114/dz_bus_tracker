// lib/widgets/layout/page_layout.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import 'responsive_layout.dart';

/// Standard page layout with consistent structure
/// Provides common page patterns used throughout the app
class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    this.title,
    required this.body,
    this.header,
    this.footer,
    this.sidebar,
    this.floatingActionButton,
    this.padding,
    this.scrollable = true,
    this.safeArea = true,
    this.showAppBar = true,
    this.appBarActions,
    this.backgroundColor,
  });

  final String? title;
  final Widget body;
  final Widget? header;
  final Widget? footer;
  final Widget? sidebar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool safeArea;
  final bool showAppBar;
  final List<Widget>? appBarActions;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Add header and footer if provided
    if (header != null || footer != null) {
      content = Column(
        children: [
          if (header != null) header!,
          Expanded(child: content),
          if (footer != null) footer!,
        ],
      );
    }

    // Add sidebar for larger screens
    if (sidebar != null) {
      content = ResponsiveLayout(
        mobile: content,
        tablet: Row(
          children: [
            SizedBox(
              width: 240,
              child: sidebar!,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: content),
          ],
        ),
        desktop: Row(
          children: [
            SizedBox(
              width: 280,
              child: sidebar!,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    // Add padding
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    } else {
      content = ResponsivePadding(child: content);
    }

    // Make scrollable if needed
    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    // Add safe area
    if (safeArea) {
      content = ResponsiveSafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.surface,
      appBar: showAppBar && title != null
          ? AppBar(
              title: Text(title!),
              actions: appBarActions,
            )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// List page layout optimized for displaying lists of items
class ListPageLayout extends StatelessWidget {
  const ListPageLayout({
    super.key,
    this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRefresh,
    this.floatingActionButton,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.showAppBar = true,
    this.appBarActions,
  });

  final String? title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? header;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(String? error)? errorBuilder;
  final RefreshCallback? onRefresh;
  final Widget? floatingActionButton;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool showAppBar;
  final List<Widget>? appBarActions;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = loadingBuilder?.call(context) ?? _buildDefaultLoading(context);
    } else if (hasError) {
      content = errorBuilder?.call(errorMessage) ?? _buildDefaultError(context);
    } else if (itemCount == 0) {
      content = emptyBuilder?.call(context) ?? _buildDefaultEmpty(context);
    } else {
      content = _buildList(context);
    }

    if (onRefresh != null && !isLoading) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: showAppBar && title != null
          ? AppBar(
              title: Text(title!),
              actions: appBarActions,
            )
          : null,
      body: ResponsiveSafeArea(child: content),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildList(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (header != null)
          SliverToBoxAdapter(child: header!),
        SliverPadding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLoading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: DesignSystem.space16),
          Text(
            'No items found',
            style: context.textStyles.headlineSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError(BuildContext context) {
    return Center(
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
            errorMessage ?? 'An error occurred',
            style: context.textStyles.headlineSmall?.copyWith(
              color: context.colors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Detail page layout for showing item details
class DetailPageLayout extends StatelessWidget {
  const DetailPageLayout({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
    this.backgroundColor,
  });

  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.surface,
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
            )
          : null,
      body: ResponsiveSafeArea(
        child: SingleChildScrollView(
          child: ResponsivePadding(child: content),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Form page layout optimized for forms
class FormPageLayout extends StatelessWidget {
  const FormPageLayout({
    super.key,
    this.title,
    required this.form,
    this.actions,
    this.isLoading = false,
    this.showAppBar = true,
    this.backgroundColor,
  });

  final String? title;
  final Widget form;
  final Widget? actions;
  final bool isLoading;
  final bool showAppBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        Expanded(child: form),
        if (actions != null) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: actions!,
          ),
        ],
      ],
    );

    if (isLoading) {
      content = Stack(
        children: [
          content,
          Container(
            color: context.colors.surface.withValues(alpha: 0.8),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.surface,
      appBar: showAppBar && title != null
          ? AppBar(
              title: Text(title!),
            )
          : null,
      body: ResponsiveSafeArea(
        child: content,
      ),
    );
  }
}

/// Dashboard layout with sections
class DashboardLayout extends StatelessWidget {
  const DashboardLayout({
    super.key,
    this.title,
    required this.sections,
    this.header,
    this.showAppBar = true,
    this.appBarActions,
    this.onRefresh,
  });

  final String? title;
  final List<DashboardSection> sections;
  final Widget? header;
  final bool showAppBar;
  final List<Widget>? appBarActions;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    Widget content = CustomScrollView(
      slivers: [
        if (header != null)
          SliverToBoxAdapter(child: header!),
        ...sections.map((section) => _buildSection(context, section)),
      ],
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: showAppBar && title != null
          ? AppBar(
              title: Text(title!),
              actions: appBarActions,
            )
          : null,
      body: ResponsiveSafeArea(child: content),
    );
  }

  Widget _buildSection(BuildContext context, DashboardSection section) {
    return SliverPadding(
      padding: const EdgeInsets.all(DesignSystem.space16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.title != null) ...[
              Text(
                section.title!,
                style: context.textStyles.headlineSmall,
              ),
              const SizedBox(height: DesignSystem.space12),
            ],
            section.content,
          ],
        ),
      ),
    );
  }
}

/// Data classes

class DashboardSection {
  const DashboardSection({
    this.title,
    required this.content,
  });

  final String? title;
  final Widget content;
}