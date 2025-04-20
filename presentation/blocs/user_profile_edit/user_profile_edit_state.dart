/// lib/presentation/blocs/user_profile_edit/user_profile_edit_state.dart

part of 'user_profile_edit_cubit.dart'; // Link to the Cubit file

/// Base abstract class for states related to updating the user's profile.
/// Uses [Equatable] for value comparison.
abstract class UserProfileEditState extends Equatable {
  const UserProfileEditState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any update attempt.
class UserProfileEditInitial extends UserProfileEditState {
  const UserProfileEditInitial();
}

/// State indicating that the profile update request is being processed.
class UserProfileEditLoading extends UserProfileEditState {
  const UserProfileEditLoading();
}

/// State indicating that the user profile was successfully updated.
class UserProfileEditSuccess extends UserProfileEditState {
  /// The updated user entity returned from the use case.
  final UserEntity updatedUser;

  const UserProfileEditSuccess({required this.updatedUser});

   @override
  List<Object?> get props => [updatedUser];
}

/// State indicating that an error occurred during the profile update attempt.
class UserProfileEditFailure extends UserProfileEditState {
  /// The error message describing the failure.
  final String message;

  const UserProfileEditFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'UserProfileEditFailure(message: $message)';
}
