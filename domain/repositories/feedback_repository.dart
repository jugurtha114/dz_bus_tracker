/// lib/domain/repositories/feedback_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/abuse_reason.dart';
import '../../core/enums/abuse_report_status.dart';
import '../../core/enums/feedback_status.dart';
import '../../core/enums/feedback_type.dart';
import '../../core/error/failures.dart';
import '../entities/abuse_report_entity.dart';
import '../entities/feedback_entity.dart';
import '../entities/paginated_list_entity.dart';

/// Abstract interface defining the contract for data operations related to
/// user Feedback and Abuse Reports.
///
/// This contract specifies methods for submitting feedback/reports, retrieving
/// user-specific submissions, and potentially administrative actions like listing,
/// assigning, and resolving reports/feedback. Implementations in the data layer
/// will interact with the corresponding backend API endpoints.
abstract class FeedbackRepository {
  // --- Feedback Methods ---

  /// Submits new feedback from the current user.
  /// Corresponds to POST /api/v1/feedback/.
  ///
  /// - [type]: The category of the feedback.
  /// - [subject]: The subject line.
  /// - [message]: The detailed feedback message.
  /// - [contactInfo]: Optional contact info if user is anonymous or wants specific contact.
  ///
  /// Returns the created [FeedbackEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, FeedbackEntity>> submitFeedback({
    required FeedbackType type,
    required String subject,
    required String message,
    String? contactInfo, // User ID often inferred from auth token
  });

  /// Fetches a paginated list of feedback submitted by the currently authenticated user.
  /// Corresponds to GET /api/v1/feedback/my_feedback/.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of items per page.
  ///
  /// Returns a [PaginatedListEntity] of [FeedbackEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<FeedbackEntity>>> getMyFeedback({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  });

  /// Fetches the details of a specific feedback entry by its ID.
  /// Users should only be able to fetch their own feedback unless they are admins.
  /// Corresponds to GET /api/v1/feedback/{id}/.
  ///
  /// - [feedbackId]: The ID of the feedback to retrieve.
  ///
  /// Returns a [FeedbackEntity] on success.
  /// Returns a [Failure] on error (e.g., not found, permission denied).
  Future<Either<Failure, FeedbackEntity>> getFeedbackDetails(String feedbackId);

  // --- Abuse Report Methods ---

  /// Submits a new abuse report from the current user against another user.
  /// Corresponds to POST /api/v1/abuse-reports/.
  ///
  /// - [reportedUserId]: The ID of the user being reported.
  /// - [reason]: The reason for the report.
  /// - [description]: A detailed description of the abusive behavior.
  ///
  /// Returns the created [AbuseReportEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, AbuseReportEntity>> submitAbuseReport({
    required String reportedUserId,
    required AbuseReason reason,
    required String description,
    // Reporter ID often inferred from auth token
  });

  /// Fetches a paginated list of abuse reports submitted by the currently authenticated user.
  /// Corresponds to GET /api/v1/abuse-reports/my_reports/.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of items per page.
  ///
  /// Returns a [PaginatedListEntity] of [AbuseReportEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<AbuseReportEntity>>> getMyAbuseReports({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  });

  /// Fetches the details of a specific abuse report by its ID.
  /// Users should only be able to fetch their own reports unless they are admins.
  /// Corresponds to GET /api/v1/abuse-reports/{id}/.
  ///
  /// - [reportId]: The ID of the abuse report to retrieve.
  ///
  /// Returns an [AbuseReportEntity] on success.
  /// Returns a [Failure] on error (e.g., not found, permission denied).
  Future<Either<Failure, AbuseReportEntity>> getAbuseReportDetails(String reportId);


  // --- Admin / Management Methods (Placeholder Signatures) ---
  // These methods would typically require admin privileges.

  /// Fetches all feedback entries, paginated and optionally filtered (Admin only).
  /// Corresponds to GET /api/v1/feedback/ and various filtered endpoints.
  Future<Either<Failure, PaginatedListEntity<FeedbackEntity>>> getAllFeedback({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
    FeedbackStatus? status,
    String? assignedToId, // ID of admin assigned
    String? searchQuery,
    // Other filters like type, date range might be added
  });

  /// Updates the status of a specific feedback entry (Admin only).
  /// Corresponds potentially to PATCH /api/v1/feedback/{id}/.
  Future<Either<Failure, FeedbackEntity>> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus newStatus,
  });

  /// Assigns a feedback entry to an admin/staff member (Admin only).
  /// Corresponds to POST /api/v1/feedback/{id}/assign/.
  Future<Either<Failure, FeedbackEntity>> assignFeedback({
    required String feedbackId,
    required String adminUserId,
  });

  /// Adds an official response to a feedback entry (Admin only).
  /// Corresponds to POST /api/v1/feedback/{id}/respond/.
  Future<Either<Failure, FeedbackEntity>> respondToFeedback({
    required String feedbackId,
    required String responseMessage,
  });

  /// Fetches all abuse reports, paginated and optionally filtered (Admin only).
  /// Corresponds to GET /api/v1/abuse-reports/ and various filtered endpoints.
  Future<Either<Failure, PaginatedListEntity<AbuseReportEntity>>> getAllAbuseReports({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
    AbuseReportStatus? status,
    String? reporterId,
    String? reportedUserId,
    // Other filters like reason, date range might be added
  });

  /// Resolves or dismisses an abuse report (Admin only).
  /// Corresponds to POST /api/v1/abuse-reports/{id}/resolve/.
  Future<Either<Failure, AbuseReportEntity>> resolveAbuseReport({
    required String reportId,
    required AbuseReportStatus finalStatus, // Should be 'resolved' or 'dismissed'
    String? resolutionNotes,
  });

   /// Updates administrative notes for an abuse report (Admin only).
   /// Corresponds potentially to PATCH /api/v1/abuse-reports/{id}/.
  Future<Either<Failure, AbuseReportEntity>> updateAbuseReportNotes({
    required String reportId,
    required String notes,
  });
}
