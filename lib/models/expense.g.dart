// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      paidByParticipantId: json['paidByParticipantId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      splitMethod: $enumDecode(_$SplitMethodEnumMap, json['splitMethod']),
      splitDetails: (json['splitDetails'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      receipt: json['receipt'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'paidByParticipantId': instance.paidByParticipantId,
      'amount': instance.amount,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'splitMethod': _$SplitMethodEnumMap[instance.splitMethod]!,
      'splitDetails': instance.splitDetails,
      'receipt': instance.receipt,
      'notes': instance.notes,
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.food: 'food',
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.accommodation: 'accommodation',
  ExpenseCategory.utilities: 'utilities',
  ExpenseCategory.groceries: 'groceries',
  ExpenseCategory.entertainment: 'entertainment',
  ExpenseCategory.shopping: 'shopping',
  ExpenseCategory.healthcare: 'healthcare',
  ExpenseCategory.other: 'other',
};

const _$SplitMethodEnumMap = {
  SplitMethod.equal: 'equal',
  SplitMethod.percentage: 'percentage',
  SplitMethod.exactAmount: 'exactAmount',
  SplitMethod.shares: 'shares',
};
