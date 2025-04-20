/// lib/presentation/pages/auth/login_page.dart

import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/theme_constants.dart'; // Use ThemeConstants
// import '../../../config/themes/app_theme.dart'; // Only if needed for Theme.of(context) access
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/mixins/validation_mixin.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/themed_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Helpers.hideKeyboard(context);
    context.read<AuthBloc>().add(LoggedIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final isLoading = state is AuthLoading;
          if (_isLoading != isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() { _isLoading = isLoading; });
            });
          }

          if (state is AuthFailure) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Helpers.showSnackBar(context, message: state.message, isError: true);
            });
          }
          // CORRECTED: Added explicit navigation on Authentication Success
          else if (state is AuthAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Log.i("LoginPage Listener: AuthAuthenticated received. Navigating home.");
                // Determine home route based on user type
                final homePath = state.user.isDriver ? RouteNames.driverDashboardPath : RouteNames.passengerHomePath;
                // Use context.go to replace the entire stack with the home route
                context.go(homePath);
              }
            });
          }
        },
        child: Stack(
          children: [
            Positioned.fill( child: Image.asset( AssetsConstants.authBackground, fit: BoxFit.cover, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.darken, ), ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset( AssetsConstants.logo, height: 80, ),
                        const SizedBox(height: ThemeConstants.spacingMedium),
                        Text( tr('welcome_back'), style: textTheme.headlineMedium?.copyWith( color: Colors.white, fontWeight: FontWeight.bold, ), ),
                        const SizedBox(height: ThemeConstants.spacingSmall),
                        Text( tr('login_to_continue'), textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith( color: Colors.white.withOpacity(0.85) ), ),
                        const SizedBox(height: ThemeConstants.spacingLarge),
                        _buildGlassyForm(context, tr),
                        const SizedBox(height: ThemeConstants.spacingXLarge),
                        _buildRegisterLink(context, tr),
                      ]
                  ),
                ),
              ),
            ),
            if (_isLoading) Container( color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator()) ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassyForm(BuildContext context, String Function(String) tr) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge), child: BackdropFilter( filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), child: Container( padding: const EdgeInsets.all(ThemeConstants.spacingLarge), decoration: BoxDecoration( color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0), ), child: Form( key: _formKey, child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ TextFormField( controller: _emailController, decoration: _buildInputDecoration( labelText: tr('email'), hintText: tr('enter_your_email'), prefixIcon: Icons.alternate_email, ), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.emailAddress, validator: validateEmail, textInputAction: TextInputAction.next, enabled: !_isLoading, ), const SizedBox(height: ThemeConstants.spacingMedium), TextFormField( controller: _passwordController, decoration: _buildInputDecoration( labelText: tr('password'), hintText: tr('enter_your_password'), prefixIcon: Icons.lock_outline, ).copyWith( suffixIcon: IconButton( icon: Icon( _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, ), color: Colors.white.withOpacity(0.7), onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); }, ), ), style: const TextStyle(color: Colors.white), obscureText: !_isPasswordVisible, validator: validatePassword, textInputAction: TextInputAction.done, onFieldSubmitted: (_) => _isLoading ? null : _login(), enabled: !_isLoading, ), const SizedBox(height: ThemeConstants.spacingSmall / 2), Align( alignment: Alignment.centerRight, child: TextButton( onPressed: _isLoading ? null : () { Log.i('Forgot Password tapped.'); context.pushNamed(RouteNames.forgotPassword); /* Corrected navigation */ }, style: TextButton.styleFrom(padding: EdgeInsets.zero), child: Text( tr('forgot_password'), style: TextStyle(color: Colors.white.withOpacity(0.9)) ), ), ), const SizedBox(height: ThemeConstants.spacingLarge), ThemedButton( text: tr('login'), isLoading: _isLoading, onPressed: _isLoading ? () {} : _login, isFullWidth: true, style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingMedium + 2), backgroundColor: ThemeConstants.primaryColor.withOpacity(0.9), foregroundColor: Colors.white, textStyle: textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), ), ), ), ], ), ), ), ), );
  }

  Widget _buildRegisterLink(BuildContext context, String Function(String) tr) {
    final textTheme = Theme.of(context).textTheme;
    return Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Text( tr('no_account'), style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)), ), TextButton( onPressed: _isLoading ? null : () { Log.i('Register link tapped.'); context.pushNamed(RouteNames.register); }, style: TextButton.styleFrom( padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingXSmall), foregroundColor: Colors.white, textStyle: textTheme.bodyMedium?.copyWith( fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white, ), ), child: Text(tr('register')), ), ],);
  }

  InputDecoration _buildInputDecoration({ required String labelText, required String hintText, required IconData prefixIcon, }) { return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: BorderSide(color: ThemeConstants.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: const BorderSide(color: ThemeConstants.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: ThemeConstants.errorColor ?? ThemeConstants.errorColor, fontWeight: FontWeight.w500), contentPadding: const EdgeInsets.all(ThemeConstants.spacingMedium), ); }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil { static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; } }