/// lib/data/repositories/user_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../core/enums/language.dart';
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart'; // Import custom exceptions
import '../../../core/network/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/remote/user_remote_data_source.dart';
import '../models/notification_preferences_model.dart'; // Returned by data source
import '../models/user_model.dart';

/// Implementation of the [UserRepository] interface.
///
/// Orchestrates user-related operations by interacting with the remote data source,
/// handling network status checks, and mapping data/exceptions between layers.
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  // No local data source needed for these specific user profile/settings operations currently.
  // Caching could be added later if performance requires it.
  final NetworkInfo networkInfo;

  /// Creates an instance of [UserRepositoryImpl].
  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  /// Checks connectivity and handles common exceptions, mapping them to Failures.
  Future<Either<Failure, T>> _performNetworkOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await operation();
        return Right(result);
      } on AuthenticationException catch (e) {
        // Although this repo doesn't handle login, actions might fail if token is invalid
        Log.w('AuthenticationException caught in UserRepository', error: e);
        // Should we clear tokens here? Probably not, let AuthRepository handle token validity checks.
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in UserRepository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
         Log.e('ServerException caught in UserRepository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
         Log.e('NetworkException caught in UserRepository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
         Log.e('DataParsingException caught in UserRepository', error: e);
         return Left(DataParsingFailure(message: e.message, code: e.code));
      } catch (e, stackTrace) {
         Log.e('Unexpected exception caught in UserRepository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('UserRepository: Network operation skipped. No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    return _performNetworkOperation<UserEntity>(() async {
      final userModel = await remoteDataSource.getUserProfile();
      return _mapUserModelToEntity(userModel);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Language? language,
  }) async {
    // Construct the update payload map, only including non-null values
    final updateData = <String, dynamic>{};
    if (firstName != null) updateData['first_name'] = firstName;
    if (lastName != null) updateData['last_name'] = lastName;
    if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
    if (language != null) updateData['language'] = language.value; // Send enum string value

    if (updateData.isEmpty) {
       Log.w('UpdateUserProfile called with no fields to update.');
       // Return current profile or specific failure? Let's return failure.
       return Left(InvalidInputFailure(message: 'No profile fields provided for update.'));
    }

    return _performNetworkOperation<UserEntity>(() async {
       final updatedUserModel = await remoteDataSource.updateUserProfile(updateData);
       return _mapUserModelToEntity(updatedUserModel);
    });
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
     if (newPassword != confirmNewPassword) {
        return Left(InvalidInputFailure(message: 'New passwords do not match.')); // TODO: Localize
     }
     // Add other password complexity validation if needed here or in UseCase/BLoC

     return _performNetworkOperation<void>(() async {
        await remoteDataSource.changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmNewPassword: confirmNewPassword,
        );
        return Future.value(); // Return void on success
     });
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
      return _performNetworkOperation<void>(() async {
         await remoteDataSource.updateFcmToken(token);
         return Future.value();
      });
  }

  @override
  Future<Either<Failure, void>> updateNotificationPreferences(
      {required Map<String, bool> preferences}) async {
      return _performNetworkOperation<void>(() async {
          // The remote data source returns the model, but the repository interface
          // requires void, so we discard the result on success.
         await remoteDataSource.updateNotificationPreferences(preferences);
         return Future.value();
      });
  }

  @override
  Future<Either<Failure, void>> sendPhoneVerification() async {
      return _performNetworkOperation<void>(() async {
         await remoteDataSource.sendPhoneVerification();
         return Future.value();
      });
  }

  @override
  Future<Either<Failure, void>> verifyPhone(String code) async {
       return _performNetworkOperation<void>(() async {
         await remoteDataSource.verifyPhone(code);
         return Future.value();
      });
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
        return _performNetworkOperation<void>(() async {
         await remoteDataSource.resendVerificationEmail();
         return Future.value();
      });
  }

  /// Simple mapper from [UserModel] (Data Layer) to [UserEntity] (Domain Layer).
  /// In a larger app, this might be moved to a dedicated mapper class.
  UserEntity _mapUserModelToEntity(UserModel model) {
    // This mapping assumes UserModel fields directly correspond to UserEntity fields.
    // Adjust if there are discrepancies or complex transformations needed.
    return UserEntity(
      id: model.id,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      phoneNumber: model.phoneNumber,
      userType: model.userType,
      language: model.language,
      isActive: model.isActive,
      isEmailVerified: model.isEmailVerified,
      isPhoneVerified: model.isPhoneVerified,
      dateJoined: model.dateJoined,
      lastLogin: model.lastLogin,
    );
  }
}
