/// lib/domain/usecases/user/get_user_profile_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

/// Use Case for fetching the profile of the currently authenticated user.
///
/// This class retrieves the user's details by calling the corresponding
/// method in the [UserRepository].
class GetUserProfileUseCase implements UseCase<UserEntity, NoParams> {
  /// The repository instance responsible for user data operations.
  final UserRepository repository;

  /// Creates a [GetUserProfileUseCase] instance that requires a [UserRepository].
  const GetUserProfileUseCase(this.repository);

  /// Executes the logic to fetch the user profile.
  ///
  /// Takes [NoParams] as input, calls the repository's getUserProfile method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error (e.g., not authenticated, network error)
  /// or the [UserEntity] on success.
  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
