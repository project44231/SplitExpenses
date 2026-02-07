import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? photoUrl,
    @Default([]) List<String> groupIds,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
