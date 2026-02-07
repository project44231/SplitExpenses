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
import '../../auth/providers/auth_provider.dart';
import '../widgets/game_timer.dart';
import '../widgets/player_buy_in_card.dart';
import '../widgets/add_buy_in_dialog.dart';
import '../widgets/edit_buy_in_dialog.dart';
import '../widgets/game_settings_dialog.dart';
import '../widgets/edit_player_dialog.dart';

class ActiveGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const ActiveGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<ActiveGameScreen> createState() => _ActiveGameScreenState();
}

class _ActiveGameScreenState extends ConsumerState<ActiveGameScreen> {
  Game? _currentGame;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    setState(() => _isLoading = true);
    
    // Load game and player data
    await ref.read(gameProvider.notifier).loadGames();
    await ref.read(playerProvider.notifier).loadPlayers();
    
    // Get or create current game
    if (widget.gameId == 'current') {
      _currentGame = await ref.read(gameProvider.notifier).getOrCreateCurrentGame();
    } else {
      _currentGame = await ref.read(gameProvider.notifier).getGame(widget.gameId);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _showAddPlayerDialog() async {
    if (_currentGame == null) return;

    final TextEditingController nameController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                hintText: 'Enter player name',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context, nameController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      // Add new player
      final player = await ref.read(playerProvider.notifier).addPlayer(
            name: result,
          );

      if (player != null && mounted) {
        // Add player to current game
        final updatedPlayerIds = [..._currentGame!.playerIds, player.id];
        final updatedGame = _currentGame!.copyWith(
          playerIds: updatedPlayerIds,
          updatedAt: DateTime.now(),
        );
        
        await ref.read(gameProvider.notifier).updateGame(updatedGame);
        
        setState(() {
          _currentGame = updatedGame;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${player.name} added')),
          );
        }
      }
    }
  }

  Future<void> _showAddBuyInDialog({String? preselectedPlayerId}) async {
    if (_currentGame == null) return;

    final playersAsync = ref.read(playerProvider);
    final players = playersAsync.when(
      data: (allPlayers) =>
          allPlayers.where((p) => _currentGame!.playerIds.contains(p.id)).toList(),
      loading: () => <Player>[],
      error: (_, __) => <Player>[],
    );

    if (players.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add players first')),
      );
      return;
    }

