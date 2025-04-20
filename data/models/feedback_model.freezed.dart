// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedbackModel _$FeedbackModelFromJson(Map<String, dynamic> json) {
  return _FeedbackModel.fromJson(json);
}

/// @nodoc
mixin _$FeedbackModel {
  /// Unique identifier for the feedback record (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the user who submitted the feedback. Matches API 'user'. Required.
  String get user => throw _privateConstructorUsedError; // UUID
  /// The type or category of the feedback. Matches API 'type'. Required.
  /// Uses [FeedbackType.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: FeedbackType.unknown)
  FeedbackType get type => throw _privateConstructorUsedError;

  /// The subject line of the feedback. Matches API 'subject'. Required.
  String get subject => throw _privateConstructorUsedError;

  /// The main content or message of the feedback. Matches API 'message'. Required.
  String get message => throw _privateConstructorUsedError;

  /// Optional contact information provided by the submitter. Matches API 'contact_info'. Nullable.
  @JsonKey(name: 'contact_info')
  String? get contactInfo => throw _privateConstructorUsedError;

  /// The current status of the feedback. Matches API 'status'. Required.
  /// Uses [FeedbackStatus.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: FeedbackStatus.unknown)
  FeedbackStatus get status => throw _privateConstructorUsedError;

  /// ID of the admin/staff assigned to handle this feedback. Matches API 'assigned_to'. Nullable.
  @JsonKey(name: 'assigned_to')
  String? get assignedTo => throw _privateConstructorUsedError; // UUID
  /// The official response provided. Matches API 'response'. Nullable.
  String? get response => throw _privateConstructorUsedError;

  /// Timestamp when the feedback was marked as resolved. Matches API 'resolved_at'. Nullable.
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Flag indicating if the feedback record is active. Matches API 'is_active'. Required.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the feedback was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the feedback was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested/Display Fields ---
  /// Details of the user who submitted the feedback. Matches API 'user_details'. Required. Read-only.
  @JsonKey(name: 'user_details')
  UserModel get userDetails => throw _privateConstructorUsedError;

  /// Details of the user assigned to handle the feedback. Matches API 'assigned_to_details'. Nullable. Read-only.
  @JsonKey(name: 'assigned_to_details')
  UserModel? get assignedToDetails => throw _privateConstructorUsedError;

  /// Display string for the feedback type. Matches API 'type_display'. Read-only.
  @JsonKey(name: 'type_display')
  String? get typeDisplay => throw _privateConstructorUsedError;

  /// Display string for the feedback status. Matches API 'status_display'. Read-only.
  @JsonKey(name: 'status_display')
  String? get statusDisplay => throw _privateConstructorUsedError;

  /// Serializes this FeedbackModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackModelCopyWith<FeedbackModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackModelCopyWith<$Res> {
  factory $FeedbackModelCopyWith(
          FeedbackModel value, $Res Function(FeedbackModel) then) =
      _$FeedbackModelCopyWithImpl<$Res, FeedbackModel>;
  @useResult
  $Res call(
      {String id,
      String user,
      @JsonKey(unknownEnumValue: FeedbackType.unknown) FeedbackType type,
      String subject,
      String message,
      @JsonKey(name: 'contact_info') String? contactInfo,
      @JsonKey(unknownEnumValue: FeedbackStatus.unknown) FeedbackStatus status,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      String? response,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'user_details') UserModel userDetails,
      @JsonKey(name: 'assigned_to_details') UserModel? assignedToDetails,
      @JsonKey(name: 'type_display') String? typeDisplay,
      @JsonKey(name: 'status_display') String? statusDisplay});

  $UserModelCopyWith<$Res> get userDetails;
  $UserModelCopyWith<$Res>? get assignedToDetails;
}

