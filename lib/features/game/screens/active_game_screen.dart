import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/buy_in.dart';
import '../../../models/game.dart';
import '../../../models/player.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';
import '../widgets/game_timer.dart';
import '../widgets/player_buy_in_card.dart';
import '../widgets/add_buy_in_dialog.dart';

class ActiveGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const ActiveGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<ActiveGameScreen> createState() => _ActiveGameScreenState();
}

class _ActiveGameScreenState extends ConsumerState<ActiveGameScreen> {
  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    // Refresh game and player data
    await ref.read(gameProvider.notifier).loadGames();
    await ref.read(playerProvider.notifier).loadPlayers();
  }

  Future<void> _showAddBuyInDialog() async {
    final game = await ref.read(gameProvider.notifier).getGame(widget.gameId);
    if (game == null) return;

    final playersAsync = ref.read(playerProvider);
    final players = playersAsync.when(
      data: (allPlayers) =>
          allPlayers.where((p) => game.playerIds.contains(p.id)).toList(),
      loading: () => <Player>[],
      error: (_, __) => <Player>[],
    );

    if (players.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No players in this game')),
      );
      return;
    }

    final currency = AppCurrencies.fromCode(game.currency);

    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddBuyInDialog(
        players: players,
        currency: currency,
      ),
    );

    if (result != null && mounted) {
      await ref.read(gameProvider.notifier).addBuyIn(
            gameId: widget.gameId,
            playerId: result['playerId'],
            amount: result['amount'],
            type: result['type'],
          );

      setState(() {}); // Trigger rebuild to show new buy-in
    }
  }

  Future<void> _endGame() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('End Game'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(gameProvider.notifier).endGame(widget.gameId);
      if (mounted) {
        context.go('${AppConstants.settlementRoute}/${widget.gameId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        ref.read(gameProvider.notifier).getGame(widget.gameId),
        ref.read(gameProvider.notifier).getBuyIns(widget.gameId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load game'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final game = snapshot.data![0] as Game?;
        final buyIns = snapshot.data![1] as List<BuyIn>;

        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Game not found')),
          );
        }

        final currency = AppCurrencies.fromCode(game.currency);
        final playersAsync = ref.watch(playerProvider);

        return playersAsync.when(
          data: (allPlayers) {
            // Get players in this game
            final gamePlayers = allPlayers
                .where((p) => game.playerIds.contains(p.id))
                .toList();

            // Calculate totals for each player
            final playerTotals = <String, double>{};
            final playerRebuys = <String, int>{};

            for (final playerId in game.playerIds) {
              playerTotals[playerId] = 0;
              playerRebuys[playerId] = 0;
            }

            for (final buyIn in buyIns) {
              playerTotals[buyIn.playerId] =
                  (playerTotals[buyIn.playerId] ?? 0) + buyIn.amount;
              if (buyIn.type == BuyInType.rebuy) {
                playerRebuys[buyIn.playerId] =
                    (playerRebuys[buyIn.playerId] ?? 0) + 1;
              }
            }

            final totalPot = playerTotals.values.fold(0.0, (sum, val) => sum + val);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Active Game'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.stop_circle),
                    onPressed: _endGame,
                    tooltip: 'End Game',
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Game Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.primaryColor,
                    child: Column(
                      children: [
                        // Timer
                        GameTimer(startTime: game.startTime),
                        const SizedBox(height: 12),

                        // Total Pot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Pot:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Formatters.formatCurrency(totalPot, currency),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Player Count
                        Text(
                          '${gamePlayers.length} player${gamePlayers.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Player List
                  Expanded(
                    child: gamePlayers.isEmpty
                        ? const Center(
                            child: Text('No players in this game'),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              setState(() {});
                            },
                            child: ListView.builder(
                              itemCount: gamePlayers.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemBuilder: (context, index) {
                                final player = gamePlayers[index];
                                final total = playerTotals[player.id] ?? 0;
                                final rebuys = playerRebuys[player.id] ?? 0;

                                return PlayerBuyInCard(
                                  player: player,
                                  totalBuyIn: total,
                                  rebuyCount: rebuys,
                                  currency: currency,
                                );
                              },
                            ),
                          ),
                  ),

                  // Buy-In Count
                  if (buyIns.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.grey.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${buyIns.length} buy-in${buyIns.length == 1 ? '' : 's'} recorded',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _showAddBuyInDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Buy-In'),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: $error')),
          ),
        );
      },
    );
  }
}
