// lib/widgets/gamification/leaderboard_entry_card.dart

import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../common/glassy_container.dart';

enum LeaderboardEntryDisplayMode {
  compact,
  detailed,
  list,
  podium,
}

class LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final LeaderboardEntryDisplayMode displayMode;
  final VoidCallback? onTap;
  final bool showRank;
  final bool showPoints;
  final bool highlightCurrentUser;
  final EdgeInsetsGeometry? margin;

  const LeaderboardEntryCard({
    super.key,
    required this.entry,
    this.displayMode = LeaderboardEntryDisplayMode.detailed,
    this.onTap,
    this.showRank = true,
    this.showPoints = true,
    this.highlightCurrentUser = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (displayMode) {
      case LeaderboardEntryDisplayMode.compact:
        return _buildCompactCard(theme);
      case LeaderboardEntryDisplayMode.detailed:
        return _buildDetailedCard(theme);
      case LeaderboardEntryDisplayMode.list:
        return _buildListCard(theme);
      case LeaderboardEntryDisplayMode.podium:
        return _buildPodiumCard(theme);
    }
  }

  Widget _buildCompactCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: _getContainerDecoration(theme),
      child: GlassyContainer(
        child: ListTile(
          dense: true,
          leading: showRank ? _buildRankBadge(theme, size: 32) : null,
          title: Text(
            entry.userName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
              color: entry.isCurrentUser ? theme.colorScheme.primary : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: showPoints ? _buildPointsChip(theme, compact: true) : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDetailedCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: _getContainerDecoration(theme),
      child: GlassyContainer(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (showRank) ...[
                  _buildRankBadge(theme, size: 48),
                  const SizedBox(width: 16),
                ],
                _buildAvatar(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.w600,
                          color: entry.isCurrentUser ? theme.colorScheme.primary : null,
                        ),
                      ),
                      if (entry.isCurrentUser) ...[
                        const SizedBox(height: 4),
                        Text(
                          'You',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showPoints) _buildPointsChip(theme),
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
      decoration: _getContainerDecoration(theme),
      child: GlassyContainer(
        child: ListTile(
          leading: showRank ? _buildRankBadge(theme, size: 40) : _buildAvatar(theme),
          title: Text(
            entry.userName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.w600,
              color: entry.isCurrentUser ? theme.colorScheme.primary : null,
            ),
          ),
          subtitle: entry.isCurrentUser 
              ? Text(
                  'You',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          trailing: showPoints ? _buildPointsChip(theme) : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildPodiumCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: GlassyContainer(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPodiumRankBadge(theme),
                const SizedBox(height: 16),
                _buildAvatar(theme, size: 60),
                const SizedBox(height: 12),
                Text(
                  entry.userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: entry.isCurrentUser ? theme.colorScheme.primary : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.isCurrentUser) ...[
                  const SizedBox(height: 4),
                  Text(
                    'You',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (showPoints) ...[
                  const SizedBox(height: 16),
                  _buildPointsChip(theme, large: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(ThemeData theme, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: entry.rankColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: entry.rankColor,
          width: 2,
        ),
      ),
      child: Center(
        child: entry.rankIcon != null
            ? Icon(
                entry.rankIcon,
                size: size * 0.6,
                color: entry.rankColor,
              )
            : Text(
                '${entry.rank}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: entry.rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.35,
                ),
              ),
      ),
    );
  }

  Widget _buildPodiumRankBadge(ThemeData theme) {
    if (!entry.isTopThree) {
      return _buildRankBadge(theme, size: 60);
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            entry.rankColor.withOpacity(0.3),
            entry.rankColor.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: entry.rankColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: entry.rankColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: entry.rankIcon != null
            ? Icon(
                entry.rankIcon,
                size: 48,
                color: entry.rankColor,
              )
            : Text(
                '${entry.rank}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: entry.rankColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, {double size = 40}) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: entry.isCurrentUser 
          ? theme.colorScheme.primary.withOpacity(0.2) 
          : theme.colorScheme.surfaceVariant,
      child: Text(
        entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : '?',
        style: theme.textTheme.titleMedium?.copyWith(
          color: entry.isCurrentUser 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildPointsChip(ThemeData theme, {bool compact = false, bool large = false}) {
    final padding = large 
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : compact 
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    
    final textStyle = large
        ? theme.textTheme.titleMedium
        : compact
            ? theme.textTheme.bodySmall
            : theme.textTheme.titleSmall;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(large ? 16 : 12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            size: large ? 20 : compact ? 14 : 16,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${entry.points}',
            style: textStyle?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration? _getContainerDecoration(ThemeData theme) {
    if (!highlightCurrentUser || !entry.isCurrentUser) return null;
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: theme.colorScheme.primary.withOpacity(0.5),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}