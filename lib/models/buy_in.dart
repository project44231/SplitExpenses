import 'package:freezed_annotation/freezed_annotation.dart';

part 'buy_in.freezed.dart';
part 'buy_in.g.dart';

enum BuyInType {
  initial,
  rebuy,
}

@freezed
class BuyIn with _$BuyIn {
  const factory BuyIn({
    required String id,
    required String gameId,
    required String playerId,
    required double amount,
    required BuyInType type,
    required DateTime timestamp,
    String? notes,
  }) = _BuyIn;

  factory BuyIn.fromJson(Map<String, dynamic> json) => _$BuyInFromJson(json);
}
