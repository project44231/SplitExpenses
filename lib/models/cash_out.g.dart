// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashOutImpl _$$CashOutImplFromJson(Map<String, dynamic> json) =>
    _$CashOutImpl(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      playerId: json['playerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CashOutImplToJson(_$CashOutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'playerId': instance.playerId,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
    };
