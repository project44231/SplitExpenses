import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_group.freezed.dart';
part 'event_group.g.dart';

@freezed
class EventGroup with _$EventGroup {
  const factory EventGroup({
    required String id,
    required String name,
    required String ownerId,
    @Default([]) List<String> memberIds,
    String? description,
    String? defaultCurrency,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _EventGroup;

  factory EventGroup.fromJson(Map<String, dynamic> json) => 
      _$EventGroupFromJson(json);
}
