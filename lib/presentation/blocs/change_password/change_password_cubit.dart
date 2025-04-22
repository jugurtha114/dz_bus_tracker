/// lib/presentation/blocs/change_password/change_password_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/user/change_password_usecase.dart'; // Import use case

part 'change_password_state.dart'; // Link to the State file

/// Cubit responsible for managing the state of the change password process.
/// Interacts with the [ChangePasswordUseCase].
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase _changePasswordUseCase;

  /// Creates an instance of [ChangePasswordCubit].
  ChangePasswordCubit({required ChangePasswordUseCase changePasswordUseCase})
      : _changePasswordUseCase = changePasswordUseCase,
        super(const ChangePasswordInitial());

  /// Attempts to change the user's password with the provided details.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    Log.d('ChangePasswordCubit: Attempting password change.');
    emit(const ChangePasswordLoading());

    final params = ChangePasswordParams(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    final result = await _changePasswordUseCase(params);

    emit(result.fold(
      (failure) {
        Log.e('ChangePasswordCubit: Password change failed.', error: failure);
        return ChangePasswordFailure(message: failure.message ?? 'Password change failed.');
      },
      (_) {
        Log.i('ChangePasswordCubit: Password change successful.');
        return const ChangePasswordSuccess();
      },
    ));
  }
}

