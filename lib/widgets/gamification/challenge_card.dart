// lib/widgets/gamification/challenge_card.dart

import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../common/glassy_container.dart';
import '../common/custom_button.dart';

enum ChallengeCardDisplayMode {
  compact,
  detailed,
  grid,
  list,
  dashboard,
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final ChallengeCardDisplayMode displayMode;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool showProgress;
  final bool showParticipants;
  final bool showTimeRemaining;
  final bool showJoinButton;
  final EdgeInsetsGeometry? margin;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.displayMode = ChallengeCardDisplayMode.detailed,
    this.onTap,
    this.onJoin,
    this.showProgress = true,
    this.showParticipants = true,
    this.showTimeRemaining = true,
    this.showJoinButton = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (displayMode) {
      case ChallengeCardDisplayMode.compact:
        return _buildCompactCard(theme);
      case ChallengeCardDisplayMode.detailed:
        return _buildDetailedCard(theme);
      case ChallengeCardDisplayMode.grid:
        return _buildGridCard(theme);
      case ChallengeCardDisplayMode.list:
        return _buildListCard(theme);
      case ChallengeCardDisplayMode.dashboard:
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
            challenge.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: showTimeRemaining ? _buildTimeRemainingText(theme) : null,
          trailing: _buildStatusChip(theme),
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
                            challenge.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(theme),
                        ],
                      ),
                    ),
                    if (showTimeRemaining)
                      _buildTimeRemainingChip(theme),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  challenge.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  _buildProgressSection(theme),
                ],
                if (showParticipants) ...[
                  const SizedBox(height: 8),
                  _buildParticipantsInfo(theme),
                ],
                const SizedBox(height: 12),
                _buildRewardInfo(theme),
                if (showJoinButton && challenge.canJoin) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Join Challenge',
                    onPressed: onJoin,
                    type: ButtonType.primary,
                    size: ButtonSize.small,
                    fullWidth: true,
                  ),
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
                  challenge.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildStatusChip(theme),
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  _buildMiniProgressBar(theme),
                  const SizedBox(height: 4),
                  Text(
                    challenge.progressPercentage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
                if (showJoinButton && challenge.canJoin) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Join',
                      onPressed: onJoin,
                      type: ButtonType.primary,
                      size: ButtonSize.small,
                    ),
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
          leading: _buildIcon(theme, size: 44),
          title: Text(
            challenge.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                challenge.description,
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusChip(theme),
              if (showTimeRemaining) ...[
                const SizedBox(height: 4),
                _buildTimeRemainingText(theme),
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
                        challenge.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        _buildProgressBar(theme),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${challenge.currentValue}/${challenge.targetValue}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              challenge.progressPercentage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusChip(theme),
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
        color: challenge.typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: challenge.typeColor,
          width: 2,
        ),
      ),
      child: Icon(
        challenge.typeIcon,
        size: size * 0.6,
        color: challenge.typeColor,
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: challenge.statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: challenge.statusColor, width: 1),
      ),
      child: Text(
        challenge.statusText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: challenge.statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeRemainingChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            challenge.timeRemaining,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemainingText(ThemeData theme) {
    return Text(
      challenge.timeRemaining,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${challenge.currentValue}/${challenge.targetValue}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(theme),
        const SizedBox(height: 4),
        Text(
          challenge.progressPercentage,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return LinearProgressIndicator(
      value: challenge.progressValue,
      backgroundColor: theme.colorScheme.surfaceVariant,
      valueColor: AlwaysStoppedAnimation<Color>(
        challenge.isCompleted ? Colors.green : theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildMiniProgressBar(ThemeData theme) {
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: challenge.progressValue,
        backgroundColor: theme.colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(
          challenge.isCompleted ? Colors.green : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildParticipantsInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          '${challenge.participantsCount} participants',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stars,
            size: 20,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            '${challenge.pointsReward} points reward',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}