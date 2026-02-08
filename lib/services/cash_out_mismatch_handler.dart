/// Service for handling cash-out vs buy-in mismatches
class CashOutMismatchHandler {
  /// Tolerance for perfect match (1 cent)
  static const double perfectTolerance = 0.01;
  
  /// Moderate threshold amount ($10)
  static const double moderateAmount = 10.0;
  
  /// Moderate threshold percentage (2%)
  static const double moderatePercent = 2.0;
  
  /// Check mismatch severity between buy-in and cash-out totals
  MismatchSeverity checkMismatch({
    required double totalBuyIn,
    required double totalCashOut,
  }) {
    if (totalBuyIn == 0) return MismatchSeverity.perfect;
    
    final difference = totalCashOut - totalBuyIn;
    final differenceAbs = difference.abs();
    final percent = (differenceAbs / totalBuyIn) * 100;
    
    // Perfect match
    if (differenceAbs <= perfectTolerance) {
      return MismatchSeverity.perfect;
    }
    
    // Acceptable (under threshold)
    if (differenceAbs <= moderateAmount && percent <= moderatePercent) {
      return MismatchSeverity.acceptable;
    }
    
    // Critical excess (cash-out > buy-in)
    if (difference > 0) {
      return MismatchSeverity.criticalExcess;
    }
    
    // Warning shortage (buy-in > cash-out)
    return MismatchSeverity.warningShortage;
  }
  
  /// Get difference amount (cash-out - buy-in)
  double getDifference({
    required double totalBuyIn,
    required double totalCashOut,
  }) {
    return totalCashOut - totalBuyIn;
  }
  
  /// Get absolute difference
  double getAbsoluteDifference({
    required double totalBuyIn,
    required double totalCashOut,
  }) {
    return (totalCashOut - totalBuyIn).abs();
  }
  
  /// Get difference percentage
  double getDifferencePercent({
    required double totalBuyIn,
    required double totalCashOut,
  }) {
    if (totalBuyIn == 0) return 0;
    final difference = (totalCashOut - totalBuyIn).abs();
    return (difference / totalBuyIn) * 100;
  }
  
  /// Get user-friendly message for the mismatch
  String getMessage(MismatchSeverity severity, double difference) {
    final absAmount = difference.abs();
    
    switch (severity) {
      case MismatchSeverity.perfect:
        return '✅ Perfect! Buy-in = Cash-out';
      case MismatchSeverity.acceptable:
        return 'Small difference: \$${absAmount.toStringAsFixed(2)} (acceptable)';
      case MismatchSeverity.warningShortage:
        return '⚠️ \$${absAmount.toStringAsFixed(2)} less cashed out than bought in';
      case MismatchSeverity.criticalExcess:
        return '❌ ERROR: \$${absAmount.toStringAsFixed(2)} MORE cashed out than bought in!';
    }
  }
  
  /// Get detailed explanation for the mismatch
  String getExplanation(MismatchSeverity severity) {
    switch (severity) {
      case MismatchSeverity.perfect:
        return 'Ready to calculate settlements.';
      case MismatchSeverity.acceptable:
        return 'This small difference is typically due to rounding. You can proceed or adjust if needed.';
      case MismatchSeverity.warningShortage:
        return 'Common causes: Tips, expenses, rounding errors';
      case MismatchSeverity.criticalExcess:
        return 'This shouldn\'t happen. Possible causes:\n• Missing buy-ins not recorded\n• Data entry error';
    }
  }
}

/// Severity levels for cash-out mismatches
enum MismatchSeverity {
  /// Perfect match within tolerance (±$0.01)
  perfect,
  
  /// Acceptable difference (under $10 AND under 2%)
  acceptable,
  
  /// Warning: buy-in > cash-out (missing money)
  warningShortage,
  
  /// Critical: cash-out > buy-in (extra money - error)
  criticalExcess,
}
