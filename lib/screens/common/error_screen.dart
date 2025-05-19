// lib/screens/common/error_screen.dart

import 'package:flutter/material.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../widgets/common/custom_button.dart';

enum ErrorType {
  network,
  server,
  notFound,
  permission,
  authentication,
  unknown,
}

class ErrorScreen extends StatelessWidget {
  final String message;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final bool showHomeButton;

  const ErrorScreen({
    Key? key,
    required this.message,
    this.errorType = ErrorType.unknown,
    this.onRetry,
    this.onGoBack,
    this.showHomeButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                _buildErrorIcon(),

                const SizedBox(height: 24),

                // Error title
                Text(
                  _getErrorTitle(),
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Error message
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mediumGrey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Retry button
                if (onRetry != null)
                  CustomButton(
                    text: 'Try Again',
                    onPressed: onRetry!,
                    icon: Icons.refresh,
                  ),

                const SizedBox(height: 16),

                // Go back button
                if (onGoBack != null)
                  CustomButton(
                    text: 'Go Back',
                    onPressed: onGoBack!,
                    type: ButtonType.outlined,
                    icon: Icons.arrow_back,
                  ),

                // Home button
                if (showHomeButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CustomButton(
                      text: 'Return to Home',
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);

                        // Navigate to appropriate home based on user type
                        if (authProvider.isDriver) {
                          AppRouter.navigateToAndClearStack(context, AppRoutes.driverHome);
                        } else {
                          AppRouter.navigateToAndClearStack(context, AppRoutes.passengerHome);
                        }
                      },
                      type: ButtonType.text,
                      icon: Icons.home,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    IconData iconData;
    Color iconColor;

    switch (errorType) {
      case ErrorType.network:
        iconData = Icons.signal_wifi_off;
        iconColor = AppColors.warning;
        break;
      case ErrorType.server:
        iconData = Icons.cloud_off;
        iconColor = AppColors.error;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off;
        iconColor = AppColors.warning;
        break;
      case ErrorType.permission:
        iconData = Icons.no_accounts;
        iconColor = AppColors.warning;
        break;
      case ErrorType.authentication:
        iconData = Icons.lock;
        iconColor = AppColors.error;
        break;
      case ErrorType.unknown:
      default:
        iconData = Icons.error_outline;
        iconColor = AppColors.error;
    }

    return Icon(
      iconData,
      size: 120,
      color: iconColor,
    );
  }

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.unknown:
      default:
        return 'Oops! Something Went Wrong';
    }
  }
}