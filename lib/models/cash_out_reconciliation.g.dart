// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_out_reconciliation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashOutReconciliationImpl _$$CashOutReconciliationImplFromJson(
        Map<String, dynamic> json) =>
    _$CashOutReconciliationImpl(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      originalBuyIn: (json['originalBuyIn'] as num).toDouble(),
      originalCashOut: (json['originalCashOut'] as num).toDouble(),
      adjustedCashOut: (json['adjustedCashOut'] as num).toDouble(),
      type: $enumDecode(_$ReconciliationTypeEnumMap, json['type']),
      adjustments: (json['adjustments'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      note: json['note'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$CashOutReconciliationImplToJson(
        _$CashOutReconciliationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'originalBuyIn': instance.originalBuyIn,
      'originalCashOut': instance.originalCashOut,
      'adjustedCashOut': instance.adjustedCashOut,
      'type': _$ReconciliationTypeEnumMap[instance.type]!,
      'adjustments': instance.adjustments,
      'note': instance.note,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$ReconciliationTypeEnumMap = {
  ReconciliationType.expense: 'expense',
  ReconciliationType.distributeWinners: 'distributeWinners',
  ReconciliationType.distributeLosers: 'distributeLosers',
  ReconciliationType.manual: 'manual',
  ReconciliationType.continueAsIs: 'continueAsIs',
};
