/// lib/presentation/blocs/reset_password/reset_password_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart'; // Import use case

part 'reset_password_state.dart'; // Link to the State file

/// Cubit responsible for managing the state of the password reset finalization process.
/// Interacts with the [ResetPasswordUseCase].
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordUseCase _resetPasswordUseCase;

  /// Creates an instance of [ResetPasswordCubit].
  ResetPasswordCubit({required ResetPasswordUseCase resetPasswordUseCase})
      : _resetPasswordUseCase = resetPasswordUseCase,
        super(const ResetPasswordInitial());

  /// Attempts to finalize the password reset using the token and new password.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
     Log.d('ResetPasswordCubit: Attempting password reset finalization.');
     // Basic validation handled by use case (passwords match)
     // Additional complexity checks could be added here or in use case
      if (newPassword.isEmpty || confirmPassword.isEmpty) {
         emit(const ResetPasswordFailure(message: 'Passwords cannot be empty.')); // TODO: Localize
         emit(const ResetPasswordInitial()); // Revert state?
         return;
      }
      if (newPassword != confirmPassword) {
          emit(const ResetPasswordFailure(message: 'Passwords do not match.')); // TODO: Localize
          emit(const ResetPasswordInitial()); // Revert state?
          return;
       }

    emit(const ResetPasswordLoading());

    final params = ResetPasswordParams(
      token: token,
      newPassword: newPassword,
      // confirmNewPassword: confirmPassword, // Add if needed by use case/repo
    );
    final result = await _resetPasswordUseCase(params);

    emit(result.fold(
      (failure) {
        Log.e('ResetPasswordCubit: Password reset finalization failed.', error: failure);
        return ResetPasswordFailure(message: failure.message ?? 'Password reset failed.');
      },
      (_) {
        Log.i('ResetPasswordCubit: Password reset successful.');
        return const ResetPasswordSuccess();
      },
    ));
  }
}

