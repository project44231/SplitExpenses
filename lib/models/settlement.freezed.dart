// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SettlementTransaction _$SettlementTransactionFromJson(
    Map<String, dynamic> json) {
  return _SettlementTransaction.fromJson(json);
}

/// @nodoc
mixin _$SettlementTransaction {
  String get fromParticipantId => throw _privateConstructorUsedError;
  String get toParticipantId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this SettlementTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettlementTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementTransactionCopyWith<SettlementTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementTransactionCopyWith<$Res> {
  factory $SettlementTransactionCopyWith(SettlementTransaction value,
          $Res Function(SettlementTransaction) then) =
      _$SettlementTransactionCopyWithImpl<$Res, SettlementTransaction>;
  @useResult
  $Res call({String fromParticipantId, String toParticipantId, double amount});
}

/// @nodoc
class _$SettlementTransactionCopyWithImpl<$Res,
        $Val extends SettlementTransaction>
    implements $SettlementTransactionCopyWith<$Res> {
  _$SettlementTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettlementTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromParticipantId = null,
    Object? toParticipantId = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      fromParticipantId: null == fromParticipantId
          ? _value.fromParticipantId
          : fromParticipantId // ignore: cast_nullable_to_non_nullable
              as String,
      toParticipantId: null == toParticipantId
          ? _value.toParticipantId
          : toParticipantId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementTransactionImplCopyWith<$Res>
    implements $SettlementTransactionCopyWith<$Res> {
  factory _$$SettlementTransactionImplCopyWith(
          _$SettlementTransactionImpl value,
          $Res Function(_$SettlementTransactionImpl) then) =
      __$$SettlementTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fromParticipantId, String toParticipantId, double amount});
}

/// @nodoc
class __$$SettlementTransactionImplCopyWithImpl<$Res>
    extends _$SettlementTransactionCopyWithImpl<$Res,
        _$SettlementTransactionImpl>
    implements _$$SettlementTransactionImplCopyWith<$Res> {
  __$$SettlementTransactionImplCopyWithImpl(_$SettlementTransactionImpl _value,
      $Res Function(_$SettlementTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettlementTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromParticipantId = null,
    Object? toParticipantId = null,
    Object? amount = null,
  }) {
    return _then(_$SettlementTransactionImpl(
      fromParticipantId: null == fromParticipantId
          ? _value.fromParticipantId
          : fromParticipantId // ignore: cast_nullable_to_non_nullable
              as String,
      toParticipantId: null == toParticipantId
          ? _value.toParticipantId
          : toParticipantId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementTransactionImpl implements _SettlementTransaction {
  const _$SettlementTransactionImpl(
      {required this.fromParticipantId,
      required this.toParticipantId,
      required this.amount});

  factory _$SettlementTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementTransactionImplFromJson(json);

  @override
  final String fromParticipantId;
  @override
  final String toParticipantId;
  @override
  final double amount;

  @override
  String toString() {
    return 'SettlementTransaction(fromParticipantId: $fromParticipantId, toParticipantId: $toParticipantId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementTransactionImpl &&
            (identical(other.fromParticipantId, fromParticipantId) ||
                other.fromParticipantId == fromParticipantId) &&
            (identical(other.toParticipantId, toParticipantId) ||
                other.toParticipantId == toParticipantId) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fromParticipantId, toParticipantId, amount);

  /// Create a copy of SettlementTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementTransactionImplCopyWith<_$SettlementTransactionImpl>
      get copyWith => __$$SettlementTransactionImplCopyWithImpl<
          _$SettlementTransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementTransactionImplToJson(
      this,
    );
  }
}

abstract class _SettlementTransaction implements SettlementTransaction {
  const factory _SettlementTransaction(
      {required final String fromParticipantId,
      required final String toParticipantId,
      required final double amount}) = _$SettlementTransactionImpl;

  factory _SettlementTransaction.fromJson(Map<String, dynamic> json) =
      _$SettlementTransactionImpl.fromJson;

  @override
  String get fromParticipantId;
  @override
  String get toParticipantId;
  @override
  double get amount;

  /// Create a copy of SettlementTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementTransactionImplCopyWith<_$SettlementTransactionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

Settlement _$SettlementFromJson(Map<String, dynamic> json) {
  return _Settlement.fromJson(json);
}

/// @nodoc
mixin _$Settlement {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
  List<SettlementTransaction> get transactions =>
      throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this Settlement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementCopyWith<Settlement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementCopyWith<$Res> {
  factory $SettlementCopyWith(
          Settlement value, $Res Function(Settlement) then) =
      _$SettlementCopyWithImpl<$Res, Settlement>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
      List<SettlementTransaction> transactions,
      DateTime generatedAt});
}

/// @nodoc
class _$SettlementCopyWithImpl<$Res, $Val extends Settlement>
    implements $SettlementCopyWith<$Res> {
  _$SettlementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? transactions = null,
    Object? generatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<SettlementTransaction>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementImplCopyWith<$Res>
    implements $SettlementCopyWith<$Res> {
  factory _$$SettlementImplCopyWith(
          _$SettlementImpl value, $Res Function(_$SettlementImpl) then) =
      __$$SettlementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
      List<SettlementTransaction> transactions,
      DateTime generatedAt});
}

/// @nodoc
class __$$SettlementImplCopyWithImpl<$Res>
    extends _$SettlementCopyWithImpl<$Res, _$SettlementImpl>
    implements _$$SettlementImplCopyWith<$Res> {
  __$$SettlementImplCopyWithImpl(
      _$SettlementImpl _value, $Res Function(_$SettlementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? transactions = null,
    Object? generatedAt = null,
  }) {
    return _then(_$SettlementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      transactions: null == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<SettlementTransaction>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementImpl implements _Settlement {
  const _$SettlementImpl(
      {required this.id,
      required this.eventId,
      @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
      required final List<SettlementTransaction> transactions,
      required this.generatedAt})
      : _transactions = transactions;

  factory _$SettlementImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  final List<SettlementTransaction> _transactions;
  @override
  @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
  List<SettlementTransaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'Settlement(id: $id, eventId: $eventId, transactions: $transactions, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, eventId,
      const DeepCollectionEquality().hash(_transactions), generatedAt);

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementImplCopyWith<_$SettlementImpl> get copyWith =>
      __$$SettlementImplCopyWithImpl<_$SettlementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementImplToJson(
      this,
    );
  }
}

abstract class _Settlement implements Settlement {
  const factory _Settlement(
      {required final String id,
      required final String eventId,
      @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
      required final List<SettlementTransaction> transactions,
      required final DateTime generatedAt}) = _$SettlementImpl;

  factory _Settlement.fromJson(Map<String, dynamic> json) =
      _$SettlementImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  @JsonKey(toJson: _transactionsToJson, fromJson: _transactionsFromJson)
  List<SettlementTransaction> get transactions;
  @override
  DateTime get generatedAt;

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementImplCopyWith<_$SettlementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
