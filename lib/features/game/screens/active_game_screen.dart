import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/buy_in.dart';
import '../../../models/game.dart';
import '../../../models/player.dart';
import '../../../services/game_share_service.dart';
import '../providers/game_provider.dart';
import '../../players/providers/player_provider.dart';
import '../../players/widgets/player_selection_dialog.dart';
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

class _ActiveGameScreenState extends ConsumerState<ActiveGameScreen> with AutomaticKeepAliveClientMixin {
  Game? _currentGame;
  bool _isLoading = true;
  int _buyInsRefreshKey = 0; // Key to force buy-ins reload

  @override
  bool get wantKeepAlive => true; // Keep state alive when switching tabs

  @override
  void initState() {
    super.initState();
    // Delay provider modification until after the widget tree is built
    Future.microtask(() => _initializeGame());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshGameData() async {
    if (!mounted || _currentGame == null) return;
    
    try {
      // Force reload from Firebase by calling loadGames first
      await ref.read(gameProvider.notifier).loadGames();
      
      // Get the fresh game data
      final game = await ref.read(gameProvider.notifier).getGame(_currentGame!.id);
      
      if (game != null && mounted) {
        setState(() {
          _currentGame = game;
        });
        print('DEBUG: Refreshed game - playerIds: ${game.playerIds}');
      }
    } catch (e) {
      // Silently fail on refresh, don't show error
      print('Error refreshing game data: $e');
    }
  }

  Future<void> _initializeGame() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // Load player data
      await ref.read(playerProvider.notifier).loadPlayers();
      
      // Get or create current game (this will reload games internally)
      if (widget.gameId == 'current') {
        _currentGame = await ref.read(gameProvider.notifier).getOrCreateCurrentGame();
      } else {
        await ref.read(gameProvider.notifier).loadGames();
        _currentGame = await ref.read(gameProvider.notifier).getGame(widget.gameId);
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  Future<void> _saveNotes(String notes) async {
    if (_currentGame == null) return;

    try {
      final updatedGame = await ref.read(gameProvider.notifier).updateGameNotes(
        _currentGame!.id,
        notes.trim(),
      );

      if (updatedGame != null && mounted) {
        setState(() {
          _currentGame = updatedGame;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving notes: $e')),
        );
      }
    }
  }

  Future<void> _showAddPlayerDialog() async {
    if (_currentGame == null) return;

    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => PlayerSelectionDialog(
        excludePlayerIds: _currentGame!.playerIds,
      ),
    );

    if (result != null && mounted) {
      try {
        // Handle both single player (backward compatibility) and multiple players
        List<Player> playersToAdd = [];
        if (result is Player) {
          playersToAdd = [result];
        } else if (result is List<Player>) {
          playersToAdd = result;
        }

        if (playersToAdd.isEmpty) return;

        // Add all selected players to current game
        final newPlayerIds = playersToAdd.map((p) => p.id).toList();
        final updatedPlayerIds = [..._currentGame!.playerIds, ...newPlayerIds];
        
        final updatedGame = _currentGame!.copyWith(
          playerIds: updatedPlayerIds,
          updatedAt: DateTime.now(),
        );
        
        await ref.read(gameProvider.notifier).updateGame(updatedGame);
        
        // Reload players to ensure UI updates
        await ref.read(playerProvider.notifier).loadPlayers();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                playersToAdd.length == 1
                    ? '${playersToAdd[0].name} added to game'
                    : '${playersToAdd.length} players added to game',
              ),
            ),
          );
        }
        
        setState(() {
          _currentGame = updatedGame;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding player: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
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
        quickAmounts: _currentGame!.customBuyInAmounts.isEmpty 
          ? [10, 50, 100]
          : _currentGame!.customBuyInAmounts,
      ),
    );

    if (result != null && mounted) {
      try {
        print('DEBUG: Adding buy-in - gameId: ${_currentGame!.id}, playerId: ${result['playerId']}, amount: ${result['amount']}');
        await ref.read(gameProvider.notifier).addBuyIn(
              gameId: _currentGame!.id,
              playerId: result['playerId'],
              amount: result['amount'],
              type: result['type'],
            );
        print('DEBUG: Buy-in added successfully');
        setState(() {
          _buyInsRefreshKey++; // Force buy-ins to reload
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buy-in added successfully')),
          );
        }
      } catch (e, stack) {
        print('DEBUG ERROR adding buy-in: $e');
        print('DEBUG Stack: $stack');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding buy-in: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
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
        quickAmounts: _currentGame!.customBuyInAmounts.isEmpty 
          ? [10, 50, 100]
          : _currentGame!.customBuyInAmounts,
      ),
    );

    if (newAmount != null && mounted) {
      final updatedBuyIn = buyIn.copyWith(amount: newAmount);
      await ref.read(gameProvider.notifier).updateBuyIn(updatedBuyIn);
      setState(() {
        _buyInsRefreshKey++; // Force buy-ins to reload
      });
      
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
        customBuyInAmounts: newAmounts.isEmpty ? [10, 50, 100] : newAmounts,
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
      setState(() {
        _buyInsRefreshKey++; // Force buy-ins to reload
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buy-in deleted for $playerName')),
        );
      }
    }
  }

