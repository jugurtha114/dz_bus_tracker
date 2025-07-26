// lib/widgets/common/glassy_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class GlassyContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final double blur;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? height;
  final double? width;
  final Alignment alignment;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool showGlow;
  final bool showShimmer;
  final Duration animationDuration;
  final GlassVariant variant;

  const GlassyContainer({
    Key? key,
    required this.child,
    this.borderRadius = AppTheme.radius2xl,
    this.color,
    this.blur = 15,
    this.padding = const EdgeInsets.all(AppTheme.spacing20),
    this.margin = EdgeInsets.zero,
    this.height,
    this.width,
    this.alignment = Alignment.center,
    this.border,
    this.boxShadow,
    this.onTap,
    this.showGlow = false,
    this.showShimmer = false,
    this.animationDuration = AppTheme.animationNormal,
    this.variant = GlassVariant.standard,
  }) : super(key: key);

  @override
  State<GlassyContainer> createState() => _GlassyContainerState();
}

enum GlassVariant {
  standard,
  primary,
  secondary,
  tertiary,
  success,
  warning,
  error,
}

class _GlassyContainerState extends State<GlassyContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.showShimmer) {
      _startShimmerAnimation();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startShimmerAnimation() {
    _animationController.repeat(
      period: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case GlassVariant.primary:
        return AppTheme.primary;
      case GlassVariant.secondary:
        return AppTheme.secondary;
      case GlassVariant.tertiary:
        return AppTheme.tertiary;
      case GlassVariant.success:
        return AppTheme.success;
      case GlassVariant.warning:
        return AppTheme.warning;
      case GlassVariant.error:
        return AppTheme.error;
      case GlassVariant.standard:
      default:
        return AppTheme.primary;
    }
  }

  BoxDecoration _getGlassDecoration() {
    final variantColor = _getVariantColor();
    
    return BoxDecoration(
      gradient: widget.color != null
          ? null
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.glass,
                AppTheme.glassMedium,
                variantColor.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
      color: widget.color,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: widget.border ?? Border.all(
        color: widget.showGlow 
            ? variantColor.withValues(alpha: 0.4)
            : AppTheme.glassBorder,
        width: widget.showGlow ? 2.0 : 1.0,
      ),
      boxShadow: widget.boxShadow ?? [
        BoxShadow(
          color: AppTheme.glassShadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        if (widget.showGlow) ...[
          BoxShadow(
            color: variantColor.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 0),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: variantColor.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 0),
            spreadRadius: 5,
          ),
        ],
      ],
    );
  }

  Widget _buildShimmerOverlay() {
    if (!widget.showShimmer) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: [
                    (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                    _shimmerAnimation.value.clamp(0.0, 1.0),
                    (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    (_shimmerAnimation.value + 0.6).clamp(0.0, 1.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect() {
    if (!widget.showGlow) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final variantColor = _getVariantColor();
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: variantColor.withValues(alpha: 0.2 * _glowAnimation.value),
                  blurRadius: 35,
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: variantColor.withValues(alpha: 0.15 * _glowAnimation.value),
                  blurRadius: 50,
                  spreadRadius: -8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPressedOverlay() {
    if (!_isPressed) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: Stack(
            children: [
              // Main glass container
              _buildGlowEffect(),
              Container(
                padding: widget.padding,
                decoration: _getGlassDecoration(),
                alignment: widget.alignment,
                child: widget.child,
              ),
              _buildShimmerOverlay(),
              _buildPressedOverlay(),
            ],
          ),
        ),
      ),
    );

    // Add gesture detection and animation
    if (widget.onTap != null) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: container,
            ),
          );
        },
      );
    }

    return container;
  }
}

// Convenience constructors for different variants
extension GlassyContainerVariants on GlassyContainer {
  static GlassyContainer primary({
    Key? key,
    required Widget child,
    double borderRadius = AppTheme.radius2xl,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppTheme.spacing20),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double? height,
    double? width,
    VoidCallback? onTap,
    bool showGlow = false,
    bool showShimmer = false,
  }) {
    return GlassyContainer(
      key: key,
      variant: GlassVariant.primary,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      onTap: onTap,
      showGlow: showGlow,
      showShimmer: showShimmer,
      child: child,
    );
  }

  static GlassyContainer secondary({
    Key? key,
    required Widget child,
    double borderRadius = AppTheme.radius2xl,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppTheme.spacing20),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double? height,
    double? width,
    VoidCallback? onTap,
    bool showGlow = false,
    bool showShimmer = false,
  }) {
    return GlassyContainer(
      key: key,
      variant: GlassVariant.secondary,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      onTap: onTap,
      showGlow: showGlow,
      showShimmer: showShimmer,
      child: child,
    );
  }

  static GlassyContainer success({
    Key? key,
    required Widget child,
    double borderRadius = AppTheme.radius2xl,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppTheme.spacing20),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double? height,
    double? width,
    VoidCallback? onTap,
    bool showGlow = false,
    bool showShimmer = false,
  }) {
    return GlassyContainer(
      key: key,
      variant: GlassVariant.success,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      onTap: onTap,
      showGlow: showGlow,
      showShimmer: showShimmer,
      child: child,
    );
  }
}