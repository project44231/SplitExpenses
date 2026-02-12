// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventGroup _$EventGroupFromJson(Map<String, dynamic> json) {
  return _EventGroup.fromJson(json);
}

/// @nodoc
mixin _$EventGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  List<String> get memberIds => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get defaultCurrency => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EventGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventGroupCopyWith<EventGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventGroupCopyWith<$Res> {
  factory $EventGroupCopyWith(
          EventGroup value, $Res Function(EventGroup) then) =
      _$EventGroupCopyWithImpl<$Res, EventGroup>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerId,
      List<String> memberIds,
      String? description,
      String? defaultCurrency,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$EventGroupCopyWithImpl<$Res, $Val extends EventGroup>
    implements $EventGroupCopyWith<$Res> {
  _$EventGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? memberIds = null,
    Object? description = freezed,
    Object? defaultCurrency = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      memberIds: null == memberIds
          ? _value.memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultCurrency: freezed == defaultCurrency
          ? _value.defaultCurrency
          : defaultCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$EventGroupImplCopyWith<$Res>
    implements $EventGroupCopyWith<$Res> {
  factory _$$EventGroupImplCopyWith(
          _$EventGroupImpl value, $Res Function(_$EventGroupImpl) then) =
      __$$EventGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerId,
      List<String> memberIds,
      String? description,
      String? defaultCurrency,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$EventGroupImplCopyWithImpl<$Res>
    extends _$EventGroupCopyWithImpl<$Res, _$EventGroupImpl>
    implements _$$EventGroupImplCopyWith<$Res> {
  __$$EventGroupImplCopyWithImpl(
      _$EventGroupImpl _value, $Res Function(_$EventGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? memberIds = null,
    Object? description = freezed,
    Object? defaultCurrency = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$EventGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      memberIds: null == memberIds
          ? _value._memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultCurrency: freezed == defaultCurrency
          ? _value.defaultCurrency
          : defaultCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$EventGroupImpl implements _EventGroup {
  const _$EventGroupImpl(
      {required this.id,
      required this.name,
      required this.ownerId,
      final List<String> memberIds = const [],
      this.description,
      this.defaultCurrency,
      required this.createdAt,
      this.updatedAt})
      : _memberIds = memberIds;

  factory _$EventGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ownerId;
  final List<String> _memberIds;
  @override
  @JsonKey()
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  @override
  final String? description;
  @override
  final String? defaultCurrency;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'EventGroup(id: $id, name: $name, ownerId: $ownerId, memberIds: $memberIds, description: $description, defaultCurrency: $defaultCurrency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            const DeepCollectionEquality()
                .equals(other._memberIds, _memberIds) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.defaultCurrency, defaultCurrency) ||
                other.defaultCurrency == defaultCurrency) &&
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
      name,
      ownerId,
      const DeepCollectionEquality().hash(_memberIds),
      description,
      defaultCurrency,
      createdAt,
      updatedAt);

  /// Create a copy of EventGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventGroupImplCopyWith<_$EventGroupImpl> get copyWith =>
      __$$EventGroupImplCopyWithImpl<_$EventGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventGroupImplToJson(
      this,
    );
  }
}

abstract class _EventGroup implements EventGroup {
  const factory _EventGroup(
      {required final String id,
      required final String name,
      required final String ownerId,
      final List<String> memberIds,
      final String? description,
      final String? defaultCurrency,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$EventGroupImpl;

  factory _EventGroup.fromJson(Map<String, dynamic> json) =
      _$EventGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ownerId;
  @override
  List<String> get memberIds;
  @override
  String? get description;
  @override
  String? get defaultCurrency;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of EventGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventGroupImplCopyWith<_$EventGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
