// lib/utils/responsive_utils.dart

import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < desktopBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile * 1;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile * 1;
    }
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final defaultMobile = mobile ?? const EdgeInsets.all(16);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return defaultMobile;
      case DeviceType.tablet:
        return tablet ?? defaultMobile * 1;
      case DeviceType.desktop:
        return desktop ?? tablet ?? defaultMobile * 2;
    }
  }

  static int getResponsiveColumns(BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? (mobile * 2).clamp(1, 4);
      case DeviceType.desktop:
        return desktop ?? tablet ?? (mobile * 3).clamp(1, 6);
    }
  }

  static double getResponsiveWidth(
    BuildContext context, {
    double mobileRatio = 1,
    double? tabletRatio,
    double? desktopRatio,
    double? maxWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    double ratio;
    switch (deviceType) {
      case DeviceType.mobile:
        ratio = mobileRatio;
        break;
      case DeviceType.tablet:
        ratio = tabletRatio ?? mobileRatio * 0;
        break;
      case DeviceType.desktop:
        ratio = desktopRatio ?? tabletRatio ?? mobileRatio * 0;
        break;
    }
    
    final calculatedWidth = screenWidth * ratio;
    return maxWidth != null 
        ? calculatedWidth.clamp(0, maxWidth) 
        : calculatedWidth;
  }

  static CrossAxisAlignment getResponsiveAlignment(BuildContext context) {
    return isMobile(context) 
        ? CrossAxisAlignment.stretch 
        : CrossAxisAlignment.center;
  }

  static MainAxisAlignment getResponsiveMainAlignment(BuildContext context) {
    return isMobile(context) 
        ? MainAxisAlignment.start 
        : MainAxisAlignment.center;
  }
}

enum DeviceType { mobile, tablet, desktop }

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.maxWidth,
    this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(
      context,
      mobile: mobilePadding,
      tablet: tabletPadding,
      desktop: desktopPadding,
    );

    Widget container = Container(
      width: double.infinity,
      padding: padding,
      child: child,
    );

    if (maxWidth != null) {
      container = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: container,
        ),
      );
    }

    return container;
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1,
    this.padding});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getResponsiveColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.wrapOnMobile = true});

  @override
  Widget build(BuildContext context) {
    if (wrapOnMobile && ResponsiveUtils.isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool expandOnDesktop;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.expandOnDesktop = false});

  @override
  Widget build(BuildContext context) {
    final crossAlignment = expandOnDesktop && ResponsiveUtils.isDesktop(context)
        ? CrossAxisAlignment.stretch
        : crossAxisAlignment;

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    TextStyle? style;
    switch (deviceType) {
      case DeviceType.mobile:
        style = mobileStyle;
        break;
      case DeviceType.tablet:
        style = tabletStyle ?? mobileStyle;
        break;
      case DeviceType.desktop:
        style = desktopStyle ?? tabletStyle ?? mobileStyle;
        break;
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets operator *(double factor) {
    return EdgeInsets.fromLTRB(
      left * factor,
      top * factor,
      right * factor,
      bottom * factor,
    );
  }
}