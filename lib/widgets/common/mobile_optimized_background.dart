// lib/widgets/common/mobile_optimized_background.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

enum MobileBackgroundVariant {
  primary,
  secondary,
  tertiary,
  neutral,
  performance, // Ultra-light variant for low-end devices
}

class MobileOptimizedBackground extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final double opacity;
  final double blurIntensity;
  final List<Color>? gradientColors;
  final bool enableEffects;
  final MobileBackgroundVariant variant;

  const MobileOptimizedBackground({
    Key? key,
    required this.child,
    this.imagePath,
    this.opacity = 0.7,
    this.blurIntensity = 3.0,
    this.gradientColors,
    this.enableEffects = true,
    this.variant = MobileBackgroundVariant.primary,
  }) : super(key: key);

  List<Color> _getVariantColors(bool isDark) {
    if (gradientColors != null) {
      return gradientColors!;
    }

    switch (variant) {
      case MobileBackgroundVariant.primary:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.primary.withValues(alpha: 0.1),
              ]
            : [
                AppTheme.neutral50,
                AppTheme.primary.withValues(alpha: 0.05),
                AppTheme.primaryLight.withValues(alpha: 0.05),
              ];
      case MobileBackgroundVariant.secondary:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.secondary.withValues(alpha: 0.1),
              ]
            : [
                AppTheme.neutral50,
                AppTheme.secondary.withValues(alpha: 0.05),
                AppTheme.secondaryLight.withValues(alpha: 0.05),
              ];
      case MobileBackgroundVariant.tertiary:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.tertiary.withValues(alpha: 0.1),
              ]
            : [
                AppTheme.neutral50,
                AppTheme.tertiary.withValues(alpha: 0.05),
                AppTheme.tertiaryLight.withValues(alpha: 0.05),
              ];
      case MobileBackgroundVariant.neutral:
        return isDark
            ? [AppTheme.neutral900, AppTheme.neutral800, AppTheme.neutral700]
            : [AppTheme.neutral50, AppTheme.neutral100, AppTheme.neutral200];
      case MobileBackgroundVariant.performance:
        return isDark
            ? [AppTheme.neutral900, AppTheme.neutral800]
            : [AppTheme.neutral50, AppTheme.neutral100];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    
    // Reduce effects on mobile for better performance
    final effectiveBlur = isMobile ? (blurIntensity * 0.5) : blurIntensity;
    final effectiveOpacity = isMobile ? (opacity * 0.8) : opacity;
    final shouldShowImage = enableEffects && imagePath != null && variant != MobileBackgroundVariant.performance;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background gradient (always show)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getVariantColors(isDark),
              ),
            ),
          ),

          // Background image (only on web or when performance allows)
          if (shouldShowImage && (!isMobile || enableEffects))
            Positioned.fill(
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(effectiveOpacity * 0.3),
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),

          // Light blur overlay (reduced on mobile, disabled for performance variant)
          if (enableEffects && variant != MobileBackgroundVariant.performance)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: Container(
                  color: (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: effectiveOpacity * 0.1),
                ),
              ),
            ),

          // Content
          child,
        ],
      ),
    );
  }
}

class OptimizedGlassCard extends StatefulWidget {
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

  const OptimizedGlassCard({
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
  State<OptimizedGlassCard> createState() => _OptimizedGlassCardState();
}

class _OptimizedGlassCardState extends State<OptimizedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100), // Faster on mobile
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
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    
    // Reduce blur on mobile for performance
    final blurIntensity = isMobile ? 5.0 : 10.0;

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
                  filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.25),
                          isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.15),
                        ],
                      ),
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
                      boxShadow: widget.showShadow && !isMobile
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.03),
                                blurRadius: 20,
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

class SimpleBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  final MobileBackgroundVariant variant;

  const SimpleBackground({
    Key? key,
    required this.child,
    this.isDarkMode = false,
    this.variant = MobileBackgroundVariant.neutral,
  }) : super(key: key);

  List<Color> _getSimpleColors() {
    switch (variant) {
      case MobileBackgroundVariant.primary:
        return isDarkMode
            ? [AppTheme.neutral900, AppTheme.primary.withValues(alpha: 0.1)]
            : [AppTheme.neutral50, AppTheme.primary.withValues(alpha: 0.05)];
      case MobileBackgroundVariant.secondary:
        return isDarkMode
            ? [AppTheme.neutral900, AppTheme.secondary.withValues(alpha: 0.1)]
            : [AppTheme.neutral50, AppTheme.secondary.withValues(alpha: 0.05)];
      case MobileBackgroundVariant.tertiary:
        return isDarkMode
            ? [AppTheme.neutral900, AppTheme.tertiary.withValues(alpha: 0.1)]
            : [AppTheme.neutral50, AppTheme.tertiary.withValues(alpha: 0.05)];
      case MobileBackgroundVariant.neutral:
      case MobileBackgroundVariant.performance:
        return isDarkMode
            ? [AppTheme.neutral900, AppTheme.neutral800]
            : [AppTheme.neutral50, AppTheme.neutral100];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getSimpleColors(),
        ),
      ),
      child: child,
    );
  }
}

// Convenience constructors
extension MobileOptimizedBackgroundVariants on MobileOptimizedBackground {
  static MobileOptimizedBackground primary({
    Key? key,
    required Widget child,
    String? imagePath,
    double opacity = 0.7,
    double blurIntensity = 3.0,
    List<Color>? gradientColors,
    bool enableEffects = true,
  }) {
    return MobileOptimizedBackground(
      key: key,
      child: child,
      imagePath: imagePath,
      opacity: opacity,
      blurIntensity: blurIntensity,
      gradientColors: gradientColors,
      enableEffects: enableEffects,
      variant: MobileBackgroundVariant.primary,
    );
  }

  static MobileOptimizedBackground performance({
    Key? key,
    required Widget child,
    String? imagePath,
    double opacity = 0.5,
    double blurIntensity = 1.0,
    List<Color>? gradientColors,
    bool enableEffects = false,
  }) {
    return MobileOptimizedBackground(
      key: key,
      child: child,
      imagePath: imagePath,
      opacity: opacity,
      blurIntensity: blurIntensity,
      gradientColors: gradientColors,
      enableEffects: enableEffects,
      variant: MobileBackgroundVariant.performance,
    );
  }

  static MobileOptimizedBackground secondary({
    Key? key,
    required Widget child,
    String? imagePath,
    double opacity = 0.7,
    double blurIntensity = 3.0,
    List<Color>? gradientColors,
    bool enableEffects = true,
  }) {
    return MobileOptimizedBackground(
      key: key,
      child: child,
      imagePath: imagePath,
      opacity: opacity,
      blurIntensity: blurIntensity,
      gradientColors: gradientColors,
      enableEffects: enableEffects,
      variant: MobileBackgroundVariant.secondary,
    );
  }
}