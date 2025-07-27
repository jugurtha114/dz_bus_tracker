// lib/widgets/common/loading_state.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Optimized loading state components
/// Provides consistent loading indicators throughout the app
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.size = LoadingSize.medium,
  });

  /// Factory constructor for full screen loading
  const LoadingState.fullScreen({
    super.key,
    String? message,
  }) : message = message,
       size = LoadingSize.large;

  final String? message;
  final LoadingSize size;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = switch (size) {
      LoadingSize.small => 20.0,
      LoadingSize.medium => 32.0,
      LoadingSize.large => 48.0,
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: size == LoadingSize.small ? 2.0 : 3.0,
              color: context.colors.primary,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: size == LoadingSize.large 
                ? DesignSystem.space16 
                : DesignSystem.space12),
            Text(
              message!,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator for use within other widgets
class InlineLoading extends StatelessWidget {
  const InlineLoading({
    super.key,
    this.size = LoadingSize.small,
    this.color,
  });

  final LoadingSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = switch (size) {
      LoadingSize.small => 16.0,
      LoadingSize.medium => 20.0,
      LoadingSize.large => 24.0,
    };

    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        color: color ?? context.colors.primary,
      ),
    );
  }
}

/// Full screen loading overlay widget
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FullScreenLoading({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.space24),
          decoration: BoxDecoration(
            color: DesignSystem.surface,
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: DesignSystem.primary,
                strokeWidth: 3,
              ),
              if (message != null) ...[
                const SizedBox(height: DesignSystem.space16),
                Text(
                  message!,
                  style: DesignSystem.bodyMedium.copyWith(
                    color: DesignSystem.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading overlay that can be placed over other content
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.color,
    this.opacity = 0.8,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (color ?? context.colors.surface).withOpacity(opacity),
            child: LoadingState(message: message),
          ),
      ],
    );
  }
}

/// Shimmer loading effect for content placeholders
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? context.colors.surfaceVariant;
    final highlightColor = widget.highlightColor ?? 
        context.colors.surface.withOpacity(0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: ShimmerGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loading for list items
class SkeletonLoading extends StatelessWidget {
  const SkeletonLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: borderRadius ?? 
              BorderRadius.circular(DesignSystem.radiusSmall),
        ),
      ),
    );
  }
}

/// Pre-built skeleton layouts for common use cases
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
  });

  final bool showAvatar;
  final bool showSubtitle;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Row(
        children: [
          if (showAvatar) ...[
            const SkeletonLoading(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.all(
                Radius.circular(DesignSystem.radiusRound),
              ),
            ),
            const SizedBox(width: DesignSystem.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoading(width: 150),
                if (showSubtitle) ...[
                  const SizedBox(height: DesignSystem.space8),
                  const SkeletonLoading(width: 100, height: 12),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: DesignSystem.space12),
            const SkeletonLoading(width: 60, height: 32),
          ],
        ],
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({
    super.key,
    this.showImage = true,
    this.showContent = true,
    this.showActions = false,
  });

  final bool showImage;
  final bool showContent;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage)
            const SkeletonLoading(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DesignSystem.radiusMedium),
                topRight: Radius.circular(DesignSystem.radiusMedium),
              ),
            ),
          if (showContent)
            Padding(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoading(width: 200),
                  const SizedBox(height: DesignSystem.space8),
                  const SkeletonLoading(width: 150, height: 12),
                  const SizedBox(height: DesignSystem.space8),
                  const SkeletonLoading(width: 100, height: 12),
                ],
              ),
            ),
          if (showActions)
            Padding(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Row(
                children: [
                  const SkeletonLoading(width: 80, height: 32),
                  const SizedBox(width: DesignSystem.space8),
                  const SkeletonLoading(width: 80, height: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Progress indicators for specific actions
class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.backgroundColor,
    this.height = 8,
  });

  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? color;
  final Color? backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DesignSystem.space4),
        ],
        LinearProgressIndicator(
          value: progress,
          backgroundColor: backgroundColor ?? 
              context.colors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? context.colors.primary,
          ),
          minHeight: height,
        ),
      ],
    );
  }
}

/// Custom gradient transform for shimmer effect
class ShimmerGradientTransform extends GradientTransform {
  const ShimmerGradientTransform(this.offset);

  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0, 0);
  }
}

enum LoadingSize {
  small,
  medium,
  large,
}