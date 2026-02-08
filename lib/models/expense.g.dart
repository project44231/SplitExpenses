// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      note: json['note'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'amount': instance.amount,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'note': instance.note,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.tips: 'tips',
  ExpenseCategory.food: 'food',
  ExpenseCategory.other: 'other',
};
