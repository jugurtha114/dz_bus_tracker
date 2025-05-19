// lib/widgets/passenger/line_list_item.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../widgets/common/glassy_container.dart';

class LineListItem extends StatelessWidget {
  final Map<String, dynamic> line;
  final VoidCallback? onTap;
  final bool showStops;
  final bool showSchedule;

  const LineListItem({
    Key? key,
    required this.line,
    this.onTap,
    this.showStops = false,
    this.showSchedule = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from line object
    final name = line['name'] ?? 'Unknown Line';
    final code = line['code'] ?? '';
    final description = line['description'] ?? '';
    final color = line['color'] != null ?
    Color(int.parse('0xFF${line['color'].toString().replaceAll('#', '')}')) :
    AppColors.primary;

    // Get stops if available
    final stops = line['stops'] as List<dynamic>? ?? [];

    return GlassyContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      color: AppColors.glassWhite,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line code and name
          Row(
            children: [
              // Line code indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  code,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Line name
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.mediumGrey,
              ),
            ],
          ),

          // Description
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mediumGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Stops summary
          if (showStops && stops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${stops.length} stops',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Schedule summary
          if (showSchedule && line.containsKey('frequency') && line['frequency'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Every ${line['frequency']} minutes',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}