/// @nodoc
class _$FeedbackModelCopyWithImpl<$Res, $Val extends FeedbackModel>
    implements $FeedbackModelCopyWith<$Res> {
  _$FeedbackModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? type = null,
    Object? subject = null,
    Object? message = null,
    Object? contactInfo = freezed,
    Object? status = null,
    Object? assignedTo = freezed,
    Object? response = freezed,
    Object? resolvedAt = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userDetails = null,
    Object? assignedToDetails = freezed,
    Object? typeDisplay = freezed,
    Object? statusDisplay = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      contactInfo: freezed == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeedbackStatus,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      response: freezed == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      userDetails: null == userDetails
          ? _value.userDetails
          : userDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      assignedToDetails: freezed == assignedToDetails
          ? _value.assignedToDetails
          : assignedToDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      typeDisplay: freezed == typeDisplay
          ? _value.typeDisplay
          : typeDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
      statusDisplay: freezed == statusDisplay
          ? _value.statusDisplay
          : statusDisplay // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get userDetails {
    return $UserModelCopyWith<$Res>(_value.userDetails, (value) {
      return _then(_value.copyWith(userDetails: value) as $Val);
    });
  }

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get assignedToDetails {
    if (_value.assignedToDetails == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.assignedToDetails!, (value) {
      return _then(_value.copyWith(assignedToDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedbackModelImplCopyWith<$Res>
    implements $FeedbackModelCopyWith<$Res> {
  factory _$$FeedbackModelImplCopyWith(
          _$FeedbackModelImpl value, $Res Function(_$FeedbackModelImpl) then) =
      __$$FeedbackModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String user,
      @JsonKey(unknownEnumValue: FeedbackType.unknown) FeedbackType type,
      String subject,
      String message,
      @JsonKey(name: 'contact_info') String? contactInfo,
      @JsonKey(unknownEnumValue: FeedbackStatus.unknown) FeedbackStatus status,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      String? response,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'user_details') UserModel userDetails,
      @JsonKey(name: 'assigned_to_details') UserModel? assignedToDetails,
      @JsonKey(name: 'type_display') String? typeDisplay,
      @JsonKey(name: 'status_display') String? statusDisplay});

  @override
  $UserModelCopyWith<$Res> get userDetails;
  @override
  $UserModelCopyWith<$Res>? get assignedToDetails;
}

/// @nodoc
class __$$FeedbackModelImplCopyWithImpl<$Res>
    extends _$FeedbackModelCopyWithImpl<$Res, _$FeedbackModelImpl>
    implements _$$FeedbackModelImplCopyWith<$Res> {
  __$$FeedbackModelImplCopyWithImpl(
      _$FeedbackModelImpl _value, $Res Function(_$FeedbackModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? type = null,
    Object? subject = null,
    Object? message = null,
    Object? contactInfo = freezed,
    Object? status = null,
    Object? assignedTo = freezed,
    Object? response = freezed,
    Object? resolvedAt = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userDetails = null,
    Object? assignedToDetails = freezed,
    Object? typeDisplay = freezed,
    Object? statusDisplay = freezed,
  }) {
    return _then(_$FeedbackModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      contactInfo: freezed == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeedbackStatus,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      response: freezed == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      userDetails: null == userDetails
          ? _value.userDetails
          : userDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      assignedToDetails: freezed == assignedToDetails
          ? _value.assignedToDetails
          : assignedToDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      typeDisplay: freezed == typeDisplay
          ? _value.typeDisplay
          : typeDisplay // ignore: cast_nullable_to_non_nullable
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
class _$FeedbackModelImpl implements _FeedbackModel {
  const _$FeedbackModelImpl(
      {required this.id,
      required this.user,
      @JsonKey(unknownEnumValue: FeedbackType.unknown) required this.type,
      required this.subject,
      required this.message,
      @JsonKey(name: 'contact_info') this.contactInfo,
      @JsonKey(unknownEnumValue: FeedbackStatus.unknown) required this.status,
      @JsonKey(name: 'assigned_to') this.assignedTo,
      this.response,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'user_details') required this.userDetails,
      @JsonKey(name: 'assigned_to_details') this.assignedToDetails,
      @JsonKey(name: 'type_display') this.typeDisplay,
      @JsonKey(name: 'status_display') this.statusDisplay});

  factory _$FeedbackModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackModelImplFromJson(json);

  /// Unique identifier for the feedback record (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the user who submitted the feedback. Matches API 'user'. Required.
  @override
  final String user;
// UUID
  /// The type or category of the feedback. Matches API 'type'. Required.
  /// Uses [FeedbackType.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: FeedbackType.unknown)
  final FeedbackType type;

  /// The subject line of the feedback. Matches API 'subject'. Required.
  @override
  final String subject;

  /// The main content or message of the feedback. Matches API 'message'. Required.
  @override
  final String message;

  /// Optional contact information provided by the submitter. Matches API 'contact_info'. Nullable.
  @override
  @JsonKey(name: 'contact_info')
  final String? contactInfo;

  /// The current status of the feedback. Matches API 'status'. Required.
  /// Uses [FeedbackStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: FeedbackStatus.unknown)
  final FeedbackStatus status;

  /// ID of the admin/staff assigned to handle this feedback. Matches API 'assigned_to'. Nullable.
  @override
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;
// UUID
  /// The official response provided. Matches API 'response'. Nullable.
  @override
  final String? response;

  /// Timestamp when the feedback was marked as resolved. Matches API 'resolved_at'. Nullable.
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;

  /// Flag indicating if the feedback record is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the feedback was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the feedback was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested/Display Fields ---
  /// Details of the user who submitted the feedback. Matches API 'user_details'. Required. Read-only.
  @override
  @JsonKey(name: 'user_details')
  final UserModel userDetails;

  /// Details of the user assigned to handle the feedback. Matches API 'assigned_to_details'. Nullable. Read-only.
  @override
  @JsonKey(name: 'assigned_to_details')
  final UserModel? assignedToDetails;

  /// Display string for the feedback type. Matches API 'type_display'. Read-only.
  @override
  @JsonKey(name: 'type_display')
  final String? typeDisplay;

  /// Display string for the feedback status. Matches API 'status_display'. Read-only.
  @override
  @JsonKey(name: 'status_display')
  final String? statusDisplay;

  @override
  String toString() {
    return 'FeedbackModel(id: $id, user: $user, type: $type, subject: $subject, message: $message, contactInfo: $contactInfo, status: $status, assignedTo: $assignedTo, response: $response, resolvedAt: $resolvedAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, userDetails: $userDetails, assignedToDetails: $assignedToDetails, typeDisplay: $typeDisplay, statusDisplay: $statusDisplay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.contactInfo, contactInfo) ||
                other.contactInfo == contactInfo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userDetails, userDetails) ||
                other.userDetails == userDetails) &&
            (identical(other.assignedToDetails, assignedToDetails) ||
                other.assignedToDetails == assignedToDetails) &&
            (identical(other.typeDisplay, typeDisplay) ||
                other.typeDisplay == typeDisplay) &&
            (identical(other.statusDisplay, statusDisplay) ||
                other.statusDisplay == statusDisplay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      type,
      subject,
      message,
      contactInfo,
      status,
      assignedTo,
      response,
      resolvedAt,
      isActive,
      createdAt,
      updatedAt,
      userDetails,
      assignedToDetails,
      typeDisplay,
      statusDisplay);

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackModelImplCopyWith<_$FeedbackModelImpl> get copyWith =>
      __$$FeedbackModelImplCopyWithImpl<_$FeedbackModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackModelImplToJson(
      this,
    );
  }
}

abstract class _FeedbackModel implements FeedbackModel {
  const factory _FeedbackModel(
      {required final String id,
      required final String user,
      @JsonKey(unknownEnumValue: FeedbackType.unknown)
      required final FeedbackType type,
      required final String subject,
      required final String message,
      @JsonKey(name: 'contact_info') final String? contactInfo,
      @JsonKey(unknownEnumValue: FeedbackStatus.unknown)
      required final FeedbackStatus status,
      @JsonKey(name: 'assigned_to') final String? assignedTo,
      final String? response,
      @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'user_details') required final UserModel userDetails,
      @JsonKey(name: 'assigned_to_details') final UserModel? assignedToDetails,
      @JsonKey(name: 'type_display') final String? typeDisplay,
      @JsonKey(name: 'status_display')
      final String? statusDisplay}) = _$FeedbackModelImpl;

  factory _FeedbackModel.fromJson(Map<String, dynamic> json) =
      _$FeedbackModelImpl.fromJson;

  /// Unique identifier for the feedback record (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the user who submitted the feedback. Matches API 'user'. Required.
  @override
  String get user; // UUID
  /// The type or category of the feedback. Matches API 'type'. Required.
  /// Uses [FeedbackType.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: FeedbackType.unknown)
  FeedbackType get type;

  /// The subject line of the feedback. Matches API 'subject'. Required.
  @override
  String get subject;

  /// The main content or message of the feedback. Matches API 'message'. Required.
  @override
  String get message;

  /// Optional contact information provided by the submitter. Matches API 'contact_info'. Nullable.
  @override
  @JsonKey(name: 'contact_info')
  String? get contactInfo;

  /// The current status of the feedback. Matches API 'status'. Required.
  /// Uses [FeedbackStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: FeedbackStatus.unknown)
  FeedbackStatus get status;

  /// ID of the admin/staff assigned to handle this feedback. Matches API 'assigned_to'. Nullable.
  @override
  @JsonKey(name: 'assigned_to')
  String? get assignedTo; // UUID
  /// The official response provided. Matches API 'response'. Nullable.
  @override
  String? get response;

  /// Timestamp when the feedback was marked as resolved. Matches API 'resolved_at'. Nullable.
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;

  /// Flag indicating if the feedback record is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the feedback was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the feedback was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested/Display Fields ---
  /// Details of the user who submitted the feedback. Matches API 'user_details'. Required. Read-only.
  @override
  @JsonKey(name: 'user_details')
  UserModel get userDetails;

  /// Details of the user assigned to handle the feedback. Matches API 'assigned_to_details'. Nullable. Read-only.
  @override
  @JsonKey(name: 'assigned_to_details')
  UserModel? get assignedToDetails;

  /// Display string for the feedback type. Matches API 'type_display'. Read-only.
  @override
  @JsonKey(name: 'type_display')
  String? get typeDisplay;

  /// Display string for the feedback status. Matches API 'status_display'. Read-only.
  @override
  @JsonKey(name: 'status_display')
  String? get statusDisplay;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackModelImplCopyWith<_$FeedbackModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
