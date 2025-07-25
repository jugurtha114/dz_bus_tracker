// lib/widgets/passenger/search_bar_widget.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../common/glassy_container.dart';
import '../common/custom_card.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onStopSearchTap;
  final String hint;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const SearchBarWidget({
    Key? key,
    required this.onSearchTap,
    required this.onStopSearchTap,
    this.hint = 'Search for lines or stops...',
    this.leadingIcon = Icons.search,
    this.trailingIcon = Icons.location_on,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      type: CardType.elevated,
      borderRadius: BorderRadius.circular(24),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onSearchTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Search icon
              Icon(
                leadingIcon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),

              const SizedBox(width: 12, height: 40),

              // Search hint
              Expanded(
                child: Text(
                  hint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ),

              // Stop search button
              if (trailingIcon != null)
                IconButton(
                  icon: Icon(
                    trailingIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: onStopSearchTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Search Stops',
                ),
            ],
          ),
        ),
      ),
    );
  }
}