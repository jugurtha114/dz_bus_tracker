/// lib/presentation/blocs/registration/registration_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/language.dart';
import '../../../core/enums/user_type.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/usecases/auth/register_usecase.dart'; // Import the use case

part 'registration_state.dart'; // Link to the State file

/// Cubit responsible for managing the state of the user registration process.
/// Interacts with the [RegisterUseCase].
class RegistrationCubit extends Cubit<RegistrationState> {
  final RegisterUseCase _registerUseCase;

  /// Creates an instance of [RegistrationCubit].
  RegistrationCubit({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase,
        super(const RegistrationInitial());

  /// Attempts to register a new user with the provided details.
  Future<void> registerUser({
    // Base User Info
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required UserType userType,
    Language? language,
    // Driver Specific Info (nullable)
    String? idNumber,
    dynamic idPhoto, // File or Uint8List
    String? licenseNumber,
    dynamic licensePhoto, // File or Uint8List
    int? experienceYears,
    DateTime? dateOfBirth,
    String? address,
    String? emergencyContact,
    String? driverNotes,
  }) async {
    Log.d('RegistrationCubit: Attempting registration for email: $email, type: $userType');
    emit(const RegistrationLoading());

    final params = RegisterParams(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      userType: userType,
      language: language,
      idNumber: idNumber,
      idPhoto: idPhoto,
      licenseNumber: licenseNumber,
      licensePhoto: licensePhoto,
      experienceYears: experienceYears,
      dateOfBirth: dateOfBirth,
      address: address,
      emergencyContact: emergencyContact,
      driverNotes: driverNotes,
    );

    final result = await _registerUseCase(params);

    emit(result.fold(
      (failure) {
        Log.e('RegistrationCubit: Registration failed.');
        return RegistrationFailure(message: failure.message ?? 'Registration failed. Please try again.');
      },
      (userEntity) {
         Log.i('RegistrationCubit: Registration successful for user ID: ${userEntity.id}');
         return const RegistrationSuccess();
      },
    ));
  }
}
