// lib/widgets/passenger/line_list_item.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class LineListItem extends StatelessWidget {
  final Map<String, dynamic> line;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showDistance;
  final bool showStatus;
  final bool showBadge;
  final String? badgeText;
  final Color? badgeColor;
  final EdgeInsetsGeometry? padding;
  final bool showStops;

  const LineListItem({
    Key? key,
    required this.line,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showDistance = false,
    this.showStatus = false,
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
    this.padding,
    this.showStops = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = line['name'] ?? 'Unknown Line';
    final code = line['code'] ?? '';
    final description = line['description'] ?? '';
    final color = line['color'] != null
        ? Color(int.parse(line['color'].toString().replaceFirst('#', '0xFF')))
        : AppColors.primary;
    final isActive = line['is_active'] == true;
    final frequency = line['frequency'];

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            children: [
              // Line color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 16),

              // Line info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line name and code
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (code.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              code,
                              style: AppTextStyles.caption.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Additional info
                    Row(
                      children: [
                        // Status indicator
                        if (showStatus) ...[
                          Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            color: isActive ? AppColors.success : AppColors.error,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.caption.copyWith(
                              color: isActive ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Frequency
                        if (frequency != null) ...[
                          const Icon(
                            Icons.schedule,
                            color: AppColors.mediumGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Every ${frequency}min',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],

                        const Spacer(),

                        // Badge
                        if (showBadge && badgeText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor ?? AppColors.warning,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite button
                  if (onFavoriteToggle != null)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : AppColors.mediumGrey,
                        size: 20,
                      ),
                      onPressed: onFavoriteToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),

                  // More options
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.mediumGrey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}