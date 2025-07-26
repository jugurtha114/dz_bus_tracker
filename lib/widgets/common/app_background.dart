// lib/widgets/common/app_background.dart

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  final bool showAnimatedShapes;
  final bool showParticles;
  final bool isDarkMode;
  final BackgroundVariant variant;

  const AppBackground({
    Key? key,
    required this.child,
    this.showAnimatedShapes = true,
    this.showParticles = false,
    this.isDarkMode = false,
    this.variant = BackgroundVariant.primary,
  }) : super(key: key);

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

enum BackgroundVariant {
  primary,
  secondary,
  tertiary,
  neutral,
  vibrant,
}

class _AppBackgroundState extends State<AppBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _animation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<Color> _getVariantColors() {
    switch (widget.variant) {
      case BackgroundVariant.primary:
        return widget.isDarkMode
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
      case BackgroundVariant.secondary:
        return widget.isDarkMode
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
      case BackgroundVariant.tertiary:
        return widget.isDarkMode
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
      case BackgroundVariant.neutral:
        return widget.isDarkMode
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.neutral700,
              ]
            : [
                AppTheme.neutral50,
                AppTheme.neutral100,
                AppTheme.neutral200.withValues(alpha: 0.5),
              ];
      case BackgroundVariant.vibrant:
        return widget.isDarkMode
            ? [
                AppTheme.neutral900,
                AppTheme.primary.withValues(alpha: 0.1),
                AppTheme.secondary.withValues(alpha: 0.1),
              ]
            : [
                AppTheme.neutral50,
                AppTheme.primary.withValues(alpha: 0.05),
                AppTheme.secondary.withValues(alpha: 0.05),
              ];
    }
  }

  RadialGradient _getGlowGradient() {
    final baseColor = widget.variant == BackgroundVariant.primary
        ? AppTheme.primary
        : widget.variant == BackgroundVariant.secondary
            ? AppTheme.secondary
            : AppTheme.tertiary;

    return RadialGradient(
      colors: [
        baseColor.withValues(alpha: widget.isDarkMode ? 0.3 : 0.2),
        baseColor.withValues(alpha: widget.isDarkMode ? 0.1 : 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Base gradient background
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getVariantColors(),
              ),
            ),
          ),
          
          // Animated shapes overlay
          if (widget.showAnimatedShapes)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: AnimatedShapesPainter(
                    _animation.value,
                    widget.isDarkMode,
                  ),
                );
              },
            ),
          
          // Floating particles
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: ParticlesPainter(_particleAnimation.value),
                );
              },
            ),
          
          // Subtle geometric patterns
          CustomPaint(
            size: size,
            painter: GeometricPatternPainter(),
          ),
          
          // Glow effects
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: _getGlowGradient(),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: _getGlowGradient(),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Main content with blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Container(
              width: size.width,
              height: size.height,
              color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.1 : 0.01),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedShapesPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  AnimatedShapesPainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? Colors.white : AppTheme.primary)
          .withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Floating circles
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        (size.width * 0.2 * i) + 
        (math.sin(animationValue + i) * 50),
        (size.height * 0.3) + 
        (math.cos(animationValue * 0.5 + i) * 100),
      );
      
      canvas.drawCircle(
        offset,
        20 + (math.sin(animationValue + i) * 10),
        paint,
      );
    }

    // Floating rectangles
    paint.color = (isDarkMode ? Colors.white : AppTheme.secondary)
        .withValues(alpha: 0.05);
    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: Offset(
          size.width * 0.8 - (math.cos(animationValue * 0.7 + i) * 100),
          size.height * 0.6 + (math.sin(animationValue * 0.3 + i) * 80),
        ),
        width: 40,
        height: 60,
      );
      
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(animationValue + i);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final progress = (animationValue + (i / 20)) % 1.0;
      final x = (i / 20) * size.width;
      final y = size.height - (progress * size.height * 1.2);
      
      if (y < size.height && y > -20) {
        canvas.drawCircle(
          Offset(x + (math.sin(progress * 4) * 30), y),
          1 + (math.sin(progress * 6) * 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Grid pattern
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Diagonal lines
    paint.color = Colors.white.withValues(alpha: 0.02);
    for (double i = -size.height; i < size.width; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Convenience constructors
extension AppBackgroundVariants on AppBackground {
  static AppBackground primary({
    Key? key,
    required Widget child,
    bool showAnimatedShapes = true,
    bool showParticles = false,
    bool isDarkMode = false,
  }) {
    return AppBackground(
      key: key,
      child: child,
      showAnimatedShapes: showAnimatedShapes,
      showParticles: showParticles,
      isDarkMode: isDarkMode,
      variant: BackgroundVariant.primary,
    );
  }

  static AppBackground secondary({
    Key? key,
    required Widget child,
    bool showAnimatedShapes = true,
    bool showParticles = false,
    bool isDarkMode = false,
  }) {
    return AppBackground(
      key: key,
      child: child,
      showAnimatedShapes: showAnimatedShapes,
      showParticles: showParticles,
      isDarkMode: isDarkMode,
      variant: BackgroundVariant.secondary,
    );
  }

  static AppBackground vibrant({
    Key? key,
    required Widget child,
    bool showAnimatedShapes = true,
    bool showParticles = false,
    bool isDarkMode = false,
  }) {
    return AppBackground(
      key: key,
      child: child,
      showAnimatedShapes: showAnimatedShapes,
      showParticles: showParticles,
      isDarkMode: isDarkMode,
      variant: BackgroundVariant.vibrant,
    );
  }
}