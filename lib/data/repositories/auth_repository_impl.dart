/// lib/data/repositories/auth_repository_impl.dart

import 'dart:async'; // Added for TimeoutException
import 'dart:io'; // For File type used in registration photos
import 'package:flutter/foundation.dart'; // For Uint8List check
// CORRECTED: Import MediaType from http_parser
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // For guessing file mime type
import 'package:path/path.dart' as p; // For getting file extension

// CORRECTED: Import Unit from dartz
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // For FormData, MultipartFile, and Options

// CORRECTED: Import ApiConstants for header name
import '../../../core/constants/api_constants.dart';
import '../../../core/enums/language.dart';
import '../../../core/enums/user_type.dart';
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart'; // Import custom exceptions
import '../../../core/network/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/local/auth_local_data_source.dart';
import '../data_sources/remote/auth_remote_data_source.dart';
import '../models/driver_model.dart'; // Needed for registerDriverDetails
import '../models/login_response_model.dart'; // Needed for login response type
import '../models/user_model.dart';

/// Implementation of the [AuthRepository] interface.
///
/// Orchestrates authentication operations by interacting with remote and local
/// data sources, handling network status checks, and mapping data/exceptions
/// between layers.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  /// Creates an instance of [AuthRepositoryImpl].
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  /// Checks connectivity and handles common exceptions, mapping them to Failures.
  Future<Either<Failure, T>> _performNetworkOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        // Add timeout to prevent hanging indefinitely
        final result = await operation().timeout(
          // TODO: Consider making timeout configurable
          const Duration(seconds: 15), // Increased timeout slightly
          onTimeout: () {
            // Use specific exception for clarity
            throw NetworkException(
              message: 'Operation timed out.', // TODO: Localize
              code: 'TIMEOUT',
            );
          },
        );
        return Right(result);
      } on AuthenticationException catch (e) {
        Log.w('AuthenticationException caught in repository', error: e);
        await localDataSource.clearAuthTokens(); // Ensure cleanup on auth failure
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in repository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        Log.e('ServerException caught in repository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('NetworkException caught in repository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
        Log.e('DataParsingException caught in repository', error: e);
        return Left(DataParsingFailure(message: e.message, code: e.code));
      } on TimeoutException catch (e) { // Handle timeout explicitly from helper
        Log.e('Operation timed out in _performNetworkOperation', error: e);
        return Left(NetworkFailure(message: 'Operation timed out.', code: 'TIMEOUT')); // TODO: Localize
      } on DioException catch (e, stackTrace) {
        // Catch any remaining DioExceptions
        Log.e('Unhandled DioException caught in repository operation', error: e, stackTrace: stackTrace);
        // Map to a general failure
        return Left(NetworkFailure(message: e.message ?? 'API request failed.', code: e.response?.statusCode?.toString()));
      } catch (e, stackTrace) {
        Log.e('Unexpected exception caught in repository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('Network operation skipped: No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    // Use the helper, applying the specific fix for the post-login profile fetch
    return _performNetworkOperation(() async {
      // 1. Call remote data source to login and get tokens
      // Assuming remoteDataSource.login throws on API error (handled by helper)
      final loginResponse = await remoteDataSource.login(email, password);

      // 2. Save tokens locally (await completion)
      await localDataSource.saveToken(loginResponse.access);
      await localDataSource.saveRefreshToken(loginResponse.refresh);
      Log.i('Tokens saved successfully after login.');

      // 3. Fetch user profile using the *newly obtained* token explicitly
      // This bypasses potential timing issues with the interceptor reading storage
      Log.d('Explicitly passing new access token for immediate profile fetch.');
      final profileOptions = Options(
        headers: {
          // Use the token directly from the login response
          ApiConstants.authorizationHeader: 'Bearer ${loginResponse.access}',
        },
      );
      // Assuming remoteDataSource.getUserProfile accepts options (added previously)
      final userModel = await remoteDataSource.getUserProfile(options: profileOptions);
      Log.i('User profile fetched successfully immediately after login.');

      // 4. Map DTO to Entity and return
      return _mapUserModelToEntity(userModel);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required UserType userType,
    Language? language,
    String? idNumber,
    dynamic idPhoto,
    String? licenseNumber,
    dynamic licensePhoto,
    int? experienceYears,
    DateTime? dateOfBirth,
    String? address,
    String? emergencyContact,
    String? driverNotes,
  }) async {
    Log.d('AuthRepositoryImpl: Register method called.'); // Added log
    // Log parameters received by the repository
    Log.d('AuthRepositoryImpl: Received params - email: $email, firstName: $firstName, lastName: $lastName, userType: ${userType.name}'); // Added logging for received params
    Log.d('AuthRepositoryImpl: Received driver params - idNumber: $idNumber, idPhoto: ${idPhoto != null ? "Present" : "Null"}, licenseNumber: $licenseNumber, licensePhoto: ${licensePhoto != null ? "Present" : "Null"}'); // Added logging for driver params


    if (password != confirmPassword) {
      Log.w('AuthRepositoryImpl: Passwords do not match.'); // Added log
      return Left(InvalidInputFailure(message: 'Passwords do not match.')); // TODO: Localize
    }

    return _performNetworkOperation(() async {
      // Prepare base user data
      final Map<String, dynamic> baseUserData = {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
        // Only include optional fields if they are not null or empty
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone_number': phoneNumber,
        'user_type': userType.name, // Ensure enum name is sent as string
        'language': language?.name ?? Language.fr.name, // Default language if null
      };
      Log.d('AuthRepositoryImpl: Prepared base user data for remoteDataSource.register(): $baseUserData'); // Added log

      // 1. Register the base user details
      final UserModel registeredUserModel = await remoteDataSource.register(baseUserData);
      Log.i('AuthRepositoryImpl: Base user registered successfully with ID: ${registeredUserModel.id}');

      // 2. If user is a driver, register driver-specific details
      if (userType == UserType.driver) {
        Log.d('AuthRepositoryImpl: User is a driver, preparing driver details registration.'); // Added log
        if (idNumber == null || idPhoto == null || licenseNumber == null || licensePhoto == null) {
          Log.e('AuthRepositoryImpl: Missing required driver information for driver registration.'); // Added error log
          throw InvalidInputException(message: 'Missing required driver information (ID number/photo, License number/photo).'); // TODO: Localize
        }

        // Prepare FormData for driver details (including files)
        final FormData formData = FormData.fromMap({
          'user': registeredUserModel.id, // Link driver details to the newly created user
          'id_number': idNumber,
          'id_photo': await _createMultipartFile(idPhoto, 'id_photo'),
          'license_number': licenseNumber,
          'license_photo': await _createMultipartFile(licensePhoto, 'license_photo'),
          // Add other driver fields to formData if implemented in backend API
          if (experienceYears != null) 'experience_years': experienceYears,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(), // Or format as required by backend
          if (address != null) 'address': address,
          if (emergencyContact != null) 'emergency_contact': emergencyContact,
          if (driverNotes != null) 'driver_notes': driverNotes,
        });
        Log.d('AuthRepositoryImpl: Prepared FormData for remoteDataSource.registerDriverDetails().'); // Added log

        await remoteDataSource.registerDriverDetails(formData);
        Log.i('AuthRepositoryImpl: Driver details registered successfully for user ID: ${registeredUserModel.id}');
      }

      // 3. Map DTO to Entity and return
      return _mapUserModelToEntity(registeredUserModel);
    });
  }

  /// Helper to create MultipartFile from File or Uint8List
  Future<MultipartFile> _createMultipartFile(dynamic fileData, String defaultFilename) async {
    Log.d('AuthRepositoryImpl: _createMultipartFile called for $defaultFilename.'); // Added log
    if (fileData is File) {
      String fileName = p.basename(fileData.path);
      String? contentType = lookupMimeType(fileData.path);
      MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null;
      Log.d('AuthRepositoryImpl: Creating MultipartFile from File: $fileName, ContentType: $contentType'); // Added log
      return await MultipartFile.fromFile(
        fileData.path,
        filename: fileName,
        contentType: mediaType,
      );
    } else if (fileData is Uint8List) {
      Log.d('AuthRepositoryImpl: Creating MultipartFile from Uint8List.'); // Added log
      String extension = '.jpg'; // Default extension
      String? contentType = lookupMimeType('', headerBytes: fileData);
      if (contentType != null) {
        extension = extensionFromMime(contentType) ?? extension;
      }
      final tempFilename = '${defaultFilename}_${DateTime.now().millisecondsSinceEpoch}$extension';
      MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null;
      Log.d('AuthRepositoryImpl: Creating MultipartFile from Uint8List with filename: $tempFilename, ContentType: $contentType'); // Added log
      return MultipartFile.fromBytes(
        fileData,
        filename: tempFilename,
        contentType: mediaType,
      );
    } else {
      Log.e('AuthRepositoryImpl: Unsupported file type provided to _createMultipartFile: ${fileData?.runtimeType}'); // Added error log
      throw ArgumentError('Unsupported file type for MultipartFile: ${fileData?.runtimeType}');
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    Log.d('AuthRepositoryImpl: Logout method called.'); // Added log
    return _performNetworkOperation<Unit>(() async { // Explicitly define generic type
      if (await networkInfo.isConnected) {
        try {
          Log.d('AuthRepositoryImpl: Calling remoteDataSource.logout().'); // Added log
          await remoteDataSource.logout();
          Log.d('AuthRepositoryImpl: remoteDataSource.logout() successful.'); // Added log
        } catch (e) {
          Log.w("AuthRepositoryImpl: Backend logout call failed (might not exist or error on backend side).", error: e); // Added log
        }
      } else {
        Log.w('AuthRepositoryImpl: Offline, skipping backend logout call.'); // Added log
      }
      Log.d('AuthRepositoryImpl: Calling localDataSource.clearAuthTokens().'); // Added log
      await localDataSource.clearAuthTokens();
      Log.i('AuthRepositoryImpl: Logout successful: Local tokens cleared.');
      return unit; // Return Unit directly
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    // ... (Implementation remains the same as previous correct version, using _checkAuthStatusInternal with timeout) ...
    Log.d('AuthRepositoryImpl: checkAuthStatus method called.'); // Added log
    try {
      Log.d('AuthRepositoryImpl: Calling _checkAuthStatusInternal with timeout.'); // Added log
      // _checkAuthStatusInternal returns Future<Either<Failure, UserEntity?>>,
      // so we don't wrap it in _performNetworkOperation which expects Future<T>.
      // The timeout should handle the Future<Either> directly.
      return await _checkAuthStatusInternal().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          Log.w('AuthRepositoryImpl: _checkAuthStatusInternal timed out after 5 seconds.'); // Added log
          // On timeout of the internal check, treat as unauthenticated.
          return const Right(null);
        },
      );
    } on TimeoutException catch (e, stackTrace) {
      Log.e('AuthRepositoryImpl: checkAuthStatus TimeoutException caught.', error: e, stackTrace: stackTrace);
      // Map the timeout exception to a NetworkFailure or keep it as Right(null) depending on desired behavior.
      // Returning Right(null) is consistent with treating as unauthenticated on failure.
      return const Right(null);
    }
    catch (e, stackTrace) {
      // This catch block handles unexpected errors *before* _checkAuthStatusInternal's own handling.
      Log.e('AuthRepositoryImpl: Unexpected error in checkAuthStatus before internal check.', error: e, stackTrace: stackTrace); // Added log
      // Returning null (unauthenticated) is safer on unexpected errors.
      return const Right(null);
    }
  }

  Future<Either<Failure, UserEntity?>> _checkAuthStatusInternal() async {
    Log.d('AuthRepositoryImpl: _checkAuthStatusInternal called.'); // Added log
    final String? token = await localDataSource.getToken();
    if (token == null || token.isEmpty) {
      Log.i('AuthRepositoryImpl: CheckAuthStatus: No local token found.'); // Added log
      return const Right(null);
    }

    Log.d('AuthRepositoryImpl: CheckAuthStatus: Local token found, attempting to verify with profile fetch.'); // Added log

    if (await networkInfo.isConnected) {
      Log.d('AuthRepositoryImpl: CheckAuthStatus: Network is connected.'); // Added log
      try {
        Log.d('AuthRepositoryImpl: Calling remoteDataSource.getUserProfile() to verify token.'); // Added log
        final userModel = await remoteDataSource.getUserProfile();
        Log.i('AuthRepositoryImpl: CheckAuthStatus: Token verified, user profile fetched.'); // Added log
        return Right(_mapUserModelToEntity(userModel));
      } on AuthenticationException catch (e) {
        Log.w('AuthRepositoryImpl: CheckAuthStatus: Token invalid/expired during profile fetch.', error: e); // Added log
        await localDataSource.clearAuthTokens(); // Clear invalid tokens
        Log.d('AuthRepositoryImpl: Cleared local tokens due to AuthenticationException.'); // Added log
        return const Right(null);
      } on AuthorizationException catch (e) {
        Log.e('AuthRepositoryImpl: CheckAuthStatus: Authorization error fetching profile.', error: e); // Added log
        await localDataSource.clearAuthTokens(); // Treat as unauthenticated on authZ error
        Log.d('AuthRepositoryImpl: Cleared local tokens due to AuthorizationException.'); // Added log
        return const Right(null);
      } on ServerException catch (e) {
        Log.e('AuthRepositoryImpl: CheckAuthStatus: Server error fetching profile.', error: e); // Added log
        // Do not clear tokens on server error, it might be temporary
        return Left(ServerFailure(message: e.message ?? 'Server error verifying session.', code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('AuthRepositoryImpl: CheckAuthStatus: Network error fetching profile.', error: e); // Added log
        // Do not clear tokens on network error
        return Left(NetworkFailure(message: e.message ?? 'Network error verifying session.', code: e.code));
      } on DioException catch (e, stackTrace) {
        // Catch DioExceptions not specifically handled by our custom exceptions
        Log.e('AuthRepositoryImpl: CheckAuthStatus: Unhandled DioException fetching profile.', error: e, stackTrace: stackTrace); // Added log
        await localDataSource.clearAuthTokens(); // Clear tokens on unhandled Dio error as a precaution
        Log.d('AuthRepositoryImpl: Cleared local tokens due to unhandled DioException.'); // Added log
        // Map to a general failure or re-throw as a custom exception if appropriate
        return Left(NetworkFailure(message: e.message ?? 'API request failed.', code: e.response?.statusCode?.toString()));
      } catch (e, stackTrace) {
        Log.e('AuthRepositoryImpl: CheckAuthStatus: Unexpected error fetching profile.', error: e, stackTrace: stackTrace); // Added log
        await localDataSource.clearAuthTokens(); // Clear tokens on unexpected error as a precaution
        Log.d('AuthRepositoryImpl: Cleared local tokens due to unexpected error.'); // Added log
        return Left(UnexpectedFailure(message: 'Unexpected error verifying session: ${e.toString()}'));
      }
    } else {
      Log.w('AuthRepositoryImpl: CheckAuthStatus: Offline, cannot verify token validity.'); // Added log
      // If offline, assume token is valid for now for offline capabilities,
      // but can't fully verify. Returning Right(null) might be safer if
      // offline access is not intended without verification.
      // For now, returning null on offline means treat as unauthenticated by UI,
      // but tokens are kept for when connection returns.
      return const Right(null);
    }
  }


  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String email) async {
    Log.d('AuthRepositoryImpl: requestPasswordReset method called for email: $email'); // Added log
    return _performNetworkOperation<Unit>(() async { // Explicitly define generic type
      Log.d('AuthRepositoryImpl: Calling remoteDataSource.requestPasswordReset().'); // Added log
      await remoteDataSource.requestPasswordReset(email);
      Log.i('AuthRepositoryImpl: Password reset request successful.'); // Added log
      return unit; // Return Unit directly
    });
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String token, String newPassword) async {
    Log.d('AuthRepositoryImpl: resetPassword method called.'); // Added log
    // Log received parameters
    Log.d('AuthRepositoryImpl: Received params - token: ${token.isNotEmpty ? "[REDACTED]" : "EMPTY"}, newPassword: ${newPassword.isNotEmpty ? "[REDACTED]" : "EMPTY"}'); // Added logging for params
    return _performNetworkOperation<Unit>(() async { // Explicitly define generic type
      Log.d('AuthRepositoryImpl: Calling remoteDataSource.resetPassword().'); // Added log
      await remoteDataSource.resetPassword(token, newPassword);
      Log.i('AuthRepositoryImpl: Password reset successful.'); // Added log
      return unit; // Return Unit directly
    });
  }

  /// Simple mapper from [UserModel] (Data Layer) to [UserEntity] (Domain Layer).
  UserEntity _mapUserModelToEntity(UserModel model) {
    Log.d('AuthRepositoryImpl: Mapping UserModel to UserEntity for user ID: ${model.id}'); // Added log
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
      // Add other fields if they exist in UserEntity but not in base UserModel (e.g., driver details if part of UserEntity)
      // Example:
      // driverDetails: model.driverDetails != null ? _mapDriverModelToEntity(model.driverDetails!) : null,
    );
  }

// Example mapper for DriverModel to DriverEntity (if needed and DriverEntity exists)
// DriverEntity _mapDriverModelToEntity(DriverModel model) {
//     return DriverEntity(
//         id: model.id,
//         userId: model.userId, // Assuming a link back to user
//         idNumber: model.idNumber,
//         idPhotoUrl: model.idPhotoUrl,
//         licenseNumber: model.licenseNumber,
//         licensePhotoUrl: model.licensePhotoUrl,
//         experienceYears: model.experienceYears,
//         dateOfBirth: model.dateOfBirth,
//         address: model.address,
//         emergencyContact: model.emergencyContact,
//         driverNotes: model.driverNotes,
//         createdAt: model.createdAt,
//         updatedAt: model.updatedAt,
//     );
// }
}



// /// lib/data/repositories/auth_repository_impl.dart
//
// import 'dart:async'; // Added for TimeoutException
// import 'dart:io'; // For File type used in registration photos
// import 'package:flutter/foundation.dart'; // For Uint8List check
// // CORRECTED: Import MediaType from http_parser
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart'; // For guessing file mime type
// import 'package:path/path.dart' as p; // For getting file extension
//
// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart'; // For FormData, MultipartFile, and Options
//
// // CORRECTED: Import ApiConstants for header name
// import '../../../core/constants/api_constants.dart';
// import '../../../core/enums/language.dart';
// import '../../../core/enums/user_type.dart';
// import '../../../core/error/failures.dart';
// import '../../../core/exceptions/app_exceptions.dart'; // Import custom exceptions
// import '../../../core/network/network_info.dart';
// import '../../../core/utils/logger.dart';
// import '../../domain/entities/user_entity.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../data_sources/local/auth_local_data_source.dart';
// import '../data_sources/remote/auth_remote_data_source.dart';
// import '../models/driver_model.dart'; // Needed for registerDriverDetails
// import '../models/login_response_model.dart'; // Needed for login response type
// import '../models/user_model.dart';
//
// /// Implementation of the [AuthRepository] interface.
// ///
// /// Orchestrates authentication operations by interacting with remote and local
// /// data sources, handling network status checks, and mapping data/exceptions
// /// between layers.
// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemoteDataSource remoteDataSource;
//   final AuthLocalDataSource localDataSource;
//   final NetworkInfo networkInfo;
//
//   /// Creates an instance of [AuthRepositoryImpl].
//   const AuthRepositoryImpl({
//     required this.remoteDataSource,
//     required this.localDataSource,
//     required this.networkInfo,
//   });
//
//   /// Helper function to safely execute network-dependent operations.
//   /// Checks connectivity and handles common exceptions, mapping them to Failures.
//   Future<Either<Failure, T>> _performNetworkOperation<T>(
//       Future<T> Function() operation) async {
//     if (await networkInfo.isConnected) {
//       try {
//         // Add timeout to prevent hanging indefinitely
//         final result = await operation().timeout(
//           // TODO: Consider making timeout configurable
//           const Duration(seconds: 15), // Increased timeout slightly
//           onTimeout: () {
//             // Use specific exception for clarity
//             throw NetworkException(
//               message: 'Operation timed out.', // TODO: Localize
//               code: 'TIMEOUT',
//             );
//           },
//         );
//         return Right(result);
//       } on AuthenticationException catch (e) {
//         Log.w('AuthenticationException caught in repository', error: e);
//         await localDataSource.clearAuthTokens(); // Ensure cleanup on auth failure
//         return Left(AuthenticationFailure(message: e.message, code: e.code));
//       } on AuthorizationException catch (e) {
//         Log.w('AuthorizationException caught in repository', error: e);
//         return Left(AuthorizationFailure(message: e.message, code: e.code));
//       } on ServerException catch (e) {
//         Log.e('ServerException caught in repository', error: e);
//         return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
//       } on NetworkException catch (e) {
//         Log.e('NetworkException caught in repository', error: e);
//         return Left(NetworkFailure(message: e.message, code: e.code));
//       } on DataParsingException catch (e) {
//         Log.e('DataParsingException caught in repository', error: e);
//         return Left(DataParsingFailure(message: e.message, code: e.code));
//       } on TimeoutException catch (e) { // Handle timeout explicitly from helper
//         Log.e('Operation timed out in _performNetworkOperation', error: e);
//         return Left(NetworkFailure(message: 'Operation timed out.', code: 'TIMEOUT')); // TODO: Localize
//       } catch (e, stackTrace) {
//         Log.e('Unexpected exception caught in repository operation', error: e, stackTrace: stackTrace);
//         return Left(UnexpectedFailure(message: e.toString()));
//       }
//     } else {
//       Log.w('Network operation skipped: No internet connection.');
//       return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
//     }
//   }
//
//   @override
//   Future<Either<Failure, UserEntity>> login(String email, String password) async {
//     // Use the helper, applying the specific fix for the post-login profile fetch
//     return _performNetworkOperation(() async {
//       // 1. Call remote data source to login and get tokens
//       // Assuming remoteDataSource.login throws on API error (handled by helper)
//       final loginResponse = await remoteDataSource.login(email, password);
//
//       // 2. Save tokens locally (await completion)
//       await localDataSource.saveToken(loginResponse.access);
//       await localDataSource.saveRefreshToken(loginResponse.refresh);
//       Log.i('Tokens saved successfully after login.');
//
//       // 3. Fetch user profile using the *newly obtained* token explicitly
//       // This bypasses potential timing issues with the interceptor reading storage
//       Log.d('Explicitly passing new access token for immediate profile fetch.');
//       final profileOptions = Options(
//         headers: {
//           // Use the token directly from the login response
//           ApiConstants.authorizationHeader: 'Bearer ${loginResponse.access}',
//         },
//       );
//       // Assuming remoteDataSource.getUserProfile accepts options (added previously)
//       final userModel = await remoteDataSource.getUserProfile(options: profileOptions);
//       Log.i('User profile fetched successfully immediately after login.');
//
//       // 4. Map DTO to Entity and return
//       return _mapUserModelToEntity(userModel);
//     });
//   }
//
//   @override
//   Future<Either<Failure, UserEntity>> register({
//     required String email,
//     required String password,
//     required String confirmPassword,
//     required String firstName,
//     required String lastName,
//     String? phoneNumber,
//     required UserType userType,
//     Language? language,
//     String? idNumber,
//     dynamic idPhoto,
//     String? licenseNumber,
//     dynamic licensePhoto,
//     int? experienceYears,
//     DateTime? dateOfBirth,
//     String? address,
//     String? emergencyContact,
//     String? driverNotes,
//   }) async {
//     if (password != confirmPassword) {
//       return Left(InvalidInputFailure(message: 'Passwords do not match.')); // TODO: Localize
//     }
//     return _performNetworkOperation(() async {
//       final Map<String, dynamic> baseUserData = { /* ... same as before ... */ };
//       final UserModel registeredUserModel = await remoteDataSource.register(baseUserData);
//       Log.i('Base user registered successfully with ID: ${registeredUserModel.id}');
//       if (userType == UserType.driver) {
//         Log.d('Registering driver details...');
//         if (idNumber == null || idPhoto == null || licenseNumber == null || licensePhoto == null) {
//           throw InvalidInputException(message: 'Missing required driver information (ID number/photo, License number/photo).');
//         }
//         final formData = FormData.fromMap({ /* ... same as before ... */ });
//         await remoteDataSource.registerDriverDetails(formData);
//         Log.i('Driver details registered successfully for user ID: ${registeredUserModel.id}');
//       }
//       return _mapUserModelToEntity(registeredUserModel);
//     });
//   }
//
//   /// Helper to create MultipartFile from File or Uint8List
//   Future<MultipartFile> _createMultipartFile(dynamic fileData, String defaultFilename) async {
//     // ... (Implementation remains the same as previous correct version) ...
//     if (fileData is File) { String fileName = p.basename(fileData.path); String? contentType = lookupMimeType(fileData.path); MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null; return await MultipartFile.fromFile( fileData.path, filename: fileName, contentType: mediaType ); } else if (fileData is Uint8List) { String extension = '.jpg'; String? contentType = lookupMimeType('', headerBytes: fileData); if (contentType != null) { extension = extensionFromMime(contentType) ?? extension; } final tempFilename = '${defaultFilename}_${DateTime.now().millisecondsSinceEpoch}$extension'; MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null; return MultipartFile.fromBytes( fileData, filename: tempFilename, contentType: mediaType ); } else { throw ArgumentError('Unsupported file type for MultipartFile: ${fileData?.runtimeType}'); }
//   }
//
//   @override
//   Future<Either<Failure, void>> logout() async {
//     // ... (Implementation remains the same as previous correct version) ...
//     try { if (await networkInfo.isConnected) { try { await remoteDataSource.logout(); } catch (e) { Log.w("Backend logout call failed (might not exist)", error: e); } } await localDataSource.clearAuthTokens(); Log.i('Logout successful: Local tokens cleared.'); return const Right(null); } catch (e, stackTrace) { Log.e('Error during local token clearing on logout', error: e, stackTrace: stackTrace); return Left(CacheFailure(message: 'Failed to clear local session data.')); }
//   }
//
//   @override
//   Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
//     // ... (Implementation remains the same as previous correct version, using _checkAuthStatusInternal with timeout) ...
//     try { return await _checkAuthStatusInternal().timeout( const Duration(seconds: 5), onTimeout: () { Log.w('CheckAuthStatus timed out after 5 seconds'); return const Right(null); }, ); } catch (e, stackTrace) { Log.e('Unexpected error in checkAuthStatus', error: e, stackTrace: stackTrace); return const Right(null); }
//   }
//
//   Future<Either<Failure, UserEntity?>> _checkAuthStatusInternal() async {
//     // ... (Implementation remains the same as previous correct version) ...
//     final String? token = await localDataSource.getToken(); if (token == null || token.isEmpty) { Log.i('CheckAuthStatus: No local token found.'); return const Right(null); } Log.d('CheckAuthStatus: Local token found, attempting to verify with profile fetch.'); if (await networkInfo.isConnected) { try { final userModel = await remoteDataSource.getUserProfile(); Log.i('CheckAuthStatus: Token verified, user profile fetched.'); return Right(_mapUserModelToEntity(userModel)); } on AuthenticationException catch (e) { Log.w('CheckAuthStatus: Token invalid/expired during profile fetch.', error: e); await localDataSource.clearAuthTokens(); return const Right(null); } on AuthorizationException catch (e) { Log.e('CheckAuthStatus: Authorization error fetching profile.', error: e); await localDataSource.clearAuthTokens(); return const Right(null); } on ServerException catch (e) { Log.e('CheckAuthStatus: Server error fetching profile.', error: e); return Left(ServerFailure(message: e.message ?? 'Server error verifying session.', code: e.statusCode?.toString())); } on NetworkException catch (e) { Log.e('CheckAuthStatus: Network error fetching profile.', error: e); return Left(NetworkFailure(message: e.message ?? 'Network error verifying session.', code: e.code)); } catch (e, stackTrace) { Log.e('CheckAuthStatus: Unexpected error fetching profile.', error: e, stackTrace: stackTrace); await localDataSource.clearAuthTokens(); return Left(UnexpectedFailure(message: 'Unexpected error verifying session: ${e.toString()}')); } } else { Log.w('CheckAuthStatus: Offline, cannot verify token validity.'); return const Right(null); }
//   }
//
//   @override
//   Future<Either<Failure, void>> requestPasswordReset(String email) async {
//     // ... (Implementation remains the same as previous correct version) ...
//     return _performNetworkOperation(() => remoteDataSource.requestPasswordReset(email));
//   }
//
//   @override
//   Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
//     // ... (Implementation remains the same as previous correct version) ...
//     return _performNetworkOperation(() => remoteDataSource.resetPassword(token, newPassword));
//   }
//
//   /// Simple mapper from [UserModel] (Data Layer) to [UserEntity] (Domain Layer).
//   UserEntity _mapUserModelToEntity(UserModel model) {
//     // ... (Implementation remains the same as previous correct version) ...
//     return UserEntity( id: model.id, email: model.email, firstName: model.firstName, lastName: model.lastName, phoneNumber: model.phoneNumber, userType: model.userType, language: model.language, isActive: model.isActive, isEmailVerified: model.isEmailVerified, isPhoneVerified: model.isPhoneVerified, dateJoined: model.dateJoined, lastLogin: model.lastLogin, );
//   }
// }