// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettlementTransactionImpl _$$SettlementTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$SettlementTransactionImpl(
      fromPlayerId: json['fromPlayerId'] as String,
      toPlayerId: json['toPlayerId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$SettlementTransactionImplToJson(
        _$SettlementTransactionImpl instance) =>
    <String, dynamic>{
      'fromPlayerId': instance.fromPlayerId,
      'toPlayerId': instance.toPlayerId,
      'amount': instance.amount,
    };

_$SettlementImpl _$$SettlementImplFromJson(Map<String, dynamic> json) =>
    _$SettlementImpl(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => SettlementTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$SettlementImplToJson(_$SettlementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'transactions': instance.transactions,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
