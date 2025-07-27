// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';
import '../../helpers/dialog_helper.dart';

/// Modern login screen with optimized UX and performance
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      showAppBar: false,
      backgroundColor: context.colors.background,
      child: ResponsivePadding(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: context.responsiveValue(
                      mobile: DesignSystem.space64,
                      tablet: DesignSystem.space64 * 1.5,
                      desktop: DesignSystem.space64 * 2,
                    )),
                    _buildHeader(context),
                    SizedBox(height: context.responsiveValue(
                      mobile: DesignSystem.space48,
                      tablet: DesignSystem.space56,
                      desktop: DesignSystem.space64,
                    )),
                    _buildLoginForm(context),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // App logo/icon
        Container(
          padding: const EdgeInsets.all(DesignSystem.space24),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.directions_bus,
            size: context.responsiveValue(
              mobile: 48,
              tablet: 64,
              desktop: 80,
            ),
            color: context.colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: DesignSystem.space24),
        Text(
          'Welcome Back',
          style: context.textStyles.displaySmall?.copyWith(
            color: context.colors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignSystem.space8),
        Text(
          'Sign in to your DZ Bus Tracker account',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildFormContent(context),
      tablet: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildFormContent(context),
        ),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AppCard(
            padding: const EdgeInsets.all(DesignSystem.space32),
            child: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return LoginForm(
      onSubmit: _handleLogin,
      isLoading: _isLoading,
      onForgotPassword: _navigateToForgotPassword,
      onRegister: _navigateToRegister,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: DesignSystem.space16),
            Text(
              'New to DZ Bus Tracker?',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignSystem.space8),
            AppButton.outlined(
              text: 'Create Account',
              onPressed: _isLoading ? null : _navigateToRegister,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(email: email, password: password);
      final success = !authProvider.hasError;
      
      if (success && mounted) {
        // Navigate to appropriate home screen based on user role
        final user = authProvider.user;
        if (user != null) {
          switch (user.userType) {
            case 'passenger':
              Navigator.of(context).pushReplacementNamed(AppRoutes.passengerHome);
              break;
            case 'driver':
              Navigator.of(context).pushReplacementNamed(AppRoutes.driverHome);
              break;
            case 'admin':
              Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
              break;
            default:
              Navigator.of(context).pushReplacementNamed(AppRoutes.passengerHome);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Login Failed',
          message: error.toString(),
          type: ErrorType.validation,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }
}

/// Enhanced login screen with additional features
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _showDriverLogin = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      showAppBar: false,
      backgroundColor: context.colors.background,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ResponsivePadding(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.responsiveValue(
                    mobile: DesignSystem.space64,
                    tablet: DesignSystem.space64 * 1.5,
                    desktop: DesignSystem.space64 * 2,
                  )),
                  _buildAnimatedHeader(context),
                  const SizedBox(height: DesignSystem.space32),
                  _buildUserTypeSelector(context),
                  const SizedBox(height: DesignSystem.space24),
                  _buildLoginForm(context),
                ],
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.space24),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.directions_bus,
              size: 56,
              color: context.colors.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: DesignSystem.space24),
        Text(
          'DZ Bus Tracker',
          style: context.textStyles.displaySmall?.copyWith(
            color: context.colors.onBackground,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignSystem.space8),
        Text(
          _showDriverLogin 
              ? 'Driver Portal Access'
              : 'Track buses in real-time',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserTypeSelector(BuildContext context) {
    return AppSegmentedButton<bool>(
      segments: const [
        AppButtonSegment(
          value: false,
          label: 'Passenger',
          icon: Icons.person,
        ),
        AppButtonSegment(
          value: true,
          label: 'Driver',
          icon: Icons.drive_eta,
        ),
      ],
      selected: {_showDriverLogin},
      onSelectionChanged: (Set<bool> selection) {
        setState(() {
          _showDriverLogin = selection.first;
        });
      },
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildFormContent(context),
      tablet: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildFormContent(context),
        ),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AppCard(
            padding: const EdgeInsets.all(DesignSystem.space32),
            child: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: LoginForm(
        key: ValueKey(_showDriverLogin),
        onSubmit: _handleLogin,
        isLoading: _isLoading,
        onForgotPassword: _navigateToForgotPassword,
        onRegister: _navigateToRegister,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: DesignSystem.space16),
            Text(
              _showDriverLogin 
                  ? 'Need driver registration?'
                  : 'New to DZ Bus Tracker?',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignSystem.space8),
            AppButton.outlined(
              text: _showDriverLogin 
                  ? 'Apply as Driver'
                  : 'Create Account',
              onPressed: _isLoading ? null : _navigateToRegister,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(email: email, password: password);
      final success = !authProvider.hasError;
      
      if (success && mounted) {
        // Add haptic feedback for successful login
        // HapticFeedback.lightImpact();
        
        final user = authProvider.user;
        if (user != null) {
          // Validate user type matches selected mode
          if (_showDriverLogin && user.userType != 'driver') {
            throw Exception('Please use passenger login for your account type');
          }
          
          switch (user.userType) {
            case 'passenger':
              Navigator.of(context).pushReplacementNamed(AppRoutes.passengerHome);
              break;
            case 'driver':
              Navigator.of(context).pushReplacementNamed(AppRoutes.driverHome);
              break;
            case 'admin':
              Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
              break;
            default:
              Navigator.of(context).pushReplacementNamed(AppRoutes.passengerHome);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Login Failed',
          message: error.toString(),
          type: ErrorType.validation,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed(
      _showDriverLogin 
          ? AppRoutes.driverRegister
          : AppRoutes.register,
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }
}