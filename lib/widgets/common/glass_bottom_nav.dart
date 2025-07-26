// lib/widgets/common/glass_bottom_nav.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'glassy_container.dart';

class GlassBottomNav extends StatefulWidget {
  final int currentIndex;
  final List<GlassBottomNavItem> items;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final GlassBottomNavVariant variant;
  final bool showBorder;
  final bool floatingStyle;

  const GlassBottomNav({
    Key? key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.variant = GlassBottomNavVariant.primary,
    this.showBorder = true,
    this.floatingStyle = false,
  }) : super(key: key);

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

enum GlassBottomNavVariant {
  primary,
  secondary,
  tertiary,
  neutral,
}

class _GlassBottomNavState extends State<GlassBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: AppTheme.animationNormal,
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map(
      (controller) => Tween<double>(
        begin: 1.0,
        end: 1.15,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      )),
    ).toList();

    _slideAnimations = _animationControllers.map(
      (controller) => Tween<double>(
        begin: 0.0,
        end: -6.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      )),
    ).toList();

    _fadeAnimations = _animationControllers.map(
      (controller) => Tween<double>(
        begin: 0.6,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
    ).toList();

    // Animate the selected item initially
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(GlassBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset previous item
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      
      // Animate new item
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case GlassBottomNavVariant.primary:
        return AppTheme.primary;
      case GlassBottomNavVariant.secondary:
        return AppTheme.secondary;
      case GlassBottomNavVariant.tertiary:
        return AppTheme.tertiary;
      case GlassBottomNavVariant.neutral:
        return AppTheme.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();
    
    if (widget.floatingStyle) {
      return _buildFloatingStyle(variantColor);
    }
    
    return _buildFixedStyle(variantColor);
  }

  Widget _buildFixedStyle(Color variantColor) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              gradient: widget.backgroundColor == null
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.glass,
                        AppTheme.glassMedium,
                        variantColor.withValues(alpha: 0.03),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    )
                  : null,
              border: widget.showBorder
                  ? Border(
                      top: BorderSide(
                        color: AppTheme.glassBorder,
                        width: 1,
                      ),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.glassShadow,
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing20,
                  vertical: AppTheme.spacing12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.items.asMap().entries.map(
                    (entry) => _buildNavItem(
                      entry.key,
                      entry.value,
                      entry.key == widget.currentIndex,
                      variantColor,
                    ),
                  ).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingStyle(Color variantColor) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing20),
      child: GlassyContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing20,
          vertical: AppTheme.spacing16,
        ),
        showGlow: true,
        variant: GlassVariant.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.items.asMap().entries.map(
            (entry) => _buildFloatingNavItem(
              entry.key,
              entry.value,
              entry.key == widget.currentIndex,
              variantColor,
            ),
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, GlassBottomNavItem item, bool isSelected, Color variantColor) {
    return Expanded(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimations[index],
          _slideAnimations[index],
          _fadeAnimations[index],
        ]),
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              widget.onTap?.call(index);
              _triggerTapAnimation(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animated container
                  Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimations[index].value),
                      child: AnimatedContainer(
                        duration: AppTheme.animationNormal,
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? variantColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radius3xl),
                          border: isSelected
                              ? Border.all(
                                  color: variantColor.withValues(alpha: 0.3),
                                  width: 1,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: variantColor.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: variantColor.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: AnimatedOpacity(
                                duration: AppTheme.animationFast,
                                opacity: _fadeAnimations[index].value,
                                child: Icon(
                                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                                  size: 24,
                                  color: isSelected
                                      ? variantColor
                                      : AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (item.badge != null)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: item.badge!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacing6),
                  
                  // Label with animation
                  AnimatedDefaultTextStyle(
                    duration: AppTheme.animationNormal,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isSelected ? variantColor : AppTheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isSelected ? 12 : 11,
                      letterSpacing: 0.5,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimations[index],
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingNavItem(int index, GlassBottomNavItem item, bool isSelected, Color variantColor) {
    return GlassyContainer(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      borderRadius: AppTheme.radiusXl,
      color: isSelected
          ? variantColor.withValues(alpha: 0.15)
          : Colors.transparent,
      showGlow: isSelected,
      variant: GlassVariant.primary,
      onTap: () {
        widget.onTap?.call(index);
        _triggerTapAnimation(index);
      },
      child: Stack(
        children: [
          Icon(
            isSelected ? (item.activeIcon ?? item.icon) : item.icon,
            size: 24,
            color: isSelected ? variantColor : AppTheme.onSurfaceVariant,
          ),
          if (item.badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: item.badge!,
            ),
        ],
      ),
    );
  }

  void _triggerTapAnimation(int index) {
    _animationControllers[index].forward().then((_) {
      if (mounted) {
        _animationControllers[index].reverse();
      }
    });
  }
}

class GlassBottomNavItem {
  final IconData icon;
  final String label;
  final IconData? activeIcon;
  final Widget? badge;

  const GlassBottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
  });
}

// Badge widget for notifications
class GlassNavBadge extends StatelessWidget {
  final String? text;
  final Color? color;
  final bool showDot;

  const GlassNavBadge({
    Key? key,
    this.text,
    this.color,
    this.showDot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color ?? AppTheme.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (color ?? AppTheme.error).withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? AppTheme.error,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.error).withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Center(
        child: Text(
          text!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Convenience constructors
extension GlassBottomNavVariants on GlassBottomNav {
  static GlassBottomNav primary({
    Key? key,
    required int currentIndex,
    required List<GlassBottomNavItem> items,
    ValueChanged<int>? onTap,
    EdgeInsetsGeometry? padding,
    bool showBorder = true,
    bool floatingStyle = false,
  }) {
    return GlassBottomNav(
      key: key,
      currentIndex: currentIndex,
      items: items,
      onTap: onTap,
      padding: padding,
      variant: GlassBottomNavVariant.primary,
      showBorder: showBorder,
      floatingStyle: floatingStyle,
    );
  }

  static GlassBottomNav secondary({
    Key? key,
    required int currentIndex,
    required List<GlassBottomNavItem> items,
    ValueChanged<int>? onTap,
    EdgeInsetsGeometry? padding,
    bool showBorder = true,
    bool floatingStyle = false,
  }) {
    return GlassBottomNav(
      key: key,
      currentIndex: currentIndex,
      items: items,
      onTap: onTap,
      padding: padding,
      variant: GlassBottomNavVariant.secondary,
      showBorder: showBorder,
      floatingStyle: floatingStyle,
    );
  }
}