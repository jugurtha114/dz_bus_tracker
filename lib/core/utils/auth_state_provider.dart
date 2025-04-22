/// lib/core/utils/auth_state_provider.dart

import '../../domain/entities/user_entity.dart';
import '../utils/logger.dart';

/// A global singleton to ensure auth state is consistently available
/// across the entire app, avoiding synchronization issues
class AuthStateProvider {
  AuthStateProvider._(); // Private constructor
  static final AuthStateProvider _instance = AuthStateProvider._();
  
  /// Access the singleton instance
  static AuthStateProvider get instance => _instance;
  
  // Authentication state
  bool _isAuthenticated = false;
  UserEntity? _currentUser;
  
  /// Check if the user is authenticated
  bool get isAuthenticated => _isAuthenticated;
  
  /// Get the current authenticated user (or null if not authenticated)
  UserEntity? get currentUser => _currentUser;
  
  /// Update authentication state (called from AuthBloc)
  void setAuthenticated(UserEntity user) {
    _isAuthenticated = true;
    _currentUser = user;
    Log.i("AuthStateProvider: Authentication state updated to AUTHENTICATED for user: ${user.email}");
  }
  
  /// Clear authentication state (called from AuthBloc)
  void setUnauthenticated() {
    _isAuthenticated = false;
    _currentUser = null;
    Log.i("AuthStateProvider: Authentication state updated to UNAUTHENTICATED");
  }
}