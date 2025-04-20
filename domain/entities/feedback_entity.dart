/// lib/domain/entities/feedback_entity.dart

import 'package:equatable/equatable.dart';

import '../../core/enums/feedback_status.dart';
import '../../core/enums/feedback_type.dart';
import 'user_entity.dart'; // Import the User entity

/// Represents the core Feedback entity within the application domain.
///
/// Contains details about feedback submitted by a user or associated administrative actions.
class FeedbackEntity extends Equatable {
  /// Unique identifier for the feedback record (UUID).
  final String id;

  /// Details of the user who submitted the feedback. Null if submitted anonymously.
  final UserEntity? userDetails;

  /// The type or category of the feedback (e.g., bug, feature, complaint). Required.
  final FeedbackType type;

  /// The subject line of the feedback submission. Required.
  final String subject;

  /// The main content or message of the feedback. Required.
  final String message;

  /// Optional contact information provided by the submitter.
  final String? contactInfo;

  /// The current status of the feedback (e.g., new, in_progress, resolved). Required.
  final FeedbackStatus status;

  /// Details of the admin or staff member assigned to handle this feedback. Null if unassigned.
  final UserEntity? assignedToDetails;

  /// The official response provided regarding the feedback. Optional.
  final String? response;

  /// Timestamp when the feedback was marked as resolved. Null if not resolved.
  final DateTime? resolvedAt;

  /// Flag indicating if the feedback record is active.
  final bool isActive;

  /// Timestamp when the feedback record was created.
  final DateTime createdAt;

  /// Timestamp when the feedback record was last updated.
  final DateTime updatedAt;

  /// Creates a [FeedbackEntity] instance.
  const FeedbackEntity({
    required this.id,
    this.userDetails, // User can be null
    required this.type,
    required this.subject,
    required this.message,
    this.contactInfo,
    required this.status,
    this.assignedToDetails, // Can be null
    this.response,
    this.resolvedAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience getter for the submitting user's ID, if available.
  String? get userId => userDetails?.id;

  /// Convenience getter for the assigned user's ID, if available.
  String? get assignedToId => assignedToDetails?.id;

  @override
  List<Object?> get props => [
        id,
        userDetails,
        type,
        subject,
        message,
        contactInfo,
        status,
        assignedToDetails,
        response,
        resolvedAt,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Creates an empty FeedbackEntity, useful for default states or placeholders.
  static FeedbackEntity empty() => FeedbackEntity(
        id: '',
        type: FeedbackType.unknown,
        subject: '',
        message: '',
        status: FeedbackStatus.unknown,
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
        // userDetails and assignedToDetails default to null
      );
}
