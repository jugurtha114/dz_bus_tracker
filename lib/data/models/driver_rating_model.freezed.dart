// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverRatingModel _$DriverRatingModelFromJson(Map<String, dynamic> json) {
  return _DriverRatingModel.fromJson(json);
}

/// @nodoc
mixin _$DriverRatingModel {
  /// Unique identifier for the rating record (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the driver who received the rating. Matches API 'driver'. Required.
  String get driver => throw _privateConstructorUsedError; // UUID
  /// ID of the user who submitted the rating. Matches API 'user'. Required.
  String get user => throw _privateConstructorUsedError; // UUID
  /// The numerical rating given (e.g., 1-5). Matches API 'rating'. Required.
  /// API Schema shows minimum: 1, maximum: 5.
  int get rating => throw _privateConstructorUsedError;

  /// Optional comment provided with the rating. Matches API 'comment'. Nullable.
  String? get comment => throw _privateConstructorUsedError;

  /// Timestamp when the rating was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the rating record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested Field ---
  /// Details of the user who submitted the rating. Matches API 'user_details'. Nullable (API says required, making nullable for robustness). Read-only.
  @JsonKey(name: 'user_details')
  UserModel? get userDetails => throw _privateConstructorUsedError;

  /// Serializes this DriverRatingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverRatingModelCopyWith<DriverRatingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverRatingModelCopyWith<$Res> {
  factory $DriverRatingModelCopyWith(
          DriverRatingModel value, $Res Function(DriverRatingModel) then) =
      _$DriverRatingModelCopyWithImpl<$Res, DriverRatingModel>;
  @useResult
  $Res call(
      {String id,
      String driver,
      String user,
      int rating,
      String? comment,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'user_details') UserModel? userDetails});

  $UserModelCopyWith<$Res>? get userDetails;
}

/// @nodoc
class _$DriverRatingModelCopyWithImpl<$Res, $Val extends DriverRatingModel>
    implements $DriverRatingModelCopyWith<$Res> {
  _$DriverRatingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? user = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userDetails = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userDetails: freezed == userDetails
          ? _value.userDetails
          : userDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  /// Create a copy of DriverRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get userDetails {
    if (_value.userDetails == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.userDetails!, (value) {
      return _then(_value.copyWith(userDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DriverRatingModelImplCopyWith<$Res>
    implements $DriverRatingModelCopyWith<$Res> {
  factory _$$DriverRatingModelImplCopyWith(_$DriverRatingModelImpl value,
          $Res Function(_$DriverRatingModelImpl) then) =
      __$$DriverRatingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driver,
      String user,
      int rating,
      String? comment,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'user_details') UserModel? userDetails});

  @override
  $UserModelCopyWith<$Res>? get userDetails;
}

/// @nodoc
class __$$DriverRatingModelImplCopyWithImpl<$Res>
    extends _$DriverRatingModelCopyWithImpl<$Res, _$DriverRatingModelImpl>
    implements _$$DriverRatingModelImplCopyWith<$Res> {
  __$$DriverRatingModelImplCopyWithImpl(_$DriverRatingModelImpl _value,
      $Res Function(_$DriverRatingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? user = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userDetails = freezed,
  }) {
    return _then(_$DriverRatingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userDetails: freezed == userDetails
          ? _value.userDetails
          : userDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverRatingModelImpl implements _DriverRatingModel {
  const _$DriverRatingModelImpl(
      {required this.id,
      required this.driver,
      required this.user,
      required this.rating,
      this.comment,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'user_details') this.userDetails});

  factory _$DriverRatingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverRatingModelImplFromJson(json);

  /// Unique identifier for the rating record (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the driver who received the rating. Matches API 'driver'. Required.
  @override
  final String driver;
// UUID
  /// ID of the user who submitted the rating. Matches API 'user'. Required.
  @override
  final String user;
// UUID
  /// The numerical rating given (e.g., 1-5). Matches API 'rating'. Required.
  /// API Schema shows minimum: 1, maximum: 5.
  @override
  final int rating;

  /// Optional comment provided with the rating. Matches API 'comment'. Nullable.
  @override
  final String? comment;

  /// Timestamp when the rating was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the rating record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested Field ---
  /// Details of the user who submitted the rating. Matches API 'user_details'. Nullable (API says required, making nullable for robustness). Read-only.
  @override
  @JsonKey(name: 'user_details')
  final UserModel? userDetails;

  @override
  String toString() {
    return 'DriverRatingModel(id: $id, driver: $driver, user: $user, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, userDetails: $userDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverRatingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userDetails, userDetails) ||
                other.userDetails == userDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, driver, user, rating,
      comment, createdAt, updatedAt, userDetails);

  /// Create a copy of DriverRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverRatingModelImplCopyWith<_$DriverRatingModelImpl> get copyWith =>
      __$$DriverRatingModelImplCopyWithImpl<_$DriverRatingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverRatingModelImplToJson(
      this,
    );
  }
}

abstract class _DriverRatingModel implements DriverRatingModel {
  const factory _DriverRatingModel(
          {required final String id,
          required final String driver,
          required final String user,
          required final int rating,
          final String? comment,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt,
          @JsonKey(name: 'user_details') final UserModel? userDetails}) =
      _$DriverRatingModelImpl;

  factory _DriverRatingModel.fromJson(Map<String, dynamic> json) =
      _$DriverRatingModelImpl.fromJson;

  /// Unique identifier for the rating record (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the driver who received the rating. Matches API 'driver'. Required.
  @override
  String get driver; // UUID
  /// ID of the user who submitted the rating. Matches API 'user'. Required.
  @override
  String get user; // UUID
  /// The numerical rating given (e.g., 1-5). Matches API 'rating'. Required.
  /// API Schema shows minimum: 1, maximum: 5.
  @override
  int get rating;

  /// Optional comment provided with the rating. Matches API 'comment'. Nullable.
  @override
  String? get comment;

  /// Timestamp when the rating was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the rating record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested Field ---
  /// Details of the user who submitted the rating. Matches API 'user_details'. Nullable (API says required, making nullable for robustness). Read-only.
  @override
  @JsonKey(name: 'user_details')
  UserModel? get userDetails;

  /// Create a copy of DriverRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverRatingModelImplCopyWith<_$DriverRatingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
