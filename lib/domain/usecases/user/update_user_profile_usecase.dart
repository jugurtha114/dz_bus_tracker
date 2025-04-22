/// lib/domain/usecases/user/update_user_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/language.dart';
import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

/// Use Case for updating the profile information of the currently authenticated user.
///
/// This class encapsulates the business logic required to modify user details
/// like name, phone number, or language preference by calling the corresponding
/// method in the [UserRepository].
class UpdateUserProfileUseCase
    implements UseCase<UserEntity, UpdateUserProfileParams> {
  /// The repository instance responsible for user data operations.
  final UserRepository repository;

  /// Creates an [UpdateUserProfileUseCase] instance that requires a [UserRepository].
  const UpdateUserProfileUseCase(this.repository);

  /// Executes the user profile update logic.
  ///
  /// Takes [UpdateUserProfileParams] containing the fields to update,
  /// calls the repository's updateUserProfile method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated [UserEntity] on success.
  @override
  Future<Either<Failure, UserEntity>> call(
      UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      language: params.language,
    );
  }
}

/// Parameters required for the [UpdateUserProfileUseCase].
///
/// Contains the optional fields that can be updated for a user's profile.
/// Only non-null fields should be considered for the update request.
class UpdateUserProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final Language? language;

  /// Creates an [UpdateUserProfileParams] instance.
  /// Provide values only for the fields intended to be updated.
  const UpdateUserProfileParams({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.language,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phoneNumber,
        language,
      ];
}
