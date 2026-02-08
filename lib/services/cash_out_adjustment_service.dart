import '../models/player.dart';

/// Service for adjusting cash-outs to match buy-ins
class CashOutAdjustmentService {
  /// Distribute amount among winners proportionally based on their winnings
  Map<String, double> distributeAmongWinners({
    required List<Player> players,
    required Map<String, double> buyInTotals,
    required Map<String, double> currentCashOuts,
    required double amountToDistribute,
  }) {
    // Calculate current profit/loss for each player
    final playerBalances = <String, double>{};
    for (final player in players) {
      final buyIn = buyInTotals[player.id] ?? 0;
      final cashOut = currentCashOuts[player.id] ?? 0;
      playerBalances[player.id] = cashOut - buyIn;
    }
    
    // Identify winners (positive balance)
    final winners = players.where((p) => playerBalances[p.id]! > 0).toList();
    
    if (winners.isEmpty) {
      // No winners, distribute equally among all players
      return _distributeEqually(players.map((p) => p.id).toList(), amountToDistribute);
    }
    
    // Calculate total winnings
    final totalWinnings = winners.fold<double>(
      0,
      (sum, player) => sum + playerBalances[player.id]!,
    );
    
    // Distribute proportionally
    return _distributeProportionally(
      winners.map((p) => p.id).toList(),
      winners.map((p) => playerBalances[p.id]!).toList(),
      totalWinnings,
      amountToDistribute,
    );
  }
  
  /// Distribute amount among losers proportionally based on their losses
  Map<String, double> distributeAmongLosers({
    required List<Player> players,
    required Map<String, double> buyInTotals,
    required Map<String, double> currentCashOuts,
    required double amountToDistribute,
  }) {
    // Calculate current profit/loss for each player
    final playerBalances = <String, double>{};
    for (final player in players) {
      final buyIn = buyInTotals[player.id] ?? 0;
      final cashOut = currentCashOuts[player.id] ?? 0;
      playerBalances[player.id] = cashOut - buyIn;
    }
    
    // Identify losers (negative balance)
    final losers = players.where((p) => playerBalances[p.id]! < 0).toList();
    
    if (losers.isEmpty) {
      // No losers, distribute equally among all players
      return _distributeEqually(players.map((p) => p.id).toList(), amountToDistribute);
    }
    
    // Calculate total losses (use absolute values)
    final totalLosses = losers.fold<double>(
      0,
      (sum, player) => sum + playerBalances[player.id]!.abs(),
    );
    
    // Distribute proportionally based on losses
    return _distributeProportionally(
      losers.map((p) => p.id).toList(),
      losers.map((p) => playerBalances[p.id]!.abs()).toList(),
      totalLosses,
      amountToDistribute,
    );
  }
  
  /// Distribute amount manually among selected players
  Map<String, double> distributeManually({
    required List<String> selectedPlayerIds,
    required double amountToDistribute,
    bool proportional = false,
    Map<String, double>? weights, // For proportional distribution
  }) {
    if (selectedPlayerIds.isEmpty) {
      return {};
    }
    
    if (!proportional || weights == null) {
      // Equal distribution
      return _distributeEqually(selectedPlayerIds, amountToDistribute);
    }
    
    // Proportional distribution based on weights
    final totalWeight = selectedPlayerIds.fold<double>(
      0,
      (sum, id) => sum + (weights[id] ?? 0),
    );
    
    return _distributeProportionally(
      selectedPlayerIds,
      selectedPlayerIds.map((id) => weights[id] ?? 0).toList(),
      totalWeight,
      amountToDistribute,
    );
  }
  
