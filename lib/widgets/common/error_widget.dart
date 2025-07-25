// lib/widgets/common/error_widget.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/exceptions/app_exceptions.dart';
import 'custom_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool useGlassyContainer;

  const ErrorDisplayWidget({
    Key? key,
    this.title = 'Oops!',
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.error_outline,
    this.useGlassyContainer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error icon
        Icon(
          icon,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),

        const SizedBox(height: 16),

        // Error title
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Error message
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: useGlassyContainer
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                : Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 16),

          // Action button
          CustomButton(
            text: actionText!,
            onPressed: onAction!,
            type: useGlassyContainer ? ButtonType.primary : ButtonType.outline,
            icon: Icons.refresh,
          ),
        ],
      ],
    );

    if (useGlassyContainer) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}

class ErrorFullScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool useAppBar;
  final String appBarTitle;

  const ErrorFullScreen({
    Key? key,
    this.title = 'Oops!',
    required this.message,
    this.actionText = 'Try Again',
    this.onAction,
    this.icon = Icons.error_outline,
    this.useAppBar = false,
    this.appBarTitle = 'Error',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: useAppBar
          ? AppBar(
              title: Text(appBarTitle),
            )
          : null,
      body: Center(
        child: ErrorDisplayWidget(
          title: title,
          message: message,
          actionText: actionText,
          onAction: onAction,
          icon: icon,
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;
  final bool useGlassyContainer;

  const EmptyStateWidget({
    Key? key,
    this.title = 'Nothing Found',
    required this.message,
    this.actionText,
    this.onAction,
    this.icon = Icons.search_off,
    this.useGlassyContainer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
      icon: icon,
      useGlassyContainer: useGlassyContainer,
    );
  }
}

/// Specialized error widget for tracking-related errors
class TrackingErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final bool useGlassyContainer;

  const TrackingErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.useGlassyContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getTrackingErrorInfo(error);
    
    return ErrorDisplayWidget(
      title: errorInfo.title,
      message: errorInfo.message,
      actionText: errorInfo.actionText,
      onAction: onRetry,
      icon: errorInfo.icon,
      useGlassyContainer: useGlassyContainer,
    );
  }

  _TrackingErrorInfo _getTrackingErrorInfo(Object error) {
    if (error is LocationException) {
      return _TrackingErrorInfo(
        title: 'Location Error',
        message: 'Unable to access location services. Please enable location permissions.',
        actionText: 'Retry',
        icon: Icons.location_off,
      );
    }
    
    if (error is NetworkException) {
      return _TrackingErrorInfo(
        title: 'Connection Error',
        message: 'Unable to connect to tracking services. Check your internet connection.',
        actionText: 'Retry',
        icon: Icons.wifi_off,
      );
    }
    
    if (error is ApiException) {
      return _TrackingErrorInfo(
        title: 'Tracking Service Error',
        message: error.message,
        actionText: 'Retry',
        icon: Icons.cloud_off,
      );
    }
    
    // Default error
    return _TrackingErrorInfo(
      title: 'Tracking Error',
      message: error.toString(),
      actionText: 'Retry',
      icon: Icons.error_outline,
    );
  }
}

class _TrackingErrorInfo {
  final String title;
  final String message;
  final String actionText;
  final IconData icon;

  const _TrackingErrorInfo({
    required this.title,
    required this.message,
    required this.actionText,
    required this.icon,
  });
}

/// Specialized empty state widget for tracking data
class TrackingEmptyStateWidget extends StatelessWidget {
  final String dataType;
  final VoidCallback? onAction;
  final bool useGlassyContainer;

  const TrackingEmptyStateWidget({
    super.key,
    required this.dataType,
    this.onAction,
    this.useGlassyContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final emptyStateInfo = _getEmptyStateInfo(dataType);
    
    return EmptyStateWidget(
      title: emptyStateInfo.title,
      message: emptyStateInfo.message,
      actionText: emptyStateInfo.actionText,
      onAction: onAction,
      icon: emptyStateInfo.icon,
      useGlassyContainer: useGlassyContainer,
    );
  }

  _EmptyStateInfo _getEmptyStateInfo(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'trips':
        return _EmptyStateInfo(
          title: 'No Trips Found',
          message: 'No bus trips are currently available. Start tracking to see trips here.',
          actionText: 'Refresh',
          icon: Icons.directions_bus_outlined,
        );
      
      case 'anomalies':
        return _EmptyStateInfo(
          title: 'No Anomalies Detected',
          message: 'All systems are running normally. No tracking anomalies detected.',
          actionText: 'Refresh',
          icon: Icons.check_circle_outline,
        );
      
      case 'locations':
        return _EmptyStateInfo(
          title: 'No Location Data',
          message: 'No location updates are available. Ensure GPS tracking is enabled.',
          actionText: 'Enable Location',
          icon: Icons.location_disabled_outlined,
        );
      
      case 'buses':
        return _EmptyStateInfo(
          title: 'No Buses Available',
          message: 'No buses are currently assigned or active on this route.',
          actionText: 'Refresh',
          icon: Icons.directions_bus_outlined,
        );
      
      default:
        return _EmptyStateInfo(
          title: 'No Data Available',
          message: 'No tracking data is currently available.',
          actionText: 'Refresh',
          icon: Icons.inbox_outlined,
        );
    }
  }
}

class _EmptyStateInfo {
  final String title;
  final String message;
  final String actionText;
  final IconData icon;

  const _EmptyStateInfo({
    required this.title,
    required this.message,
    required this.actionText,
    required this.icon,
  });
}