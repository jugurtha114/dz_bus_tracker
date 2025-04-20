/// lib/domain/usecases/base_usecase.dart

import 'package:dartz/dartz.dart'; // For Either type
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart'; // Import the Failure base class

/// Abstract base class for all Use Cases in the application.
///
/// Defines a standard contract for executing a specific piece of business logic.
/// It takes parameters of type [Params] and returns a [Future] containing
/// an [Either] type, which holds either a [Failure] or the expected success
/// result of type [Type].
///
/// Type [Type]: The data type returned upon successful execution of the use case.
/// Type [Params]: The parameters required to execute the use case. Use [NoParams]
/// if the use case does not require any input parameters.
abstract class UseCase<Type, Params> {
  /// Executes the business logic encapsulated by the use case.
  Future<Either<Failure, Type>> call(Params params);
}

/// A utility class representing the absence of parameters for a [UseCase].
///
/// Used as the [Params] type for use cases that do not require any input.
/// Extends [Equatable] to allow for value comparison if needed, although typically
/// it won't have any properties to compare.
class NoParams extends Equatable {
  const NoParams(); // Add const constructor

  @override
  List<Object?> get props => []; // No properties to include in equality comparison
}
