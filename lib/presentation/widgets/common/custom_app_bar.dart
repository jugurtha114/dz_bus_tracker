/// lib/presentation/widgets/common/custom_app_bar.dart

import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // For default styling hints

/// A custom AppBar widget implementing a "glassmorphism" effect with blur.
/// Provides a consistent styled AppBar for the application.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The primary widget displayed in the AppBar. Typically a [Text] widget.
  final Widget? title;

  /// A widget to display before the [title]. Typically an [IconButton] or [BackButton].
  final Widget? leading;

  /// Widgets to display after the [title]. Typically [IconButton]s.
  final List<Widget>? actions;

  /// Whether the title should be centered. Defaults based on platform.
  final bool? centerTitle;

  /// The background color *behind* the blur effect. Can be semi-transparent.
  /// Defaults to a semi-transparent surface color based on the theme.
  final Color? backgroundColor;

  /// The default color for icons and text within the AppBar.
  /// Defaults based on theme brightness (white for dark, black for light).
  final Color? foregroundColor;

  /// The elevation of the AppBar (shadow below). Defaults to 0 for glassy look.
  final double elevation;

  /// The sigma value for the Gaussian blur effect. Higher values mean more blur.
  final double blurSigma;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.0, // Default elevation to 0 for glassy effect
    this.blurSigma = 8.0, // Default blur intensity
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine default background and foreground colors based on theme
    final defaultBgColor = isDark
        ? AppTheme.neutralDark.withOpacity(0.2) // Dark glassy background
        : Colors.white.withOpacity(0.15); // Light glassy background

    final defaultFgColor = isDark ? Colors.white : AppTheme.neutralDark;

    final effectiveBgColor = backgroundColor ?? defaultBgColor;
    final effectiveFgColor = foregroundColor ?? defaultFgColor;

    return ClipRect( // Clip the blur effect
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          // Apply the semi-transparent background color *inside* the blur
          color: effectiveBgColor,
          child: AppBar(
            // Make the underlying AppBar transparent to see the blurred background
            backgroundColor: Colors.transparent,
            // Set elevation to 0 to avoid AppBar's own shadow interfering
            elevation: 0,
            scrolledUnderElevation: 0, // Prevent color change on scroll
            // Pass through parameters
            title: title,
            leading: leading,
            actions: actions,
            centerTitle: centerTitle,
            // Apply foreground color for icons and potentially title if not styled explicitly
            foregroundColor: effectiveFgColor,
            iconTheme: IconThemeData(color: effectiveFgColor),
            actionsIconTheme: IconThemeData(color: effectiveFgColor),
            titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(color: effectiveFgColor),
          ),
        ),
      ),
    );
     // Optional: Add a subtle bottom border outside the BackdropFilter if desired
    // return PreferredSize(
    //    preferredSize: preferredSize,
    //    child: Container(
    //       decoration: BoxDecoration(
    //          border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.5))
    //       ),
    //       child: ClipRect(...) // Rest of the AppBar structure above
    //    )
    // );
  }

  /// Defines the preferred size of the AppBar, typically the standard toolbar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
