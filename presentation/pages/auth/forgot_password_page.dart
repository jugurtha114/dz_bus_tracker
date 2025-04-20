/// lib/presentation/pages/auth/forgot_password_page.dart

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
import '../../blocs/forgot_password/forgot_password_cubit.dart'; // Import Cubit
import '../../routes/route_names.dart'; // For navigation
import '../../widgets/common/themed_button.dart';

/// Page for users to request a password reset link/code via email.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit scoped to this page
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(requestPasswordResetUseCase: sl()),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => __ForgotPasswordViewState();
}

class __ForgotPasswordViewState extends State<_ForgotPasswordView> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false; // Local loading state managed by Cubit listener

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates form and dispatches request to the Cubit.
  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Helpers.hideKeyboard(context);
    context.read<ForgotPasswordCubit>().requestReset(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
       resizeToAvoidBottomInset: true, // Allow resize
       extendBodyBehindAppBar: true, // Make AppBar background blurry
       appBar: AppBar(
         backgroundColor: Colors.white.withOpacity(0.1), // Semi-transparent glassy background
         elevation: 0,
         flexibleSpace: ClipRect(
           child: BackdropFilter(
             filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
             child: Container(color: Colors.transparent), // Needs a color for filter
           ),
         ),
         leading: BackButton(color: Colors.white, onPressed: () => context.pop()),
         title: Text(tr('forgot_password'), style: textTheme.titleLarge?.copyWith(color: Colors.white)), // TODO: Localize
         centerTitle: true,
       ),
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          final isLoading = state is ForgotPasswordLoading;
          // Avoid unnecessary setState calls if loading state hasn't changed
          if (_isLoading != isLoading) {
            setState(() { _isLoading = isLoading; });
          }

          if (state is ForgotPasswordFailure) {
            Helpers.showSnackBar(context, message: state.message, isError: true);
          } else if (state is ForgotPasswordSuccess) {
             Helpers.showSnackBar(context, message: tr('password_reset_email_sent')); // TODO: Localize 'If an account exists for that email, a password reset link has been sent.'
             // Optionally pop back to login after success message displayed
             // Future.delayed(const Duration(seconds: 2), () {
             //   if (mounted && context.canPop()) context.pop();
             // });
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
            )),
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
                   child: const Center(child: CircularProgressIndicator()) // Use simple indicator
                ),
          ],
        ),
      ),
    );
  }


  /// Builds the main form within the glassy container.
  Widget _buildGlassyForm(BuildContext context, String Function(String) tr) {
    final textTheme = Theme.of(context).textTheme;

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
                   tr('enter_email_to_reset_password'), // TODO: Localize 'Enter your email address below and we\'ll send you a link to reset your password.'
                   textAlign: TextAlign.center,
                   style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                 ),
                 const SizedBox(height: AppTheme.spacingLarge),
                 // Email Field
                 TextFormField(
                   controller: _emailController,
                   decoration: _buildInputDecoration(labelText: tr('email'), prefixIcon: Icons.alternate_email), // TODO: Localize
                   style: const TextStyle(color: Colors.white),
                   keyboardType: TextInputType.emailAddress,
                   validator: validateEmail, // Use validation mixin
                   textInputAction: TextInputAction.done,
                   onFieldSubmitted: (_) => _isLoading ? null : _submitRequest(),
                   enabled: !_isLoading,
                 ),
                 const SizedBox(height: AppTheme.spacingLarge * 1.5),
                // Submit Button
                ThemedButton(
                  text: tr('send_reset_link'), // TODO: Localize
                  isLoading: _isLoading,
                  onPressed: _isLoading ? () {} : _submitRequest,
                  isFullWidth: true,
                   style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                      foregroundColor: Colors.white,
                      textStyle: textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                ),
                 const SizedBox(height: AppTheme.spacingMedium),
                 // Back to Login Link
                 TextButton(
                    onPressed: _isLoading ? null : () => context.pop(), // Go back
                    child: Text(
                       tr('back_to_login'), // TODO: Localize
                       style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                    )
                 )
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
