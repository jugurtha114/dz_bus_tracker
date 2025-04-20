/// lib/domain/usecases/line/get_line_details_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/line_entity.dart';
import '../../repositories/line_repository.dart'; // Import the Line repository
import '../base_usecase.dart';

/// Use Case for fetching the detailed information of a specific bus line.
///
/// This class retrieves the line details, potentially including associated stops
/// or buses depending on the repository implementation, by calling the corresponding
/// method in the [LineRepository].
class GetLineDetailsUseCase
    implements UseCase<LineEntity, GetLineDetailsParams> {
  /// The repository instance responsible for line data operations.
  final LineRepository repository;

  /// Creates a [GetLineDetailsUseCase] instance that requires a [LineRepository].
  const GetLineDetailsUseCase(this.repository);

  /// Executes the logic to fetch line details.
  ///
  /// Takes [GetLineDetailsParams] containing the ID of the line to fetch,
  /// calls the repository's getLineDetails method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// (e.g., line not found, network error) or the [LineEntity] on success.
  @override
  Future<Either<Failure, LineEntity>> call(GetLineDetailsParams params) async {
    return await repository.getLineDetails(params.lineId);
  }
}

/// Parameters required for the [GetLineDetailsUseCase].
///
/// Contains the unique identifier of the bus line whose details are requested.
class GetLineDetailsParams extends Equatable {
  /// The ID of the line.
  final String lineId;

  /// Creates a [GetLineDetailsParams] instance.
  const GetLineDetailsParams({required this.lineId});

  @override
  List<Object?> get props => [lineId];
}
