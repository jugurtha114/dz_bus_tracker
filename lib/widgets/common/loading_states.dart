// lib/widgets/common/loading_states.dart

import 'package:flutter/material.dart';

enum LoadingType { circular, linear, dots, pulse, shimmer }
enum LoadingSize { small, medium, large }

class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final Color? color;
  final String? message;
  final bool showMessage;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
    this.showMessage = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget loadingIndicator;

    switch (type) {
      case LoadingType.circular:
        loadingIndicator = _buildCircularLoading(colorScheme);
        break;
      case LoadingType.linear:
        loadingIndicator = _buildLinearLoading(colorScheme);
        break;
      case LoadingType.dots:
        loadingIndicator = _buildDotsLoading(colorScheme);
        break;
      case LoadingType.pulse:
        loadingIndicator = _buildPulseLoading(colorScheme);
        break;
      case LoadingType.shimmer:
        loadingIndicator = _buildShimmerLoading(colorScheme);
        break;
    }

    if (showMessage && message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingIndicator;
  }

  Widget _buildCircularLoading(ColorScheme colorScheme) {
    final indicatorSize = _getIndicatorSize();
    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        color: color ?? colorScheme.primary,
        strokeWidth: _getStrokeWidth(),
      ),
    );
  }

  Widget _buildLinearLoading(ColorScheme colorScheme) {
    return SizedBox(
      width: _getLinearWidth(),
      child: LinearProgressIndicator(
        color: color ?? colorScheme.primary,
        backgroundColor: (color ?? colorScheme.primary).withOpacity(0.1),
      ),
    );
  }

  Widget _buildDotsLoading(ColorScheme colorScheme) {
    return _DotsLoadingAnimation(
      color: color ?? colorScheme.primary,
      size: size,
    );
  }

  Widget _buildPulseLoading(ColorScheme colorScheme) {
    return _PulseLoadingAnimation(
      color: color ?? colorScheme.primary,
      size: _getIndicatorSize(),
    );
  }

  Widget _buildShimmerLoading(ColorScheme colorScheme) {
    return _ShimmerLoadingAnimation(
      color: color ?? colorScheme.primary,
      size: size,
    );
  }

  double _getIndicatorSize() {
    switch (size) {
      case LoadingSize.small:
        return 16;
      case LoadingSize.medium:
        return 24;
      case LoadingSize.large:
        return 32;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  double _getLinearWidth() {
    switch (size) {
      case LoadingSize.small:
        return 100;
      case LoadingSize.medium:
        return 150;
      case LoadingSize.large:
        return 200;
    }
  }
}

class _DotsLoadingAnimation extends StatefulWidget {
  final Color color;
  final LoadingSize size;

  const _DotsLoadingAnimation({
    required this.color,
    required this.size});

  @override
  State<_DotsLoadingAnimation> createState() => _DotsLoadingAnimationState();
}

class _DotsLoadingAnimationState extends State<_DotsLoadingAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = _getDotSize();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0 + (_animations[index].value * 0)),
              ),
            );
          },
        );
      }),
    );
  }

  double _getDotSize() {
    switch (widget.size) {
      case LoadingSize.small:
        return 6;
      case LoadingSize.medium:
        return 8;
      case LoadingSize.large:
        return 10;
    }
  }
}

class _PulseLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoadingAnimation({
    required this.color,
    required this.size});

  @override
  State<_PulseLoadingAnimation> createState() => _PulseLoadingAnimationState();
}

class _PulseLoadingAnimationState extends State<_PulseLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
          ),
        );
      },
    );
  }
}

class _ShimmerLoadingAnimation extends StatefulWidget {
  final Color color;
  final LoadingSize size;

  const _ShimmerLoadingAnimation({
    required this.color,
    required this.size});

  @override
  State<_ShimmerLoadingAnimation> createState() => _ShimmerLoadingAnimationState();
}

class _ShimmerLoadingAnimationState extends State<_ShimmerLoadingAnimation>
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
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = _getShimmerWidth();
    final height = _getShimmerHeight();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0,
                _animation.value,
                _animation.value + 0,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
              colors: [
                widget.color.withOpacity(0.1),
                widget.color.withOpacity(0.1),
                widget.color.withOpacity(0.1),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getShimmerWidth() {
    switch (widget.size) {
      case LoadingSize.small:
        return 80;
      case LoadingSize.medium:
        return 120;
      case LoadingSize.large:
        return 160;
    }
  }

  double _getShimmerHeight() {
    switch (widget.size) {
      case LoadingSize.small:
        return 12;
      case LoadingSize.medium:
        return 16;
      case LoadingSize.large:
        return 20;
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;
  final Color? loadingColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.type = LoadingType.circular,
    this.backgroundColor,
    this.loadingColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: LoadingWidget(
                type: type,
                size: LoadingSize.large,
                color: loadingColor,
                message: message,
                showMessage: message != null,
              ),
            ),
          ),
      ],
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;
  final int subtitleLines;

  const ShimmerListTile({
    super.key,
    this.showLeading = true,
    this.showTrailing = true,
    this.subtitleLines = 1});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showLeading) ...[
            _ShimmerLoadingAnimation(
              color: colorScheme.primary,
              size: LoadingSize.large,
            ),
            const SizedBox(width: 16, height: 40),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerLoadingAnimation(
                  color: colorScheme.primary,
                  size: LoadingSize.medium,
                ),
                const SizedBox(height: 16),
                ...List.generate(subtitleLines, (index) => Padding(
                  padding: EdgeInsets.only(bottom: index < subtitleLines - 1 ? 4 : 0),
                  child: _ShimmerLoadingAnimation(
                    color: colorScheme.primary,
                    size: LoadingSize.small,
                  ),
                )),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 16, height: 40),
            _ShimmerLoadingAnimation(
              color: colorScheme.primary,
              size: LoadingSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}