import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_out.freezed.dart';
part 'cash_out.g.dart';

@freezed
class CashOut with _$CashOut {
  const factory CashOut({
    required String id,
    required String gameId,
    required String playerId,
    required double amount,
    required DateTime timestamp,
    String? notes,
  }) = _CashOut;

  factory CashOut.fromJson(Map<String, dynamic> json) => _$CashOutFromJson(json);
}
