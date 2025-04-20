/// lib/core/typedefs/common_types.dart

/// Defines a type alias for a standard JSON map structure.
/// Used frequently when dealing with JSON data from APIs or local storage.
typedef JsonMap = Map<String, dynamic>;

// --- Optional Common Functional Types (if using dartz extensively) ---
// Example: Alias for Future<Either<Failure, T>> pattern
// import 'package:dartz/dartz.dart';
// import '../error/failures.dart'; // Assuming Failure base class exists
// typedef FutureEither<T> = Future<Either<Failure, T>>;

// Add other common type definitions here if needed as the project evolves.
// For example:
// typedef UserId = String;
// typedef BusId = String;
// typedef LineId = String;
// typedef StopId = String;
// typedef SessionId = String;
