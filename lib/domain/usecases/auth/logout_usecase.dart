/// lib/domain/usecases/auth/logout_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

/// Use Case for handling user logout.
///
/// This class encapsulates the business logic required to log out the currently
/// authenticated user by calling the corresponding method in the [AuthRepository].
/// It clears local tokens and may notify the backend.
class LogoutUseCase implements UseCase<void, NoParams> {
  /// The repository instance responsible for authentication data operations.
  final AuthRepository repository;

  /// Creates a [LogoutUseCase] instance that requires an [AuthRepository].
  const LogoutUseCase(this.repository);

  /// Executes the logout logic.
  ///
  /// Takes [NoParams] as input, calls the repository's logout method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error or `void` (represented as `Right(null)`) on success.
  /// Note: Logout failures might often be handled gracefully by simply proceeding
  /// as if logout was successful locally.
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
