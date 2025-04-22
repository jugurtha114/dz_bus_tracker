/// lib/domain/usecases/feedback/submit_feedback_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/feedback_type.dart';
import '../../../core/error/failures.dart';
import '../../entities/feedback_entity.dart';
import '../../repositories/feedback_repository.dart'; // Import Feedback repo
import '../base_usecase.dart';

/// Use Case for submitting user feedback (e.g., bug report, feature request, complaint).
///
/// This class encapsulates the business logic required to send feedback
/// by calling the corresponding method in the [FeedbackRepository].
class SubmitFeedbackUseCase
    implements UseCase<FeedbackEntity, SubmitFeedbackParams> {
  /// The repository instance responsible for feedback operations.
  final FeedbackRepository repository;

  /// Creates a [SubmitFeedbackUseCase] instance that requires a [FeedbackRepository].
  const SubmitFeedbackUseCase(this.repository);

  /// Executes the logic to submit feedback.
  ///
  /// Takes [SubmitFeedbackParams] containing the feedback details,
  /// validates basic input, calls the repository's submitFeedback method,
  /// and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the created [FeedbackEntity] on success.
  @override
  Future<Either<Failure, FeedbackEntity>> call(
      SubmitFeedbackParams params) async {
    // Basic validation
    if (params.subject.trim().isEmpty) {
      return Left(
          InvalidInputFailure(message: 'Feedback subject cannot be empty.'));
    }
    if (params.message.trim().isEmpty) {
      return Left(
          InvalidInputFailure(message: 'Feedback message cannot be empty.'));
    }
    if (params.type == FeedbackType.unknown) {
      return Left(
          InvalidInputFailure(message: 'A valid feedback type must be selected.'));
    }

    return await repository.submitFeedback(
      type: params.type,
      subject: params.subject,
      message: params.message,
      contactInfo: params.contactInfo,
    );
  }
}

/// Parameters required for the [SubmitFeedbackUseCase].
///
/// Contains the necessary information for submitting user feedback.
class SubmitFeedbackParams extends Equatable {
  /// The type or category of the feedback.
  final FeedbackType type;

  /// The subject line of the feedback.
  final String subject;

  /// The detailed message or content of the feedback.
  final String message;

  /// Optional: Contact information (e.g., email, phone) if the user
  /// is anonymous or wants a specific contact method used.
  final String? contactInfo;

  /// Creates a [SubmitFeedbackParams] instance.
  const SubmitFeedbackParams({
    required this.type,
    required this.subject,
    required this.message,
    this.contactInfo,
  });

  @override
  List<Object?> get props => [
        type,
        subject,
        message,
        contactInfo,
      ];
}
