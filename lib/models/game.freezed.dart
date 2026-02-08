// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  GameStatus get status => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  List<String> get playerIds => throw _privateConstructorUsedError;
  List<double> get customBuyInAmounts => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get shareToken => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call(
      {String id,
      String groupId,
      GameStatus status,
      String currency,
      List<String> playerIds,
      List<double> customBuyInAmounts,
      DateTime startTime,
      DateTime? endTime,
      String? notes,
      String? shareToken,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? status = null,
    Object? currency = null,
    Object? playerIds = null,
    Object? customBuyInAmounts = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? shareToken = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStatus,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      playerIds: null == playerIds
          ? _value.playerIds
          : playerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customBuyInAmounts: null == customBuyInAmounts
          ? _value.customBuyInAmounts
          : customBuyInAmounts // ignore: cast_nullable_to_non_nullable
              as List<double>,
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
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
          _$GameImpl value, $Res Function(_$GameImpl) then) =
      __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String groupId,
      GameStatus status,
      String currency,
      List<String> playerIds,
      List<double> customBuyInAmounts,
      DateTime startTime,
      DateTime? endTime,
      String? notes,
      String? shareToken,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
      : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? status = null,
    Object? currency = null,
    Object? playerIds = null,
    Object? customBuyInAmounts = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? shareToken = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$GameImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStatus,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      playerIds: null == playerIds
          ? _value._playerIds
          : playerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customBuyInAmounts: null == customBuyInAmounts
          ? _value._customBuyInAmounts
          : customBuyInAmounts // ignore: cast_nullable_to_non_nullable
              as List<double>,
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
class _$GameImpl implements _Game {
  const _$GameImpl(
      {required this.id,
      required this.groupId,
      required this.status,
      required this.currency,
      final List<String> playerIds = const [],
      final List<double> customBuyInAmounts = const [20, 50, 100, 200],
      required this.startTime,
      this.endTime,
      this.notes,
      this.shareToken,
      required this.createdAt,
      this.updatedAt})
      : _playerIds = playerIds,
        _customBuyInAmounts = customBuyInAmounts;

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final GameStatus status;
  @override
  final String currency;
  final List<String> _playerIds;
  @override
  @JsonKey()
  List<String> get playerIds {
    if (_playerIds is EqualUnmodifiableListView) return _playerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerIds);
  }

  final List<double> _customBuyInAmounts;
  @override
  @JsonKey()
  List<double> get customBuyInAmounts {
    if (_customBuyInAmounts is EqualUnmodifiableListView)
      return _customBuyInAmounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customBuyInAmounts);
  }

  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final String? notes;
  @override
  final String? shareToken;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Game(id: $id, groupId: $groupId, status: $status, currency: $currency, playerIds: $playerIds, customBuyInAmounts: $customBuyInAmounts, startTime: $startTime, endTime: $endTime, notes: $notes, shareToken: $shareToken, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality()
                .equals(other._playerIds, _playerIds) &&
            const DeepCollectionEquality()
                .equals(other._customBuyInAmounts, _customBuyInAmounts) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.shareToken, shareToken) ||
                other.shareToken == shareToken) &&
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
      groupId,
      status,
      currency,
      const DeepCollectionEquality().hash(_playerIds),
      const DeepCollectionEquality().hash(_customBuyInAmounts),
      startTime,
      endTime,
      notes,
      shareToken,
      createdAt,
      updatedAt);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(
      this,
    );
  }
}

abstract class _Game implements Game {
  const factory _Game(
      {required final String id,
      required final String groupId,
      required final GameStatus status,
      required final String currency,
      final List<String> playerIds,
      final List<double> customBuyInAmounts,
      required final DateTime startTime,
      final DateTime? endTime,
      final String? notes,
      final String? shareToken,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$GameImpl;

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  GameStatus get status;
  @override
  String get currency;
  @override
  List<String> get playerIds;
  @override
  List<double> get customBuyInAmounts;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  String? get notes;
  @override
  String? get shareToken;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
