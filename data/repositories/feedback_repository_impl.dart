/// lib/data/repositories/feedback_repository_impl.dart

import 'package:collection/collection.dart'; // For mapNotNull
import 'package:dartz/dartz.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/abuse_reason.dart';
import '../../../core/enums/abuse_report_status.dart';
import '../../../core/enums/feedback_status.dart';
import '../../../core/enums/feedback_type.dart';
import '../../../core/enums/language.dart'; // Needed for user mapping
import '../../../core/enums/user_type.dart'; // Needed for user mapping
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/typedefs/common_types.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/abuse_report_entity.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/entities/user_entity.dart'; // Needed for mapping
import '../../domain/repositories/feedback_repository.dart';
import '../data_sources/remote/feedback_remote_data_source.dart';
import '../models/abuse_report_model.dart';
import '../models/api_response.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart'; // Needed for mapping

/// Implementation of the [FeedbackRepository] interface.
///
/// Orchestrates feedback and abuse report operations by interacting with the remote
/// data source, handling network status checks, and mapping data/exceptions between layers.
class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Creates an instance of [FeedbackRepositoryImpl].
  const FeedbackRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  /// Checks connectivity and handles common exceptions, mapping them to Failures.
  Future<Either<Failure, T>> _performNetworkOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await operation();
        return Right(result);
      } on AuthenticationException catch (e) {
        Log.w('AuthenticationException caught in FeedbackRepository', error: e);
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in FeedbackRepository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        Log.e('ServerException caught in FeedbackRepository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('NetworkException caught in FeedbackRepository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
        Log.e('DataParsingException caught in FeedbackRepository', error: e);
        return Left(DataParsingFailure(message: e.message, code: e.code));
      } catch (e, stackTrace) {
        Log.e('Unexpected exception caught in FeedbackRepository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('FeedbackRepository: Network operation skipped. No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  // --- Feedback Methods ---

  @override
  Future<Either<Failure, FeedbackEntity>> submitFeedback({
    required FeedbackType type,
    required String subject,
    required String message,
    String? contactInfo,
  }) async {
    return _performNetworkOperation(() async {
      final model = await remoteDataSource.submitFeedback(
        type: type,
        subject: subject,
        message: message,
        contactInfo: contactInfo,
      );
      return _mapFeedbackModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<FeedbackEntity>>> getMyFeedback({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  }) async {
     return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getMyFeedback(page: page, pageSize: pageSize);
        return _mapApiResponseToPaginatedList<FeedbackModel, FeedbackEntity>(
            apiResponse, _mapFeedbackModelToEntity);
     });
  }

   @override
  Future<Either<Failure, FeedbackEntity>> getFeedbackDetails(String feedbackId) async {
     return _performNetworkOperation(() async {
        final model = await remoteDataSource.getFeedbackDetails(feedbackId);
        return _mapFeedbackModelToEntity(model);
     });
  }

  // --- Abuse Report Methods ---

   @override
  Future<Either<Failure, AbuseReportEntity>> submitAbuseReport({
    required String reportedUserId,
    required AbuseReason reason,
    required String description,
  }) async {
     return _performNetworkOperation(() async {
        final model = await remoteDataSource.submitAbuseReport(
            reportedUserId: reportedUserId, reason: reason, description: description);
        return _mapAbuseReportModelToEntity(model);
     });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<AbuseReportEntity>>> getMyAbuseReports({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  }) async {
      return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getMyAbuseReports(page: page, pageSize: pageSize);
        return _mapApiResponseToPaginatedList<AbuseReportModel, AbuseReportEntity>(
            apiResponse, _mapAbuseReportModelToEntity);
     });
  }

  @override
  Future<Either<Failure, AbuseReportEntity>> getAbuseReportDetails(String reportId) async {
      return _performNetworkOperation(() async {
        final model = await remoteDataSource.getAbuseReportDetails(reportId);
        return _mapAbuseReportModelToEntity(model);
     });
  }

  // --- Admin Methods ---

  @override
  Future<Either<Failure, PaginatedListEntity<FeedbackEntity>>> getAllFeedback({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
    FeedbackStatus? status,
    String? assignedToId,
    String? searchQuery,
  }) async {
     return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getAllFeedback(
            page: page, pageSize: pageSize, status: status, assignedToId: assignedToId, searchQuery: searchQuery);
        return _mapApiResponseToPaginatedList<FeedbackModel, FeedbackEntity>(
            apiResponse, _mapFeedbackModelToEntity);
     });
  }

  @override
  Future<Either<Failure, FeedbackEntity>> updateFeedbackStatus({required String feedbackId, required FeedbackStatus newStatus}) async {
      return _performNetworkOperation(() async {
        final model = await remoteDataSource.updateFeedbackStatus(feedbackId: feedbackId, newStatus: newStatus);
        return _mapFeedbackModelToEntity(model);
     });
  }

  @override
  Future<Either<Failure, FeedbackEntity>> assignFeedback({required String feedbackId, required String adminUserId}) async {
     return _performNetworkOperation(() async {
        final model = await remoteDataSource.assignFeedback(feedbackId: feedbackId, adminUserId: adminUserId);
        return _mapFeedbackModelToEntity(model);
     });
  }

  @override
  Future<Either<Failure, FeedbackEntity>> respondToFeedback({required String feedbackId, required String responseMessage}) async {
     return _performNetworkOperation(() async {
        final model = await remoteDataSource.respondToFeedback(feedbackId: feedbackId, responseMessage: responseMessage);
        return _mapFeedbackModelToEntity(model);
     });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<AbuseReportEntity>>> getAllAbuseReports({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
    AbuseReportStatus? status,
    String? reporterId,
    String? reportedUserId,
  }) async {
       return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getAllAbuseReports(
            page: page, pageSize: pageSize, status: status, reporterId: reporterId, reportedUserId: reportedUserId);
        return _mapApiResponseToPaginatedList<AbuseReportModel, AbuseReportEntity>(
            apiResponse, _mapAbuseReportModelToEntity);
     });
  }

  @override
  Future<Either<Failure, AbuseReportEntity>> resolveAbuseReport({required String reportId, required AbuseReportStatus finalStatus, String? resolutionNotes}) async {
     return _performNetworkOperation(() async {
        final model = await remoteDataSource.resolveAbuseReport(reportId: reportId, finalStatus: finalStatus, resolutionNotes: resolutionNotes);
        return _mapAbuseReportModelToEntity(model);
     });
  }

  @override
  Future<Either<Failure, AbuseReportEntity>> updateAbuseReportNotes({required String reportId, required String notes}) async {
     return _performNetworkOperation(() async {
        final model = await remoteDataSource.updateAbuseReportNotes(reportId: reportId, notes: notes);
        return _mapAbuseReportModelToEntity(model);
     });
  }


  // --- Helper Mappers ---

  /// Maps an [ApiResponse] DTO to a [PaginatedListEntity] domain object.
  PaginatedListEntity<E> _mapApiResponseToPaginatedList<M, E>(
      ApiResponse<M> apiResponse, E Function(M model) mapper) {
    return PaginatedListEntity<E>(
      items: apiResponse.results.map(mapper).toList(),
      totalCount: apiResponse.count,
      hasMore: apiResponse.next != null,
    );
  }

  /// Maps a [FeedbackModel] DTO to a [FeedbackEntity] domain object.
  FeedbackEntity _mapFeedbackModelToEntity(FeedbackModel model) {
    return FeedbackEntity(
      id: model.id,
      // User details can be null if reporter is anonymous or deleted
      userDetails: model.userDetails != null ? _mapUserModelToEntity(model.userDetails!) : null,
      type: model.type,
      subject: model.subject,
      message: model.message,
      contactInfo: model.contactInfo,
      status: model.status,
      // Assigned user details can be null
      assignedToDetails: model.assignedToDetails != null ? _mapUserModelToEntity(model.assignedToDetails!) : null,
      response: model.response,
      resolvedAt: model.resolvedAt,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Maps an [AbuseReportModel] DTO to an [AbuseReportEntity] domain object.
  AbuseReportEntity _mapAbuseReportModelToEntity(AbuseReportModel model) {
    return AbuseReportEntity(
      id: model.id,
      // Reporter/Reported user details can be null if user deleted
      reporterDetails: model.reporterDetails != null ? _mapUserModelToEntity(model.reporterDetails!) : null,
      reportedUserDetails: model.reportedUserDetails != null ? _mapUserModelToEntity(model.reportedUserDetails!) : null,
      reason: model.reason,
      description: model.description,
      status: model.status,
      // Resolved by user details can be null
      resolvedByDetails: model.resolvedByDetails != null ? _mapUserModelToEntity(model.resolvedByDetails!) : null,
      resolvedAt: model.resolvedAt,
      notes: model.notes,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Simple mapper from [UserModel] (Data Layer) to [UserEntity] (Domain Layer).
  /// Copied from AuthRepositoryImpl - consider centralizing mappers later.
  UserEntity _mapUserModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      phoneNumber: model.phoneNumber,
      userType: model.userType,
      language: model.language,
      isActive: model.isActive,
      isEmailVerified: model.isEmailVerified,
      isPhoneVerified: model.isPhoneVerified,
      dateJoined: model.dateJoined,
      lastLogin: model.lastLogin,
    );
  }
}
