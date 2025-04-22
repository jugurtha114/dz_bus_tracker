/// lib/presentation/widgets/eta/eta_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For time formatting

import '../../../config/themes/app_theme.dart';
import '../../../core/enums/eta_status.dart';
import '../../../core/utils/date_utils.dart'; // For timeAgoOrUntil maybe
import '../../../domain/entities/eta_entity.dart';

/// Widget to display a single Estimated Time of Arrival (ETA) item in a list.
class EtaListItem extends StatelessWidget {
  final EtaEntity eta;
  final VoidCallback? onTap; // Optional tap action

  const EtaListItem({
    super.key,
    required this.eta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final etaStatusColor = _getEtaStatusColor(eta.status, theme);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: etaStatusColor.withOpacity(0.15),
        child: Icon(Icons.directions_bus, color: etaStatusColor, size: 24),
      ),
      title: Text(
        'Line ${eta.lineName ?? eta.lineId}', // TODO: Localize 'Line'
        style: textTheme.titleMedium,
      ),
      subtitle: Text(
        'Bus ${eta.busMatricule ?? eta.busId}', // TODO: Localize 'Bus'
        style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
      ),
      trailing: _buildEtaTimeDisplay(context, eta, etaStatusColor),
    );
  }

  Widget _buildEtaTimeDisplay(BuildContext context, EtaEntity eta, Color statusColor) {
      final textTheme = Theme.of(context).textTheme;
      final minutes = eta.minutesRemaining;
      final timeStr = DateFormat.Hm().format(eta.estimatedArrivalTime.toLocal());
      final textStyle = textTheme.bodyLarge?.copyWith(color: statusColor, fontWeight: FontWeight.bold);

      String etaText;
      IconData etaIcon = Icons.access_time_filled; // Default icon

      if (eta.status == EtaStatus.arrived) { etaText = 'Arrived $timeStr'; etaIcon = Icons.check_circle;} // TODO: Localize
      else if (eta.status == EtaStatus.cancelled) { etaText = 'Cancelled'; etaIcon = Icons.cancel; } // TODO: Localize
      else if (minutes != null && minutes <= 1) { etaText = 'Due'; etaIcon = Icons.directions_walk; } // TODO: Localize
      else if (minutes != null) { etaText = '$minutes min'; } // TODO: Localize
      else { etaText = timeStr; } // Fallback to time

      return Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.end,
         children: [
           Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Icon(etaIcon, size: 18, color: statusColor),
                 const SizedBox(width: AppTheme.spacingXSmall),
                 Text(etaText, style: textStyle),
              ],
           ),
            // Optionally show absolute time if relative time is shown
           if (eta.status != EtaStatus.arrived && eta.status != EtaStatus.cancelled && minutes != null && minutes > 1)
             Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(timeStr, style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium)),
             ),
         ],
      );
   }

   Color _getEtaStatusColor(EtaStatus status, ThemeData theme) {
      switch (status) {
         case EtaStatus.approaching: return AppTheme.successColor;
         case EtaStatus.arrived: return AppTheme.successColor.withOpacity(0.8);
         case EtaStatus.delayed: return AppTheme.warningColor;
         case EtaStatus.cancelled: return AppTheme.errorColor;
         case EtaStatus.scheduled:
         case EtaStatus.unknown:
         default: return theme.colorScheme.primary;
      }
   }
}
