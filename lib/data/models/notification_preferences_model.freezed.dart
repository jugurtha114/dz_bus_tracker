// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
    Map<String, dynamic> json) {
  return _NotificationPreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferencesModel {
  /// ID of the user these preferences belong to. Matches API 'user'. Required. Read-only.
  String get user => throw _privateConstructorUsedError; // UUID
  /// Enable/disable notifications for updates on favorited lines. Matches API 'favorite_line_updates'.
  @JsonKey(name: 'favorite_line_updates', defaultValue: true)
  bool get favoriteLineUpdates => throw _privateConstructorUsedError;

  /// Enable/disable notifications about service disruptions. Matches API 'service_disruptions'.
  @JsonKey(name: 'service_disruptions', defaultValue: true)
  bool get serviceDisruptions => throw _privateConstructorUsedError;

  /// Enable/disable notifications for general announcements. Matches API 'general_announcements'.
  @JsonKey(name: 'general_announcements', defaultValue: true)
  bool get generalAnnouncements => throw _privateConstructorUsedError;

  /// Enable/disable notifications about new app features. Matches API 'new_features'.
  @JsonKey(name: 'new_features', defaultValue: false)
  bool get newFeatures => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesModelCopyWith<NotificationPreferencesModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesModelCopyWith<$Res> {
  factory $NotificationPreferencesModelCopyWith(
          NotificationPreferencesModel value,
          $Res Function(NotificationPreferencesModel) then) =
      _$NotificationPreferencesModelCopyWithImpl<$Res,
          NotificationPreferencesModel>;
  @useResult
  $Res call(
      {String user,
      @JsonKey(name: 'favorite_line_updates', defaultValue: true)
      bool favoriteLineUpdates,
      @JsonKey(name: 'service_disruptions', defaultValue: true)
      bool serviceDisruptions,
      @JsonKey(name: 'general_announcements', defaultValue: true)
      bool generalAnnouncements,
      @JsonKey(name: 'new_features', defaultValue: false) bool newFeatures});
}

/// @nodoc
class _$NotificationPreferencesModelCopyWithImpl<$Res,
        $Val extends NotificationPreferencesModel>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  _$NotificationPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? favoriteLineUpdates = null,
    Object? serviceDisruptions = null,
    Object? generalAnnouncements = null,
    Object? newFeatures = null,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      favoriteLineUpdates: null == favoriteLineUpdates
          ? _value.favoriteLineUpdates
          : favoriteLineUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      serviceDisruptions: null == serviceDisruptions
          ? _value.serviceDisruptions
          : serviceDisruptions // ignore: cast_nullable_to_non_nullable
              as bool,
      generalAnnouncements: null == generalAnnouncements
          ? _value.generalAnnouncements
          : generalAnnouncements // ignore: cast_nullable_to_non_nullable
              as bool,
      newFeatures: null == newFeatures
          ? _value.newFeatures
          : newFeatures // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesModelImplCopyWith<$Res>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  factory _$$NotificationPreferencesModelImplCopyWith(
          _$NotificationPreferencesModelImpl value,
          $Res Function(_$NotificationPreferencesModelImpl) then) =
      __$$NotificationPreferencesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user,
      @JsonKey(name: 'favorite_line_updates', defaultValue: true)
      bool favoriteLineUpdates,
      @JsonKey(name: 'service_disruptions', defaultValue: true)
      bool serviceDisruptions,
      @JsonKey(name: 'general_announcements', defaultValue: true)
      bool generalAnnouncements,
      @JsonKey(name: 'new_features', defaultValue: false) bool newFeatures});
}

