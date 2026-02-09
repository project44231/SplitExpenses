import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/currency.dart';
import '../../../models/game.dart';
import '../../../models/buy_in.dart';
import '../../../models/cash_out.dart';
import '../../../models/player.dart';
import '../../players/providers/player_provider.dart';

class GameHistoryCard extends ConsumerWidget {
  final Game game;
  final List<BuyIn> buyIns;
  final List<CashOut> cashOuts;
  final VoidCallback onTap;

  const GameHistoryCard({
    super.key,
    required this.game,
    required this.buyIns,
    required this.cashOuts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = AppCurrencies.fromCode(game.currency);
    final playersAsync = ref.watch(playerProvider);

    // Calculate totals
    final totalBuyIn = buyIns.fold<double>(0, (sum, b) => sum + b.amount);

    // Calculate duration
    final duration = game.endTime != null
        ? game.endTime!.difference(game.startTime)
        : Duration.zero;
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';

    // Get players
    final gamePlayers = playersAsync.when(
      data: (players) =>
          players.where((p) => game.playerIds.contains(p.id)).toList(),
      loading: () => <Player>[],
      error: (_, __) => <Player>[],
    );

    // Find biggest winner
    String biggestWinner = '-';
    double biggestWin = 0;

    if (cashOuts.isNotEmpty) {
      final playerProfits = <String, double>{};
      for (final buyIn in buyIns) {
        playerProfits[buyIn.playerId] =
            (playerProfits[buyIn.playerId] ?? 0) - buyIn.amount;
      }
      for (final cashOut in cashOuts) {
        playerProfits[cashOut.playerId] =
            (playerProfits[cashOut.playerId] ?? 0) + cashOut.amount;
      }

      // Find max profit
      for (final entry in playerProfits.entries) {
        if (entry.value > biggestWin) {
          biggestWin = entry.value;
          final player = gamePlayers.firstWhere(
            (p) => p.id == entry.key,
            orElse: () => Player(
              id: entry.key,
              name: 'Unknown',
              createdAt: DateTime.now(),
            ),
          );
          biggestWinner = player.name;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game name (if set)
              if (game.name != null && game.name!.isNotEmpty) ...[
                Text(
                  game.name!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Date and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatDate(game.endTime ?? game.startTime),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          durationText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.people,
                    label: '${game.playerIds.length} players',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.account_balance_wallet,
                    label: Formatters.formatCurrency(totalBuyIn, currency),
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Biggest winner
              if (biggestWinner != '-') ...[
                const Divider(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Top Winner: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      biggestWinner,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(+${Formatters.formatCurrency(biggestWin, currency)})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
