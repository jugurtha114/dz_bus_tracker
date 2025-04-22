/// lib/domain/usecases/auth/login_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

/// Use Case for handling user login.
///
/// This class encapsulates the business logic required to authenticate a user
/// by calling the corresponding method in the [AuthRepository].
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  /// The repository instance responsible for authentication data operations.
  final AuthRepository repository;

  /// Creates a [LoginUseCase] instance that requires an [AuthRepository].
  const LoginUseCase(this.repository);

  /// Executes the login logic.
  ///
  /// Takes [LoginParams] containing the user's email and password,
  /// calls the repository's login method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a [UserEntity] on successful login.
  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    // Input validation could potentially happen here or in the BLoC/ViewModel layer.
    // For simplicity, we assume basic validation (e.g., non-empty) happened before calling.
    return await repository.login(params.email, params.password);
  }
}

/// Parameters required for the [LoginUseCase].
///
/// Contains the user's email and password necessary for authentication.
class LoginParams extends Equatable {
  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Creates a [LoginParams] instance.
  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
