// lib/widgets/gamification/point_transaction_card.dart

import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../common/glassy_container.dart';

enum PointTransactionCardDisplayMode {
  compact,
  detailed,
  list,
  timeline,
}

class PointTransactionCard extends StatelessWidget {
  final PointTransaction transaction;
  final PointTransactionCardDisplayMode displayMode;
  final VoidCallback? onTap;
  final bool showDate;
  final bool showTime;
  final bool showDescription;
  final EdgeInsetsGeometry? margin;

  const PointTransactionCard({
    super.key,
    required this.transaction,
    this.displayMode = PointTransactionCardDisplayMode.detailed,
    this.onTap,
    this.showDate = true,
    this.showTime = true,  
    this.showDescription = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (displayMode) {
      case PointTransactionCardDisplayMode.compact:
        return _buildCompactCard(theme);
      case PointTransactionCardDisplayMode.detailed:
        return _buildDetailedCard(theme);
      case PointTransactionCardDisplayMode.list:
        return _buildListCard(theme);
      case PointTransactionCardDisplayMode.timeline:
        return _buildTimelineCard(theme);
    }
  }

  Widget _buildCompactCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GlassyContainer(
        child: ListTile(
          dense: true,
          leading: _buildIcon(theme, size: 32),
          title: Text(
            transaction.transactionType.displayName,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildPointsChip(theme, compact: true),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDetailedCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: GlassyContainer(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(theme, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.transactionType.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (showDate) ...[
                            const SizedBox(height: 4),
                            Text(
                              transaction.formattedDateTime,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildPointsChip(theme),
                  ],
                ),
                if (showDescription && transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    transaction.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassyContainer(
        child: ListTile(
          leading: _buildIcon(theme, size: 40),
          title: Text(
            transaction.transactionType.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDescription && transaction.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (showDate) ...[
                const SizedBox(height: 4),
                Text(
                  transaction.formattedDateTime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
          trailing: _buildPointsChip(theme),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildTimelineCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: transaction.typeColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: GlassyContainer(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            transaction.typeIcon,
                            size: 20,
                            color: transaction.typeColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              transaction.transactionType.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildPointsText(theme),
                        ],
                      ),
                      if (showDescription && transaction.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          transaction.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (showDate) ...[
                        const SizedBox(height: 8),
                        Text(
                          transaction.formattedDateTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: transaction.typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: transaction.typeColor,
          width: 2,
        ),
      ),
      child: Icon(
        transaction.typeIcon,
        size: size * 0.6,
        color: transaction.typeColor,
      ),
    );
  }

  Widget _buildPointsChip(ThemeData theme, {bool compact = false}) {
    final padding = compact 
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    
    final textStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.titleSmall;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: transaction.pointsColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: transaction.pointsColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            transaction.isPositive ? Icons.add : Icons.remove,
            size: compact ? 14 : 16,
            color: transaction.pointsColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${transaction.points.abs()}',
            style: textStyle?.copyWith(
              color: transaction.pointsColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsText(ThemeData theme) {
    return Text(
      transaction.pointsText,
      style: theme.textTheme.titleSmall?.copyWith(
        color: transaction.pointsColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}