/// lib/presentation/pages/auth/reset_password_page.dart

import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart';
import '../../../core/di/service_locator.dart'; // To get Cubit/UseCase
import '../../../core/mixins/validation_mixin.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../blocs/reset_password/reset_password_cubit.dart'; // Import Cubit
import '../../routes/route_names.dart'; // For navigation
import '../../widgets/common/themed_button.dart';

/// Page for users to set a new password using a token received via email/SMS.
class ResetPasswordPage extends StatelessWidget {
  /// The password reset token, usually extracted from the URL deep link.
  final String token;

  const ResetPasswordPage({super.key, required this.token});

   @override
  Widget build(BuildContext context) {
    // Provide the Cubit scoped to this page
    return BlocProvider(
      create: (context) => ResetPasswordCubit(resetPasswordUseCase: sl()),
      child: _ResetPasswordView(token: token),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  final String token;
  const _ResetPasswordView({required this.token});

  @override
  State<_ResetPasswordView> createState() => __ResetPasswordViewState();
}

class __ResetPasswordViewState extends State<_ResetPasswordView> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Local loading state managed by Cubit listener

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates the form and dispatches the reset request to the Cubit.
  Future<void> _submitResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Helpers.hideKeyboard(context);

    context.read<ResetPasswordCubit>().resetPassword(
      token: widget.token,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
       resizeToAvoidBottomInset: true,
       extendBodyBehindAppBar: true,
       appBar: AppBar(
         backgroundColor: Colors.white.withOpacity(0.1),
         elevation: 0,
         flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(color: Colors.transparent))),
         // Go back to login if user explicitly hits back button from this page
         leading: BackButton(color: Colors.white, onPressed: () => context.goNamed(RouteNames.login)),
         title: Text(tr('reset_password'), style: textTheme.titleLarge?.copyWith(color: Colors.white)), // TODO: Localize
         centerTitle: true,
       ),
      body: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          final isLoading = state is ResetPasswordLoading;
           if (_isLoading != isLoading) {
               // Use WidgetsBinding to avoid calling setState during build
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) setState(() { _isLoading = isLoading; });
               });
           }

          if (state is ResetPasswordFailure) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) Helpers.showSnackBar(context, message: state.message, isError: true);
              });
          } else if (state is ResetPasswordSuccess) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                    Helpers.showSnackBar(context, message: tr('password_reset_success_login')); // TODO: Localize 'Password reset successfully! You can now login.'
                    context.goNamed(RouteNames.login); // Navigate to login after success
                }
             });
          }
        },
         child: Stack(
           children: [
              // Background Image
              Positioned.fill(child: Image.asset(AssetsConstants.authBackground, fit: BoxFit.cover, color: Colors.black.withOpacity(0.6), colorBlendMode: BlendMode.darken)),
               // Main Content
              SafeArea(
                child: Center(
                   child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: ConstrainedBox(
                         constraints: const BoxConstraints(maxWidth: 450),
                         child: _buildGlassyForm(context, tr),
                      ),
                   ),
                ),
              ),
               // Loading overlay during submission
               if (_isLoading)
                  Container(
                     color: Colors.black.withOpacity(0.5),
                     child: const Center(child: CircularProgressIndicator())
                  ),
           ],
         ),
      ),
    );
  }

   /// Builds the main form within the glassy container.
  Widget _buildGlassyForm(BuildContext context, String Function(String) tr) {
     return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration( color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text(
                     tr('enter_new_password'), // TODO: Localize 'Enter your new password below.'
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                   ),
                   const SizedBox(height: AppTheme.spacingLarge),
                   // New Password
                   TextFormField(
                      controller: _newPasswordController,
                      decoration: _buildInputDecoration(labelText: tr('new_password'), prefixIcon: Icons.lock_outline).copyWith(
                         suffixIcon: IconButton(icon: Icon(_isNewPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined), color: Colors.white.withOpacity(0.7), onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible)),
                      ),
                      obscureText: !_isNewPasswordVisible,
                       validator: validatePassword, // Use standard password validation
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),
                   // Confirm New Password
                   TextFormField(
                      controller: _confirmPasswordController,
                      decoration: _buildInputDecoration(labelText: tr('confirm_new_password'), prefixIcon: Icons.lock_outline).copyWith(
                         suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined), color: Colors.white.withOpacity(0.7), onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                       validator: (value) => validateConfirmPassword(value, _newPasswordController.text),
                      textInputAction: TextInputAction.done,
                       onFieldSubmitted: (_) => _isLoading ? null : _submitResetPassword(),
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingLarge * 1.5),
                  // Save Button
                  ThemedButton(
                    text: tr('reset_password'), // TODO: Localize
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _submitResetPassword,
                    isFullWidth: true,
                    style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
                       backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                       foregroundColor: Colors.white,
                       textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                     ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  /// Helper to build consistent InputDecoration (copied/adapted)
  InputDecoration _buildInputDecoration({ required String labelText, String? hintText, required IconData prefixIcon,}) { return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: AppTheme.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500), ); }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil { static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; } }

