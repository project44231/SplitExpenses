// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_out_reconciliation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CashOutReconciliation _$CashOutReconciliationFromJson(
    Map<String, dynamic> json) {
  return _CashOutReconciliation.fromJson(json);
}

/// @nodoc
mixin _$CashOutReconciliation {
  String get id => throw _privateConstructorUsedError;
  String get gameId => throw _privateConstructorUsedError;
  double get originalBuyIn => throw _privateConstructorUsedError;
  double get originalCashOut => throw _privateConstructorUsedError;
  double get adjustedCashOut => throw _privateConstructorUsedError;
  ReconciliationType get type => throw _privateConstructorUsedError;
  Map<String, double> get adjustments =>
      throw _privateConstructorUsedError; // playerId -> adjustment amount
  String? get note => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CashOutReconciliation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CashOutReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashOutReconciliationCopyWith<CashOutReconciliation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashOutReconciliationCopyWith<$Res> {
  factory $CashOutReconciliationCopyWith(CashOutReconciliation value,
          $Res Function(CashOutReconciliation) then) =
      _$CashOutReconciliationCopyWithImpl<$Res, CashOutReconciliation>;
  @useResult
  $Res call(
      {String id,
      String gameId,
      double originalBuyIn,
      double originalCashOut,
      double adjustedCashOut,
      ReconciliationType type,
      Map<String, double> adjustments,
      String? note,
      DateTime timestamp});
}

/// @nodoc
class _$CashOutReconciliationCopyWithImpl<$Res,
        $Val extends CashOutReconciliation>
    implements $CashOutReconciliationCopyWith<$Res> {
  _$CashOutReconciliationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashOutReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? originalBuyIn = null,
    Object? originalCashOut = null,
    Object? adjustedCashOut = null,
    Object? type = null,
    Object? adjustments = null,
    Object? note = freezed,
    Object? timestamp = null,
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
      originalBuyIn: null == originalBuyIn
          ? _value.originalBuyIn
          : originalBuyIn // ignore: cast_nullable_to_non_nullable
              as double,
      originalCashOut: null == originalCashOut
          ? _value.originalCashOut
          : originalCashOut // ignore: cast_nullable_to_non_nullable
              as double,
      adjustedCashOut: null == adjustedCashOut
          ? _value.adjustedCashOut
          : adjustedCashOut // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReconciliationType,
      adjustments: null == adjustments
          ? _value.adjustments
          : adjustments // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CashOutReconciliationImplCopyWith<$Res>
    implements $CashOutReconciliationCopyWith<$Res> {
  factory _$$CashOutReconciliationImplCopyWith(
          _$CashOutReconciliationImpl value,
          $Res Function(_$CashOutReconciliationImpl) then) =
      __$$CashOutReconciliationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String gameId,
      double originalBuyIn,
      double originalCashOut,
      double adjustedCashOut,
      ReconciliationType type,
      Map<String, double> adjustments,
      String? note,
      DateTime timestamp});
}

/// @nodoc
class __$$CashOutReconciliationImplCopyWithImpl<$Res>
    extends _$CashOutReconciliationCopyWithImpl<$Res,
        _$CashOutReconciliationImpl>
    implements _$$CashOutReconciliationImplCopyWith<$Res> {
  __$$CashOutReconciliationImplCopyWithImpl(_$CashOutReconciliationImpl _value,
      $Res Function(_$CashOutReconciliationImpl) _then)
      : super(_value, _then);

  /// Create a copy of CashOutReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? originalBuyIn = null,
    Object? originalCashOut = null,
    Object? adjustedCashOut = null,
    Object? type = null,
    Object? adjustments = null,
    Object? note = freezed,
    Object? timestamp = null,
  }) {
    return _then(_$CashOutReconciliationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      originalBuyIn: null == originalBuyIn
          ? _value.originalBuyIn
          : originalBuyIn // ignore: cast_nullable_to_non_nullable
              as double,
      originalCashOut: null == originalCashOut
          ? _value.originalCashOut
          : originalCashOut // ignore: cast_nullable_to_non_nullable
              as double,
      adjustedCashOut: null == adjustedCashOut
          ? _value.adjustedCashOut
          : adjustedCashOut // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReconciliationType,
      adjustments: null == adjustments
          ? _value._adjustments
          : adjustments // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CashOutReconciliationImpl implements _CashOutReconciliation {
  const _$CashOutReconciliationImpl(
      {required this.id,
      required this.gameId,
      required this.originalBuyIn,
      required this.originalCashOut,
      required this.adjustedCashOut,
      required this.type,
      required final Map<String, double> adjustments,
      this.note,
      required this.timestamp})
      : _adjustments = adjustments;

  factory _$CashOutReconciliationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashOutReconciliationImplFromJson(json);

  @override
  final String id;
  @override
  final String gameId;
  @override
  final double originalBuyIn;
  @override
  final double originalCashOut;
  @override
  final double adjustedCashOut;
  @override
  final ReconciliationType type;
  final Map<String, double> _adjustments;
  @override
  Map<String, double> get adjustments {
    if (_adjustments is EqualUnmodifiableMapView) return _adjustments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_adjustments);
  }

// playerId -> adjustment amount
  @override
  final String? note;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'CashOutReconciliation(id: $id, gameId: $gameId, originalBuyIn: $originalBuyIn, originalCashOut: $originalCashOut, adjustedCashOut: $adjustedCashOut, type: $type, adjustments: $adjustments, note: $note, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashOutReconciliationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.originalBuyIn, originalBuyIn) ||
                other.originalBuyIn == originalBuyIn) &&
            (identical(other.originalCashOut, originalCashOut) ||
                other.originalCashOut == originalCashOut) &&
            (identical(other.adjustedCashOut, adjustedCashOut) ||
                other.adjustedCashOut == adjustedCashOut) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._adjustments, _adjustments) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      gameId,
      originalBuyIn,
      originalCashOut,
      adjustedCashOut,
      type,
      const DeepCollectionEquality().hash(_adjustments),
      note,
      timestamp);

  /// Create a copy of CashOutReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashOutReconciliationImplCopyWith<_$CashOutReconciliationImpl>
      get copyWith => __$$CashOutReconciliationImplCopyWithImpl<
          _$CashOutReconciliationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashOutReconciliationImplToJson(
      this,
    );
  }
}

abstract class _CashOutReconciliation implements CashOutReconciliation {
  const factory _CashOutReconciliation(
      {required final String id,
      required final String gameId,
      required final double originalBuyIn,
      required final double originalCashOut,
      required final double adjustedCashOut,
      required final ReconciliationType type,
      required final Map<String, double> adjustments,
      final String? note,
      required final DateTime timestamp}) = _$CashOutReconciliationImpl;

  factory _CashOutReconciliation.fromJson(Map<String, dynamic> json) =
      _$CashOutReconciliationImpl.fromJson;

  @override
  String get id;
  @override
  String get gameId;
  @override
  double get originalBuyIn;
  @override
  double get originalCashOut;
  @override
  double get adjustedCashOut;
  @override
  ReconciliationType get type;
  @override
  Map<String, double> get adjustments; // playerId -> adjustment amount
  @override
  String? get note;
  @override
  DateTime get timestamp;

  /// Create a copy of CashOutReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashOutReconciliationImplCopyWith<_$CashOutReconciliationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
