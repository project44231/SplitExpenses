// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get shareToken => throw _privateConstructorUsedError;
  List<String> get categoryTags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? name,
      String? description,
      String groupId,
      EventStatus status,
      String currency,
      List<String> participantIds,
      DateTime startTime,
      DateTime? endTime,
      String? notes,
      String? shareToken,
      List<String> categoryTags,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? groupId = null,
    Object? status = null,
    Object? currency = null,
    Object? participantIds = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? shareToken = freezed,
    Object? categoryTags = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      shareToken: freezed == shareToken
          ? _value.shareToken
          : shareToken // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryTags: null == categoryTags
          ? _value.categoryTags
          : categoryTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
          _$EventImpl value, $Res Function(_$EventImpl) then) =
      __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? name,
      String? description,
      String groupId,
      EventStatus status,
      String currency,
      List<String> participantIds,
      DateTime startTime,
      DateTime? endTime,
      String? notes,
      String? shareToken,
      List<String> categoryTags,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
      _$EventImpl _value, $Res Function(_$EventImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? groupId = null,
    Object? status = null,
    Object? currency = null,
    Object? participantIds = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? shareToken = freezed,
    Object? categoryTags = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$EventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      shareToken: freezed == shareToken
          ? _value.shareToken
          : shareToken // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryTags: null == categoryTags
          ? _value._categoryTags
          : categoryTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl(
      {required this.id,
      required this.userId,
      this.name,
      this.description,
      required this.groupId,
      required this.status,
      required this.currency,
      final List<String> participantIds = const [],
      required this.startTime,
      this.endTime,
      this.notes,
      this.shareToken,
      final List<String> categoryTags = const [],
      required this.createdAt,
      this.updatedAt})
      : _participantIds = participantIds,
        _categoryTags = categoryTags;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String groupId;
  @override
  final EventStatus status;
  @override
  final String currency;
  final List<String> _participantIds;
  @override
  @JsonKey()
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final String? notes;
  @override
  final String? shareToken;
  final List<String> _categoryTags;
  @override
  @JsonKey()
  List<String> get categoryTags {
    if (_categoryTags is EqualUnmodifiableListView) return _categoryTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryTags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Event(id: $id, userId: $userId, name: $name, description: $description, groupId: $groupId, status: $status, currency: $currency, participantIds: $participantIds, startTime: $startTime, endTime: $endTime, notes: $notes, shareToken: $shareToken, categoryTags: $categoryTags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.shareToken, shareToken) ||
                other.shareToken == shareToken) &&
            const DeepCollectionEquality()
                .equals(other._categoryTags, _categoryTags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      groupId,
      status,
      currency,
      const DeepCollectionEquality().hash(_participantIds),
      startTime,
      endTime,
      notes,
      shareToken,
      const DeepCollectionEquality().hash(_categoryTags),
      createdAt,
      updatedAt);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(
      this,
    );
  }
}

abstract class _Event implements Event {
  const factory _Event(
      {required final String id,
      required final String userId,
      final String? name,
      final String? description,
      required final String groupId,
      required final EventStatus status,
      required final String currency,
      final List<String> participantIds,
      required final DateTime startTime,
      final DateTime? endTime,
      final String? notes,
      final String? shareToken,
      final List<String> categoryTags,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String get groupId;
  @override
  EventStatus get status;
  @override
  String get currency;
  @override
  List<String> get participantIds;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  String? get notes;
  @override
  String? get shareToken;
  @override
  List<String> get categoryTags;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
