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
    this.size = 40,
    this.color,
    this.type = LoadingIndicatorType.pulse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

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
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(type: type),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized loading indicator for tracking operations
class TrackingLoadingIndicator extends StatelessWidget {
  final String operation;
  final bool showProgress;
  final double? progress;

  const TrackingLoadingIndicator({
    super.key,
    required this.operation,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle for progress
              if (showProgress && progress != null)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    strokeWidth: 3,
                  ),
                ),
              
              // Icon based on operation type
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getOperationIcon(operation),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Loading message
          Text(
            _getLoadingMessage(operation),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Progress percentage
          if (showProgress && progress != null)
            Text(
              '${(progress! * 100).toInt()}%',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            // Animated loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: LoadingIndicator(
                    size: 8,
                    type: LoadingIndicatorType.pulse,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getOperationIcon(String operation) {
    switch (operation.toLowerCase()) {
      case 'tracking':
      case 'location':
        return Icons.location_searching;
      case 'trips':
        return Icons.directions_bus;
      case 'anomalies':
        return Icons.warning_amber;
      case 'sync':
      case 'syncing':
        return Icons.sync;
      case 'loading':
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getLoadingMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'tracking':
        return 'Updating Location...';
      case 'location':
        return 'Getting Location...';
      case 'trips':
        return 'Loading Trips...';
      case 'anomalies':
        return 'Checking for Anomalies...';
      case 'sync':
      case 'syncing':
        return 'Synchronizing Data...';
      case 'loading':
      default:
        return 'Loading...';
    }
  }
}

/// Overlay loading indicator for tracking operations
class TrackingLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String operation;
  final bool showProgress;
  final double? progress;

  const TrackingLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.operation = 'loading',
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: TrackingLoadingIndicator(
              operation: operation,
              showProgress: showProgress,
              progress: progress,
            ),
          ),
      ],
    );
  }
}