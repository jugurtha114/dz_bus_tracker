/// lib/domain/usecases/auth/reset_password_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart'; // Import Auth repo
import '../base_usecase.dart';

/// Use Case for finalizing the password reset process using a token.
///
/// This class encapsulates the business logic required to set a new password
/// using the reset token received by the user (e.g., via email link)
/// by calling the corresponding method in the [AuthRepository].
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  /// The repository instance responsible for authentication data operations.
  final AuthRepository repository;

  /// Creates a [ResetPasswordUseCase] instance that requires an [AuthRepository].
  const ResetPasswordUseCase(this.repository);

  /// Executes the password reset finalization logic.
  ///
  /// Takes [ResetPasswordParams] containing the token and new password,
  /// calls the repository's resetPassword method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// (e.g., invalid/expired token) or `void` (represented as `Right(null)`) on success.
  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    // Optional: Validate new password complexity here if needed
    // Note: Repository interface doesn't require confirmPassword here,
    // assuming backend handles matching if necessary based on its input.
    // If confirmPassword is needed by repo method, add it to params.
    return await repository.resetPassword(params.token, params.newPassword);
  }
}

/// Parameters required for the [ResetPasswordUseCase].
///
/// Contains the password reset token and the new password details.
class ResetPasswordParams extends Equatable {
  /// The password reset token received by the user (e.g., from email link).
  final String token;
  /// The desired new password.
  final String newPassword;
  // Optional: Add confirmNewPassword if needed by repository/API endpoint
  // final String confirmNewPassword;

  /// Creates a [ResetPasswordParams] instance.
  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
    // required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [token, newPassword /*, confirmNewPassword */];
}
