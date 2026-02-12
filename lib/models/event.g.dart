// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      groupId: json['groupId'] as String,
      status: $enumDecode(_$EventStatusEnumMap, json['status']),
      currency: json['currency'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      notes: json['notes'] as String?,
      shareToken: json['shareToken'] as String?,
      categoryTags: (json['categoryTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'groupId': instance.groupId,
      'status': _$EventStatusEnumMap[instance.status]!,
      'currency': instance.currency,
      'participantIds': instance.participantIds,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'notes': instance.notes,
      'shareToken': instance.shareToken,
      'categoryTags': instance.categoryTags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$EventStatusEnumMap = {
  EventStatus.active: 'active',
  EventStatus.settled: 'settled',
  EventStatus.archived: 'archived',
};
