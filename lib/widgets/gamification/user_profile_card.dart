// lib/widgets/gamification/user_profile_card.dart

import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../common/glassy_container.dart';

enum UserProfileCardDisplayMode {
  compact,
  detailed,
  dashboard,
  header,
}

class UserProfileCard extends StatelessWidget {
  final UserProfile userProfile;
  final UserProfileCardDisplayMode displayMode;
  final VoidCallback? onTap;
  final bool showLevel;
  final bool showPoints;
  final bool showStats;
  final bool showProgress;
  final EdgeInsetsGeometry? margin;

  const UserProfileCard({
    super.key,
    required this.userProfile,
    this.displayMode = UserProfileCardDisplayMode.detailed,
    this.onTap,
    this.showLevel = true,
    this.showPoints = true,
    this.showStats = true,
    this.showProgress = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (displayMode) {
      case UserProfileCardDisplayMode.compact:
        return _buildCompactCard(theme);
      case UserProfileCardDisplayMode.detailed:
        return _buildDetailedCard(theme);
      case UserProfileCardDisplayMode.dashboard:
        return _buildDashboardCard(theme);
      case UserProfileCardDisplayMode.header:
        return _buildHeaderCard(theme);
    }
  }

  Widget _buildCompactCard(ThemeData theme) {
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
                _buildAvatar(theme, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.user.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (showLevel) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Level ${userProfile.currentLevel}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showPoints)
                  _buildPointsChip(theme),
              ],
            ),
          ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(theme, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.user.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (showLevel)
                            _buildLevelSection(theme),
                          if (showPoints) ...[
                            const SizedBox(height: 8),
                            _buildPointsSection(theme),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (showProgress) ...[
                  const SizedBox(height: 20),
                  _buildProgressSection(theme),
                ],
                if (showStats) ...[
                  const SizedBox(height: 20),
                  _buildStatsSection(theme),
                ],
              ],
            ),
          ),
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
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(theme, size: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.user.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (showLevel) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Level ${userProfile.currentLevel}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showPoints)
                      _buildPointsChip(theme, large: true),
                  ],
                ),
                if (showProgress) ...[
                  const SizedBox(height: 16),
                  _buildProgressSection(theme),
                ],
                const SizedBox(height: 16),
                _buildQuickStatsRow(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      margin: margin,
      child: GlassyContainer(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildAvatar(theme, size: 80),
                const SizedBox(height: 16),
                Text(
                  userProfile.user.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showLevel) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${userProfile.currentLevel}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (showProgress) ...[
                  const SizedBox(height: 20),
                  _buildProgressSection(theme),
                ],
                if (showStats) ...[
                  const SizedBox(height: 20),
                  _buildStatsGrid(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.3),
            theme.colorScheme.secondary.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          userProfile.user.fullName.isNotEmpty 
              ? userProfile.user.fullName[0].toUpperCase() 
              : '?',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSection(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.trending_up,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          'Level ${userProfile.currentLevel}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.stars,
          size: 20,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${userProfile.totalPoints} points',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsChip(ThemeData theme, {bool large = false}) {
    final padding = large 
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    
    final textStyle = large
        ? theme.textTheme.titleMedium
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
            size: large ? 20 : 16,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            '${userProfile.totalPoints}',
            style: textStyle?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
              'Level Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userProfile.pointsToNextLevelText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: userProfile.levelProgressValue,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          userProfile.levelProgressText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(theme, Icons.route, '${userProfile.totalTrips}', 'Trips'),
        _buildStatDivider(theme),
        _buildStatItem(theme, Icons.straighten, userProfile.formattedTotalDistance, 'Distance'),
        _buildStatDivider(theme),
        _buildStatItem(theme, Icons.local_fire_department, userProfile.streakText, 'Streak'),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatsGrid(theme),
      ],
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard(theme, Icons.route, '${userProfile.totalTrips}', 'Total Trips'),
        _buildStatCard(theme, Icons.straighten, userProfile.formattedTotalDistance, 'Distance'),
        _buildStatCard(theme, Icons.local_fire_department, userProfile.streakText, 'Current Streak'),
        _buildStatCard(theme, Icons.eco, userProfile.formattedCarbonSaved, 'CO₂ Saved'),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 40,
      color: theme.colorScheme.onSurface.withOpacity(0.2),
    );
  }
}