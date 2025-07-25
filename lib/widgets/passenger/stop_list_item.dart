// lib/widgets/passenger/stop_list_item.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/custom_card.dart';

class StopListItem extends StatelessWidget {
  final Map<String, dynamic> stop;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showLines;

  const StopListItem({
    Key? key,
    required this.stop,
    this.onTap,
    this.showDistance = false,
    this.showLines = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from stop object
    final name = stop['name'] ?? 'Unknown Stop';
    final address = stop['address'] ?? '';
    final description = stop['description'] ?? '';

    // Distance if available
    double? distance;
    if (showDistance && stop.containsKey('distance')) {
      distance = double.tryParse(stop['distance'].toString());
    }

    // Lines that pass through this stop if available
    final lines = stop['lines'] as List<dynamic>? ?? [];

    return CustomCard(
      type: CardType.elevated,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stop name and distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stop name with icon
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Distance if available
              if (showDistance && distance != null)
                Text(
                  distance < 1000
                      ? '${distance.toStringAsFixed(0)} m'
                      : '${(distance / 1000).toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          // Address
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Text(
                address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Lines that pass through this stop
          if (showLines && lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lines:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: lines.map<Widget>((line) {
                        final code = line['code'] ?? '';
                        final color = line['color'] != null
                            ? Color(int.parse('0xFF${line['color'].toString().replaceAll('#', '')}'))
                            : Theme.of(context).colorScheme.primary;

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            code,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
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