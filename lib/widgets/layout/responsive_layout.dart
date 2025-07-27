// lib/widgets/layout/responsive_layout.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Responsive layout component that adapts to different screen sizes
/// Follows Material You breakpoints and responsive design principles
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.breakpoints,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final ResponsiveBreakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoints = this.breakpoints ?? ResponsiveBreakpoints.material();
        
        if (constraints.maxWidth >= breakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= breakpoints.tablet && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive builder that provides screen size information
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.breakpoints,
  });

  final Widget Function(BuildContext context, ScreenSize screenSize, BoxConstraints constraints) builder;
  final ResponsiveBreakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoints = this.breakpoints ?? ResponsiveBreakpoints.material();
        final screenSize = _getScreenSize(constraints.maxWidth, breakpoints);
        
        return builder(context, screenSize, constraints);
      },
    );
  }

  ScreenSize _getScreenSize(double width, ResponsiveBreakpoints breakpoints) {
    if (width >= breakpoints.desktop) return ScreenSize.desktop;
    if (width >= breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

/// Adaptive layout that changes navigation based on screen size
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.body,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.breakpoints,
    this.navigationRailExtended = false,
  });

  final Widget body;
  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final ResponsiveBreakpoints? breakpoints;
  final bool navigationRailExtended;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, screenSize, constraints) {
        switch (screenSize) {
          case ScreenSize.mobile:
            return _buildMobileLayout(context);
          case ScreenSize.tablet:
            return _buildTabletLayout(context);
          case ScreenSize.desktop:
            return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map((dest) => NavigationDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: dest.selectedIcon != null 
                      ? Icon(dest.selectedIcon!)
                      : Icon(dest.icon),
                  label: dest.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: navigationRailExtended,
            destinations: destinations
                .map((dest) => NavigationRailDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: dest.selectedIcon != null 
                          ? Icon(dest.selectedIcon!)
                          : Icon(dest.icon),
                      label: Text(dest.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: true,
            destinations: destinations
                .map((dest) => NavigationRailDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: dest.selectedIcon != null 
                          ? Icon(dest.selectedIcon!)
                          : Icon(dest.icon),
                      label: Text(dest.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Grid layout with responsive columns
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = DesignSystem.space16,
    this.runSpacing,
    this.breakpoints,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double? runSpacing;
  final ResponsiveBreakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, screenSize, constraints) {
        final columns = switch (screenSize) {
          ScreenSize.mobile => mobileColumns,
          ScreenSize.tablet => tabletColumns,
          ScreenSize.desktop => desktopColumns,
        };

        return _buildGrid(columns);
      },
    );
  }

  Widget _buildGrid(int columns) {
    if (children.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < columns; j++) {
        if (i + j < children.length) {
          rowChildren.add(Expanded(child: children[i + j]));
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
        
        if (j < columns - 1) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }
      
      rows.add(Row(children: rowChildren));
      
      if (i + columns < children.length) {
        rows.add(SizedBox(height: runSpacing ?? spacing));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

/// Container with responsive padding
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(DesignSystem.space16),
    this.tabletPadding = const EdgeInsets.all(DesignSystem.space24),
    this.desktopPadding = const EdgeInsets.all(DesignSystem.space32),
    this.breakpoints,
  });

  final Widget child;
  final EdgeInsetsGeometry mobilePadding;
  final EdgeInsetsGeometry tabletPadding;
  final EdgeInsetsGeometry desktopPadding;
  final ResponsiveBreakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      builder: (context, screenSize, constraints) {
        final padding = switch (screenSize) {
          ScreenSize.mobile => mobilePadding,
          ScreenSize.tablet => tabletPadding,
          ScreenSize.desktop => desktopPadding,
        };

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// Safe area with responsive behavior
class ResponsiveSafeArea extends StatelessWidget {
  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
  });

  final Widget child;
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        // On larger screens, we might want different safe area behavior
        final adaptedBottom = screenSize == ScreenSize.mobile ? bottom : false;
        
        return SafeArea(
          left: left,
          top: top,
          right: right,
          bottom: adaptedBottom,
          minimum: minimum,
          maintainBottomViewPadding: maintainBottomViewPadding,
          child: child,
        );
      },
    );
  }
}

/// Data classes

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints({
    required this.tablet,
    required this.desktop,
  });

  final double tablet;
  final double desktop;

  /// Material Design breakpoints
  factory ResponsiveBreakpoints.material() {
    return const ResponsiveBreakpoints(
      tablet: 600,
      desktop: 1240,
    );
  }

  /// Custom breakpoints for bus tracker app
  factory ResponsiveBreakpoints.busTracker() {
    return const ResponsiveBreakpoints(
      tablet: 768,
      desktop: 1200,
    );
  }
}

class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// Extensions for easy access to responsive values
extension ResponsiveValues on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.of(this).size.width;
    if (width >= 1240) return ScreenSize.desktop;
    if (width >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return switch (screenSize) {
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet ?? mobile,
      ScreenSize.desktop => desktop ?? tablet ?? mobile,
    };
  }
}