// lib/widgets/common/empty_state_widget.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double? iconSize;
  final double spacing;
  final bool useAnimation;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 80.0,
    this.spacing = 16.0,
    this.useAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = useAnimation
        ? _buildAnimatedIcon()
        : Icon(
      icon,
      size: iconSize,
      color: AppColors.mediumGrey,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(height: spacing),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing / 2),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null)
              Padding(
                padding: EdgeInsets.only(top: spacing),
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(buttonText!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Icon(
        icon,
        size: iconSize,
        color: AppColors.mediumGrey,
      ),
    );
  }

  // Factory methods for common empty states
  static EmptyStateWidget noData({
    String title = 'No Data',
    String message = 'There is no data available',
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.hourglass_empty,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      useAnimation: true,
    );
  }

  static EmptyStateWidget noResults({
    String title = 'No Results',
    String message = 'Your search did not match any results',
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  static EmptyStateWidget noNotifications({
    String title = 'No Notifications',
    String message = 'You don\'t have any notifications yet',
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.notifications_off_outlined,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  static EmptyStateWidget noConnection({
    String title = 'No Connection',
    String message = 'Please check your internet connection and try again',
    String buttonText = 'Retry',
    required VoidCallback onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      useAnimation: true,
    );
  }

  static EmptyStateWidget noBuses({
    String title = 'No Buses',
    String message = 'There are no buses available nearby',
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.directions_bus_outlined,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  static EmptyStateWidget noStops({
    String title = 'No Stops',
    String message = 'There are no bus stops nearby',
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.location_off,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }
}