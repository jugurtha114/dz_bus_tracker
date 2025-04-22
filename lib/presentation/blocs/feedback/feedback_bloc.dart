/// lib/presentation/blocs/feedback/feedback_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For droppable transformer
import 'package:equatable/equatable.dart';

import '../../../core/enums/abuse_reason.dart';
import '../../../core/enums/feedback_type.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/abuse_report_entity.dart';
import '../../../domain/entities/feedback_entity.dart';
import '../../../domain/usecases/feedback/submit_abuse_report_usecase.dart';
import '../../../domain/usecases/feedback/submit_feedback_usecase.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

/// BLoC responsible for managing the state related to submitting user feedback
/// and abuse reports.
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SubmitFeedbackUseCase _submitFeedbackUseCase;
  final SubmitAbuseReportUseCase _submitAbuseReportUseCase;

  /// Creates an instance of [FeedbackBloc].
  FeedbackBloc({
    required SubmitFeedbackUseCase submitFeedbackUseCase,
    required SubmitAbuseReportUseCase submitAbuseReportUseCase,
  })  : _submitFeedbackUseCase = submitFeedbackUseCase,
        _submitAbuseReportUseCase = submitAbuseReportUseCase,
        super(const FeedbackInitial()) {
    // Register event handlers
    on<SubmitFeedback>(
      _onSubmitFeedback,
      transformer: droppable(), // Prevent multiple submissions at once
    );
    on<SubmitAbuseReport>(
      _onSubmitAbuseReport,
      transformer: droppable(), // Prevent multiple submissions at once
    );
  }

  /// Handles the [SubmitFeedback] event.
  Future<void> _onSubmitFeedback(
      SubmitFeedback event, Emitter<FeedbackState> emit) async {
    Log.d('FeedbackBloc: Handling SubmitFeedback event.');
    emit(const FeedbackSubmitting());

    final result = await _submitFeedbackUseCase(SubmitFeedbackParams(
      type: event.type,
      subject: event.subject,
      message: event.message,
      contactInfo: event.contactInfo,
    ));

    emit(result.fold(
      (failure) {
        Log.e('FeedbackBloc: Failed to submit feedback.', error: failure);
        return FeedbackFailure(message: failure.message ?? 'Failed to submit feedback.');
      },
      (feedbackEntity) {
        Log.i('FeedbackBloc: Feedback submitted successfully (ID: ${feedbackEntity.id}).');
        // TODO: Add localization for success message
        return const FeedbackSuccess(message: 'Feedback submitted successfully!');
      },
    ));
  }

  /// Handles the [SubmitAbuseReport] event.
  Future<void> _onSubmitAbuseReport(
      SubmitAbuseReport event, Emitter<FeedbackState> emit) async {
    Log.d('FeedbackBloc: Handling SubmitAbuseReport event.');
    emit(const FeedbackSubmitting());

    final result = await _submitAbuseReportUseCase(SubmitAbuseReportParams(
      reportedUserId: event.reportedUserId,
      reason: event.reason,
      description: event.description,
    ));

    emit(result.fold(
      (failure) {
        Log.e('FeedbackBloc: Failed to submit abuse report.', error: failure);
        return FeedbackFailure(message: failure.message ?? 'Failed to submit report.');
      },
      (abuseReportEntity) {
        Log.i('FeedbackBloc: Abuse report submitted successfully (ID: ${abuseReportEntity.id}).');
         // TODO: Add localization for success message
        return const FeedbackSuccess(message: 'Report submitted successfully.');
      },
    ));
  }
}
