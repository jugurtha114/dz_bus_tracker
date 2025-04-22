// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'abuse_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AbuseReportModel _$AbuseReportModelFromJson(Map<String, dynamic> json) {
  return _AbuseReportModel.fromJson(json);
}

/// @nodoc
mixin _$AbuseReportModel {
  /// Unique identifier for the abuse report (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the user who submitted the report. Matches API 'reporter'. Required.
  String get reporter => throw _privateConstructorUsedError; // UUID
  /// ID of the user who is the subject of the report. Matches API 'reported_user'. Required.
  @JsonKey(name: 'reported_user')
  String get reportedUser => throw _privateConstructorUsedError; // UUID
  /// The reason provided for the report. Matches API 'reason'. Required.
  /// Uses [AbuseReason.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: AbuseReason.unknown)
  AbuseReason get reason => throw _privateConstructorUsedError;

  /// A detailed description of the issue being reported. Matches API 'description'. Required.
  String get description => throw _privateConstructorUsedError;

  /// The current status of the report. Matches API 'status'. Required.
  /// Uses [AbuseReportStatus.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
  AbuseReportStatus get status => throw _privateConstructorUsedError;

  /// ID of the admin who resolved the report. Matches API 'resolved_by'. Nullable.
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError; // UUID
  /// Timestamp when the report was resolved or dismissed. Matches API 'resolved_at'. Nullable.
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Administrative notes regarding the investigation/resolution. Matches API 'notes'. Nullable.
  String? get notes => throw _privateConstructorUsedError;

  /// Flag indicating if the report record is active. Matches API 'is_active'. Required.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the report was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the report was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested/Display Fields ---
  /// Details of the user who submitted the report. Matches API 'reporter_details'. Required. Read-only.
  @JsonKey(name: 'reporter_details')
  UserModel get reporterDetails => throw _privateConstructorUsedError;

  /// Details of the user who is the subject of the report. Matches API 'reported_user_details'. Required. Read-only.
  @JsonKey(name: 'reported_user_details')
  UserModel get reportedUserDetails => throw _privateConstructorUsedError;

  /// Details of the admin who resolved the report. Matches API 'resolved_by_details'. Nullable. Read-only.
  @JsonKey(name: 'resolved_by_details')
  UserModel? get resolvedByDetails => throw _privateConstructorUsedError;

  /// Display string for the report reason. Matches API 'reason_display'. Nullable. Read-only.
  @JsonKey(name: 'reason_display')
  String? get reasonDisplay => throw _privateConstructorUsedError;

  /// Display string for the report status. Matches API 'status_display'. Nullable. Read-only.
  @JsonKey(name: 'status_display')
  String? get statusDisplay => throw _privateConstructorUsedError;

  /// Serializes this AbuseReportModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AbuseReportModelCopyWith<AbuseReportModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AbuseReportModelCopyWith<$Res> {
  factory $AbuseReportModelCopyWith(
          AbuseReportModel value, $Res Function(AbuseReportModel) then) =
      _$AbuseReportModelCopyWithImpl<$Res, AbuseReportModel>;
  @useResult
  $Res call(
      {String id,
      String reporter,
      @JsonKey(name: 'reported_user') String reportedUser,
      @JsonKey(unknownEnumValue: AbuseReason.unknown) AbuseReason reason,
      String description,
      @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
      AbuseReportStatus status,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      String? notes,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'reporter_details') UserModel reporterDetails,
      @JsonKey(name: 'reported_user_details') UserModel reportedUserDetails,
      @JsonKey(name: 'resolved_by_details') UserModel? resolvedByDetails,
      @JsonKey(name: 'reason_display') String? reasonDisplay,
      @JsonKey(name: 'status_display') String? statusDisplay});

  $UserModelCopyWith<$Res> get reporterDetails;
  $UserModelCopyWith<$Res> get reportedUserDetails;
  $UserModelCopyWith<$Res>? get resolvedByDetails;
}

