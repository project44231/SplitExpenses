import 'package:freezed_annotation/freezed_annotation.dart';

part 'settlement.freezed.dart';
part 'settlement.g.dart';

@freezed
class SettlementTransaction with _$SettlementTransaction {
  const factory SettlementTransaction({
    required String fromParticipantId,
    required String toParticipantId,
    required double amount,
  }) = _SettlementTransaction;

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) =>
      _$SettlementTransactionFromJson(json);
}

@freezed
class Settlement with _$Settlement {
  const factory Settlement({
    required String id,
    required String eventId,
    @JsonKey(
      toJson: _transactionsToJson,
      fromJson: _transactionsFromJson,
    )
    required List<SettlementTransaction> transactions,
    required DateTime generatedAt,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);
}

// Helper functions for JSON conversion
List<Map<String, dynamic>> _transactionsToJson(List<SettlementTransaction> transactions) {
  return transactions.map((t) => t.toJson()).toList();
}

List<SettlementTransaction> _transactionsFromJson(List<dynamic> json) {
  return json.map((e) => SettlementTransaction.fromJson(e as Map<String, dynamic>)).toList();
}
