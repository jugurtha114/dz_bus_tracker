/// lib/data/data_sources/local/auth_local_data_source.dart

import '../../../core/services/storage_service.dart'; // Import the storage service interface
import '../../../core/utils/logger.dart'; // For logging

/// Abstract interface for accessing locally stored authentication data.
/// Defines methods for managing authentication tokens (access and refresh).
abstract class AuthLocalDataSource {
  /// Persists the access token securely.
  Future<void> saveToken(String token);

  /// Retrieves the stored access token. Returns null if not found.
  Future<String?> getToken();

  /// Deletes the stored access token.
  Future<void> deleteToken();

  /// Persists the refresh token securely.
  Future<void> saveRefreshToken(String token);

  /// Retrieves the stored refresh token. Returns null if not found.
  Future<String?> getRefreshToken();

  /// Deletes the stored refresh token.
  Future<void> deleteRefreshToken();

  /// Clears all authentication tokens (access and refresh).
  Future<void> clearAuthTokens();
}

/// Implementation of [AuthLocalDataSource] using the core [StorageService].
/// Delegates token management to the underlying secure storage mechanism.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService _storageService;

  /// Creates an instance of [AuthLocalDataSourceImpl].
  /// Requires an instance of [StorageService] to interact with storage.
  const AuthLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  Future<void> saveToken(String token) async {
    Log.d('AuthLocalDataSource: Saving access token.');
    await _storageService.saveUserToken(token);
  }

  @override
  Future<String?> getToken() async {
    Log.d('AuthLocalDataSource: Retrieving access token.');
    return await _storageService.getUserToken();
  }

  @override
  Future<void> deleteToken() async {
    Log.d('AuthLocalDataSource: Deleting access token.');
    await _storageService.deleteUserToken();
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    Log.d('AuthLocalDataSource: Saving refresh token.');
    await _storageService.saveRefreshToken(token);
  }

  @override
  Future<String?> getRefreshToken() async {
    Log.d('AuthLocalDataSource: Retrieving refresh token.');
    return await _storageService.getRefreshToken();
  }

  @override
  Future<void> deleteRefreshToken() async {
    Log.d('AuthLocalDataSource: Deleting refresh token.');
    await _storageService.deleteRefreshToken();
  }

  @override
  Future<void> clearAuthTokens() async {
    Log.d('AuthLocalDataSource: Clearing all auth tokens.');
    // Call individual delete methods for clarity and potential future difference
    // in how secure storage handles deletion vs clearing.
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
    ]);
    Log.i('All authentication tokens cleared from local storage.');
  }
}
