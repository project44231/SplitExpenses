import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/currency.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/game.dart';
import '../../../models/player.dart';
import '../../../models/buy_in.dart';
import '../../../models/settlement.dart';
import '../../../services/firestore_service.dart';
import '../../players/providers/player_provider.dart';
import '../../auth/providers/auth_provider.dart';

class GameDetailsScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameDetailsScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends ConsumerState<GameDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  Game? _game;
  List<Player> _players = [];
  List<BuyIn> _buyIns = [];
  List<Settlement> _settlements = [];
  Map<String, double> _buyInTotals = {};
  Map<String, double> _cashOutTotals = {};
  Map<String, int> _buyInCounts = {};
  bool _isNotesExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => _loadGameData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGameData() async {
    setState(() => _isLoading = true);

    try {
      // Ensure players are loaded first
      await ref.read(playerProvider.notifier).loadPlayers();
      
      final firestoreService = FirestoreService();
      final game = await firestoreService.getGame(widget.gameId);
      
      if (game == null || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      final buyIns = await firestoreService.getBuyIns(widget.gameId);
      final cashOuts = await firestoreService.getCashOuts(widget.gameId);
      final settlements = await firestoreService.getSettlements(widget.gameId);

      // Get players
      final playersAsync = ref.read(playerProvider);
      final allPlayers = playersAsync.when(
        data: (players) => players,
        loading: () => <Player>[],
        error: (_, __) => <Player>[],
      );

      final gamePlayers = allPlayers
          .where((p) => game.playerIds.contains(p.id))
          .toList();

      // Calculate totals
      final buyInTotals = <String, double>{};
      final buyInCounts = <String, int>{};
      final cashOutTotals = <String, double>{};

      for (final playerId in game.playerIds) {
        buyInTotals[playerId] = 0;
        buyInCounts[playerId] = 0;
        cashOutTotals[playerId] = 0;
      }

      for (final buyIn in buyIns) {
        buyInTotals[buyIn.playerId] = (buyInTotals[buyIn.playerId] ?? 0) + buyIn.amount;
        buyInCounts[buyIn.playerId] = (buyInCounts[buyIn.playerId] ?? 0) + 1;
      }

      for (final cashOut in cashOuts) {
        cashOutTotals[cashOut.playerId] = (cashOutTotals[cashOut.playerId] ?? 0) + cashOut.amount;
      }

      if (mounted) {
        setState(() {
          _game = game;
          _players = gamePlayers;
          _buyIns = buyIns;
          _settlements = settlements;
          _buyInTotals = buyInTotals;
          _cashOutTotals = cashOutTotals;
          _buyInCounts = buyInCounts;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.homeRoute),
            tooltip: 'Back to Home',
          ),
          title: const Text('Game Details'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_game == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.homeRoute),
            tooltip: 'Back to Home',
          ),
          title: const Text('Game Details'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(child: Text('Game not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.homeRoute),
          tooltip: 'Back to Home',
        ),
        title: const Text('Game Details'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: _editGameNotes,
            tooltip: 'Edit Notes',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareGameSummary,
            tooltip: 'Share',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Players'),
            Tab(text: 'Settlements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPlayersTab(),
          _buildSettlementsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final currency = AppCurrencies.fromCode(_game!.currency);
    final totalBuyIn = _buyInTotals.values.fold(0.0, (sum, val) => sum + val);
    final totalCashOut = _cashOutTotals.values.fold(0.0, (sum, val) => sum + val);
    final duration = _game!.endTime != null
        ? _game!.endTime!.difference(_game!.startTime)
        : Duration.zero;

    // Find biggest winner and loser
    String? biggestWinner;
    double biggestWin = 0;
    String? biggestLoser;
    double biggestLoss = 0;

    for (final player in _players) {
      final profit = (_cashOutTotals[player.id] ?? 0) - (_buyInTotals[player.id] ?? 0);
      if (profit > biggestWin) {
        biggestWin = profit;
        biggestWinner = player.name;
      }
      if (profit < biggestLoss) {
        biggestLoss = profit;
        biggestLoser = player.name;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Game Info Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.formatDate(_game!.startTime),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '${Formatters.formatTime(_game!.startTime)} - ${_game!.endTime != null ? Formatters.formatTime(_game!.endTime!) : 'N/A'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.formatDuration(duration),
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Financial Summary Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Financial Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildSummaryRow('Total Buy-In', Formatters.formatCurrency(totalBuyIn, currency)),
                _buildSummaryRow('Total Cash-Out', Formatters.formatCurrency(totalCashOut, currency)),
                _buildSummaryRow('Players', '${_players.length}'),
                _buildSummaryRow('Total Buy-Ins', '${_buyIns.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Game Notes Card (if available)
        if (_game!.notes != null && _game!.notes!.trim().isNotEmpty)
          Card(
            elevation: 2,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _isNotesExpanded = !_isNotesExpanded);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Game Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isNotesExpanded)
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
                        Icon(
                          _isNotesExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isNotesExpanded
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Text(
                                _game!.notes!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        if (_game!.notes != null && _game!.notes!.trim().isNotEmpty)
          const SizedBox(height: 16),

        // Winners/Losers Card
        if (biggestWinner != null || biggestLoser != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Highlights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (biggestWinner != null && biggestWin > 0) ...[
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biggest Winner',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                biggestWinner,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${Formatters.formatCurrency(biggestWin, currency)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (biggestLoser != null && biggestLoss < 0) ...[
                    Row(
                      children: [
                        Icon(Icons.trending_down, color: Colors.red.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biggest Loser',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                biggestLoser,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(biggestLoss, currency),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Game Notes Card (if any)
        if (_game!.notes != null && _game!.notes!.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(
                    _game!.notes!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayersTab() {
    final currency = AppCurrencies.fromCode(_game!.currency);

    // Sort players by profit/loss (winners first)
    final sortedPlayers = List<Player>.from(_players)
      ..sort((a, b) {
        final profitA = (_cashOutTotals[a.id] ?? 0) - (_buyInTotals[a.id] ?? 0);
        final profitB = (_cashOutTotals[b.id] ?? 0) - (_buyInTotals[b.id] ?? 0);
        return profitB.compareTo(profitA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedPlayers.length,
      itemBuilder: (context, index) {
        final player = sortedPlayers[index];
        final buyInTotal = _buyInTotals[player.id] ?? 0;
        final cashOutTotal = _cashOutTotals[player.id] ?? 0;
        final profit = cashOutTotal - buyInTotal;
        final buyInCount = _buyInCounts[player.id] ?? 0;

        // Get player's buy-ins for expandable history
        final playerBuyIns = _buyIns
            .where((b) => b.playerId == player.id)
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return _PlayerDetailsCard(
          player: player,
          buyInTotal: buyInTotal,
          cashOutTotal: cashOutTotal,
          profit: profit,
          buyInCount: buyInCount,
          buyIns: playerBuyIns,
          currency: currency,
          rank: index + 1,
        );
      },
    );
  }

  Widget _buildSettlementsTab() {
    final currency = AppCurrencies.fromCode(_game!.currency);

    // Get all transactions from all settlements
    final allTransactions = _settlements.expand((s) => s.transactions).toList();

    if (allTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No Settlements',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Settlement data not available for this game',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    final playerMap = {for (var p in _players) p.id: p.name};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settlement Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simplified settlements to minimize transactions',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Divider(),
                ...allTransactions.asMap().entries.map((entry) {
                  final transaction = entry.value;
                  final fromName = playerMap[transaction.fromPlayerId] ?? 'Unknown';
                  final toName = playerMap[transaction.toPlayerId] ?? 'Unknown';
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.errorColor.withValues(alpha: 0.2),
                                child: Text(
                                  fromName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  fromName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward, color: Colors.grey.shade600, size: 20),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.successColor.withValues(alpha: 0.2),
                                child: Text(
                                  toName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  toName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(transaction.amount, currency),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _editGameNotes() async {
    final controller = TextEditingController(text: _game!.notes ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Game Notes'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add notes about this game...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        final updatedGame = _game!.copyWith(
          notes: result.isEmpty ? null : result,
          updatedAt: DateTime.now(),
        );
        
        final firestoreService = FirestoreService();
        await firestoreService.saveGame(updatedGame, ref.read(authServiceProvider).currentUserId ?? 'guest');
        
        setState(() {
          _game = updatedGame;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notes updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating notes: $e')),
          );
        }
      }
    }
  }

  Future<void> _shareGameSummary() async {
    final currency = AppCurrencies.fromCode(_game!.currency);
    final totalBuyIn = _buyInTotals.values.fold(0.0, (sum, val) => sum + val);
    final duration = _game!.endTime != null
        ? _game!.endTime!.difference(_game!.startTime)
        : Duration.zero;

    // Build summary text
    final buffer = StringBuffer();
    buffer.writeln('🎰 Poker Game Summary');
    buffer.writeln('━━━━━━━━━━━━━━━━━');
    buffer.writeln('📅 Date: ${Formatters.formatDate(_game!.startTime)}');
    buffer.writeln('⏱️ Duration: ${Formatters.formatDuration(duration)}');
    buffer.writeln('');
    buffer.writeln('💰 Financial Summary');
    buffer.writeln('Total Pot: ${Formatters.formatCurrency(totalBuyIn, currency)}');
    buffer.writeln('Players: ${_players.length}');
    buffer.writeln('');
    buffer.writeln('👥 Player Results');
    buffer.writeln('━━━━━━━━━━━━━━━━━');

    // Sort players by profit
    final sortedPlayers = List<Player>.from(_players)
      ..sort((a, b) {
        final profitA = (_cashOutTotals[a.id] ?? 0) - (_buyInTotals[a.id] ?? 0);
        final profitB = (_cashOutTotals[b.id] ?? 0) - (_buyInTotals[b.id] ?? 0);
        return profitB.compareTo(profitA);
      });

    for (var i = 0; i < sortedPlayers.length; i++) {
      final player = sortedPlayers[i];
      final profit = (_cashOutTotals[player.id] ?? 0) - (_buyInTotals[player.id] ?? 0);
      final icon = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
      buffer.writeln('$icon ${player.name}: ${profit >= 0 ? '+' : ''}${Formatters.formatCurrency(profit, currency)}');
    }

    if (_settlements.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('💸 Settlements');
      buffer.writeln('━━━━━━━━━━━━━━━━━');
      final playerMap = {for (var p in _players) p.id: p.name};
      
      for (final settlement in _settlements) {
        for (final transaction in settlement.transactions) {
          final fromName = playerMap[transaction.fromPlayerId] ?? 'Unknown';
          final toName = playerMap[transaction.toPlayerId] ?? 'Unknown';
          buffer.writeln('$fromName → $toName: ${Formatters.formatCurrency(transaction.amount, currency)}');
        }
      }
    }

    await Share.share(buffer.toString(), subject: 'Poker Game Summary');
  }
}

// Player Details Card Widget with Expandable Buy-in History
class _PlayerDetailsCard extends StatefulWidget {
  final Player player;
  final double buyInTotal;
  final double cashOutTotal;
  final double profit;
  final int buyInCount;
  final List<BuyIn> buyIns;
  final Currency currency;
  final int rank;

  const _PlayerDetailsCard({
    required this.player,
    required this.buyInTotal,
    required this.cashOutTotal,
    required this.profit,
    required this.buyInCount,
    required this.buyIns,
    required this.currency,
    required this.rank,
  });

  @override
  State<_PlayerDetailsCard> createState() => _PlayerDetailsCardState();
}

class _PlayerDetailsCardState extends State<_PlayerDetailsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final profitColor = widget.profit > 0
        ? AppTheme.successColor
        : widget.profit < 0
            ? AppTheme.errorColor
            : Colors.grey.shade700;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.rank <= 3
                          ? (widget.rank == 1
                              ? Colors.amber.shade100
                              : widget.rank == 2
                                  ? Colors.grey.shade300
                                  : Colors.orange.shade100)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.rank <= 3
                            ? (widget.rank == 1 ? '🥇' : widget.rank == 2 ? '🥈' : '🥉')
                            : '#${widget.rank}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Player info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.player.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.buyInCount} buy-in${widget.buyInCount != 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Formatters.formatCurrency(widget.buyInTotal, widget.currency),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Profit/Loss
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.profit >= 0 ? '+' : ''}${Formatters.formatCurrency(widget.profit, widget.currency)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatCurrency(widget.cashOutTotal, widget.currency),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  
                  // Expand icon
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable buy-in history
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Text(
                              'Buy-In History',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...widget.buyIns.asMap().entries.map((entry) {
                          final index = entry.key;
                          final buyIn = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Buy-in #${index + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Text(
                                  Formatters.formatTime(buyIn.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  Formatters.formatCurrency(buyIn.amount, widget.currency),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cash Out',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(widget.cashOutTotal, widget.currency),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