/// @nodoc
class _$AbuseReportModelCopyWithImpl<$Res, $Val extends AbuseReportModel>
    implements $AbuseReportModelCopyWith<$Res> {
  _$AbuseReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporter = null,
    Object? reportedUser = null,
    Object? reason = null,
    Object? description = null,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? reporterDetails = null,
    Object? reportedUserDetails = null,
    Object? resolvedByDetails = freezed,
    Object? reasonDisplay = freezed,
    Object? statusDisplay = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reporter: null == reporter
          ? _value.reporter
          : reporter // ignore: cast_nullable_to_non_nullable
              as String,
      reportedUser: null == reportedUser
          ? _value.reportedUser
          : reportedUser // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as AbuseReason,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AbuseReportStatus,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reporterDetails: null == reporterDetails
          ? _value.reporterDetails
          : reporterDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      reportedUserDetails: null == reportedUserDetails
          ? _value.reportedUserDetails
          : reportedUserDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      resolvedByDetails: freezed == resolvedByDetails
          ? _value.resolvedByDetails
          : resolvedByDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      reasonDisplay: freezed == reasonDisplay
          ? _value.reasonDisplay
          : reasonDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      statusDisplay: freezed == statusDisplay
          ? _value.statusDisplay
          : statusDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get reporterDetails {
    return $UserModelCopyWith<$Res>(_value.reporterDetails, (value) {
      return _then(_value.copyWith(reporterDetails: value) as $Val);
    });
  }

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get reportedUserDetails {
    return $UserModelCopyWith<$Res>(_value.reportedUserDetails, (value) {
      return _then(_value.copyWith(reportedUserDetails: value) as $Val);
    });
  }

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get resolvedByDetails {
    if (_value.resolvedByDetails == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.resolvedByDetails!, (value) {
      return _then(_value.copyWith(resolvedByDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AbuseReportModelImplCopyWith<$Res>
    implements $AbuseReportModelCopyWith<$Res> {
  factory _$$AbuseReportModelImplCopyWith(_$AbuseReportModelImpl value,
          $Res Function(_$AbuseReportModelImpl) then) =
      __$$AbuseReportModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String reporter,
      @JsonKey(name: 'reported_user') String reportedUser,
      @JsonKey(unknownEnumValue: AbuseReason.unknown) AbuseReason reason,
      String description,
      @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
      AbuseReportStatus status,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      String? notes,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'reporter_details') UserModel reporterDetails,
      @JsonKey(name: 'reported_user_details') UserModel reportedUserDetails,
      @JsonKey(name: 'resolved_by_details') UserModel? resolvedByDetails,
      @JsonKey(name: 'reason_display') String? reasonDisplay,
      @JsonKey(name: 'status_display') String? statusDisplay});

  @override
  $UserModelCopyWith<$Res> get reporterDetails;
  @override
  $UserModelCopyWith<$Res> get reportedUserDetails;
  @override
  $UserModelCopyWith<$Res>? get resolvedByDetails;
}

/// @nodoc
class __$$AbuseReportModelImplCopyWithImpl<$Res>
    extends _$AbuseReportModelCopyWithImpl<$Res, _$AbuseReportModelImpl>
    implements _$$AbuseReportModelImplCopyWith<$Res> {
  __$$AbuseReportModelImplCopyWithImpl(_$AbuseReportModelImpl _value,
      $Res Function(_$AbuseReportModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporter = null,
    Object? reportedUser = null,
    Object? reason = null,
    Object? description = null,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? reporterDetails = null,
    Object? reportedUserDetails = null,
    Object? resolvedByDetails = freezed,
    Object? reasonDisplay = freezed,
    Object? statusDisplay = freezed,
  }) {
    return _then(_$AbuseReportModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reporter: null == reporter
          ? _value.reporter
          : reporter // ignore: cast_nullable_to_non_nullable
              as String,
      reportedUser: null == reportedUser
          ? _value.reportedUser
          : reportedUser // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as AbuseReason,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AbuseReportStatus,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reporterDetails: null == reporterDetails
          ? _value.reporterDetails
          : reporterDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      reportedUserDetails: null == reportedUserDetails
          ? _value.reportedUserDetails
          : reportedUserDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      resolvedByDetails: freezed == resolvedByDetails
          ? _value.resolvedByDetails
          : resolvedByDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      reasonDisplay: freezed == reasonDisplay
          ? _value.reasonDisplay
          : reasonDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      statusDisplay: freezed == statusDisplay
          ? _value.statusDisplay
          : statusDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AbuseReportModelImpl implements _AbuseReportModel {
  const _$AbuseReportModelImpl(
      {required this.id,
      required this.reporter,
      @JsonKey(name: 'reported_user') required this.reportedUser,
      @JsonKey(unknownEnumValue: AbuseReason.unknown) required this.reason,
      required this.description,
      @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
      required this.status,
      @JsonKey(name: 'resolved_by') this.resolvedBy,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      this.notes,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'reporter_details') required this.reporterDetails,
      @JsonKey(name: 'reported_user_details') required this.reportedUserDetails,
      @JsonKey(name: 'resolved_by_details') this.resolvedByDetails,
      @JsonKey(name: 'reason_display') this.reasonDisplay,
      @JsonKey(name: 'status_display') this.statusDisplay});

  factory _$AbuseReportModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AbuseReportModelImplFromJson(json);

  /// Unique identifier for the abuse report (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the user who submitted the report. Matches API 'reporter'. Required.
  @override
  final String reporter;
// UUID
  /// ID of the user who is the subject of the report. Matches API 'reported_user'. Required.
  @override
  @JsonKey(name: 'reported_user')
  final String reportedUser;
// UUID
  /// The reason provided for the report. Matches API 'reason'. Required.
  /// Uses [AbuseReason.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: AbuseReason.unknown)
  final AbuseReason reason;

  /// A detailed description of the issue being reported. Matches API 'description'. Required.
  @override
  final String description;

  /// The current status of the report. Matches API 'status'. Required.
  /// Uses [AbuseReportStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
  final AbuseReportStatus status;

  /// ID of the admin who resolved the report. Matches API 'resolved_by'. Nullable.
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
// UUID
  /// Timestamp when the report was resolved or dismissed. Matches API 'resolved_at'. Nullable.
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;

  /// Administrative notes regarding the investigation/resolution. Matches API 'notes'. Nullable.
  @override
  final String? notes;

  /// Flag indicating if the report record is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the report was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the report was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested/Display Fields ---
  /// Details of the user who submitted the report. Matches API 'reporter_details'. Required. Read-only.
  @override
  @JsonKey(name: 'reporter_details')
  final UserModel reporterDetails;

  /// Details of the user who is the subject of the report. Matches API 'reported_user_details'. Required. Read-only.
  @override
  @JsonKey(name: 'reported_user_details')
  final UserModel reportedUserDetails;

  /// Details of the admin who resolved the report. Matches API 'resolved_by_details'. Nullable. Read-only.
  @override
  @JsonKey(name: 'resolved_by_details')
  final UserModel? resolvedByDetails;

  /// Display string for the report reason. Matches API 'reason_display'. Nullable. Read-only.
  @override
  @JsonKey(name: 'reason_display')
  final String? reasonDisplay;

  /// Display string for the report status. Matches API 'status_display'. Nullable. Read-only.
  @override
  @JsonKey(name: 'status_display')
  final String? statusDisplay;

  @override
  String toString() {
    return 'AbuseReportModel(id: $id, reporter: $reporter, reportedUser: $reportedUser, reason: $reason, description: $description, status: $status, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, notes: $notes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, reporterDetails: $reporterDetails, reportedUserDetails: $reportedUserDetails, resolvedByDetails: $resolvedByDetails, reasonDisplay: $reasonDisplay, statusDisplay: $statusDisplay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AbuseReportModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reporter, reporter) ||
                other.reporter == reporter) &&
            (identical(other.reportedUser, reportedUser) ||
                other.reportedUser == reportedUser) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.reporterDetails, reporterDetails) ||
                other.reporterDetails == reporterDetails) &&
            (identical(other.reportedUserDetails, reportedUserDetails) ||
                other.reportedUserDetails == reportedUserDetails) &&
            (identical(other.resolvedByDetails, resolvedByDetails) ||
                other.resolvedByDetails == resolvedByDetails) &&
            (identical(other.reasonDisplay, reasonDisplay) ||
                other.reasonDisplay == reasonDisplay) &&
            (identical(other.statusDisplay, statusDisplay) ||
                other.statusDisplay == statusDisplay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reporter,
      reportedUser,
      reason,
      description,
      status,
      resolvedBy,
      resolvedAt,
      notes,
      isActive,
      createdAt,
      updatedAt,
      reporterDetails,
      reportedUserDetails,
      resolvedByDetails,
      reasonDisplay,
      statusDisplay);

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AbuseReportModelImplCopyWith<_$AbuseReportModelImpl> get copyWith =>
      __$$AbuseReportModelImplCopyWithImpl<_$AbuseReportModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AbuseReportModelImplToJson(
      this,
    );
  }
}

abstract class _AbuseReportModel implements AbuseReportModel {
  const factory _AbuseReportModel(
      {required final String id,
      required final String reporter,
      @JsonKey(name: 'reported_user') required final String reportedUser,
      @JsonKey(unknownEnumValue: AbuseReason.unknown)
      required final AbuseReason reason,
      required final String description,
      @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
      required final AbuseReportStatus status,
      @JsonKey(name: 'resolved_by') final String? resolvedBy,
      @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
      final String? notes,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'reporter_details')
      required final UserModel reporterDetails,
      @JsonKey(name: 'reported_user_details')
      required final UserModel reportedUserDetails,
      @JsonKey(name: 'resolved_by_details') final UserModel? resolvedByDetails,
      @JsonKey(name: 'reason_display') final String? reasonDisplay,
      @JsonKey(name: 'status_display')
      final String? statusDisplay}) = _$AbuseReportModelImpl;

  factory _AbuseReportModel.fromJson(Map<String, dynamic> json) =
      _$AbuseReportModelImpl.fromJson;

  /// Unique identifier for the abuse report (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the user who submitted the report. Matches API 'reporter'. Required.
  @override
  String get reporter; // UUID
  /// ID of the user who is the subject of the report. Matches API 'reported_user'. Required.
  @override
  @JsonKey(name: 'reported_user')
  String get reportedUser; // UUID
  /// The reason provided for the report. Matches API 'reason'. Required.
  /// Uses [AbuseReason.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: AbuseReason.unknown)
  AbuseReason get reason;

  /// A detailed description of the issue being reported. Matches API 'description'. Required.
  @override
  String get description;

  /// The current status of the report. Matches API 'status'. Required.
  /// Uses [AbuseReportStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
  AbuseReportStatus get status;

  /// ID of the admin who resolved the report. Matches API 'resolved_by'. Nullable.
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy; // UUID
  /// Timestamp when the report was resolved or dismissed. Matches API 'resolved_at'. Nullable.
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;

  /// Administrative notes regarding the investigation/resolution. Matches API 'notes'. Nullable.
  @override
  String? get notes;

  /// Flag indicating if the report record is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the report was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the report was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested/Display Fields ---
  /// Details of the user who submitted the report. Matches API 'reporter_details'. Required. Read-only.
  @override
  @JsonKey(name: 'reporter_details')
  UserModel get reporterDetails;

  /// Details of the user who is the subject of the report. Matches API 'reported_user_details'. Required. Read-only.
  @override
  @JsonKey(name: 'reported_user_details')
  UserModel get reportedUserDetails;

  /// Details of the admin who resolved the report. Matches API 'resolved_by_details'. Nullable. Read-only.
  @override
  @JsonKey(name: 'resolved_by_details')
  UserModel? get resolvedByDetails;

  /// Display string for the report reason. Matches API 'reason_display'. Nullable. Read-only.
  @override
  @JsonKey(name: 'reason_display')
  String? get reasonDisplay;

  /// Display string for the report status. Matches API 'status_display'. Nullable. Read-only.
  @override
  @JsonKey(name: 'status_display')
  String? get statusDisplay;

  /// Create a copy of AbuseReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AbuseReportModelImplCopyWith<_$AbuseReportModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
