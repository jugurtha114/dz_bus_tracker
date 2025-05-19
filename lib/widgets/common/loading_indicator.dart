// lib/widgets/common/loading_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/theme_config.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final LoadingIndicatorType type;

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.type = LoadingIndicatorType.pulse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    switch (type) {
      case LoadingIndicatorType.pulse:
        return SpinKitPulse(
          color: effectiveColor,
          size: size,
        );
      case LoadingIndicatorType.wave:
        return SpinKitWave(
          color: effectiveColor,
          size: size,
        );
      case LoadingIndicatorType.doubleBounce:
        return SpinKitDoubleBounce(
          color: effectiveColor,
          size: size,
        );
      case LoadingIndicatorType.fadingCircle:
        return SpinKitFadingCircle(
          color: effectiveColor,
          size: size,
        );
      case LoadingIndicatorType.ripple:
        return SpinKitRipple(
          color: effectiveColor,
          size: size,
        );
      default:
        return SpinKitPulse(
          color: effectiveColor,
          size: size,
        );
    }
  }
}

enum LoadingIndicatorType {
  pulse,
  wave,
  doubleBounce,
  fadingCircle,
  ripple,
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final LoadingIndicatorType type;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.type = LoadingIndicatorType.pulse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkGrey.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(type: type),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTextStyles.body.copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}