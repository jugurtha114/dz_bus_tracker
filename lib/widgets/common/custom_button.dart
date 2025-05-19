// lib/widgets/common/custom_button.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

enum ButtonType { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final ButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final double height;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final bool iconOnRight;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.type = ButtonType.filled,
    this.isLoading = false,
    this.isDisabled = false,
    this.color,
    this.textColor,
    this.borderRadius = 8,
    this.height = 48,
    this.padding,
    this.icon,
    this.iconOnRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors based on type and state
    final Color effectiveColor = color ?? AppColors.primary;
    final bool isFilledButton = type == ButtonType.filled;
    final bool isOutlinedButton = type == ButtonType.outlined;

    // Content to display within the button
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !iconOnRight)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              icon,
              color: isFilledButton
                  ? AppColors.white
                  : effectiveColor,
              size: 20,
            ),
          ),
        Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: isFilledButton
                ? textColor ?? AppColors.white
                : textColor ?? effectiveColor,
          ),
        ),
        if (icon != null && iconOnRight)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              icon,
              color: isFilledButton
                  ? AppColors.white
                  : effectiveColor,
              size: 20,
            ),
          ),
      ],
    );

    // Show loading indicator if loading
    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isFilledButton ? AppColors.white : effectiveColor,
          ),
          strokeWidth: 2.0,
        ),
      );
    }

    // Button styling based on type
    if (isFilledButton) {
      return SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: isLoading || isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveColor,
            foregroundColor: textColor ?? AppColors.white,
            disabledBackgroundColor: effectiveColor.withOpacity(0.5),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0,
          ),
          child: content,
        ),
      );
    } else if (isOutlinedButton) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: isLoading || isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            side: BorderSide(color: isDisabled ? effectiveColor.withOpacity(0.5) : effectiveColor),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        ),
      );
    } else {
      return SizedBox(
        height: height,
        child: TextButton(
          onPressed: isLoading || isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: effectiveColor,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        ),
      );
    }
  }
}