import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback.freezed.dart';
part 'feedback.g.dart';

@freezed
class UserFeedback with _$UserFeedback {
  const factory UserFeedback({
    required String id,
    required String userId,
    required String userName,
    required String userEmail,
    required FeedbackType type,
    required String message,
    @Default([]) List<String> imageUrls,
    String? deviceInfo,
    String? appVersion,
    required DateTime createdAt,
    @Default(FeedbackStatus.submitted) FeedbackStatus status,
  }) = _UserFeedback;

  factory UserFeedback.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackFromJson(json);
}

enum FeedbackType {
  @JsonValue('bug_report')
  bugReport,
  @JsonValue('feature_suggestion')
  featureSuggestion,
  @JsonValue('general_feedback')
  generalFeedback,
  @JsonValue('help_support')
  helpSupport,
  @JsonValue('other')
  other,
}

enum FeedbackStatus {
  @JsonValue('submitted')
  submitted,
  @JsonValue('in_review')
  inReview,
  @JsonValue('resolved')
  resolved,
}

extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.bugReport:
        return 'Bug Report';
      case FeedbackType.featureSuggestion:
        return 'Feature Suggestion';
      case FeedbackType.generalFeedback:
        return 'General Feedback';
      case FeedbackType.helpSupport:
        return 'Help/Support';
      case FeedbackType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case FeedbackType.bugReport:
        return '🐛';
      case FeedbackType.featureSuggestion:
        return '💡';
      case FeedbackType.generalFeedback:
        return '💬';
      case FeedbackType.helpSupport:
        return '❓';
      case FeedbackType.other:
        return '📝';
    }
  }
}
