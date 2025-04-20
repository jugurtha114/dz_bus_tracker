/// lib/presentation/pages/settings/change_password_page.dart

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
import '../../blocs/change_password/change_password_cubit.dart'; // Import Cubit
import '../../widgets/common/themed_button.dart';

/// Page for authenticated users to change their password.
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit scoped to this page
    return BlocProvider(
      create: (context) => ChangePasswordCubit(changePasswordUseCase: sl()),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => __ChangePasswordViewState();
}

class __ChangePasswordViewState extends State<_ChangePasswordView> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Local loading state managed by Cubit listener

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Attempts to change the password.
  Future<void> _submitChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Log.w('Change password form validation failed.');
      return;
    }
    Helpers.hideKeyboard(context);

    context.read<ChangePasswordCubit>().changePassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmNewPassword: _confirmPasswordController.text,
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
         flexibleSpace: ClipRect(
           child: BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
             child: Container(color: Colors.transparent),
           ),
         ),
         leading: BackButton(color: Colors.white, onPressed: () => context.pop()),
         title: Text(
           tr('change_password'), // TODO: Localize
           style: textTheme.titleLarge?.copyWith(color: Colors.white),
         ),
         centerTitle: true,
      ),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
         listener: (context, state) {
           setState(() {
              _isLoading = (state is ChangePasswordLoading);
           });

           if (state is ChangePasswordFailure) {
              Helpers.showSnackBar(context, message: state.message, isError: true);
           } else if (state is ChangePasswordSuccess) {
              Helpers.showSnackBar(context, message: tr('password_changed_success')); // TODO: Localize 'Password changed successfully!'
              context.pop(); // Go back after success
           }
         },
         child: Stack(
           children: [
              // Background Image
                Positioned.fill(
                  child: Image.asset(
                    AssetsConstants.authBackground, // Reuse background
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                 // Main Content
                 SafeArea(
                    child: Center(
                       child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 450),
                              child: _buildGlassyForm(context),
                          ),
                       ),
                    ),
                 ),
           ],
         ),
      ),
    );
  }


  /// Builds the main form within the glassy container.
  Widget _buildGlassyForm(BuildContext context) {
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                     tr('enter_current_and_new_password'), // TODO: Localize
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                   // Current Password
                   TextFormField(
                      controller: _oldPasswordController,
                      decoration: _buildInputDecoration(labelText: tr('current_password'), prefixIcon: Icons.lock_open_outlined).copyWith(
                         suffixIcon: IconButton(
                          icon: Icon(_isOldPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          color: Colors.white.withOpacity(0.7),
                          onPressed: () => setState(() => _isOldPasswordVisible = !_isOldPasswordVisible),
                        ),
                      ),
                      obscureText: !_isOldPasswordVisible,
                      validator: (value) => validateRequiredField(value, tr('current_password')), // TODO: Localize field name
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingMedium),

                   // New Password
                   TextFormField(
                      controller: _newPasswordController,
                      decoration: _buildInputDecoration(labelText: tr('new_password'), prefixIcon: Icons.lock_outline).copyWith(
                         suffixIcon: IconButton(
                          icon: Icon(_isNewPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          color: Colors.white.withOpacity(0.7),
                          onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                        ),
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
                         suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          color: Colors.white.withOpacity(0.7),
                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                       validator: (value) => validateConfirmPassword(value, _newPasswordController.text),
                      textInputAction: TextInputAction.done,
                       onFieldSubmitted: (_) => _isLoading ? null : _submitChangePassword(),
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(height: AppTheme.spacingLarge * 1.5),

                  // Save Button
                  ThemedButton(
                    text: tr('save_changes'), // TODO: Localize
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _submitChangePassword,
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
  InputDecoration _buildInputDecoration({
      required String labelText, String? hintText, required IconData prefixIcon,}) {
      return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: BorderSide(color: AppTheme.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500), );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
