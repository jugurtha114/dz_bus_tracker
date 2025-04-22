/// lib/domain/usecases/auth/check_auth_status_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

/// Use Case for checking the current authentication status of the user.
///
/// This class determines if a user is currently logged in by checking for
/// valid authentication tokens (locally) and potentially verifying them with
/// the backend via the [AuthRepository].
class CheckAuthStatusUseCase implements UseCase<UserEntity?, NoParams> {
  // Note the nullable UserEntity? in the UseCase definition ^

  /// The repository instance responsible for authentication data operations.
  final AuthRepository repository;

  /// Creates a [CheckAuthStatusUseCase] instance that requires an [AuthRepository].
  const CheckAuthStatusUseCase(this.repository);

  /// Executes the authentication status check.
  ///
  /// Takes [NoParams] as input, calls the repository's checkAuthStatus method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error, or a nullable [UserEntity] on success.
  /// A `null` UserEntity indicates the user is not authenticated.
  /// A non-null UserEntity indicates the user is authenticated.
  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