  /// Helper: Distribute amount equally among player IDs
  Map<String, double> _distributeEqually(
    List<String> playerIds,
    double totalAmount,
  ) {
    if (playerIds.isEmpty) return {};
    
    final perPlayer = totalAmount / playerIds.length;
    final adjustments = <String, double>{};
    
    // Distribute equally
    for (var i = 0; i < playerIds.length; i++) {
      adjustments[playerIds[i]] = _roundToTwoDecimals(perPlayer);
    }
    
    // Handle rounding remainder - add to first player
    final distributed = adjustments.values.fold<double>(0, (sum, val) => sum + val);
    final remainder = totalAmount - distributed;
    if (remainder.abs() > 0.001 && playerIds.isNotEmpty) {
      adjustments[playerIds[0]] = adjustments[playerIds[0]]! + remainder;
      adjustments[playerIds[0]] = _roundToTwoDecimals(adjustments[playerIds[0]]!);
    }
    
    return adjustments;
  }
  
  /// Helper: Distribute amount proportionally based on weights
  Map<String, double> _distributeProportionally(
    List<String> playerIds,
    List<double> weights,
    double totalWeight,
    double totalAmount,
  ) {
    if (playerIds.isEmpty || totalWeight == 0) return {};
    
    final adjustments = <String, double>{};
    
    // Calculate proportional amounts
    for (var i = 0; i < playerIds.length; i++) {
      final proportion = weights[i] / totalWeight;
      adjustments[playerIds[i]] = _roundToTwoDecimals(totalAmount * proportion);
    }
    
    // Handle rounding remainder - add to player with largest adjustment
    final distributed = adjustments.values.fold<double>(0, (sum, val) => sum + val);
    final remainder = totalAmount - distributed;
    
    if (remainder.abs() > 0.001 && adjustments.isNotEmpty) {
      // Find player with largest adjustment
      String largestPlayerId = playerIds[0];
      double largestAmount = adjustments[largestPlayerId]!;
      
      for (final entry in adjustments.entries) {
        if (entry.value > largestAmount) {
          largestPlayerId = entry.key;
          largestAmount = entry.value;
        }
      }
      
      adjustments[largestPlayerId] = adjustments[largestPlayerId]! + remainder;
      adjustments[largestPlayerId] = _roundToTwoDecimals(adjustments[largestPlayerId]!);
    }
    
    return adjustments;
  }
  
  /// Calculate proportional split preview (for showing before applying)
  Map<String, AdjustmentPreview> calculateAdjustmentPreview({
    required List<Player> players,
    required Map<String, double> buyInTotals,
    required Map<String, double> currentCashOuts,
    required Map<String, double> adjustments,
  }) {
    final preview = <String, AdjustmentPreview>{};
    
    for (final player in players) {
      final buyIn = buyInTotals[player.id] ?? 0;
      final oldCashOut = currentCashOuts[player.id] ?? 0;
      final adjustment = adjustments[player.id] ?? 0;
      final newCashOut = oldCashOut + adjustment;
      final oldProfitLoss = oldCashOut - buyIn;
      final newProfitLoss = newCashOut - buyIn;
      
      preview[player.id] = AdjustmentPreview(
        playerId: player.id,
        playerName: player.name,
        buyIn: buyIn,
        oldCashOut: oldCashOut,
        adjustment: adjustment,
        newCashOut: newCashOut,
        oldProfitLoss: oldProfitLoss,
        newProfitLoss: newProfitLoss,
      );
    }
    
    return preview;
  }
  
  /// Round to two decimal places
  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

/// Preview of adjustment for a player
class AdjustmentPreview {
  final String playerId;
  final String playerName;
  final double buyIn;
  final double oldCashOut;
  final double adjustment;
  final double newCashOut;
  final double oldProfitLoss;
  final double newProfitLoss;
  
  AdjustmentPreview({
    required this.playerId,
    required this.playerName,
    required this.buyIn,
    required this.oldCashOut,
    required this.adjustment,
    required this.newCashOut,
    required this.oldProfitLoss,
    required this.newProfitLoss,
  });
  
  bool get hasAdjustment => adjustment.abs() > 0.001;
}
