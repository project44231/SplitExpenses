import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/currency.dart';
import '../../../models/compat.dart';
import '../../players/providers/player_provider.dart';


class LeaderboardTab extends ConsumerWidget {
  final List<Game> games;
  final Map<String, List<BuyIn>> gamesBuyIns;
  final Map<String, List<dynamic>> gamesCashOuts; // Removed CashOut model

  const LeaderboardTab({
    super.key,
    required this.games,
    required this.gamesBuyIns,
    required this.gamesCashOuts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Data Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Complete some games to see player statistics',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final playersAsync = ref.watch(playerProvider);

    return playersAsync.when(
      data: (allPlayers) {
        final stats = _calculatePlayerStats(allPlayers);

        if (stats.isEmpty) {
          return const Center(child: Text('No statistics available'));
        }

        // Sort by total profit (descending)
        final sortedStats = stats.values.toList()
          ..sort((a, b) => b.totalProfit.compareTo(a.totalProfit));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedStats.length,
          itemBuilder: (context, index) {
            final stat = sortedStats[index];
            final rank = index + 1;

            return _buildLeaderboardCard(stat, rank);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Map<String, PlayerStats> _calculatePlayerStats(List<Participant> allPlayers) {
    final stats = <String, PlayerStats>{};

    // Calculate stats for each player across all games
    for (final game in games) {
      final buyIns = gamesBuyIns[game.id] ?? [];
      final cashOuts = gamesCashOuts[game.id] ?? [];

      // Build player profit map for this game
      final playerProfits = <String, double>{};
      for (final buyIn in buyIns) {
        playerProfits[buyIn.playerId] =
            (playerProfits[buyIn.playerId] ?? 0) - buyIn.amount;
      }
      for (final cashOut in cashOuts) {
        playerProfits[cashOut.playerId] =
            (playerProfits[cashOut.playerId] ?? 0) + cashOut.amount;
      }

      // Update stats for each player in this game
      for (final entry in playerProfits.entries) {
        final playerId = entry.key;
        final profit = entry.value;

        if (!stats.containsKey(playerId)) {
          final player = allPlayers.cast<Participant>().firstWhere(
            (p) => p.id == playerId,
            orElse: () => Participant(
              id: playerId,
              name: 'Unknown',
              userId: 'guest',
              eventsAttended: 0,
              createdAt: DateTime.now(),
            ),
          );

          stats[playerId] = PlayerStats(
            playerId: playerId,
            playerName: player.name,
            gamesPlayed: 0,
            totalProfit: 0,
            wins: 0,
            losses: 0,
            biggestWin: 0,
            biggestLoss: 0,
            lastPlayedAt: game.endTime ?? game.startTime,
          );
        }

        final currentStats = stats[playerId]!;
        stats[playerId] = PlayerStats(
          playerId: playerId,
          playerName: currentStats.playerName,
          gamesPlayed: currentStats.gamesPlayed + 1,
          totalProfit: currentStats.totalProfit + profit,
          wins: profit > 0 ? currentStats.wins + 1 : currentStats.wins,
          losses: profit < 0 ? currentStats.losses + 1 : currentStats.losses,
          biggestWin: profit > currentStats.biggestWin ? profit : currentStats.biggestWin,
          biggestLoss: profit < currentStats.biggestLoss ? profit : currentStats.biggestLoss,
          lastPlayedAt: game.endTime ?? game.startTime,
        );
      }
    }

    return stats;
  }

  Widget _buildLeaderboardCard(PlayerStats stats, int rank) {
    // Determine medal icon for top 3
    Widget? rankWidget;
    if (rank == 1) {
      rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32);
    } else if (rank == 2) {
      rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28);
    } else if (rank == 3) {
      rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24);
    } else {
      rankWidget = Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final winRate = stats.gamesPlayed > 0
        ? (stats.wins / stats.gamesPlayed * 100).toStringAsFixed(1)
        : '0.0';
    final avgProfit = stats.gamesPlayed > 0
        ? stats.totalProfit / stats.gamesPlayed
        : 0.0;

    final isPositive = stats.totalProfit >= 0;
    final profitColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: rank <= 3 ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            rankWidget,
            const SizedBox(width: 16),

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.playerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stats.gamesPlayed} games • $winRate% win rate',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      _buildMiniStat(
                        'Total',
                        '${isPositive ? '+' : ''}${Formatters.formatCurrency(stats.totalProfit, AppCurrencies.usd)}',
                        profitColor,
                      ),
                      const SizedBox(width: 16),
                      _buildMiniStat(
                        'Avg/Game',
                        '${avgProfit >= 0 ? '+' : ''}${Formatters.formatCurrency(avgProfit, AppCurrencies.usd)}',
                        avgProfit >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Player statistics aggregated across games
class PlayerStats {
  final String playerId;
  final String playerName;
  final int gamesPlayed;
  final double totalProfit;
  final int wins;
  final int losses;
  final double biggestWin;
  final double biggestLoss;
  final DateTime lastPlayedAt;

  PlayerStats({
    required this.playerId,
    required this.playerName,
    required this.gamesPlayed,
    required this.totalProfit,
    required this.wins,
    required this.losses,
    required this.biggestWin,
    required this.biggestLoss,
    required this.lastPlayedAt,
  });

  double get winRate => gamesPlayed > 0 ? (wins / gamesPlayed) * 100 : 0;
  double get avgProfitPerGame => gamesPlayed > 0 ? totalProfit / gamesPlayed : 0;
}
