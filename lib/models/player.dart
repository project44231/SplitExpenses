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
    String? notes,
    @Default([]) List<String> groupIds,
    @Default(false) bool isFavorite,
    @Default(0) int gamesPlayed,
    DateTime? lastPlayedAt,
    @Default(0.0) double totalProfit,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
