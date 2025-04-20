/// lib/domain/usecases/feedback/submit_abuse_report_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/abuse_reason.dart';
import '../../../core/error/failures.dart';
import '../../entities/abuse_report_entity.dart';
import '../../repositories/feedback_repository.dart'; // Import Feedback repo
import '../base_usecase.dart';

/// Use Case for submitting an abuse report against a user.
///
/// This class encapsulates the business logic required to file an abuse report
/// by calling the corresponding method in the [FeedbackRepository].
class SubmitAbuseReportUseCase
    implements UseCase<AbuseReportEntity, SubmitAbuseReportParams> {
  /// The repository instance responsible for feedback and abuse report operations.
  final FeedbackRepository repository;

  /// Creates a [SubmitAbuseReportUseCase] instance that requires a [FeedbackRepository].
  const SubmitAbuseReportUseCase(this.repository);

  /// Executes the logic to submit an abuse report.
  ///
  /// Takes [SubmitAbuseReportParams] containing the details of the report,
  /// validates basic input, calls the repository's submitAbuseReport method,
  /// and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the created [AbuseReportEntity] on success.
  @override
  Future<Either<Failure, AbuseReportEntity>> call(
      SubmitAbuseReportParams params) async {
    // Basic validation
    if (params.reportedUserId.trim().isEmpty) {
      return Left(
          InvalidInputFailure(message: 'Reported User ID cannot be empty.'));
    }
    if (params.reason == AbuseReason.unknown) {
      return Left(InvalidInputFailure(message: 'A valid reason must be selected.'));
    }
    if (params.description.trim().isEmpty) {
      return Left(InvalidInputFailure(
          message: 'Abuse report description cannot be empty.'));
    }

    return await repository.submitAbuseReport(
      reportedUserId: params.reportedUserId,
      reason: params.reason,
      description: params.description,
    );
  }
}

/// Parameters required for the [SubmitAbuseReportUseCase].
///
/// Contains the necessary information for submitting an abuse report.
class SubmitAbuseReportParams extends Equatable {
  /// The ID of the user being reported.
  final String reportedUserId;

  /// The reason category for the report.
  final AbuseReason reason;

  /// A detailed description outlining the reason for the report.
  final String description;

  /// Creates a [SubmitAbuseReportParams] instance.
  const SubmitAbuseReportParams({
    required this.reportedUserId,
    required this.reason,
    required this.description,
  });

  @override
  List<Object?> get props => [
        reportedUserId,
        reason,
        description,
      ];
}
