// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      splitType: $enumDecode(_$ExpenseSplitTypeEnumMap, json['splitType']),
      contributorPlayerIds: (json['contributorPlayerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'description': instance.description,
      'amount': instance.amount,
      'splitType': _$ExpenseSplitTypeEnumMap[instance.splitType]!,
      'contributorPlayerIds': instance.contributorPlayerIds,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$ExpenseSplitTypeEnumMap = {
  ExpenseSplitType.hostAbsorbs: 'hostAbsorbs',
  ExpenseSplitType.equalSplit: 'equalSplit',
  ExpenseSplitType.customSplit: 'customSplit',
};
