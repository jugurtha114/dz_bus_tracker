/// lib/presentation/blocs/feedback/feedback_event.dart

part of 'feedback_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to submitting feedback or abuse reports.
/// Uses [Equatable] for value comparison.
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user submits feedback via the form.
class SubmitFeedback extends FeedbackEvent {
  /// The type or category of the feedback.
  final FeedbackType type;
  /// The subject line of the feedback.
  final String subject;
  /// The detailed message or content of the feedback.
  final String message;
  /// Optional: Contact information provided by the submitter.
  final String? contactInfo;

  /// Creates a [SubmitFeedback] event.
  const SubmitFeedback({
    required this.type,
    required this.subject,
    required this.message,
    this.contactInfo,
  });

  @override
  List<Object?> get props => [type, subject, message, contactInfo];

   @override
  String toString() => 'SubmitFeedback(type: $type, subject: $subject)';
}

/// Event triggered when the user submits an abuse report via the form.
class SubmitAbuseReport extends FeedbackEvent {
  /// The ID of the user being reported.
  final String reportedUserId;
  /// The reason category for the report.
  final AbuseReason reason;
  /// A detailed description outlining the reason for the report.
  final String description;

  /// Creates a [SubmitAbuseReport] event.
  const SubmitAbuseReport({
    required this.reportedUserId,
    required this.reason,
    required this.description,
  });

  @override
  List<Object?> get props => [reportedUserId, reason, description];

   @override
  String toString() => 'SubmitAbuseReport(reportedUserId: $reportedUserId, reason: $reason)';
}
