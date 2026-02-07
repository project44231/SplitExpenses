import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_group.freezed.dart';
part 'game_group.g.dart';

@freezed
class GameGroup with _$GameGroup {
  const factory GameGroup({
    required String id,
    required String name,
    required String ownerId,
    @Default([]) List<String> memberIds,
    String? description,
    String? defaultCurrency,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _GameGroup;

  factory GameGroup.fromJson(Map<String, dynamic> json) =>
      _$GameGroupFromJson(json);
}
