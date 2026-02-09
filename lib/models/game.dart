import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

enum GameStatus {
  active,
  ended,
  archived,
}

@freezed
class Game with _$Game {
  const factory Game({
    required String id,
    String? name,
    required String groupId,
    required GameStatus status,
    required String currency,
    @Default([]) List<String> playerIds,
    @Default([20, 50, 100, 200]) List<double> customBuyInAmounts,
    required DateTime startTime,
    DateTime? endTime,
    String? notes,
    String? shareToken,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

/// Player result in a game (computed, not stored separately)
class PlayerResult {
  final String playerId;
  final double totalBuyIn;
  final double totalCashOut;
  final double profitLoss;
  final int rebuyCount;

  PlayerResult({
    required this.playerId,
    required this.totalBuyIn,
    required this.totalCashOut,
    required this.rebuyCount,
  }) : profitLoss = totalCashOut - totalBuyIn;

  bool get isWinner => profitLoss > 0;
  bool get isLoser => profitLoss < 0;
  bool get isBreakEven => profitLoss == 0;
}
