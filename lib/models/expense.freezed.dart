// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return _Expense.fromJson(json);
}

/// @nodoc
mixin _$Expense {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get paidByParticipantId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  ExpenseCategory get category => throw _privateConstructorUsedError;
  SplitMethod get splitMethod =>
      throw _privateConstructorUsedError; // For equal: empty or all participants with equal values
// For percentage: participantId -> percentage (0-100)
// For exactAmount: participantId -> exact amount
// For shares: participantId -> number of shares
  Map<String, double> get splitDetails => throw _privateConstructorUsedError;
  String? get receipt =>
      throw _privateConstructorUsedError; // optional photo URL
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCopyWith<Expense> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCopyWith<$Res> {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) then) =
      _$ExpenseCopyWithImpl<$Res, Expense>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      String paidByParticipantId,
      double amount,
      String description,
      DateTime timestamp,
      ExpenseCategory category,
      SplitMethod splitMethod,
      Map<String, double> splitDetails,
      String? receipt,
      String? notes});
}

/// @nodoc
class _$ExpenseCopyWithImpl<$Res, $Val extends Expense>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? paidByParticipantId = null,
    Object? amount = null,
    Object? description = null,
    Object? timestamp = null,
    Object? category = null,
    Object? splitMethod = null,
    Object? splitDetails = null,
    Object? receipt = freezed,
    Object? notes = freezed,
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
      paidByParticipantId: null == paidByParticipantId
          ? _value.paidByParticipantId
          : paidByParticipantId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExpenseCategory,
      splitMethod: null == splitMethod
          ? _value.splitMethod
          : splitMethod // ignore: cast_nullable_to_non_nullable
              as SplitMethod,
      splitDetails: null == splitDetails
          ? _value.splitDetails
          : splitDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      receipt: freezed == receipt
          ? _value.receipt
          : receipt // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseImplCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$$ExpenseImplCopyWith(
          _$ExpenseImpl value, $Res Function(_$ExpenseImpl) then) =
      __$$ExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      String paidByParticipantId,
      double amount,
      String description,
      DateTime timestamp,
      ExpenseCategory category,
      SplitMethod splitMethod,
      Map<String, double> splitDetails,
      String? receipt,
      String? notes});
}

/// @nodoc
class __$$ExpenseImplCopyWithImpl<$Res>
    extends _$ExpenseCopyWithImpl<$Res, _$ExpenseImpl>
    implements _$$ExpenseImplCopyWith<$Res> {
  __$$ExpenseImplCopyWithImpl(
      _$ExpenseImpl _value, $Res Function(_$ExpenseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? paidByParticipantId = null,
    Object? amount = null,
    Object? description = null,
    Object? timestamp = null,
    Object? category = null,
    Object? splitMethod = null,
    Object? splitDetails = null,
    Object? receipt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ExpenseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      paidByParticipantId: null == paidByParticipantId
          ? _value.paidByParticipantId
          : paidByParticipantId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExpenseCategory,
      splitMethod: null == splitMethod
          ? _value.splitMethod
          : splitMethod // ignore: cast_nullable_to_non_nullable
              as SplitMethod,
      splitDetails: null == splitDetails
          ? _value._splitDetails
          : splitDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      receipt: freezed == receipt
          ? _value.receipt
          : receipt // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseImpl implements _Expense {
  const _$ExpenseImpl(
      {required this.id,
      required this.eventId,
      required this.paidByParticipantId,
      required this.amount,
      required this.description,
      required this.timestamp,
      required this.category,
      required this.splitMethod,
      final Map<String, double> splitDetails = const {},
      this.receipt,
      this.notes})
      : _splitDetails = splitDetails;

  factory _$ExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String paidByParticipantId;
  @override
  final double amount;
  @override
  final String description;
  @override
  final DateTime timestamp;
  @override
  final ExpenseCategory category;
  @override
  final SplitMethod splitMethod;
// For equal: empty or all participants with equal values
// For percentage: participantId -> percentage (0-100)
// For exactAmount: participantId -> exact amount
// For shares: participantId -> number of shares
  final Map<String, double> _splitDetails;
// For equal: empty or all participants with equal values
// For percentage: participantId -> percentage (0-100)
// For exactAmount: participantId -> exact amount
// For shares: participantId -> number of shares
  @override
  @JsonKey()
  Map<String, double> get splitDetails {
    if (_splitDetails is EqualUnmodifiableMapView) return _splitDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_splitDetails);
  }

  @override
  final String? receipt;
// optional photo URL
  @override
  final String? notes;

  @override
  String toString() {
    return 'Expense(id: $id, eventId: $eventId, paidByParticipantId: $paidByParticipantId, amount: $amount, description: $description, timestamp: $timestamp, category: $category, splitMethod: $splitMethod, splitDetails: $splitDetails, receipt: $receipt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.paidByParticipantId, paidByParticipantId) ||
                other.paidByParticipantId == paidByParticipantId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.splitMethod, splitMethod) ||
                other.splitMethod == splitMethod) &&
            const DeepCollectionEquality()
                .equals(other._splitDetails, _splitDetails) &&
            (identical(other.receipt, receipt) || other.receipt == receipt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      eventId,
      paidByParticipantId,
      amount,
      description,
      timestamp,
      category,
      splitMethod,
      const DeepCollectionEquality().hash(_splitDetails),
      receipt,
      notes);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      __$$ExpenseImplCopyWithImpl<_$ExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseImplToJson(
      this,
    );
  }
}

abstract class _Expense implements Expense {
  const factory _Expense(
      {required final String id,
      required final String eventId,
      required final String paidByParticipantId,
      required final double amount,
      required final String description,
      required final DateTime timestamp,
      required final ExpenseCategory category,
      required final SplitMethod splitMethod,
      final Map<String, double> splitDetails,
      final String? receipt,
      final String? notes}) = _$ExpenseImpl;

  factory _Expense.fromJson(Map<String, dynamic> json) = _$ExpenseImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get paidByParticipantId;
  @override
  double get amount;
  @override
  String get description;
  @override
  DateTime get timestamp;
  @override
  ExpenseCategory get category;
  @override
  SplitMethod
      get splitMethod; // For equal: empty or all participants with equal values
// For percentage: participantId -> percentage (0-100)
// For exactAmount: participantId -> exact amount
// For shares: participantId -> number of shares
  @override
  Map<String, double> get splitDetails;
  @override
  String? get receipt; // optional photo URL
  @override
  String? get notes;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
