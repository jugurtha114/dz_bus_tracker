/// lib/presentation/blocs/feedback/feedback_state.dart

part of 'feedback_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to submitting feedback or abuse reports.
/// Uses [Equatable] for value comparison.
abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any submission attempt.
class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();
}

/// State indicating that feedback or an abuse report is currently being submitted to the backend.
class FeedbackSubmitting extends FeedbackState {
  const FeedbackSubmitting();
}

/// State indicating that the feedback or abuse report was successfully submitted.
class FeedbackSuccess extends FeedbackState {
  /// Optional success message to display to the user.
  final String? message;

  const FeedbackSuccess({this.message});

   @override
  List<Object?> get props => [message];

   @override
  String toString() => 'FeedbackSuccess(message: $message)';
}

/// State indicating that an error occurred while submitting feedback or an abuse report.
class FeedbackFailure extends FeedbackState {
  /// The error message describing the failure.
  final String message;

  const FeedbackFailure({required this.message});

  @override
  List<Object?> get props => [message];

   @override
  String toString() => 'FeedbackFailure(message: $message)';
}
