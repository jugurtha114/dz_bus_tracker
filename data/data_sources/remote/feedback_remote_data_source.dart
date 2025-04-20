/// lib/data/data_sources/remote/feedback_remote_data_source.dart

import '../../../core/constants/api_constants.dart';
import '../../../core/enums/abuse_reason.dart';
import '../../../core/enums/abuse_report_status.dart';
import '../../../core/enums/feedback_status.dart';
import '../../../core/enums/feedback_type.dart';
import '../../../core/network/api_client.dart';
import '../../../core/typedefs/common_types.dart'; // For JsonMap
import '../../../core/utils/logger.dart';
import '../../models/abuse_report_model.dart';
import '../../models/api_response.dart';
import '../../models/feedback_model.dart';

/// Abstract interface for remote data operations related to Feedback and Abuse Reports.
/// Defines methods for interacting with feedback and abuse report API endpoints.
abstract class FeedbackRemoteDataSource {
  // --- Feedback ---
  /// Submits new feedback to the API.
  Future<FeedbackModel> submitFeedback({
    required FeedbackType type,
    required String subject,
    required String message,
    String? contactInfo,
  });

  /// Fetches the current user's submitted feedback (paginated).
  Future<ApiResponse<FeedbackModel>> getMyFeedback({int page = 1, int pageSize = 20});

  /// Fetches details for a specific feedback entry.
  Future<FeedbackModel> getFeedbackDetails(String feedbackId);

  // --- Abuse Reports ---
  /// Submits a new abuse report to the API.
  Future<AbuseReportModel> submitAbuseReport({
    required String reportedUserId,
    required AbuseReason reason,
    required String description,
  });

  /// Fetches the current user's submitted abuse reports (paginated).
  Future<ApiResponse<AbuseReportModel>> getMyAbuseReports({int page = 1, int pageSize = 20});

  /// Fetches details for a specific abuse report.
  Future<AbuseReportModel> getAbuseReportDetails(String reportId);

  // --- Admin Methods ---

  /// Fetches all feedback entries (paginated, filtered). Admin only.
  Future<ApiResponse<FeedbackModel>> getAllFeedback({
    int page = 1,
    int pageSize = 20,
    FeedbackStatus? status,
    String? assignedToId,
    String? searchQuery,
  });

  /// Updates the status of a specific feedback entry. Admin only.
  Future<FeedbackModel> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus newStatus,
  });

  /// Assigns feedback to an admin user. Admin only.
  Future<FeedbackModel> assignFeedback({
    required String feedbackId,
    required String adminUserId,
  });

  /// Adds an official response to feedback. Admin only.
  Future<FeedbackModel> respondToFeedback({
    required String feedbackId,
    required String responseMessage,
  });

  /// Fetches all abuse reports (paginated, filtered). Admin only.
  Future<ApiResponse<AbuseReportModel>> getAllAbuseReports({
    int page = 1,
    int pageSize = 20,
    AbuseReportStatus? status,
    String? reporterId,
    String? reportedUserId,
  });

  /// Resolves or dismisses an abuse report. Admin only.
  Future<AbuseReportModel> resolveAbuseReport({
    required String reportId,
    required AbuseReportStatus finalStatus,
    String? resolutionNotes,
  });

  /// Updates administrative notes for an abuse report. Admin only.
  Future<AbuseReportModel> updateAbuseReportNotes({
    required String reportId,
    required String notes,
  });
}


