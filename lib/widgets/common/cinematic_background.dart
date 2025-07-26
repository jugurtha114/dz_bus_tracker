// lib/widgets/common/cinematic_background.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CinematicBackground extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final double intensity;
  final List<Color>? gradientColors;
  final CinematicVariant variant;

  const CinematicBackground({
    Key? key,
    required this.child,
    this.showOverlay = true,
    this.intensity = 1.0,
    this.gradientColors,
    this.variant = CinematicVariant.primary,
  }) : super(key: key);

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

enum CinematicVariant {
  primary,
  secondary,
  tertiary,
  vibrant,
  subtle,
}

class _CinematicBackgroundState extends State<CinematicBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _particleController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  List<Color> _getVariantColors(bool isDark) {
    if (widget.gradientColors != null) {
      return widget.gradientColors!;
    }

    switch (widget.variant) {
      case CinematicVariant.primary:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.primary.withValues(alpha: 0.2),
              ]
            : [
                AppTheme.primary.withValues(alpha: 0.3),
                AppTheme.primaryLight.withValues(alpha: 0.2),
                AppTheme.primary,
              ];
      case CinematicVariant.secondary:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.secondary.withValues(alpha: 0.2),
              ]
            : [
                AppTheme.secondary.withValues(alpha: 0.3),
                AppTheme.secondaryLight.withValues(alpha: 0.2),
                AppTheme.secondary,
              ];
      case CinematicVariant.tertiary:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.neutral800,
                AppTheme.tertiary.withValues(alpha: 0.2),
              ]
            : [
                AppTheme.tertiary.withValues(alpha: 0.3),
                AppTheme.tertiaryLight.withValues(alpha: 0.2),
                AppTheme.tertiary,
              ];
      case CinematicVariant.vibrant:
        return isDark
            ? [
                AppTheme.neutral900,
                AppTheme.primary.withValues(alpha: 0.2),
                AppTheme.secondary.withValues(alpha: 0.2),
              ]
            : [
                AppTheme.primary.withValues(alpha: 0.3),
                AppTheme.secondary.withValues(alpha: 0.3),
                AppTheme.tertiary.withValues(alpha: 0.3),
              ];
      case CinematicVariant.subtle:
        return isDark
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
    }
  }

  Color _getWaveColor(bool isDark) {
    switch (widget.variant) {
      case CinematicVariant.primary:
        return isDark ? AppTheme.primaryLight : AppTheme.primary;
      case CinematicVariant.secondary:
        return isDark ? AppTheme.secondaryLight : AppTheme.secondary;
      case CinematicVariant.tertiary:
        return isDark ? AppTheme.tertiaryLight : AppTheme.tertiary;
      case CinematicVariant.vibrant:
        return isDark ? AppTheme.info : AppTheme.primary;
      case CinematicVariant.subtle:
        return isDark ? AppTheme.neutral600 : AppTheme.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Base gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getVariantColors(isDark),
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Animated wave patterns
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: WavePatternPainter(
                  animation: _waveAnimation.value,
                  intensity: widget.intensity,
                  waveColor: _getWaveColor(isDark),
                ),
              );
            },
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: ParticlePainter(
                  animation: _particleAnimation.value,
                  intensity: widget.intensity,
                  particleColor: _getWaveColor(isDark),
                ),
              );
            },
          ),

          // Glow orbs
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: GlowOrbPainter(
                  animation: _glowAnimation.value,
                  intensity: widget.intensity,
                  variant: widget.variant,
                  isDark: isDark,
                ),
              );
            },
          ),

          // Blur overlay
          if (widget.showOverlay)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(
                color: (isDark ? Colors.black : Colors.white)
                    .withValues(alpha: 0.1),
              ),
            ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class WavePatternPainter extends CustomPainter {
  final double animation;
  final double intensity;
  final Color waveColor;

  WavePatternPainter({
    required this.animation,
    required this.intensity,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = waveColor.withValues(alpha: 0.2 * intensity);

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 50.0 + (animation * 30);
      final path = Path();
      
      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        final waveOffset = math.sin(animation + angle * 3) * 10;
        final x = center.dx + (radius + waveOffset) * math.cos(angle);
        final y = center.dy + (radius + waveOffset) * math.sin(angle);
        
        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double animation;
  final double intensity;
  final Color particleColor;

  ParticlePainter({
    required this.animation,
    required this.intensity,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (int i = 0; i < 50; i++) {
      final progress = (animation + (i * 0.02)) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = size.height * (1 - progress);
      
      final particleSize = random.nextDouble() * 3 + 1;
      final alpha = (1 - progress) * 0.7 * intensity;
      
      paint.color = particleColor.withValues(alpha: alpha);
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GlowOrbPainter extends CustomPainter {
  final double animation;
  final double intensity;
  final CinematicVariant variant;
  final bool isDark;

  GlowOrbPainter({
    required this.animation,
    required this.intensity,
    required this.variant,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final orbs = _getOrbConfigs(size);

    for (final orb in orbs) {
      paint.color = (orb['color'] as Color)
          .withValues(alpha: animation * 0.3 * intensity);
      
      canvas.drawCircle(
        Offset(orb['x'] as double, orb['y'] as double),
        (orb['size'] as double) * animation,
        paint,
      );
    }
  }

  List<Map<String, dynamic>> _getOrbConfigs(Size size) {
    switch (variant) {
      case CinematicVariant.primary:
        return [
          {
            'x': size.width * 0.2,
            'y': size.height * 0.3,
            'color': isDark ? AppTheme.primaryLight : AppTheme.primary,
            'size': 60.0,
          },
          {
            'x': size.width * 0.8,
            'y': size.height * 0.7,
            'color': isDark ? AppTheme.primary : AppTheme.primaryDark,
            'size': 80.0,
          },
        ];
      case CinematicVariant.secondary:
        return [
          {
            'x': size.width * 0.3,
            'y': size.height * 0.2,
            'color': isDark ? AppTheme.secondaryLight : AppTheme.secondary,
            'size': 70.0,
          },
          {
            'x': size.width * 0.7,
            'y': size.height * 0.8,
            'color': isDark ? AppTheme.secondary : AppTheme.secondaryDark,
            'size': 50.0,
          },
        ];
      case CinematicVariant.tertiary:
        return [
          {
            'x': size.width * 0.5,
            'y': size.height * 0.3,
            'color': isDark ? AppTheme.tertiaryLight : AppTheme.tertiary,
            'size': 90.0,
          },
          {
            'x': size.width * 0.2,
            'y': size.height * 0.7,
            'color': isDark ? AppTheme.tertiary : AppTheme.tertiaryDark,
            'size': 40.0,
          },
        ];
      case CinematicVariant.vibrant:
        return [
          {
            'x': size.width * 0.2,
            'y': size.height * 0.3,
            'color': isDark ? AppTheme.primaryLight : AppTheme.primary,
            'size': 60.0,
          },
          {
            'x': size.width * 0.8,
            'y': size.height * 0.7,
            'color': isDark ? AppTheme.secondaryLight : AppTheme.secondary,
            'size': 80.0,
          },
          {
            'x': size.width * 0.6,
            'y': size.height * 0.2,
            'color': isDark ? AppTheme.tertiaryLight : AppTheme.tertiary,
            'size': 40.0,
          },
        ];
      case CinematicVariant.subtle:
        return [
          {
            'x': size.width * 0.3,
            'y': size.height * 0.4,
            'color': isDark ? AppTheme.neutral600 : AppTheme.neutral300,
            'size': 50.0,
          },
          {
            'x': size.width * 0.7,
            'y': size.height * 0.6,
            'color': isDark ? AppTheme.neutral700 : AppTheme.neutral400,
            'size': 70.0,
          },
        ];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Convenience constructors
extension CinematicBackgroundVariants on CinematicBackground {
  static CinematicBackground primary({
    Key? key,
    required Widget child,
    bool showOverlay = true,
    double intensity = 1.0,
    List<Color>? gradientColors,
  }) {
    return CinematicBackground(
      key: key,
      child: child,
      showOverlay: showOverlay,
      intensity: intensity,
      gradientColors: gradientColors,
      variant: CinematicVariant.primary,
    );
  }

  static CinematicBackground secondary({
    Key? key,
    required Widget child,
    bool showOverlay = true,
    double intensity = 1.0,
    List<Color>? gradientColors,
  }) {
    return CinematicBackground(
      key: key,
      child: child,
      showOverlay: showOverlay,
      intensity: intensity,
      gradientColors: gradientColors,
      variant: CinematicVariant.secondary,
    );
  }

  static CinematicBackground vibrant({
    Key? key,
    required Widget child,
    bool showOverlay = true,
    double intensity = 1.0,
    List<Color>? gradientColors,
  }) {
    return CinematicBackground(
      key: key,
      child: child,
      showOverlay: showOverlay,
      intensity: intensity,
      gradientColors: gradientColors,
      variant: CinematicVariant.vibrant,
    );
  }
}