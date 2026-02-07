import '../models/settlement.dart';
import '../models/game.dart';

/// Service for calculating optimized settlements
class SettlementService {
  /// Calculate optimized settlement transactions using debt simplification algorithm
  /// 
  /// Algorithm:
  /// 1. Calculate net profit/loss for each player
  /// 2. Separate winners (positive balance) and losers (negative balance)
  /// 3. Sort winners descending, losers ascending (by absolute value)
  /// 4. Match largest winner with largest loser
  /// 5. Create transaction for the minimum of the two amounts
  /// 6. Repeat until all debts are settled
  /// 
  /// This minimizes the number of transactions needed.
  List<SettlementTransaction> calculateSettlement(
    List<PlayerResult> playerResults,
  ) {
    final transactions = <SettlementTransaction>[];

    // Calculate net balance for each player
    final balances = playerResults.map((result) {
      return _PlayerBalance(
        playerId: result.playerId,
        balance: result.profitLoss,
      );
    }).toList();

    // Separate winners and losers
    final winners = balances
        .where((b) => b.balance > 0)
        .toList()
      ..sort((a, b) => b.balance.compareTo(a.balance)); // Descending

    final losers = balances
        .where((b) => b.balance < 0)
        .toList()
      ..sort((a, b) => a.balance.compareTo(b.balance)); // Ascending (most negative first)

    // Track remaining balances
    final winnerBalances = Map<String, double>.fromEntries(
      winners.map((w) => MapEntry(w.playerId, w.balance)),
    );

    final loserBalances = Map<String, double>.fromEntries(
      losers.map((l) => MapEntry(l.playerId, l.balance.abs())),
    );

    // Match winners with losers
    for (final winner in winners) {
      if (winnerBalances[winner.playerId]! <= 0.01) continue;

      for (final loser in losers) {
        final winnerRemaining = winnerBalances[winner.playerId]!;
        final loserRemaining = loserBalances[loser.playerId]!;

        if (winnerRemaining <= 0.01 || loserRemaining <= 0.01) continue;

        // Calculate transaction amount (minimum of what winner should receive and loser should pay)
        final transactionAmount = winnerRemaining < loserRemaining
            ? winnerRemaining
            : loserRemaining;

        // Skip very small transactions (less than 1 cent)
        if (transactionAmount < 0.01) continue;

        // Create transaction
        transactions.add(
          SettlementTransaction(
            fromPlayerId: loser.playerId,
            toPlayerId: winner.playerId,
            amount: _roundToTwoDecimals(transactionAmount),
          ),
        );

        // Update balances
        winnerBalances[winner.playerId] = winnerRemaining - transactionAmount;
        loserBalances[loser.playerId] = loserRemaining - transactionAmount;
      }
    }

    return transactions;
  }

  /// Validate settlement matches total buy-ins and cash-outs
  /// Returns true if settlement is valid within tolerance
  bool validateSettlement({
    required double totalBuyIns,
    required double totalCashOuts,
    double tolerancePercent = 5.0,
  }) {
    final difference = (totalCashOuts - totalBuyIns).abs();
    final tolerance = totalBuyIns * (tolerancePercent / 100);

    return difference <= tolerance;
  }

  /// Calculate the mismatch percentage
  double calculateMismatchPercent({
    required double totalBuyIns,
    required double totalCashOuts,
  }) {
    if (totalBuyIns == 0) return 0;
    final difference = (totalCashOuts - totalBuyIns).abs();
    return (difference / totalBuyIns) * 100;
  }

  /// Generate shareable text summary of settlement
  String generateSettlementText({
    required String gameName,
    required DateTime gameDate,
    required List<PlayerResult> playerResults,
    required List<SettlementTransaction> transactions,
    required String currencySymbol,
    Map<String, String>? playerNames,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('🎴 $gameName');
    buffer.writeln('Date: ${_formatDate(gameDate)}');
    buffer.writeln();

    // Results
    buffer.writeln('Results:');
    for (final result in playerResults) {
      final playerName = playerNames?[result.playerId] ?? result.playerId;
      final sign = result.profitLoss >= 0 ? '+' : '';
      buffer.writeln(
        '• $playerName: $sign$currencySymbol${result.profitLoss.toStringAsFixed(2)}',
      );
    }
    buffer.writeln();

    // Settlements
    if (transactions.isEmpty) {
      buffer.writeln('No settlements needed - everyone broke even!');
    } else {
      buffer.writeln('Settlements:');
      for (final transaction in transactions) {
        final fromName = playerNames?[transaction.fromPlayerId] ??
            transaction.fromPlayerId;
        final toName =
            playerNames?[transaction.toPlayerId] ?? transaction.toPlayerId;
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

/// Internal class for tracking player balances
class _PlayerBalance {
  final String playerId;
  final double balance;

  _PlayerBalance({
    required this.playerId,
    required this.balance,
  });
}
