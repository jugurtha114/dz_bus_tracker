// lib/widgets/common/glassy_image_background.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

enum GlassyVariant {
  primary,
  secondary,
  tertiary,
  neutral,
  dark,
}

class GlassyImageBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final double opacity;
  final double blurIntensity;
  final Color overlayColor;
  final List<Color>? gradientColors;
  final bool showGradient;
  final GlassyVariant variant;

  const GlassyImageBackground({
    Key? key,
    required this.child,
    required this.imagePath,
    this.opacity = 0.7,
    this.blurIntensity = 5.0,
    this.overlayColor = Colors.black,
    this.gradientColors,
    this.showGradient = true,
    this.variant = GlassyVariant.primary,
  }) : super(key: key);

  List<Color> _getVariantColors(bool isDark) {
    if (gradientColors != null) {
      return gradientColors!;
    }

    switch (variant) {
      case GlassyVariant.primary:
        return isDark
            ? [AppTheme.neutral900, AppTheme.primary.withValues(alpha: 0.3)]
            : [AppTheme.primary.withValues(alpha: 0.2), AppTheme.primaryLight];
      case GlassyVariant.secondary:
        return isDark
            ? [AppTheme.neutral900, AppTheme.secondary.withValues(alpha: 0.3)]
            : [AppTheme.secondary.withValues(alpha: 0.2), AppTheme.secondaryLight];
      case GlassyVariant.tertiary:
        return isDark
            ? [AppTheme.neutral900, AppTheme.tertiary.withValues(alpha: 0.3)]
            : [AppTheme.tertiary.withValues(alpha: 0.2), AppTheme.tertiaryLight];
      case GlassyVariant.neutral:
        return isDark
            ? [AppTheme.neutral900, AppTheme.neutral800]
            : [AppTheme.neutral100, AppTheme.neutral200];
      case GlassyVariant.dark:
        return [AppTheme.neutral900, AppTheme.neutral800];
    }
  }

  Color _getOverlayGradientColor() {
    switch (variant) {
      case GlassyVariant.primary:
        return AppTheme.primary;
      case GlassyVariant.secondary:
        return AppTheme.secondary;
      case GlassyVariant.tertiary:
        return AppTheme.tertiary;
      case GlassyVariant.neutral:
      case GlassyVariant.dark:
        return AppTheme.neutral700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getVariantColors(isDark),
                    ),
                  ),
                );
              },
            ),
          ),

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurIntensity,
                sigmaY: blurIntensity,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Gradient overlay
          if (showGradient)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors ?? [
                      overlayColor.withValues(alpha: 0.4),
                      overlayColor.withValues(alpha: 0.2),
                      _getOverlayGradientColor().withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),

          // Glass effect overlay
          Positioned.fill(
            child: Container(
              color: (isDark ? Colors.black : Colors.white)
                  .withValues(alpha: opacity * 0.1),
            ),
          ),

          // Content
          child,
        ],
      ),
    );
  }
}

class GlassyCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;
  final Color? borderColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassyCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.showBorder = true,
    this.showShadow = true,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
  }) : super(key: key);

  @override
  State<GlassyCard> createState() => _GlassyCardState();
}

class _GlassyCardState extends State<GlassyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? (_) => _handleTapDown() : null,
            onTapUp: widget.onTap != null ? (_) => _handleTapUp() : null,
            onTapCancel: widget.onTap != null ? _handleTapCancel : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin ?? EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: widget.showBorder
                          ? Border.all(
                              color: widget.borderColor ??
                                  (isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.3)),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: widget.showShadow
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 0),
                              ),
                            ]
                          : null,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }
}

class GlassyAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GlassyAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1));
    final fgColor = foregroundColor ?? 
        (isDark ? Colors.white : AppTheme.onSurface);

    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (leading != null)
                      leading!
                    else if ((canPop || showBackButton) && onBackPressed != null)
                      GlassyCard(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 16),
                        borderRadius: 12,
                        onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: fgColor,
                        ),
                      ),

                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: fgColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    if (actions != null) ...actions! else const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Convenience constructors
extension GlassyImageBackgroundVariants on GlassyImageBackground {
  static GlassyImageBackground primary({
    Key? key,
    required Widget child,
    required String imagePath,
    double opacity = 0.7,
    double blurIntensity = 5.0,
    Color overlayColor = Colors.black,
    List<Color>? gradientColors,
    bool showGradient = true,
  }) {
    return GlassyImageBackground(
      key: key,
      child: child,
      imagePath: imagePath,
      opacity: opacity,
      blurIntensity: blurIntensity,
      overlayColor: overlayColor,
      gradientColors: gradientColors,
      showGradient: showGradient,
      variant: GlassyVariant.primary,
    );
  }

  static GlassyImageBackground secondary({
    Key? key,
    required Widget child,
    required String imagePath,
    double opacity = 0.7,
    double blurIntensity = 5.0,
    Color overlayColor = Colors.black,
    List<Color>? gradientColors,
    bool showGradient = true,
  }) {
    return GlassyImageBackground(
      key: key,
      child: child,
      imagePath: imagePath,
      opacity: opacity,
      blurIntensity: blurIntensity,
      overlayColor: overlayColor,
      gradientColors: gradientColors,
      showGradient: showGradient,
      variant: GlassyVariant.secondary,
    );
  }

  static GlassyImageBackground dark({
    Key? key,
    required Widget child,
    required String imagePath,
    double opacity = 0.7,
    double blurIntensity = 5.0,
    Color overlayColor = Colors.black,
    List<Color>? gradientColors,
    bool showGradient = true,
  }) {
    return GlassyImageBackground(
      key: key,
      child: child,
      imagePath: imagePath,
      opacity: opacity,
      blurIntensity: blurIntensity,
      overlayColor: overlayColor,
      gradientColors: gradientColors,
      showGradient: showGradient,
      variant: GlassyVariant.dark,
    );
  }
}