    final currency = AppCurrencies.fromCode(_currentGame!.currency);

    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddBuyInDialog(
        players: players,
        currency: currency,
        preselectedPlayerId: preselectedPlayerId,
        quickAmounts: _currentGame!.customBuyInAmounts,
      ),
    );

    if (result != null && mounted) {
      await ref.read(gameProvider.notifier).addBuyIn(
            gameId: _currentGame!.id,
            playerId: result['playerId'],
            amount: result['amount'],
            type: result['type'],
          );

      setState(() {}); // Trigger rebuild
    }
  }

  Future<void> _showEditBuyInDialog(BuyIn buyIn, String playerName) async {
    final currency = AppCurrencies.fromCode(_currentGame!.currency);

    if (!mounted) return;
    final newAmount = await showDialog<double>(
      context: context,
      builder: (context) => EditBuyInDialog(
        buyIn: buyIn,
        currency: currency,
        playerName: playerName,
        quickAmounts: _currentGame!.customBuyInAmounts,
      ),
    );

    if (newAmount != null && mounted) {
      final updatedBuyIn = buyIn.copyWith(amount: newAmount);
      await ref.read(gameProvider.notifier).updateBuyIn(updatedBuyIn);
      setState(() {}); // Trigger rebuild
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buy-in updated successfully')),
        );
      }
    }
  }

  Future<void> _showGameSettingsDialog() async {
    if (_currentGame == null) return;

    final currency = AppCurrencies.fromCode(_currentGame!.currency);

    if (!mounted) return;
    final newAmounts = await showDialog<List<double>>(
      context: context,
      builder: (context) => GameSettingsDialog(
        currentAmounts: _currentGame!.customBuyInAmounts,
        currency: currency,
      ),
    );

    if (newAmounts != null && mounted) {
      final updatedGame = _currentGame!.copyWith(
        customBuyInAmounts: newAmounts,
        updatedAt: DateTime.now(),
      );
      
      await ref.read(gameProvider.notifier).updateGame(updatedGame);
      
      // Update the local state
      setState(() {
        _currentGame = updatedGame;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game settings updated successfully')),
        );
      }
    }
  }

  Future<void> _showEditPlayerDialog(Player player) async {
    if (!mounted) return;
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => EditPlayerDialog(player: player),
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      final updatedPlayer = player.copyWith(name: newName);
      await ref.read(playerProvider.notifier).updatePlayer(updatedPlayer);
      setState(() {}); // Trigger rebuild
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${player.name} renamed to $newName')),
        );
      }
    }
  }

  Future<void> _deletePlayer(Player player, double totalBuyIn) async {
    if (totalBuyIn > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot remove ${player.name} - player has buy-ins'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Player'),
        content: Text(
          'Are you sure you want to remove ${player.name} from this game?\n\n'
          'This will not delete the player from your player list.',
        ),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && _currentGame != null) {
      // Remove player from game
      final updatedPlayerIds = List<String>.from(_currentGame!.playerIds)
        ..remove(player.id);
      
      final updatedGame = _currentGame!.copyWith(
        playerIds: updatedPlayerIds,
        updatedAt: DateTime.now(),
      );
      
      await ref.read(gameProvider.notifier).updateGame(updatedGame);
      
      setState(() {
        _currentGame = updatedGame;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${player.name} removed from game')),
        );
      }
    }
  }

  Future<void> _deleteBuyIn(BuyIn buyIn, String playerName) async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Buy-In'),
        content: Text(
          'Are you sure you want to delete this buy-in for $playerName?\n\n'
          'Amount: ${Formatters.formatCurrency(buyIn.amount, AppCurrencies.fromCode(_currentGame!.currency))}\n'
          'Time: ${Formatters.formatDateTime(buyIn.timestamp)}',
        ),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(gameProvider.notifier).deleteBuyIn(buyIn.id);
      setState(() {}); // Trigger rebuild
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buy-in deleted successfully')),
        );
      }
    }
  }

  Future<void> _endGame() async {
    if (_currentGame == null) return;

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
      await ref.read(gameProvider.notifier).endGame(_currentGame!.id);
      if (mounted) {
        context.go('${AppConstants.settlementRoute}/${_currentGame!.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentGame == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Failed to load game')),
      );
    }

    return FutureBuilder(
      future: Future.wait([
        ref.read(gameProvider.notifier).getBuyIns(_currentGame!.id),
        Future.value(ref.read(playerProvider)),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final buyIns = (snapshot.data?[0] as List<BuyIn>?) ?? [];
        final playersAsync = snapshot.data?[1] as AsyncValue<List<Player>>?;

        return playersAsync?.when(
          data: (allPlayers) {
            final gamePlayers = allPlayers
                .where((p) => _currentGame!.playerIds.contains(p.id))
                .toList();

            // Calculate totals
            final playerTotals = <String, double>{};
            final playerBuyInCounts = <String, int>{};

            for (final playerId in _currentGame!.playerIds) {
              playerTotals[playerId] = 0;
              playerBuyInCounts[playerId] = 0;
            }

            for (final buyIn in buyIns) {
              playerTotals[buyIn.playerId] =
                  (playerTotals[buyIn.playerId] ?? 0) + buyIn.amount;
              playerBuyInCounts[buyIn.playerId] =
                  (playerBuyInCounts[buyIn.playerId] ?? 0) + 1;
            }

            final totalPot = playerTotals.values.fold(0.0, (sum, val) => sum + val);
            final currency = AppCurrencies.fromCode(_currentGame!.currency);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Active Game'),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showGameSettingsDialog,
                    tooltip: 'Game Settings',
                  ),
                ],
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Poker Tracker',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Track your home games',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Game History'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(AppConstants.historyRoute);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(AppConstants.profileRoute);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure? This will clear all local data.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true && context.mounted) {
                          // Sign out and go to auth screen
                          await ref.read(authNotifierProvider.notifier).signOut();
                          if (context.mounted) {
                            context.go(AppConstants.authRoute);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  // Game Info Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: AppTheme.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Timer (only show if there are buy-ins)
                        if (buyIns.isNotEmpty)
                          GameTimer(startTime: _currentGame!.startTime)
                        else
                          const SizedBox(width: 80), // Placeholder for alignment
                        
                        // Total Pot (centered)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Formatters.formatCurrency(totalPot, currency),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Player Count (right side)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${gamePlayers.length} ${gamePlayers.length == 1 ? 'player' : 'players'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons (under banner)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Add Player Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showAddPlayerDialog,
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Add Player'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Game Button
                        if (buyIns.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _endGame,
                              icon: const Icon(Icons.stop_circle, size: 18),
                              label: const Text('End Game'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Player List or Empty State
                  Expanded(
                    child: gamePlayers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No players yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add players to start the game',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _showAddPlayerDialog,
                                  icon: const Icon(Icons.person_add),
                                  label: const Text('Add First Player'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                final buyInCount = playerBuyInCounts[player.id] ?? 0;
                                final playerBuyIns = buyIns
                                    .where((b) => b.playerId == player.id)
                                    .toList()
                                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                                return PlayerBuyInCard(
                                  player: player,
                                  totalBuyIn: total,
                                  buyInCount: buyInCount,
                                  buyIns: playerBuyIns,
                                  currency: currency,
                                  onAddBuyIn: () => _showAddBuyInDialog(
                                    preselectedPlayerId: player.id,
                                  ),
                                  onEditBuyIn: (buyIn) => _showEditBuyInDialog(buyIn, player.name),
                                  onDeleteBuyIn: (buyIn) => _deleteBuyIn(buyIn, player.name),
                                  onEditPlayer: () => _showEditPlayerDialog(player),
                                  onDeletePlayer: () => _deletePlayer(player, total),
                                );
                              },
                            ),
                          ),
                  ),

                ],
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
        ) ?? const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
