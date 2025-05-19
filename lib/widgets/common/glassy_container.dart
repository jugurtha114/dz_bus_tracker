// lib/widgets/common/glassy_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class GlassyContainer extends StatelessWidget {
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

  const GlassyContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.color,
    this.blur = 10,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.height,
    this.width,
    this.alignment = Alignment.center,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.glassWhite,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: boxShadow,
            ),
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }
}