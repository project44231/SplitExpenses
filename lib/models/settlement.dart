import 'package:freezed_annotation/freezed_annotation.dart';

part 'settlement.freezed.dart';
part 'settlement.g.dart';

@freezed
class SettlementTransaction with _$SettlementTransaction {
  const factory SettlementTransaction({
    required String fromPlayerId,
    required String toPlayerId,
    required double amount,
  }) = _SettlementTransaction;

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) =>
      _$SettlementTransactionFromJson(json);
}

@freezed
class Settlement with _$Settlement {
  const factory Settlement({
    required String id,
    required String gameId,
    required List<SettlementTransaction> transactions,
    required DateTime generatedAt,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);
}
