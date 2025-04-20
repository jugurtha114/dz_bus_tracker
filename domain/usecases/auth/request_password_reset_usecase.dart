/// lib/domain/usecases/auth/request_password_reset_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

/// Use Case for initiating the password reset process for a user.
///
/// This class encapsulates the business logic required to request a password
/// reset email/link to be sent to the user associated with the provided email,
/// by calling the corresponding method in the [AuthRepository].
class RequestPasswordResetUseCase
    implements UseCase<void, RequestPasswordResetParams> {
  /// The repository instance responsible for authentication data operations.
  final AuthRepository repository;

  /// Creates a [RequestPasswordResetUseCase] instance that requires an [AuthRepository].
  const RequestPasswordResetUseCase(this.repository);

  /// Executes the password reset request logic.
  ///
  /// Takes [RequestPasswordResetParams] containing the user's email,
  /// calls the repository's requestPasswordReset method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on successful request initiation.
  @override
  Future<Either<Failure, void>> call(RequestPasswordResetParams params) async {
    // Add email format validation here or in the BLoC/ViewModel if desired.
    return await repository.requestPasswordReset(params.email);
  }
}

/// Parameters required for the [RequestPasswordResetUseCase].
///
/// Contains the user's email address for whom the password reset is requested.
class RequestPasswordResetParams extends Equatable {
  /// The email address associated with the account needing a password reset.
  final String email;

  /// Creates a [RequestPasswordResetParams] instance.
  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}
