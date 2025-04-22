/// lib/domain/entities/abuse_report_entity.dart

import 'package:equatable/equatable.dart';

import '../../core/enums/abuse_reason.dart';
import '../../core/enums/abuse_report_status.dart';
import 'user_entity.dart';

/// Represents the core Abuse Report entity within the application domain.
///
/// Contains details about a report filed against potentially problematic behavior.
class AbuseReportEntity extends Equatable {
  /// Unique identifier for the abuse report (UUID).
  final String id;

  /// Details of the user who submitted the report. Null if reported anonymously.
  final UserEntity? reporterDetails;

  /// Details of the user who is the subject of the report. Null if reported entity is not a user.
  final UserEntity? reportedUserDetails;

  /// The reason provided for the report (e.g., harassment, spam). Required.
  final AbuseReason reason;

  /// A detailed description of the issue being reported. Required.
  final String description;

  /// The current status of the report (e.g., pending, investigating, resolved). Required.
  final AbuseReportStatus status;

  /// Details of the admin or staff member who resolved the report. Null if not resolved or resolved automatically.
  final UserEntity? resolvedByDetails;

  /// Timestamp when the report was marked as resolved or dismissed. Null otherwise.
  final DateTime? resolvedAt;

  /// Administrative notes regarding the investigation or resolution. Optional.
  final String? notes;

  /// Flag indicating if the report record is active.
  final bool isActive;

  /// Timestamp when the report record was created.
  final DateTime createdAt;

  /// Timestamp when the report record was last updated.
  final DateTime updatedAt;

  /// Creates an [AbuseReportEntity] instance.
  const AbuseReportEntity({
    required this.id,
    this.reporterDetails,
    this.reportedUserDetails,
    required this.reason,
    required this.description,
    required this.status,
    this.resolvedByDetails,
    this.resolvedAt,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience getter for the reporter's user ID, if available.
  String? get reporterId => reporterDetails?.id;

  /// Convenience getter for the reported user's ID, if available.
  String? get reportedUserId => reportedUserDetails?.id;

  /// Convenience getter for the resolving user's ID, if available.
  String? get resolvedById => resolvedByDetails?.id;

  @override
  List<Object?> get props => [
        id,
        reporterDetails,
        reportedUserDetails,
        reason,
        description,
        status,
        resolvedByDetails,
        resolvedAt,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Creates an empty AbuseReportEntity, useful for default states or placeholders.
  static AbuseReportEntity empty() => AbuseReportEntity(
        id: '',
        reason: AbuseReason.unknown,
        description: '',
        status: AbuseReportStatus.unknown,
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
        // reporterDetails, reportedUserDetails, resolvedByDetails default to null
      );
}
