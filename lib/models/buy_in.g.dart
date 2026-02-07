// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buy_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuyInImpl _$$BuyInImplFromJson(Map<String, dynamic> json) => _$BuyInImpl(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      playerId: json['playerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$BuyInTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$BuyInImplToJson(_$BuyInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'playerId': instance.playerId,
      'amount': instance.amount,
      'type': _$BuyInTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
    };

const _$BuyInTypeEnumMap = {
  BuyInType.initial: 'initial',
  BuyInType.rebuy: 'rebuy',
};
