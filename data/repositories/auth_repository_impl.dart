/// lib/data/repositories/auth_repository_impl.dart

import 'dart:async'; // Added for TimeoutException
import 'dart:io'; // For File type used in registration photos
import 'package:flutter/foundation.dart'; // For Uint8List check
// CORRECTED: Import MediaType from http_parser
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // For guessing file mime type
import 'package:path/path.dart' as p; // For getting file extension

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
    if (password != confirmPassword) {
      return Left(InvalidInputFailure(message: 'Passwords do not match.')); // TODO: Localize
    }
    return _performNetworkOperation(() async {
      final Map<String, dynamic> baseUserData = { /* ... same as before ... */ };
      final UserModel registeredUserModel = await remoteDataSource.register(baseUserData);
      Log.i('Base user registered successfully with ID: ${registeredUserModel.id}');
      if (userType == UserType.driver) {
        Log.d('Registering driver details...');
        if (idNumber == null || idPhoto == null || licenseNumber == null || licensePhoto == null) {
          throw InvalidInputException(message: 'Missing required driver information (ID number/photo, License number/photo).');
        }
        final formData = FormData.fromMap({ /* ... same as before ... */ });
        await remoteDataSource.registerDriverDetails(formData);
        Log.i('Driver details registered successfully for user ID: ${registeredUserModel.id}');
      }
      return _mapUserModelToEntity(registeredUserModel);
    });
  }

  /// Helper to create MultipartFile from File or Uint8List
  Future<MultipartFile> _createMultipartFile(dynamic fileData, String defaultFilename) async {
    // ... (Implementation remains the same as previous correct version) ...
    if (fileData is File) { String fileName = p.basename(fileData.path); String? contentType = lookupMimeType(fileData.path); MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null; return await MultipartFile.fromFile( fileData.path, filename: fileName, contentType: mediaType ); } else if (fileData is Uint8List) { String extension = '.jpg'; String? contentType = lookupMimeType('', headerBytes: fileData); if (contentType != null) { extension = extensionFromMime(contentType) ?? extension; } final tempFilename = '${defaultFilename}_${DateTime.now().millisecondsSinceEpoch}$extension'; MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null; return MultipartFile.fromBytes( fileData, filename: tempFilename, contentType: mediaType ); } else { throw ArgumentError('Unsupported file type for MultipartFile: ${fileData?.runtimeType}'); }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // ... (Implementation remains the same as previous correct version) ...
    try { if (await networkInfo.isConnected) { try { await remoteDataSource.logout(); } catch (e) { Log.w("Backend logout call failed (might not exist)", error: e); } } await localDataSource.clearAuthTokens(); Log.i('Logout successful: Local tokens cleared.'); return const Right(null); } catch (e, stackTrace) { Log.e('Error during local token clearing on logout', error: e, stackTrace: stackTrace); return Left(CacheFailure(message: 'Failed to clear local session data.')); }
  }

  @override
  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    // ... (Implementation remains the same as previous correct version, using _checkAuthStatusInternal with timeout) ...
    try { return await _checkAuthStatusInternal().timeout( const Duration(seconds: 5), onTimeout: () { Log.w('CheckAuthStatus timed out after 5 seconds'); return const Right(null); }, ); } catch (e, stackTrace) { Log.e('Unexpected error in checkAuthStatus', error: e, stackTrace: stackTrace); return const Right(null); }
  }

  Future<Either<Failure, UserEntity?>> _checkAuthStatusInternal() async {
    // ... (Implementation remains the same as previous correct version) ...
    final String? token = await localDataSource.getToken(); if (token == null || token.isEmpty) { Log.i('CheckAuthStatus: No local token found.'); return const Right(null); } Log.d('CheckAuthStatus: Local token found, attempting to verify with profile fetch.'); if (await networkInfo.isConnected) { try { final userModel = await remoteDataSource.getUserProfile(); Log.i('CheckAuthStatus: Token verified, user profile fetched.'); return Right(_mapUserModelToEntity(userModel)); } on AuthenticationException catch (e) { Log.w('CheckAuthStatus: Token invalid/expired during profile fetch.', error: e); await localDataSource.clearAuthTokens(); return const Right(null); } on AuthorizationException catch (e) { Log.e('CheckAuthStatus: Authorization error fetching profile.', error: e); await localDataSource.clearAuthTokens(); return const Right(null); } on ServerException catch (e) { Log.e('CheckAuthStatus: Server error fetching profile.', error: e); return Left(ServerFailure(message: e.message ?? 'Server error verifying session.', code: e.statusCode?.toString())); } on NetworkException catch (e) { Log.e('CheckAuthStatus: Network error fetching profile.', error: e); return Left(NetworkFailure(message: e.message ?? 'Network error verifying session.', code: e.code)); } catch (e, stackTrace) { Log.e('CheckAuthStatus: Unexpected error fetching profile.', error: e, stackTrace: stackTrace); await localDataSource.clearAuthTokens(); return Left(UnexpectedFailure(message: 'Unexpected error verifying session: ${e.toString()}')); } } else { Log.w('CheckAuthStatus: Offline, cannot verify token validity.'); return const Right(null); }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    // ... (Implementation remains the same as previous correct version) ...
    return _performNetworkOperation(() => remoteDataSource.requestPasswordReset(email));
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    // ... (Implementation remains the same as previous correct version) ...
    return _performNetworkOperation(() => remoteDataSource.resetPassword(token, newPassword));
  }

  /// Simple mapper from [UserModel] (Data Layer) to [UserEntity] (Domain Layer).
  UserEntity _mapUserModelToEntity(UserModel model) {
    // ... (Implementation remains the same as previous correct version) ...
    return UserEntity( id: model.id, email: model.email, firstName: model.firstName, lastName: model.lastName, phoneNumber: model.phoneNumber, userType: model.userType, language: model.language, isActive: model.isActive, isEmailVerified: model.isEmailVerified, isPhoneVerified: model.isPhoneVerified, dateJoined: model.dateJoined, lastLogin: model.lastLogin, );
  }
}