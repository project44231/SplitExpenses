import '../models/settlement.dart';
import '../models/event.dart';

/// Service for calculating optimized settlements
class SettlementService {
  /// Calculate optimized settlement transactions using debt simplification algorithm
  /// 
  /// Algorithm:
  /// 1. Calculate net balance for each participant (paid - owed)
  /// 2. Separate receivers (positive balance) and payers (negative balance)
  /// 3. Sort receivers descending, payers ascending (by absolute value)
  /// 4. Match largest receiver with largest payer
  /// 5. Create transaction for the minimum of the two amounts
  /// 6. Repeat until all debts are settled
  /// 
  /// This minimizes the number of transactions needed.
  List<SettlementTransaction> calculateSettlement(
    List<ParticipantResult> participantResults,
  ) {
    final transactions = <SettlementTransaction>[];

    // Calculate net balance for each participant
    final balances = participantResults.map((result) {
      return _ParticipantBalance(
        participantId: result.participantId,
        balance: result.netBalance,
      );
    }).toList();

    // Separate receivers (should receive money) and payers (should pay money)
    final receivers = balances
        .where((b) => b.balance > 0)
        .toList()
      ..sort((a, b) => b.balance.compareTo(a.balance)); // Descending

    final payers = balances
        .where((b) => b.balance < 0)
        .toList()
      ..sort((a, b) => a.balance.compareTo(b.balance)); // Ascending (most negative first)

    // Track remaining balances
    final receiverBalances = Map<String, double>.fromEntries(
      receivers.map((r) => MapEntry(r.participantId, r.balance)),
    );

    final payerBalances = Map<String, double>.fromEntries(
      payers.map((p) => MapEntry(p.participantId, p.balance.abs())),
    );

    // Match receivers with payers
    for (final receiver in receivers) {
      if (receiverBalances[receiver.participantId]! <= 0.01) continue;

      for (final payer in payers) {
        final receiverRemaining = receiverBalances[receiver.participantId]!;
        final payerRemaining = payerBalances[payer.participantId]!;

        if (receiverRemaining <= 0.01 || payerRemaining <= 0.01) continue;

        // Calculate transaction amount (minimum of what receiver should get and payer should pay)
        final transactionAmount = receiverRemaining < payerRemaining
            ? receiverRemaining
            : payerRemaining;

        // Skip very small transactions (less than 1 cent)
        if (transactionAmount < 0.01) continue;

        // Create transaction
        transactions.add(
          SettlementTransaction(
            fromParticipantId: payer.participantId,
            toParticipantId: receiver.participantId,
            amount: _roundToTwoDecimals(transactionAmount),
          ),
        );

        // Update balances
        receiverBalances[receiver.participantId] = receiverRemaining - transactionAmount;
        payerBalances[payer.participantId] = payerRemaining - transactionAmount;
      }
    }

    return transactions;
  }

  /// Validate settlement totals
  /// Returns true if total paid equals total owed within tolerance
  bool validateSettlement({
    required double totalPaid,
    required double totalOwed,
    double tolerancePercent = 5.0,
  }) {
    final difference = (totalOwed - totalPaid).abs();
    final tolerance = totalPaid * (tolerancePercent / 100);

    return difference <= tolerance;
  }

  /// Calculate the mismatch percentage
  double calculateMismatchPercent({
    required double totalPaid,
    required double totalOwed,
  }) {
    if (totalPaid == 0) return 0;
    final difference = (totalOwed - totalPaid).abs();
    return (difference / totalPaid) * 100;
  }

  /// Generate shareable text summary of settlement
  String generateSettlementText({
    required String eventName,
    required DateTime eventDate,
    required List<ParticipantResult> participantResults,
    required List<SettlementTransaction> transactions,
    required String currencySymbol,
    Map<String, String>? participantNames,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('💰 $eventName');
    buffer.writeln('Date: ${_formatDate(eventDate)}');
    buffer.writeln();

    // Results
    buffer.writeln('Balances:');
    for (final result in participantResults) {
      final participantName = participantNames?[result.participantId] ?? result.participantId;
      final sign = result.netBalance >= 0 ? '+' : '';
      buffer.writeln(
        '• $participantName: $sign$currencySymbol${result.netBalance.toStringAsFixed(2)}',
      );
    }
    buffer.writeln();

    // Settlements
    if (transactions.isEmpty) {
      buffer.writeln('No settlements needed - everyone is settled!');
    } else {
      buffer.writeln('Settlements:');
      for (final transaction in transactions) {
        final fromName = participantNames?[transaction.fromParticipantId] ??
            transaction.fromParticipantId;
        final toName =
            participantNames?[transaction.toParticipantId] ?? transaction.toParticipantId;
        buffer.writeln(
          '• $fromName pays $toName: $currencySymbol${transaction.amount.toStringAsFixed(2)}',
        );
      }
    }

    return buffer.toString();
  }

  /// Round to two decimal places
  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }

  /// Format date for text output
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Internal class for tracking participant balances
class _ParticipantBalance {
  final String participantId;
  final double balance;

  _ParticipantBalance({
    required this.participantId,
    required this.balance,
  });
}
