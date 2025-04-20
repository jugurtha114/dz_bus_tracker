/// lib/domain/usecases/user/update_fcm_token_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

/// Use Case for updating the user's FCM (Firebase Cloud Messaging) device token on the backend.
///
/// This ensures the backend can send push notifications to the correct device for this user.
class UpdateFcmTokenUseCase implements UseCase<void, UpdateFcmTokenParams> {
  /// The repository instance responsible for user data operations.
  final UserRepository repository;

  /// Creates an [UpdateFcmTokenUseCase] instance that requires a [UserRepository].
  const UpdateFcmTokenUseCase(this.repository);

  /// Executes the logic to update the FCM token.
  ///
  /// Takes [UpdateFcmTokenParams] containing the FCM token, calls the
  /// repository's updateFcmToken method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on success.
  @override
  Future<Either<Failure, void>> call(UpdateFcmTokenParams params) async {
    // Basic validation: ensure token is not empty
    if (params.token.isEmpty) {
      return Left(InvalidInputFailure(message: 'FCM token cannot be empty.'));
    }
    return await repository.updateFcmToken(params.token);
  }
}

/// Parameters required for the [UpdateFcmTokenUseCase].
///
/// Contains the FCM registration token obtained from the device.
class UpdateFcmTokenParams extends Equatable {
  /// The FCM registration token string.
  final String token;

  /// Creates an [UpdateFcmTokenParams] instance.
  const UpdateFcmTokenParams({required this.token});

  @override
  List<Object?> get props => [token];
}
