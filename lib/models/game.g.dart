// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      status: $enumDecode(_$GameStatusEnumMap, json['status']),
      currency: json['currency'] as String,
      playerIds: (json['playerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customBuyInAmounts: (json['customBuyInAmounts'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [20, 50, 100, 200],
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'status': _$GameStatusEnumMap[instance.status]!,
      'currency': instance.currency,
      'playerIds': instance.playerIds,
      'customBuyInAmounts': instance.customBuyInAmounts,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$GameStatusEnumMap = {
  GameStatus.active: 'active',
  GameStatus.ended: 'ended',
  GameStatus.archived: 'archived',
};
