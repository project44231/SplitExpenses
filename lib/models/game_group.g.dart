// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameGroupImpl _$$GameGroupImplFromJson(Map<String, dynamic> json) =>
    _$GameGroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
      defaultCurrency: json['defaultCurrency'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$GameGroupImplToJson(_$GameGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'memberIds': instance.memberIds,
      'description': instance.description,
      'defaultCurrency': instance.defaultCurrency,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
