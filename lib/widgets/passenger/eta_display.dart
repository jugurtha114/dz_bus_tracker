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
      etaColor = Theme.of(context).colorScheme.primary;
      etaText = 'Passed';
    } else if (minutes <= 0) {
      etaColor = Theme.of(context).colorScheme.primary;
      etaText = 'Now';
    } else if (minutes <= 5) {
      etaColor = Theme.of(context).colorScheme.primary;
      etaText = '$minutes min';
    } else {
      etaColor = Theme.of(context).colorScheme.primary;
      etaText = '$minutes min';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentStop ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          border: isCurrentStop
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
        
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentStop ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color: isPassed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),

            const SizedBox(width: 16, height: 40),

            // Stop name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stopName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isCurrentStop ? FontWeight.bold : FontWeight.normal,
                      color: isPassed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                      decoration: isPassed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (isCurrentStop)
                    Text(
                      'Current stop',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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