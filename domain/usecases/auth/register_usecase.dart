/// lib/domain/usecases/auth/register_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/language.dart';
import '../../../core/enums/user_type.dart';
import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

/// Use Case for handling new user registration, including driver-specific details if applicable.
///
/// This class encapsulates the business logic required to register a user
/// by calling the corresponding method in the [AuthRepository].
class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  /// The repository instance responsible for authentication data operations.
  final AuthRepository repository;

  /// Creates a [RegisterUseCase] instance that requires an [AuthRepository].
  const RegisterUseCase(this.repository);

  /// Executes the registration logic.
  ///
  /// Takes [RegisterParams] containing all necessary user information (and driver
  /// details if applicable), calls the repository's register method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the created [UserEntity] on successful registration.
  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    // Potential complex validation (e.g., password strength beyond basic checks) could go here.
    return await repository.register(
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      userType: params.userType,
      language: params.language,
      // Pass driver details only if registering as a driver
      idNumber: params.userType == UserType.driver ? params.idNumber : null,
      idPhoto: params.userType == UserType.driver ? params.idPhoto : null,
      licenseNumber: params.userType == UserType.driver ? params.licenseNumber : null,
      licensePhoto: params.userType == UserType.driver ? params.licensePhoto : null,
      experienceYears: params.userType == UserType.driver ? params.experienceYears : null,
      dateOfBirth: params.userType == UserType.driver ? params.dateOfBirth : null,
      address: params.userType == UserType.driver ? params.address : null,
      emergencyContact: params.userType == UserType.driver ? params.emergencyContact : null,
      driverNotes: params.userType == UserType.driver ? params.driverNotes : null,
    );
  }
}

/// Parameters required for the [RegisterUseCase].
///
/// Contains all necessary information for registering a new user, including
/// optional fields specific to driver registration.
class RegisterParams extends Equatable {
  // Base User Info
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserType userType;
  final Language? language; // Optional, let backend default if not provided

  // Driver Specific Info (nullable, only relevant if userType is driver)
  final String? idNumber;
  final dynamic idPhoto; // Expect File or Uint8List
  final String? licenseNumber;
  final dynamic licensePhoto; // Expect File or Uint8List
  final int? experienceYears;
  final DateTime? dateOfBirth;
  final String? address;
  final String? emergencyContact;
  final String? driverNotes;

  /// Creates a [RegisterParams] instance.
  const RegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userType,
    this.language,
    this.idNumber,
    this.idPhoto,
    this.licenseNumber,
    this.licensePhoto,
    this.experienceYears,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    this.driverNotes,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        firstName,
        lastName,
        phoneNumber,
        userType,
        language,
        idNumber,
        idPhoto, // Note: Equality for File/Uint8List might not work as expected
        licenseNumber,
        licensePhoto,
        experienceYears,
        dateOfBirth,
        address,
        emergencyContact,
        driverNotes,
      ];
}
