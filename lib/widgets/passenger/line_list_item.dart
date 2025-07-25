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
        : Theme.of(context).colorScheme.primary;
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
        
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 16, height: 40),

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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (code.isNotEmpty) ...[
                          const SizedBox(width: 8, height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withValues(alpha: 0)),
                            ),
                            child: Text(
                              code,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 16),

                    // Additional info
                    Row(
                      children: [
                        // Status indicator
                        if (showStatus) ...[
                          Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4, height: 40),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12, height: 40),
                        ],

                        // Frequency
                        if (frequency != null) ...[
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4, height: 40),
                          Text(
                            'Every ${frequency}min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
                              color: badgeColor ?? Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
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
                        color: isFavorite ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
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
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
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