// lib/widgets/gamification/reward_card.dart

import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../common/glassy_container.dart';
import '../common/custom_button.dart';

enum RewardCardDisplayMode {
  compact,
  detailed,
  grid,
  list,
  dashboard,
}

class RewardCard extends StatelessWidget {
  final Reward reward;
  final RewardCardDisplayMode displayMode;
  final VoidCallback? onTap;
  final VoidCallback? onRedeem;
  final bool showCost;
  final bool showAvailability;
  final bool showValidPeriod;
  final bool showRedeemButton;
  final EdgeInsetsGeometry? margin;

  const RewardCard({
    super.key,
    required this.reward,
    this.displayMode = RewardCardDisplayMode.detailed,
    this.onTap,
    this.onRedeem,
    this.showCost = true,
    this.showAvailability = true,
    this.showValidPeriod = true,
    this.showRedeemButton = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (displayMode) {
      case RewardCardDisplayMode.compact:
        return _buildCompactCard(theme);
      case RewardCardDisplayMode.detailed:
        return _buildDetailedCard(theme);
      case RewardCardDisplayMode.grid:
        return _buildGridCard(theme);
      case RewardCardDisplayMode.list:
        return _buildListCard(theme);
      case RewardCardDisplayMode.dashboard:
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
            reward.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: showCost ? _buildCostText(theme) : null,
          trailing: showAvailability ? _buildAvailabilityChip(theme) : null,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reward.image != null) _buildImage(theme),
              Padding(
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
                                reward.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (reward.partnerName != null)
                                Text(
                                  'by ${reward.partnerName}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (showAvailability)
                          _buildAvailabilityChip(theme),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      reward.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showCost) ...[
                      const SizedBox(height: 12),
                      _buildCostSection(theme),
                    ],
                    if (showAvailability) ...[
                      const SizedBox(height: 8),
                      _buildQuantityInfo(theme),
                    ],
                    if (showValidPeriod) ...[
                      const SizedBox(height: 8),
                      _buildValidPeriodInfo(theme),
                    ],
                    if (showRedeemButton && reward.canRedeem) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Redeem Reward',
                        onPressed: onRedeem,
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                        fullWidth: true,
                      ),
                    ] else if (showRedeemButton && !reward.canAfford) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Insufficient Points',
                        onPressed: null,
                        type: ButtonType.secondary,
                        size: ButtonSize.small,
                        fullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
          child: Column(
            children: [
              if (reward.image != null) 
                Expanded(flex: 2, child: _buildGridImage(theme))
              else
                Expanded(flex: 1, child: _buildGridIconHeader(theme)),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            reward.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (showCost) ...[
                            const SizedBox(height: 8),
                            _buildCostChip(theme),
                          ],
                        ],
                      ),
                      if (showRedeemButton && reward.canRedeem) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Redeem',
                            onPressed: onRedeem,
                            type: ButtonType.primary,
                            size: ButtonSize.small,
                          ),
                        ),
                      ] else if (showAvailability) ...[
                        const SizedBox(height: 8),
                        _buildAvailabilityChip(theme),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
            reward.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                reward.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showCost) ...[
                const SizedBox(height: 8),
                _buildCostText(theme),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showAvailability)
                _buildAvailabilityChip(theme),
              if (showValidPeriod) ...[
                const SizedBox(height: 4),
                Text(
                  reward.validityPeriod,
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
                        reward.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (showCost)
                        _buildCostText(theme),
                      if (showAvailability) ...[
                        const SizedBox(height: 4),
                        Text(
                          reward.quantityText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildAvailabilityChip(theme),
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
        color: reward.typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: reward.typeColor,
          width: 2,
        ),
      ),
      child: Icon(
        reward.typeIcon,
        size: size * 0.6,
        color: reward.typeColor,
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        image: reward.image != null
            ? DecorationImage(
                image: NetworkImage(reward.image!),
                fit: BoxFit.cover,
              )
            : null,
        color: reward.image == null ? theme.colorScheme.surfaceVariant : null,
      ),
      child: reward.image == null
          ? Center(
              child: Icon(
                reward.typeIcon,
                size: 60,
                color: reward.typeColor,
              ),
            )
          : null,
    );
  }

  Widget _buildGridImage(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        image: reward.image != null
            ? DecorationImage(
                image: NetworkImage(reward.image!),
                fit: BoxFit.cover,
              )
            : null,
        color: reward.image == null ? theme.colorScheme.surfaceVariant : null,
      ),
      child: reward.image == null
          ? Center(
              child: Icon(
                reward.typeIcon,
                size: 40,
                color: reward.typeColor,
              ),
            )
          : null,
    );
  }

  Widget _buildGridIconHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: reward.typeColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Icon(
          reward.typeIcon,
          size: 40,
          color: reward.typeColor,
        ),
      ),
    );
  }

  Widget _buildAvailabilityChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: reward.availabilityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: reward.availabilityColor, width: 1),
      ),
      child: Text(
        reward.availabilityText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: reward.availabilityColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCostSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stars,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${reward.pointsCost} points',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostChip(ThemeData theme) {
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
            Icons.stars,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '${reward.pointsCost}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostText(ThemeData theme) {
    return Text(
      '${reward.pointsCost} points',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuantityInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.inventory,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          reward.quantityText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildValidPeriodInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Valid: ${reward.validityPeriod}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}