/// lib/presentation/blocs/user_profile_edit/user_profile_edit_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/language.dart'; // May be needed if updating language
import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user/update_user_profile_usecase.dart'; // Import use case

part 'user_profile_edit_state.dart'; // Link to the State file

/// Cubit responsible for managing the state of the user profile update process.
/// Interacts with the [UpdateUserProfileUseCase].
class UserProfileEditCubit extends Cubit<UserProfileEditState> {
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  /// Creates an instance of [UserProfileEditCubit].
  UserProfileEditCubit({required UpdateUserProfileUseCase updateUserProfileUseCase})
      : _updateUserProfileUseCase = updateUserProfileUseCase,
        super(const UserProfileEditInitial());

  /// Attempts to update the user's profile with the provided details.
  /// Only non-null values will be sent in the update request.
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Language? language,
  }) async {
     Log.d('UserProfileEditCubit: Attempting profile update.');
     // Check if any data is actually provided for update
     if (firstName == null && lastName == null && phoneNumber == null && language == null) {
        Log.w('UserProfileEditCubit: Update attempt with no changes provided.');
        // Optionally emit a specific state or message, or just do nothing.
        // emit(const UserProfileEditFailure(message: 'No changes provided.'));
        // emit(const UserProfileEditInitial()); // Revert silently?
        return;
     }

    emit(const UserProfileEditLoading());

    final params = UpdateUserProfileParams(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      language: language,
    );

    final result = await _updateUserProfileUseCase(params);

    emit(result.fold(
      (failure) {
        Log.e('UserProfileEditCubit: Profile update failed.',error:  failure);
        return UserProfileEditFailure(message: failure.message ?? 'Profile update failed.');
      },
      (updatedUser) {
        Log.i('UserProfileEditCubit: Profile update successful for user ID: ${updatedUser.id}');
        // Also potentially update the global AuthBloc state? Requires inter-bloc communication or event bus.
        // For now, just emit success here. The AuthBloc would re-fetch on next AppStart.
        return UserProfileEditSuccess(updatedUser: updatedUser);
      },
    ));
  }
}
