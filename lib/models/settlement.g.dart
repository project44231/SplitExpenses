// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettlementTransactionImpl _$$SettlementTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$SettlementTransactionImpl(
      fromParticipantId: json['fromParticipantId'] as String,
      toParticipantId: json['toParticipantId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$SettlementTransactionImplToJson(
        _$SettlementTransactionImpl instance) =>
    <String, dynamic>{
      'fromParticipantId': instance.fromParticipantId,
      'toParticipantId': instance.toParticipantId,
      'amount': instance.amount,
    };

_$SettlementImpl _$$SettlementImplFromJson(Map<String, dynamic> json) =>
    _$SettlementImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      transactions: _transactionsFromJson(json['transactions'] as List),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$SettlementImplToJson(_$SettlementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'transactions': _transactionsToJson(instance.transactions),
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