/// @nodoc
class __$$NotificationPreferencesModelImplCopyWithImpl<$Res>
    extends _$NotificationPreferencesModelCopyWithImpl<$Res,
        _$NotificationPreferencesModelImpl>
    implements _$$NotificationPreferencesModelImplCopyWith<$Res> {
  __$$NotificationPreferencesModelImplCopyWithImpl(
      _$NotificationPreferencesModelImpl _value,
      $Res Function(_$NotificationPreferencesModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? favoriteLineUpdates = null,
    Object? serviceDisruptions = null,
    Object? generalAnnouncements = null,
    Object? newFeatures = null,
  }) {
    return _then(_$NotificationPreferencesModelImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      favoriteLineUpdates: null == favoriteLineUpdates
          ? _value.favoriteLineUpdates
          : favoriteLineUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      serviceDisruptions: null == serviceDisruptions
          ? _value.serviceDisruptions
          : serviceDisruptions // ignore: cast_nullable_to_non_nullable
              as bool,
      generalAnnouncements: null == generalAnnouncements
          ? _value.generalAnnouncements
          : generalAnnouncements // ignore: cast_nullable_to_non_nullable
              as bool,
      newFeatures: null == newFeatures
          ? _value.newFeatures
          : newFeatures // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesModelImpl
    implements _NotificationPreferencesModel {
  const _$NotificationPreferencesModelImpl(
      {required this.user,
      @JsonKey(name: 'favorite_line_updates', defaultValue: true)
      required this.favoriteLineUpdates,
      @JsonKey(name: 'service_disruptions', defaultValue: true)
      required this.serviceDisruptions,
      @JsonKey(name: 'general_announcements', defaultValue: true)
      required this.generalAnnouncements,
      @JsonKey(name: 'new_features', defaultValue: false)
      required this.newFeatures});

  factory _$NotificationPreferencesModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$NotificationPreferencesModelImplFromJson(json);

  /// ID of the user these preferences belong to. Matches API 'user'. Required. Read-only.
  @override
  final String user;
// UUID
  /// Enable/disable notifications for updates on favorited lines. Matches API 'favorite_line_updates'.
  @override
  @JsonKey(name: 'favorite_line_updates', defaultValue: true)
  final bool favoriteLineUpdates;

  /// Enable/disable notifications about service disruptions. Matches API 'service_disruptions'.
  @override
  @JsonKey(name: 'service_disruptions', defaultValue: true)
  final bool serviceDisruptions;

  /// Enable/disable notifications for general announcements. Matches API 'general_announcements'.
  @override
  @JsonKey(name: 'general_announcements', defaultValue: true)
  final bool generalAnnouncements;

  /// Enable/disable notifications about new app features. Matches API 'new_features'.
  @override
  @JsonKey(name: 'new_features', defaultValue: false)
  final bool newFeatures;

  @override
  String toString() {
    return 'NotificationPreferencesModel(user: $user, favoriteLineUpdates: $favoriteLineUpdates, serviceDisruptions: $serviceDisruptions, generalAnnouncements: $generalAnnouncements, newFeatures: $newFeatures)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesModelImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.favoriteLineUpdates, favoriteLineUpdates) ||
                other.favoriteLineUpdates == favoriteLineUpdates) &&
            (identical(other.serviceDisruptions, serviceDisruptions) ||
                other.serviceDisruptions == serviceDisruptions) &&
            (identical(other.generalAnnouncements, generalAnnouncements) ||
                other.generalAnnouncements == generalAnnouncements) &&
            (identical(other.newFeatures, newFeatures) ||
                other.newFeatures == newFeatures));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, favoriteLineUpdates,
      serviceDisruptions, generalAnnouncements, newFeatures);

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesModelImplCopyWith<
          _$NotificationPreferencesModelImpl>
      get copyWith => __$$NotificationPreferencesModelImplCopyWithImpl<
          _$NotificationPreferencesModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationPreferencesModel
    implements NotificationPreferencesModel {
  const factory _NotificationPreferencesModel(
      {required final String user,
      @JsonKey(name: 'favorite_line_updates', defaultValue: true)
      required final bool favoriteLineUpdates,
      @JsonKey(name: 'service_disruptions', defaultValue: true)
      required final bool serviceDisruptions,
      @JsonKey(name: 'general_announcements', defaultValue: true)
      required final bool generalAnnouncements,
      @JsonKey(name: 'new_features', defaultValue: false)
      required final bool newFeatures}) = _$NotificationPreferencesModelImpl;

  factory _NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesModelImpl.fromJson;

  /// ID of the user these preferences belong to. Matches API 'user'. Required. Read-only.
  @override
  String get user; // UUID
  /// Enable/disable notifications for updates on favorited lines. Matches API 'favorite_line_updates'.
  @override
  @JsonKey(name: 'favorite_line_updates', defaultValue: true)
  bool get favoriteLineUpdates;

  /// Enable/disable notifications about service disruptions. Matches API 'service_disruptions'.
  @override
  @JsonKey(name: 'service_disruptions', defaultValue: true)
  bool get serviceDisruptions;

  /// Enable/disable notifications for general announcements. Matches API 'general_announcements'.
  @override
  @JsonKey(name: 'general_announcements', defaultValue: true)
  bool get generalAnnouncements;

  /// Enable/disable notifications about new app features. Matches API 'new_features'.
  @override
  @JsonKey(name: 'new_features', defaultValue: false)
  bool get newFeatures;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesModelImplCopyWith<
          _$NotificationPreferencesModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