/// Implementation of [FeedbackRemoteDataSource] using the core [ApiClient].
/// Makes specific API calls for feedback and abuse report tasks.
class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates an instance of [FeedbackRemoteDataSourceImpl].
  /// Requires an instance of [ApiClient] to make HTTP requests.
  const FeedbackRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  // --- Feedback Implementation ---

  @override
  Future<FeedbackModel> submitFeedback({
    required FeedbackType type,
    required String subject,
    required String message,
    String? contactInfo,
  }) async {
    Log.d('FeedbackRemoteDataSource: Calling submit feedback API.');
    // API expects FeedbackCreateRequest schema
    final payload = <String, dynamic>{
      'type': type.value, // Send enum string value
      'subject': subject,
      'message': message,
      if (contactInfo != null) 'contact_info': contactInfo,
      // 'user' ID is likely inferred from auth token by backend
    };
    final response = await _apiClient.post(ApiConstants.feedback, data: payload);
    return FeedbackModel.fromJson(response.data);
  }

  @override
  Future<ApiResponse<FeedbackModel>> getMyFeedback({int page = 1, int pageSize = 20}) async {
    Log.d('FeedbackRemoteDataSource: Calling get my feedback API.');
     final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    final response = await _apiClient.get(
      ApiConstants.feedbackMyFeedback, // Specific endpoint for user's feedback
      queryParameters: queryParameters,
      );
     return ApiResponse<FeedbackModel>.fromJson(
      response.data as JsonMap,
      (json) => FeedbackModel.fromJson(json as JsonMap),
    );
  }

   @override
  Future<FeedbackModel> getFeedbackDetails(String feedbackId) async {
    Log.d('FeedbackRemoteDataSource: Calling get feedback details API for ID: $feedbackId.');
    final response = await _apiClient.get(ApiConstants.feedbackDetail(feedbackId));
    return FeedbackModel.fromJson(response.data);
  }

  // --- Abuse Report Implementation ---

  @override
  Future<AbuseReportModel> submitAbuseReport({
    required String reportedUserId,
    required AbuseReason reason,
    required String description,
  }) async {
    Log.d('FeedbackRemoteDataSource: Calling submit abuse report API.');
     // API expects AbuseReportCreateRequest schema
     final payload = <String, dynamic>{
        'reported_user': reportedUserId,
        'reason': reason.value, // Send enum string value
        'description': description,
        // 'reporter' ID is likely inferred from auth token by backend
     };
     final response = await _apiClient.post(ApiConstants.abuseReports, data: payload);
     return AbuseReportModel.fromJson(response.data);
  }

   @override
  Future<ApiResponse<AbuseReportModel>> getMyAbuseReports({int page = 1, int pageSize = 20}) async {
     Log.d('FeedbackRemoteDataSource: Calling get my abuse reports API.');
      final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    final response = await _apiClient.get(
      ApiConstants.abuseReportsMyReports, // Specific endpoint for user's reports
      queryParameters: queryParameters,
      );
     return ApiResponse<AbuseReportModel>.fromJson(
      response.data as JsonMap,
      (json) => AbuseReportModel.fromJson(json as JsonMap),
    );
  }

  @override
  Future<AbuseReportModel> getAbuseReportDetails(String reportId) async {
    Log.d('FeedbackRemoteDataSource: Calling get abuse report details API for ID: $reportId.');
    final response = await _apiClient.get(ApiConstants.abuseReportDetail(reportId));
    return AbuseReportModel.fromJson(response.data);
  }

  // --- Admin Methods Implementation ---

  @override
  Future<ApiResponse<FeedbackModel>> getAllFeedback({
    int page = 1,
    int pageSize = 20,
    FeedbackStatus? status,
    String? assignedToId,
    String? searchQuery,
  }) async {
     Log.d('FeedbackRemoteDataSource: Calling get all feedback API (Admin).');
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status.value,
        if (assignedToId != null) 'assigned_to_id': assignedToId, // Adjust query param name based on API
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
      };
      queryParameters.removeWhere((key, value) => value == null);

      final response = await _apiClient.get(
        ApiConstants.feedback, // Base endpoint for listing all
        queryParameters: queryParameters,
      );
      return ApiResponse<FeedbackModel>.fromJson(
        response.data as JsonMap,
        (json) => FeedbackModel.fromJson(json as JsonMap),
      );
  }

  @override
  Future<FeedbackModel> updateFeedbackStatus({required String feedbackId, required FeedbackStatus newStatus}) async {
      Log.d('FeedbackRemoteDataSource: Calling update feedback status API (Admin).');
      // Use PATCH to update status
      final response = await _apiClient.patch(
          ApiConstants.feedbackDetail(feedbackId),
          data: {'status': newStatus.value},
      );
      return FeedbackModel.fromJson(response.data);
  }

  @override
  Future<FeedbackModel> assignFeedback({required String feedbackId, required String adminUserId}) async {
      Log.d('FeedbackRemoteDataSource: Calling assign feedback API (Admin).');
      final response = await _apiClient.post(
         ApiConstants.feedbackAssign(feedbackId),
         data: {'assigned_to_id': adminUserId}, // Check API for exact payload key
      );
       return FeedbackModel.fromJson(response.data);
  }

  @override
  Future<FeedbackModel> respondToFeedback({required String feedbackId, required String responseMessage}) async {
      Log.d('FeedbackRemoteDataSource: Calling respond to feedback API (Admin).');
      final response = await _apiClient.post(
         ApiConstants.feedbackRespond(feedbackId),
         data: {'response': responseMessage}, // Check API for exact payload key
      );
       return FeedbackModel.fromJson(response.data);
  }

  @override
  Future<ApiResponse<AbuseReportModel>> getAllAbuseReports({
    int page = 1,
    int pageSize = 20,
    AbuseReportStatus? status,
    String? reporterId,
    String? reportedUserId,
  }) async {
      Log.d('FeedbackRemoteDataSource: Calling get all abuse reports API (Admin).');
       final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status.value,
        if (reporterId != null) 'reporter_id': reporterId, // Adjust query param name based on API
        if (reportedUserId != null) 'reported_user_id': reportedUserId, // Adjust query param name
      };
      queryParameters.removeWhere((key, value) => value == null);

      final response = await _apiClient.get(
        ApiConstants.abuseReports, // Base endpoint for listing all
        queryParameters: queryParameters,
      );
      return ApiResponse<AbuseReportModel>.fromJson(
        response.data as JsonMap,
        (json) => AbuseReportModel.fromJson(json as JsonMap),
      );
  }

   @override
  Future<AbuseReportModel> resolveAbuseReport({required String reportId, required AbuseReportStatus finalStatus, String? resolutionNotes}) async {
      Log.d('FeedbackRemoteDataSource: Calling resolve abuse report API (Admin).');
      final payload = <String, dynamic>{
         'final_status': finalStatus.value, // API likely needs the final status (resolved/dismissed)
         if (resolutionNotes != null) 'notes': resolutionNotes,
      };
       final response = await _apiClient.post(
          ApiConstants.abuseReportResolve(reportId),
          data: payload,
       );
       return AbuseReportModel.fromJson(response.data);
  }

   @override
  Future<AbuseReportModel> updateAbuseReportNotes({required String reportId, required String notes}) async {
       Log.d('FeedbackRemoteDataSource: Calling update abuse report notes API (Admin).');
       // Use PATCH to update notes
       final response = await _apiClient.patch(
           ApiConstants.abuseReportDetail(reportId),
           data: {'notes': notes},
       );
        return AbuseReportModel.fromJson(response.data);
  }

}

