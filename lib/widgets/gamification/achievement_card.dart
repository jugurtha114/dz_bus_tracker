// lib/widgets/gamification/achievement_card.dart

import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../common/glassy_container.dart';

enum AchievementCardDisplayMode {
  compact,
  detailed,
  grid,
  list,
  dashboard,
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementCardDisplayMode displayMode;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool showRarity;
  final EdgeInsetsGeometry? margin;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.displayMode = AchievementCardDisplayMode.detailed,
    this.onTap,
    this.showProgress = true,
    this.showRarity = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (displayMode) {
      case AchievementCardDisplayMode.compact:
        return _buildCompactCard(theme);
      case AchievementCardDisplayMode.detailed:
        return _buildDetailedCard(theme);
      case AchievementCardDisplayMode.grid:
        return _buildGridCard(theme);
      case AchievementCardDisplayMode.list:
        return _buildListCard(theme);
      case AchievementCardDisplayMode.dashboard:
        return _buildDashboardCard(theme);
    }
  }

  Widget _buildCompactCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GlassyContainer(
        child: ListTile(
          leading: _buildIcon(theme, size: 40),
          title: Text(
            achievement.name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: achievement.isUnlocked ? theme.colorScheme.onSurface : theme.disabledColor,
              fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: showProgress ? _buildProgressText(theme) : null,
          trailing: achievement.isUnlocked ? 
            Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20) : 
            null,
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
                            achievement.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: achievement.isUnlocked ? theme.colorScheme.onSurface : theme.disabledColor,
                              fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (showRarity && achievement.rarity != null)
                            _buildRarityChip(theme),
                        ],
                      ),
                    ),
                    if (achievement.isUnlocked)
                      Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(theme),
                  const SizedBox(height: 8),
                  _buildProgressInfo(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.all(4),
      child: GlassyContainer(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(theme, size: 40),
                const SizedBox(height: 8),
                Text(
                  achievement.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: achievement.isUnlocked ? theme.colorScheme.onSurface : theme.disabledColor,
                    fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  _buildMiniProgressBar(theme),
                  const SizedBox(height: 4),
                  Text(
                    achievement.progressPercentageText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
                if (achievement.isUnlocked) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 16),
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
          leading: _buildIcon(theme, size: 44),
          title: Text(
            achievement.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: achievement.isUnlocked ? theme.colorScheme.onSurface : theme.disabledColor,
              fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                achievement.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showProgress) ...[
                const SizedBox(height: 8),
                _buildProgressBar(theme),
                const SizedBox(height: 4),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (achievement.isUnlocked)
                Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24)
              else if (showRarity && achievement.rarity != null)
                _buildRarityChip(theme),
              if (showProgress) ...[
                const SizedBox(height: 4),
                Text(
                  achievement.progressPercentageText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDashboardCard(ThemeData theme) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: GlassyContainer(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildIcon(theme, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: achievement.isUnlocked ? theme.colorScheme.onSurface : theme.disabledColor,
                          fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        _buildProgressBar(theme),
                        const SizedBox(height: 4),
                        Text(
                          achievement.progressText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (achievement.isUnlocked)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? achievement.rarityColor.withOpacity(0.2) : theme.disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: achievement.isUnlocked ? achievement.rarityColor : theme.disabledColor,
          width: 2,
        ),
      ),
      child: Icon(
        achievement.typeIcon,
        size: size * 0.6,
        color: achievement.isUnlocked ? achievement.rarityColor : theme.disabledColor,
      ),
    );
  }

  Widget _buildRarityChip(ThemeData theme) {
    if (achievement.rarity == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: achievement.rarityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: achievement.rarityColor, width: 1),
      ),
      child: Text(
        achievement.rarity!.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: achievement.rarityColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return LinearProgressIndicator(
      value: achievement.progressPercentage / 100.0,
      backgroundColor: theme.colorScheme.surfaceVariant,
      valueColor: AlwaysStoppedAnimation<Color>(
        achievement.isCompleted ? Colors.green : theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildMiniProgressBar(ThemeData theme) {
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: achievement.progressPercentage / 100.0,
        backgroundColor: theme.colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(
          achievement.isCompleted ? Colors.green : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProgressText(ThemeData theme) {
    return Text(
      achievement.progressText,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildProgressInfo(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          achievement.progressText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          achievement.progressPercentageText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: achievement.isCompleted ? Colors.green : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}