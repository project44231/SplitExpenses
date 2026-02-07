// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buy_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuyIn _$BuyInFromJson(Map<String, dynamic> json) {
  return _BuyIn.fromJson(json);
}

/// @nodoc
mixin _$BuyIn {
  String get id => throw _privateConstructorUsedError;
  String get gameId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  BuyInType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this BuyIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuyIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuyInCopyWith<BuyIn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuyInCopyWith<$Res> {
  factory $BuyInCopyWith(BuyIn value, $Res Function(BuyIn) then) =
      _$BuyInCopyWithImpl<$Res, BuyIn>;
  @useResult
  $Res call(
      {String id,
      String gameId,
      String playerId,
      double amount,
      BuyInType type,
      DateTime timestamp,
      String? notes});
}

/// @nodoc
class _$BuyInCopyWithImpl<$Res, $Val extends BuyIn>
    implements $BuyInCopyWith<$Res> {
  _$BuyInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuyIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? playerId = null,
    Object? amount = null,
    Object? type = null,
    Object? timestamp = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BuyInType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuyInImplCopyWith<$Res> implements $BuyInCopyWith<$Res> {
  factory _$$BuyInImplCopyWith(
          _$BuyInImpl value, $Res Function(_$BuyInImpl) then) =
      __$$BuyInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String gameId,
      String playerId,
      double amount,
      BuyInType type,
      DateTime timestamp,
      String? notes});
}

/// @nodoc
class __$$BuyInImplCopyWithImpl<$Res>
    extends _$BuyInCopyWithImpl<$Res, _$BuyInImpl>
    implements _$$BuyInImplCopyWith<$Res> {
  __$$BuyInImplCopyWithImpl(
      _$BuyInImpl _value, $Res Function(_$BuyInImpl) _then)
      : super(_value, _then);

  /// Create a copy of BuyIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? playerId = null,
    Object? amount = null,
    Object? type = null,
    Object? timestamp = null,
    Object? notes = freezed,
  }) {
    return _then(_$BuyInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BuyInType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuyInImpl implements _BuyIn {
  const _$BuyInImpl(
      {required this.id,
      required this.gameId,
      required this.playerId,
      required this.amount,
      required this.type,
      required this.timestamp,
      this.notes});

  factory _$BuyInImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuyInImplFromJson(json);

  @override
  final String id;
  @override
  final String gameId;
  @override
  final String playerId;
  @override
  final double amount;
  @override
  final BuyInType type;
  @override
  final DateTime timestamp;
  @override
  final String? notes;

  @override
  String toString() {
    return 'BuyIn(id: $id, gameId: $gameId, playerId: $playerId, amount: $amount, type: $type, timestamp: $timestamp, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuyInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, gameId, playerId, amount, type, timestamp, notes);

  /// Create a copy of BuyIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuyInImplCopyWith<_$BuyInImpl> get copyWith =>
      __$$BuyInImplCopyWithImpl<_$BuyInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuyInImplToJson(
      this,
    );
  }
}

abstract class _BuyIn implements BuyIn {
  const factory _BuyIn(
      {required final String id,
      required final String gameId,
      required final String playerId,
      required final double amount,
      required final BuyInType type,
      required final DateTime timestamp,
      final String? notes}) = _$BuyInImpl;

  factory _BuyIn.fromJson(Map<String, dynamic> json) = _$BuyInImpl.fromJson;

  @override
  String get id;
  @override
  String get gameId;
  @override
  String get playerId;
  @override
  double get amount;
  @override
  BuyInType get type;
  @override
  DateTime get timestamp;
  @override
  String? get notes;

  /// Create a copy of BuyIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuyInImplCopyWith<_$BuyInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