  Future<void> _shareGame() async {
    if (_currentGame == null) return;

    try {
      final shareService = GameShareService();
      
      // Generate share token if not exists
      String shareToken = _currentGame!.shareToken ?? shareService.generateShareToken();
      
      // Update game with share token
      if (_currentGame!.shareToken == null) {
        final updatedGame = _currentGame!.copyWith(
          shareToken: shareToken,
          updatedAt: DateTime.now(),
        );
        await ref.read(gameProvider.notifier).updateGame(updatedGame);
        setState(() {
          _currentGame = updatedGame;
        });
      }

      // Show share options dialog
      final shareUrl = shareService.buildShareUrl(_currentGame!.id, shareToken);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Share Game'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Players can view live standings at:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    shareUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Link stays active permanently\n'
                  '• Shows live updates\n'
                  '• Read-only access',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  await shareService.copyShareUrl(
                    gameId: _currentGame!.id,
                    shareToken: shareToken,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  }
                },
                child: const Text('Copy Link'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await shareService.shareGame(
                    game: _currentGame!,
                    shareToken: shareToken,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing game: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
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
      // Navigate to cash-out screen (game stays active until cash-outs are submitted)
      context.go('/cash-out/${_currentGame!.id}');
    }
  }

  Future<void> _showCancelGameDialog() async {
    if (_currentGame == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel This Game'),
        content: const Text(
          'Are you sure you want to cancel this game?\n\n'
          'This will delete the current game and all buy-ins, and start a fresh game.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Game'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel Game'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // Delete the current game
        await ref.read(gameProvider.notifier).deleteGame(_currentGame!.id);
        
        // Create a new game
        final newGame = await ref.read(gameProvider.notifier).getOrCreateCurrentGame();
        
        if (mounted) {
          setState(() {
            _currentGame = newGame;
            _isLoading = false;
            _buyInsRefreshKey++;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game cancelled. New game started.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cancelling game: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  /// Generate default game name based on date and time
  String _generateDefaultGameName(DateTime startTime) {
    final dayOfWeek = DateFormat('EEEE').format(startTime);
    final timeOfDay = startTime.hour >= 17 ? 'Night' : startTime.hour >= 12 ? 'Afternoon' : 'Morning';
    return '$dayOfWeek $timeOfDay Game';
  }

  /// Show dialog to edit game name
  Future<void> _showEditGameNameDialog() async {
    if (_currentGame == null) return;

    final initialName = _currentGame!.name ?? _generateDefaultGameName(_currentGame!.startTime);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditGameNameDialog(initialName: initialName),
    );

    if (result != null && mounted) {
      final updatedGame = await ref.read(gameProvider.notifier)
          .updateGameName(_currentGame!.id, result);
      if (updatedGame != null) {
        setState(() => _currentGame = updatedGame);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game name updated'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
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

    // Watch the player provider to get live updates
    final playersAsync = ref.watch(playerProvider);
    
    return FutureBuilder<List<BuyIn>>(
      key: ValueKey(_buyInsRefreshKey), // Force rebuild when key changes
      future: ref.read(gameProvider.notifier).getBuyIns(_currentGame!.id),
      builder: (context, buyInSnapshot) {
        if (buyInSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final buyIns = buyInSnapshot.data ?? [];

        return playersAsync.when(
          data: (allPlayers) {
            print('DEBUG: All players count: ${allPlayers.length}');
            print('DEBUG: Game player IDs: ${_currentGame!.playerIds}');
            
            final gamePlayers = allPlayers
                .where((p) => _currentGame!.playerIds.contains(p.id))
                .toList();
            
            print('DEBUG: Game players count: ${gamePlayers.length}');
            for (final p in gamePlayers) {
              print('DEBUG: Player in game: ${p.id} - ${p.name}');
            }

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
                leading: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'images/app_icon.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: GestureDetector(
                  onTap: _showEditGameNameDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _currentGame?.name ?? _generateDefaultGameName(_currentGame!.startTime),
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit, size: 16, color: Colors.white),
                    ],
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Game Settings',
                    onSelected: (value) {
                      if (value == 'buy_in_settings') {
                        _showGameSettingsDialog();
                      } else if (value == 'cancel_game') {
                        _showCancelGameDialog();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'buy_in_settings',
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, size: 20),
                            SizedBox(width: 12),
                            Text('Buy-In Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel_game',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Cancel This Game', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
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
                            'Game buy in tracker',
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
                        const SizedBox(width: 8),
                        // Live Link Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareGame,
                            icon: const Icon(Icons.link, size: 18, color: Colors.white),
                            label: const Text('Live Link', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // End Game Button
                        if (buyIns.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _endGame,
                              icon: const Icon(Icons.stop_circle, size: 18, color: Colors.white),
                              label: const Text('End Game'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Game Notes Section
                  _GameNotesSection(
                    game: _currentGame!,
                    onSaveNotes: _saveNotes,
                  ),

                  // Player List or Empty State
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshGameData,
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
                                    backgroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
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

/// Separate widget for game notes to prevent entire page rebuild
class _GameNotesSection extends StatefulWidget {
  final Game game;
  final Future<void> Function(String notes) onSaveNotes;

  const _GameNotesSection({
    required this.game,
    required this.onSaveNotes,
  });

  @override
  State<_GameNotesSection> createState() => _GameNotesSectionState();
}

class _GameNotesSectionState extends State<_GameNotesSection> {
  bool _isExpanded = false;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.game.notes ?? '');
  }

  @override
  void didUpdateWidget(_GameNotesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if game notes changed externally
    if (widget.game.notes != oldWidget.game.notes) {
      _notesController.text = widget.game.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    try {
      await widget.onSaveNotes(_notesController.text);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isExpanded = false; // Close after saving
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: _isExpanded ? 200 : 48,
      color: Colors.grey.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Game Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if ((widget.game.notes ?? '').isNotEmpty && !_isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      maxLength: 1000,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add notes about this game...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 48),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 28,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _handleSave,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                                size: 16,
                              ),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog widget for editing game name with proper controller lifecycle
class _EditGameNameDialog extends StatefulWidget {
  final String initialName;

  const _EditGameNameDialog({required this.initialName});

  @override
  State<_EditGameNameDialog> createState() => _EditGameNameDialogState();
}

class _EditGameNameDialogState extends State<_EditGameNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Game Name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        decoration: const InputDecoration(
          hintText: 'Enter game name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
