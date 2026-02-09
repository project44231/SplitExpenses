// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserFeedbackImpl _$$UserFeedbackImplFromJson(Map<String, dynamic> json) =>
    _$UserFeedbackImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      type: $enumDecode(_$FeedbackTypeEnumMap, json['type']),
      message: json['message'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      deviceInfo: json['deviceInfo'] as String?,
      appVersion: json['appVersion'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecodeNullable(_$FeedbackStatusEnumMap, json['status']) ??
          FeedbackStatus.submitted,
    );

Map<String, dynamic> _$$UserFeedbackImplToJson(_$UserFeedbackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'message': instance.message,
      'imageUrls': instance.imageUrls,
      'deviceInfo': instance.deviceInfo,
      'appVersion': instance.appVersion,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$FeedbackStatusEnumMap[instance.status]!,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.bugReport: 'bug_report',
  FeedbackType.featureSuggestion: 'feature_suggestion',
  FeedbackType.generalFeedback: 'general_feedback',
  FeedbackType.helpSupport: 'help_support',
  FeedbackType.other: 'other',
};

const _$FeedbackStatusEnumMap = {
  FeedbackStatus.submitted: 'submitted',
  FeedbackStatus.inReview: 'in_review',
  FeedbackStatus.resolved: 'resolved',
};
