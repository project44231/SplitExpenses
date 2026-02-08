import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_out_reconciliation.freezed.dart';
part 'cash_out_reconciliation.g.dart';

/// Record of cash-out reconciliation adjustments
@freezed
class CashOutReconciliation with _$CashOutReconciliation {
  const factory CashOutReconciliation({
    required String id,
    required String gameId,
    required double originalBuyIn,
    required double originalCashOut,
    required double adjustedCashOut,
    required ReconciliationType type,
    required Map<String, double> adjustments, // playerId -> adjustment amount
    String? note,
    required DateTime timestamp,
  }) = _CashOutReconciliation;

  factory CashOutReconciliation.fromJson(Map<String, dynamic> json) =>
      _$CashOutReconciliationFromJson(json);
}

/// Type of reconciliation performed
enum ReconciliationType {
  expense,
  distributeWinners,
  distributeLosers,
  manual,
  continueAsIs;

  String get displayName {
    switch (this) {
      case ReconciliationType.expense:
        return 'Expense Entry';
      case ReconciliationType.distributeWinners:
        return 'Distribute Among Winners';
      case ReconciliationType.distributeLosers:
        return 'Distribute Among Losers';
      case ReconciliationType.manual:
        return 'Manual Adjustment';
      case ReconciliationType.continueAsIs:
        return 'Continue As-Is';
    }
  }
}
