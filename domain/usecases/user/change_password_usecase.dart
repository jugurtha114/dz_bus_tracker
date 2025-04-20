/// lib/domain/usecases/user/change_password_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/user_repository.dart'; // Import User repo
import '../base_usecase.dart';

/// Use Case for changing the user's password.
///
/// This class encapsulates the business logic required to securely change the
/// password by calling the corresponding method in the [UserRepository].
class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  /// The repository instance responsible for user data operations.
  final UserRepository repository;

  /// Creates a [ChangePasswordUseCase] instance that requires a [UserRepository].
  const ChangePasswordUseCase(this.repository);

  /// Executes the password change logic.
  ///
  /// Takes [ChangePasswordParams] containing the old and new passwords,
  /// performs basic validation (new passwords match), calls the repository's
  /// changePassword method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on success.
  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    // Basic validation: Ensure new passwords match
    if (params.newPassword != params.confirmNewPassword) {
      return Left(InvalidInputFailure(message: 'New passwords do not match.')); // TODO: Localize
    }
    // Optional: Add complexity checks for new password here if not done by backend

    return await repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      confirmNewPassword: params.confirmNewPassword,
    );
  }
}

/// Parameters required for the [ChangePasswordUseCase].
///
/// Contains the user's current password and the new password details.
class ChangePasswordParams extends Equatable {
  /// The user's current password for verification.
  final String oldPassword;
  /// The desired new password.
  final String newPassword;
  /// Confirmation of the new password.
  final String confirmNewPassword;

  /// Creates a [ChangePasswordParams] instance.
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmNewPassword];
}
