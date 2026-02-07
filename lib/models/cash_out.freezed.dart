// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_out.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CashOut _$CashOutFromJson(Map<String, dynamic> json) {
  return _CashOut.fromJson(json);
}

/// @nodoc
mixin _$CashOut {
  String get id => throw _privateConstructorUsedError;
  String get gameId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this CashOut to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CashOut
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashOutCopyWith<CashOut> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashOutCopyWith<$Res> {
  factory $CashOutCopyWith(CashOut value, $Res Function(CashOut) then) =
      _$CashOutCopyWithImpl<$Res, CashOut>;
  @useResult
  $Res call(
      {String id,
      String gameId,
      String playerId,
      double amount,
      DateTime timestamp,
      String? notes});
}

/// @nodoc
class _$CashOutCopyWithImpl<$Res, $Val extends CashOut>
    implements $CashOutCopyWith<$Res> {
  _$CashOutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashOut
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? playerId = null,
    Object? amount = null,
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
abstract class _$$CashOutImplCopyWith<$Res> implements $CashOutCopyWith<$Res> {
  factory _$$CashOutImplCopyWith(
          _$CashOutImpl value, $Res Function(_$CashOutImpl) then) =
      __$$CashOutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String gameId,
      String playerId,
      double amount,
      DateTime timestamp,
      String? notes});
}

/// @nodoc
class __$$CashOutImplCopyWithImpl<$Res>
    extends _$CashOutCopyWithImpl<$Res, _$CashOutImpl>
    implements _$$CashOutImplCopyWith<$Res> {
  __$$CashOutImplCopyWithImpl(
      _$CashOutImpl _value, $Res Function(_$CashOutImpl) _then)
      : super(_value, _then);

  /// Create a copy of CashOut
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? playerId = null,
    Object? amount = null,
    Object? timestamp = null,
    Object? notes = freezed,
  }) {
    return _then(_$CashOutImpl(
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
class _$CashOutImpl implements _CashOut {
  const _$CashOutImpl(
      {required this.id,
      required this.gameId,
      required this.playerId,
      required this.amount,
      required this.timestamp,
      this.notes});

  factory _$CashOutImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashOutImplFromJson(json);

  @override
  final String id;
  @override
  final String gameId;
  @override
  final String playerId;
  @override
  final double amount;
  @override
  final DateTime timestamp;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CashOut(id: $id, gameId: $gameId, playerId: $playerId, amount: $amount, timestamp: $timestamp, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashOutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, gameId, playerId, amount, timestamp, notes);

  /// Create a copy of CashOut
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashOutImplCopyWith<_$CashOutImpl> get copyWith =>
      __$$CashOutImplCopyWithImpl<_$CashOutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashOutImplToJson(
      this,
    );
  }
}

abstract class _CashOut implements CashOut {
  const factory _CashOut(
      {required final String id,
      required final String gameId,
      required final String playerId,
      required final double amount,
      required final DateTime timestamp,
      final String? notes}) = _$CashOutImpl;

  factory _CashOut.fromJson(Map<String, dynamic> json) = _$CashOutImpl.fromJson;

  @override
  String get id;
  @override
  String get gameId;
  @override
  String get playerId;
  @override
  double get amount;
  @override
  DateTime get timestamp;
  @override
  String? get notes;

  /// Create a copy of CashOut
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashOutImplCopyWith<_$CashOutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
