// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParticipantImpl _$$ParticipantImplFromJson(Map<String, dynamic> json) =>
    _$ParticipantImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
      groupIds: (json['groupIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      eventsAttended: (json['eventsAttended'] as num?)?.toInt() ?? 0,
      lastEventAt: json['lastEventAt'] == null
          ? null
          : DateTime.parse(json['lastEventAt'] as String),
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      totalOwed: (json['totalOwed'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ParticipantImplToJson(_$ParticipantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'photoUrl': instance.photoUrl,
      'notes': instance.notes,
      'groupIds': instance.groupIds,
      'isFavorite': instance.isFavorite,
      'eventsAttended': instance.eventsAttended,
      'lastEventAt': instance.lastEventAt?.toIso8601String(),
      'totalPaid': instance.totalPaid,
      'totalOwed': instance.totalOwed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
