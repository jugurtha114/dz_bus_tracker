/// lib/presentation/blocs/forgot_password/forgot_password_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/auth/request_password_reset_usecase.dart'; // Import use case

part 'forgot_password_state.dart'; // Link to the State file

/// Cubit responsible for managing the state of the forgot password request process.
/// Interacts with the [RequestPasswordResetUseCase].
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;

  /// Creates an instance of [ForgotPasswordCubit].
  ForgotPasswordCubit({required RequestPasswordResetUseCase requestPasswordResetUseCase})
      : _requestPasswordResetUseCase = requestPasswordResetUseCase,
        super(const ForgotPasswordInitial());

  /// Attempts to request a password reset for the given email.
  Future<void> requestReset(String email) async {
    Log.d('ForgotPasswordCubit: Attempting password reset request for: $email');
    // Basic email validation could happen here or in use case/repo if desired
    if (email.isEmpty || !email.contains('@')) { // Simple check
        emit(const ForgotPasswordFailure(message: 'Please enter a valid email address.')); // TODO: Localize
        emit(const ForgotPasswordInitial()); // Revert to initial after showing error briefly? Or stay in failure? Stay in failure.
        return;
    }

    emit(const ForgotPasswordLoading());

    final params = RequestPasswordResetParams(email: email);
    final result = await _requestPasswordResetUseCase(params);

    emit(result.fold(
      (failure) {
        Log.e('ForgotPasswordCubit: Password reset request failed.', error: failure);
        return ForgotPasswordFailure(message: failure.message ?? 'Password reset request failed.');
      },
      (_) {
        Log.i('ForgotPasswordCubit: Password reset request successful for: $email');
        return const ForgotPasswordSuccess();
      },
    ));
  }
}
