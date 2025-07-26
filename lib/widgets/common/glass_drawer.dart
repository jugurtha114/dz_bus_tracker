// lib/widgets/common/glass_drawer.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../localization/localization_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../localization/app_localizations.dart';
import '../../config/route_config.dart';
import '../../models/user_model.dart';
import 'glassy_container.dart';

class GlassDrawer extends StatefulWidget {
  final GlassDrawerVariant variant;
  final bool showBorder;
  final bool showGlow;

  const GlassDrawer({
    Key? key,
    this.variant = GlassDrawerVariant.primary,
    this.showBorder = true,
    this.showGlow = false,
  }) : super(key: key);

  @override
  State<GlassDrawer> createState() => _GlassDrawerState();
}

enum GlassDrawerVariant {
  primary,
  secondary,
  tertiary,
  neutral,
}

class _GlassDrawerState extends State<GlassDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -300.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getVariantColor() {
    switch (widget.variant) {
      case GlassDrawerVariant.primary:
        return AppTheme.primary;
      case GlassDrawerVariant.secondary:
        return AppTheme.secondary;
      case GlassDrawerVariant.tertiary:
        return AppTheme.tertiary;
      case GlassDrawerVariant.neutral:
        return AppTheme.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final variantColor = _getVariantColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: size.width * 0.85,
              height: size.height,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.glass,
                          AppTheme.glassMedium,
                          variantColor.withValues(alpha: 0.05),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      border: widget.showBorder
                          ? Border(
                              right: BorderSide(
                                color: variantColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.glassShadow,
                          blurRadius: 20,
                          offset: const Offset(5, 0),
                        ),
                        if (widget.showGlow)
                          BoxShadow(
                            color: variantColor.withValues(alpha: 0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 0),
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Header Section
                          _buildHeader(context, variantColor),

                          const SizedBox(height: AppTheme.spacing20),

                          // Navigation Items
                          Expanded(
                            child: _buildNavigationItems(context, variantColor),
                          ),

                          // Settings Section
                          _buildSettingsSection(context, variantColor),

                          // Logout Section
                          _buildLogoutSection(context),

                          const SizedBox(height: AppTheme.spacing20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color variantColor) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context);
    final user = authProvider.user;

    return GlassyContainer(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      variant: GlassVariant.primary,
      showGlow: widget.showGlow,
      child: Column(
        children: [
          // Profile Picture with modern glass effect
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  variantColor,
                  variantColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: variantColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppTheme.glassShadow,
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.profile?.avatar != null
                  ? Image.network(
                      user!.profile!.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(variantColor),
                    )
                  : _buildDefaultAvatar(variantColor),
            ),
          ),

          const SizedBox(height: AppTheme.spacing16),

          // User Name
          Text(
            user?.fullName ?? localizations.translate('guest'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              fontFamily: AppTheme.fontFamily,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppTheme.spacing8),

          // User Role Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: variantColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: variantColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: variantColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _getUserRoleText(authProvider.userType, localizations),
              style: TextStyle(
                color: variantColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 1.2,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(Color variantColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            variantColor,
            variantColor.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 45,
        color: Colors.white,
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, Color variantColor) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context);
    final userRole = authProvider.userType;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      children: [
        // Dashboard
        _buildDrawerItem(
          context,
          icon: Icons.dashboard_rounded,
          title: localizations.translate('dashboard'),
          onTap: () => _navigateToHome(context, userRole),
          variantColor: variantColor,
        ),

        // Profile
        _buildDrawerItem(
          context,
          icon: Icons.person_rounded,
          title: localizations.translate('profile'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          variantColor: variantColor,
        ),

        // Role-specific navigation items
        ..._buildRoleSpecificItems(context, userRole, localizations, variantColor),

        const SizedBox(height: AppTheme.spacing20),

        // Common items
        _buildDrawerItem(
          context,
          icon: Icons.notifications_rounded,
          title: localizations.translate('notifications'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          variantColor: variantColor,
        ),

        _buildDrawerItem(
          context,
          icon: Icons.help_outline_rounded,
          title: localizations.translate('help'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          variantColor: variantColor,
        ),
      ],
    );
  }

  List<Widget> _buildRoleSpecificItems(
    BuildContext context,
    UserType? userRole,
    AppLocalizations localizations,
    Color variantColor,
  ) {
    switch (userRole) {
      case UserType.passenger:
        return [
          _buildDrawerItem(
            context,
            icon: Icons.directions_bus_rounded,
            title: localizations.translate('bus_search'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.passengerHome),
            variantColor: variantColor,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history_rounded,
            title: localizations.translate('trip_history'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.tripHistory),
            variantColor: variantColor,
          ),
        ];

      case UserType.driver:
        return [
          _buildDrawerItem(
            context,
            icon: Icons.directions_bus_filled_rounded,
            title: localizations.translate('my_buses'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.busManagement),
            variantColor: variantColor,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.route_rounded,
            title: localizations.translate('trips'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.driverTrips),
            variantColor: variantColor,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics_rounded,
            title: localizations.translate('performance'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.driverPerformance),
            variantColor: variantColor,
          ),
        ];

      case UserType.admin:
        return [
          _buildDrawerItem(
            context,
            icon: Icons.admin_panel_settings_rounded,
            title: localizations.translate('admin_panel'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
            variantColor: variantColor,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people_rounded,
            title: localizations.translate('user_management'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.userManagement),
            variantColor: variantColor,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.directions_bus_filled_rounded,
            title: localizations.translate('fleet_management'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.fleetManagement),
            variantColor: variantColor,
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color variantColor,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing16,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? variantColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: isSelected
                  ? Border.all(
                      color: variantColor.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? variantColor.withValues(alpha: 0.15)
                        : AppTheme.neutral100.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? variantColor : AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? variantColor : AppTheme.onSurface,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: variantColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, Color variantColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context);

    return GlassyContainer(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      variant: GlassVariant.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('settings'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              fontFamily: AppTheme.fontFamily,
            ),
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Theme Toggle
          _buildSettingRow(
            context,
            icon: Icons.brightness_6_rounded,
            title: localizations.translate('dark_mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: themeProvider.isAnimating
                  ? null
                  : (value) => themeProvider.toggleTheme(),
              activeColor: variantColor,
              inactiveThumbColor: AppTheme.neutral400,
              inactiveTrackColor: AppTheme.neutral200,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            variantColor: variantColor,
          ),

          const SizedBox(height: AppTheme.spacing12),

          // Language Selector
          _buildSettingRow(
            context,
            icon: Icons.language_rounded,
            title: localizations.translate('language'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLanguageDisplayName(localizationProvider.locale.languageCode),
                  style: TextStyle(
                    color: variantColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: variantColor,
                ),
              ],
            ),
            onTap: () => _showLanguageDialog(context, localizationProvider),
            variantColor: variantColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required Color variantColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: variantColor,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurface,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context, authProvider, localizations),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: AppTheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Text(
                    localizations.translate('logout'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUserRoleText(UserType? userType, AppLocalizations localizations) {
    switch (userType) {
      case UserType.admin:
        return localizations.translate('admin');
      case UserType.driver:
        return localizations.translate('driver');
      case UserType.passenger:
        return localizations.translate('passenger');
      default:
        return localizations.translate('guest');
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'Français';
    }
  }

  void _navigateToHome(BuildContext context, UserType? userType) {
    switch (userType) {
      case UserType.admin:
        Navigator.pushNamed(context, AppRoutes.adminDashboard);
        break;
      case UserType.driver:
        Navigator.pushNamed(context, AppRoutes.driverHome);
        break;
      case UserType.passenger:
      default:
        Navigator.pushNamed(context, AppRoutes.passengerHome);
        break;
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    LocalizationProvider localizationProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassyContainer(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          variant: GlassVariant.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              const SizedBox(height: AppTheme.spacing20),
              _buildLanguageOption(
                context,
                'Français',
                'fr',
                localizationProvider,
              ),
              _buildLanguageOption(
                context,
                'English',
                'en',
                localizationProvider,
              ),
              _buildLanguageOption(
                context,
                'العربية',
                'ar',
                localizationProvider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String languageCode,
    LocalizationProvider localizationProvider,
  ) {
    final isSelected = localizationProvider.locale.languageCode == languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          localizationProvider.changeLocale(languageCode);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: languageCode,
                groupValue: localizationProvider.locale.languageCode,
                onChanged: (value) {
                  localizationProvider.changeLocale(value!);
                  Navigator.pop(context);
                },
                activeColor: AppTheme.primary,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassyContainer(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          variant: GlassVariant.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 48,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                localizations.translate('logout'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                localizations.translate('logout_confirm'),
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  fontFamily: AppTheme.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                      ),
                      child: Text(
                        localizations.translate('cancel'),
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        authProvider.logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                        elevation: 0,
                      ),
                      child: Text(
                        localizations.translate('logout'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
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

// Convenience constructors
extension GlassDrawerVariants on GlassDrawer {
  static GlassDrawer primary({
    Key? key,
    bool showBorder = true,
    bool showGlow = false,
  }) {
    return GlassDrawer(
      key: key,
      variant: GlassDrawerVariant.primary,
      showBorder: showBorder,
      showGlow: showGlow,
    );
  }

  static GlassDrawer secondary({
    Key? key,
    bool showBorder = true,
    bool showGlow = false,
  }) {
    return GlassDrawer(
      key: key,
      variant: GlassDrawerVariant.secondary,
      showBorder: showBorder,
      showGlow: showGlow,
    );
  }
}