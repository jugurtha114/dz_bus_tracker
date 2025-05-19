// lib/widgets/passenger/eta_display.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class ETADisplay extends StatelessWidget {
  final int minutes;
  final String stopName;
  final bool isCurrentStop;
  final bool isPassed;
  final VoidCallback? onTap;

  const ETADisplay({
    Key? key,
    required this.minutes,
    required this.stopName,
    this.isCurrentStop = false,
    this.isPassed = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on ETA
    Color etaColor;
    String etaText;

    if (isPassed) {
      etaColor = AppColors.mediumGrey;
      etaText = 'Passed';
    } else if (minutes <= 0) {
      etaColor = AppColors.primary;
      etaText = 'Now';
    } else if (minutes <= 5) {
      etaColor = AppColors.warning;
      etaText = '$minutes min';
    } else {
      etaColor = AppColors.success;
      etaText = '$minutes min';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentStop ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: isCurrentStop
              ? Border.all(color: AppColors.primary)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Stop indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentStop ? AppColors.primary : AppColors.lightGrey,
                border: Border.all(
                  color: isPassed ? AppColors.lightGrey : AppColors.primary,
                  width: 2,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Stop name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stopName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isCurrentStop ? FontWeight.bold : FontWeight.normal,
                      color: isPassed ? AppColors.mediumGrey : AppColors.darkGrey,
                      decoration: isPassed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (isCurrentStop)
                    Text(
                      'Current stop',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // ETA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: etaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: etaColor),
              ),
              child: Text(
                etaText,
                style: AppTextStyles.caption.copyWith(
                  color: etaColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}