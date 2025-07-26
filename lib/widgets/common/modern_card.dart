// lib/widgets/common/modern_card.dart

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'glassy_container.dart';

enum ModernCardType {
  elevated,
  flat,
  outlined,
  glass,
  gradient,
}

enum ModernCardVariant {
  primary,
  secondary,
  success,
  warning,
  danger,
  neutral,
}

class ModernCard extends StatefulWidget {
  final Widget child;
  final ModernCardType type;
  final ModernCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showShadow;
  final bool showBorder;
  final double borderRadius;
  final Widget? header;
  final Widget? footer;
  final IconData? headerIcon;
  final String? headerTitle;
  final List<Widget>? actions;

  const ModernCard({
    Key? key,
    required this.child,
    this.type = ModernCardType.glass,
    this.variant = ModernCardVariant.neutral,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showShadow = true,
    this.showBorder = true,
    this.borderRadius = 20,
    this.header,
    this.footer,
    this.headerIcon,
    this.headerTitle,
    this.actions,
  }) : super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin ?? const EdgeInsets.all(8),
              child: _buildCardContent(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(bool isDark) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.header != null || widget.headerTitle != null)
          _buildHeader(isDark),
        
        Flexible(
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(20),
            child: widget.child,
          ),
        ),
        
        if (widget.footer != null)
          _buildFooter(isDark),
      ],
    );

    switch (widget.type) {
      case ModernCardType.elevated:
        return _buildElevatedCard(content, isDark);
      case ModernCardType.flat:
        return _buildFlatCard(content, isDark);
      case ModernCardType.outlined:
        return _buildOutlinedCard(content, isDark);
      case ModernCardType.glass:
        return _buildGlassCard(content, isDark);
      case ModernCardType.gradient:
        return _buildGradientCard(content, isDark);
    }
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getVariantColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.borderRadius),
          topRight: Radius.circular(widget.borderRadius),
        ),
      ),
      child: widget.header ?? Row(
        children: [
          if (widget.headerIcon != null) ...[
            Icon(
              widget.headerIcon,
              color: _getVariantColor(),
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          
          if (widget.headerTitle != null)
            Expanded(
              child: Text(
                widget.headerTitle!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getVariantColor(),
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          
          if (widget.actions != null) ...[
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.actions!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.neutral800.withValues(alpha: 0.5)
            : AppTheme.neutral100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(widget.borderRadius),
          bottomRight: Radius.circular(widget.borderRadius),
        ),
      ),
      child: widget.footer,
    );
  }

  Widget _buildElevatedCard(Widget content, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.showShadow ? [
          BoxShadow(
            color: AppTheme.glassShadow,
            blurRadius: 20 * _elevationAnimation.value,
            offset: Offset(0, 8 * _elevationAnimation.value),
            spreadRadius: -2,
          ),
        ] : null,
      ),
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: content,
              ),
            )
          : content,
    );
  }

  Widget _buildFlatCard(Widget content, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: content,
              ),
            )
          : content,
    );
  }

  Widget _buildOutlinedCard(Widget content, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _getVariantColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: content,
              ),
            )
          : content,
    );
  }

  Widget _buildGlassCard(Widget content, bool isDark) {
    return GlassyContainer(
      borderRadius: widget.borderRadius,
      showGlow: _isHovered,
      onTap: widget.onTap,
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  Widget _buildGradientCard(Widget content, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getVariantGradient(),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.showShadow ? [
          BoxShadow(
            color: _getVariantColor().withValues(alpha: 0.3),
            blurRadius: 20 * _elevationAnimation.value,
            offset: Offset(0, 8 * _elevationAnimation.value),
            spreadRadius: -2,
          ),
        ] : null,
      ),
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: content,
              ),
            )
          : content,
    );
  }

  void _handleHover(bool isHovered) {
    if (widget.onTap == null) return;
    
    setState(() => _isHovered = isHovered);
    
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case ModernCardVariant.primary:
        return AppTheme.primary;
      case ModernCardVariant.secondary:
        return AppTheme.secondary;
      case ModernCardVariant.success:
        return AppTheme.success;
      case ModernCardVariant.warning:
        return AppTheme.warning;
      case ModernCardVariant.danger:
        return AppTheme.error;
      case ModernCardVariant.neutral:
        return AppTheme.neutral600;
    }
  }

  Gradient _getVariantGradient() {
    switch (widget.variant) {
      case ModernCardVariant.primary:
        return AppTheme.primaryGradient;
      case ModernCardVariant.success:
        return AppTheme.successGradient;
      case ModernCardVariant.secondary:
      case ModernCardVariant.warning:
      case ModernCardVariant.danger:
      case ModernCardVariant.neutral:
      default:
        return LinearGradient(
          colors: [
            _getVariantColor(),
            _getVariantColor().withValues(alpha: 0.8),
          ],
        );
    }
  }
}

// Specialized card variants
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final Widget? chart;
  final VoidCallback? onTap;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.chart,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? AppTheme.primary;
    
    return ModernCard(
      type: ModernCardType.glass,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          
          if (chart != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: chart!,
            ),
          ],
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Widget? badge;

  const ActionCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? AppTheme.primary;
    
    return ModernCard(
      type: ModernCardType.glass,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cardColor,
                  cardColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (badge != null) badge!,
                  ],
                ),
                
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}