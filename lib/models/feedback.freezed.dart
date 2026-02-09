// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserFeedback _$UserFeedbackFromJson(Map<String, dynamic> json) {
  return _UserFeedback.fromJson(json);
}

/// @nodoc
mixin _$UserFeedback {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get userEmail => throw _privateConstructorUsedError;
  FeedbackType get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  String? get deviceInfo => throw _privateConstructorUsedError;
  String? get appVersion => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  FeedbackStatus get status => throw _privateConstructorUsedError;

  /// Serializes this UserFeedback to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserFeedbackCopyWith<UserFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFeedbackCopyWith<$Res> {
  factory $UserFeedbackCopyWith(
          UserFeedback value, $Res Function(UserFeedback) then) =
      _$UserFeedbackCopyWithImpl<$Res, UserFeedback>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      String userEmail,
      FeedbackType type,
      String message,
      List<String> imageUrls,
      String? deviceInfo,
      String? appVersion,
      DateTime createdAt,
      FeedbackStatus status});
}

/// @nodoc
class _$UserFeedbackCopyWithImpl<$Res, $Val extends UserFeedback>
    implements $UserFeedbackCopyWith<$Res> {
  _$UserFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userEmail = null,
    Object? type = null,
    Object? message = null,
    Object? imageUrls = null,
    Object? deviceInfo = freezed,
    Object? appVersion = freezed,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeedbackStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserFeedbackImplCopyWith<$Res>
    implements $UserFeedbackCopyWith<$Res> {
  factory _$$UserFeedbackImplCopyWith(
          _$UserFeedbackImpl value, $Res Function(_$UserFeedbackImpl) then) =
      __$$UserFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      String userEmail,
      FeedbackType type,
      String message,
      List<String> imageUrls,
      String? deviceInfo,
      String? appVersion,
      DateTime createdAt,
      FeedbackStatus status});
}

/// @nodoc
class __$$UserFeedbackImplCopyWithImpl<$Res>
    extends _$UserFeedbackCopyWithImpl<$Res, _$UserFeedbackImpl>
    implements _$$UserFeedbackImplCopyWith<$Res> {
  __$$UserFeedbackImplCopyWithImpl(
      _$UserFeedbackImpl _value, $Res Function(_$UserFeedbackImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userEmail = null,
    Object? type = null,
    Object? message = null,
    Object? imageUrls = null,
    Object? deviceInfo = freezed,
    Object? appVersion = freezed,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(_$UserFeedbackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: null == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeedbackStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserFeedbackImpl implements _UserFeedback {
  const _$UserFeedbackImpl(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.userEmail,
      required this.type,
      required this.message,
      final List<String> imageUrls = const [],
      this.deviceInfo,
      this.appVersion,
      required this.createdAt,
      this.status = FeedbackStatus.submitted})
      : _imageUrls = imageUrls;

  factory _$UserFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserFeedbackImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String userEmail;
  @override
  final FeedbackType type;
  @override
  final String message;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  final String? deviceInfo;
  @override
  final String? appVersion;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final FeedbackStatus status;

  @override
  String toString() {
    return 'UserFeedback(id: $id, userId: $userId, userName: $userName, userEmail: $userEmail, type: $type, message: $message, imageUrls: $imageUrls, deviceInfo: $deviceInfo, appVersion: $appVersion, createdAt: $createdAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      userName,
      userEmail,
      type,
      message,
      const DeepCollectionEquality().hash(_imageUrls),
      deviceInfo,
      appVersion,
      createdAt,
      status);

  /// Create a copy of UserFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFeedbackImplCopyWith<_$UserFeedbackImpl> get copyWith =>
      __$$UserFeedbackImplCopyWithImpl<_$UserFeedbackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserFeedbackImplToJson(
      this,
    );
  }
}

abstract class _UserFeedback implements UserFeedback {
  const factory _UserFeedback(
      {required final String id,
      required final String userId,
      required final String userName,
      required final String userEmail,
      required final FeedbackType type,
      required final String message,
      final List<String> imageUrls,
      final String? deviceInfo,
      final String? appVersion,
      required final DateTime createdAt,
      final FeedbackStatus status}) = _$UserFeedbackImpl;

  factory _UserFeedback.fromJson(Map<String, dynamic> json) =
      _$UserFeedbackImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String get userEmail;
  @override
  FeedbackType get type;
  @override
  String get message;
  @override
  List<String> get imageUrls;
  @override
  String? get deviceInfo;
  @override
  String? get appVersion;
  @override
  DateTime get createdAt;
  @override
  FeedbackStatus get status;

  /// Create a copy of UserFeedback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserFeedbackImplCopyWith<_$UserFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
