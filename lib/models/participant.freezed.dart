// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Participant _$ParticipantFromJson(Map<String, dynamic> json) {
  return _Participant.fromJson(json);
}

/// @nodoc
mixin _$Participant {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<String> get groupIds => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int get eventsAttended => throw _privateConstructorUsedError;
  DateTime? get lastEventAt => throw _privateConstructorUsedError;
  double get totalPaid => throw _privateConstructorUsedError;
  double get totalOwed => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Participant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantCopyWith<Participant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantCopyWith<$Res> {
  factory $ParticipantCopyWith(
          Participant value, $Res Function(Participant) then) =
      _$ParticipantCopyWithImpl<$Res, Participant>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? email,
      String? phone,
      String? photoUrl,
      String? notes,
      List<String> groupIds,
      bool isFavorite,
      int eventsAttended,
      DateTime? lastEventAt,
      double totalPaid,
      double totalOwed,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ParticipantCopyWithImpl<$Res, $Val extends Participant>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? photoUrl = freezed,
    Object? notes = freezed,
    Object? groupIds = null,
    Object? isFavorite = null,
    Object? eventsAttended = null,
    Object? lastEventAt = freezed,
    Object? totalPaid = null,
    Object? totalOwed = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      groupIds: null == groupIds
          ? _value.groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      eventsAttended: null == eventsAttended
          ? _value.eventsAttended
          : eventsAttended // ignore: cast_nullable_to_non_nullable
              as int,
      lastEventAt: freezed == lastEventAt
          ? _value.lastEventAt
          : lastEventAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalPaid: null == totalPaid
          ? _value.totalPaid
          : totalPaid // ignore: cast_nullable_to_non_nullable
              as double,
      totalOwed: null == totalOwed
          ? _value.totalOwed
          : totalOwed // ignore: cast_nullable_to_non_nullable
              as double,
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
abstract class _$$ParticipantImplCopyWith<$Res>
    implements $ParticipantCopyWith<$Res> {
  factory _$$ParticipantImplCopyWith(
          _$ParticipantImpl value, $Res Function(_$ParticipantImpl) then) =
      __$$ParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? email,
      String? phone,
      String? photoUrl,
      String? notes,
      List<String> groupIds,
      bool isFavorite,
      int eventsAttended,
      DateTime? lastEventAt,
      double totalPaid,
      double totalOwed,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ParticipantImplCopyWithImpl<$Res>
    extends _$ParticipantCopyWithImpl<$Res, _$ParticipantImpl>
    implements _$$ParticipantImplCopyWith<$Res> {
  __$$ParticipantImplCopyWithImpl(
      _$ParticipantImpl _value, $Res Function(_$ParticipantImpl) _then)
      : super(_value, _then);

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? photoUrl = freezed,
    Object? notes = freezed,
    Object? groupIds = null,
    Object? isFavorite = null,
    Object? eventsAttended = null,
    Object? lastEventAt = freezed,
    Object? totalPaid = null,
    Object? totalOwed = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ParticipantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      groupIds: null == groupIds
          ? _value._groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      eventsAttended: null == eventsAttended
          ? _value.eventsAttended
          : eventsAttended // ignore: cast_nullable_to_non_nullable
              as int,
      lastEventAt: freezed == lastEventAt
          ? _value.lastEventAt
          : lastEventAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalPaid: null == totalPaid
          ? _value.totalPaid
          : totalPaid // ignore: cast_nullable_to_non_nullable
              as double,
      totalOwed: null == totalOwed
          ? _value.totalOwed
          : totalOwed // ignore: cast_nullable_to_non_nullable
              as double,
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
class _$ParticipantImpl implements _Participant {
  const _$ParticipantImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.email,
      this.phone,
      this.photoUrl,
      this.notes,
      final List<String> groupIds = const [],
      this.isFavorite = false,
      this.eventsAttended = 0,
      this.lastEventAt,
      this.totalPaid = 0.0,
      this.totalOwed = 0.0,
      required this.createdAt,
      this.updatedAt})
      : _groupIds = groupIds;

  factory _$ParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? photoUrl;
  @override
  final String? notes;
  final List<String> _groupIds;
  @override
  @JsonKey()
  List<String> get groupIds {
    if (_groupIds is EqualUnmodifiableListView) return _groupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupIds);
  }

  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final int eventsAttended;
  @override
  final DateTime? lastEventAt;
  @override
  @JsonKey()
  final double totalPaid;
  @override
  @JsonKey()
  final double totalOwed;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Participant(id: $id, userId: $userId, name: $name, email: $email, phone: $phone, photoUrl: $photoUrl, notes: $notes, groupIds: $groupIds, isFavorite: $isFavorite, eventsAttended: $eventsAttended, lastEventAt: $lastEventAt, totalPaid: $totalPaid, totalOwed: $totalOwed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.eventsAttended, eventsAttended) ||
                other.eventsAttended == eventsAttended) &&
            (identical(other.lastEventAt, lastEventAt) ||
                other.lastEventAt == lastEventAt) &&
            (identical(other.totalPaid, totalPaid) ||
                other.totalPaid == totalPaid) &&
            (identical(other.totalOwed, totalOwed) ||
                other.totalOwed == totalOwed) &&
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
      email,
      phone,
      photoUrl,
      notes,
      const DeepCollectionEquality().hash(_groupIds),
      isFavorite,
      eventsAttended,
      lastEventAt,
      totalPaid,
      totalOwed,
      createdAt,
      updatedAt);

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantImplCopyWith<_$ParticipantImpl> get copyWith =>
      __$$ParticipantImplCopyWithImpl<_$ParticipantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantImplToJson(
      this,
    );
  }
}

abstract class _Participant implements Participant {
  const factory _Participant(
      {required final String id,
      required final String userId,
      required final String name,
      final String? email,
      final String? phone,
      final String? photoUrl,
      final String? notes,
      final List<String> groupIds,
      final bool isFavorite,
      final int eventsAttended,
      final DateTime? lastEventAt,
      final double totalPaid,
      final double totalOwed,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$ParticipantImpl;

  factory _Participant.fromJson(Map<String, dynamic> json) =
      _$ParticipantImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get photoUrl;
  @override
  String? get notes;
  @override
  List<String> get groupIds;
  @override
  bool get isFavorite;
  @override
  int get eventsAttended;
  @override
  DateTime? get lastEventAt;
  @override
  double get totalPaid;
  @override
  double get totalOwed;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantImplCopyWith<_$ParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
